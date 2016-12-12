# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https:#github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require dropzone
#= require jquery.nicescroll
#= require_tree .

number_with_commas = (x) ->
  x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')

init_script = ->
  data_page = $("body").data('page')

  # Layout script setup
  $('.switch-pane').on 'click', (e)->
    e.preventDefault()
    target = $(this).data('target')
    active_pane = $('.pane.fade.active.in')
    active_pane.removeClass 'in'

    setTimeout(()->
      active_pane.removeClass('active')
      $("#" + target).addClass('active')
      setTimeout(()->
        $("#" + target).addClass('in')
      , 100)
    , 100)

    $('.nav > li.active').removeClass('active')
    $(this).parent().addClass('active')

  translation = JSON.parse(gon.i18n)
  i18n_text = ->
    locale = $('body').attr('lang')
    translation[locale]

  switch data_page
    when 'root:index'
      # parameters being retrieved as a parse result
      uploading_filename = null
      file_encoding = null
      diff_server = null
      diff_client = null
      errorCount = null
      file_size = null
      file_lines = null
      current_file_id = null

      refresh_share_btn = ->
        share_btn = $('#share-btn')
        share_btn.data('hash', current_file_id)
        share_btn.on 'click', (e)->
          e.preventDefault()
          e.stopPropagation()
          hash = $(this).data('hash')
          share_link_url = "#{window.location.protocol}//#{window.location.host}/?name=#{hash}"

          cover_layer = $('<div id="cover-layer">')
          $('body').append(cover_layer)
          dialog_box = i18n_text()['index']['share_dialog_html']
          cover_layer.append(dialog_box)
          input = cover_layer.find('input')
          input.val(share_link_url)
          input.select()

          dismiss_dialog = (e)->
            if !$(e.target).closest('#share-dialog').length
              cover_layer.remove()

          $(document).on 'click', dismiss_dialog

      refresh_i18n_text = ->
        $('.page-title').text(i18n_text()['title'])
        $('.nav > li > a[data-target=about]').text(i18n_text()['menu']['about'])
        $('.nav > li > a[data-target=parsetree]').text(i18n_text()['menu']['try'])
        $('#preface').html(i18n_text()['index']['preface_html'])
        $('#about > .description').html(i18n_text()['about']['description_html'])
        $('.dz-message > span').text(i18n_text()['index']['drophere'])

        result_msg = $('.result-msg')
        if result_msg.length > 0
          result_text = i18n_text()['index']['parse_result_html']
          result_text = result_text
            .replace('#{uploading_filename}', uploading_filename)
            .replace('#{encoding}', file_encoding)
            .replace('#{diff_server}', diff_server)
            .replace('#{diff_client}', diff_client)
            .replace('#{errorCount}', errorCount)
            .replace('#{file_size}', number_with_commas(file_size))
            .replace('#{file_lines}', file_lines)
          result_msg.html(result_text)

        ptree_desc = $('.ptree-description')
        if ptree_desc.length > 0
          ptree_desc.html(i18n_text()['index']['what_is_parse_tree'])

        if errorCount > 0
          error_text = """
                  #{i18n_text()['index']['error']['caption']}<br />
                  <table class='errors'>
                  """
          for val, i in CST.errors()
            escaped_msg = $('<div />').text(val.msg).html()
            error_text += """
                    <tr><td>#{i18n_text()['index']['error']['line']}#{val.line}</td><td>#{val.pos}#{i18n_text()['index']['error']['bytes']}</td><td>#{escaped_msg}</td></tr>
                    """

          error_text += """
                  </table>
                  """

          parse_error = $('#parse-error')
          parse_error.html(error_text)
          parse_error.addClass('in')

        refresh_share_btn()

      $('.select-lang > a').on 'click', (e)->
        e.preventDefault()
        target_lang = $(this).data('lang')
        $('body').attr('lang', target_lang)
        refresh_i18n_text()
        false

      # Initialize nicescroll
      $('html').niceScroll
        autohidemode: true
        cursorwidth: "10px"
        zindex: 20000
        hidecursordelay: 1000

      parse_error = $('#parse-error')
      dropzone_msg_area = $('#dropzone-msg')

      render_parse_tree = (file_id, diff_server, encoding)->
        dropzone_msg_area.removeClass('in')
        setTimeout ->
          if diff_server
            dropzone_msg_area.html("<p>#{i18n_text()['index']['processing_time_in_server']} #{diff_server} #{i18n_text()['index']['milliseconds']}</p><p><img src='#{image_path('hourglass.gif')}'>#{i18n_text()['index']['rendering']}</p>")
          else
            dropzone_msg_area.html("<p><img src='#{image_path('hourglass.gif')}'>#{i18n_text()['index']['rendering']}</p>")
          dropzone_msg_area.addClass('in')

          setTimeout ->
            $('#note').removeClass("cover")

            start_time = +new Date()

            script_cst = $('#parsetree_script')
            if script_cst.length > 0
              script_cst.remove()

            try
              $("head").append("<script id='parsetree_script' src='/js/#{file_id}'>")
              throw 'CST not loaded exception' if !CST
            catch e
              $('#note').addClass("cover")
              dropzone_msg_area.empty()
              alert('File not found. CST failed to be loaded.')
              return

            CST.addRuleListener constructTreeView(CST, jQuery)
            CST.walk()

            $("#note").append(CST.treeView)

            $(CST.treeViewRoot).addClass("collapsibleList")
            CollapsibleLists.apply()
            CollapsibleLists.openAll($(".collapsibleList").get(0))

            end_time = +new Date()

            uploading_filename = file_id unless uploading_filename
            diff_client = end_time - start_time
            errorCount = CST.errors().length
            diff_server = Math.round(CST.summary.total_time * 1000)
            file_encoding = CST.summary.encoding
            file_size = CST.summary.size
            file_lines = CST.summary.line

            dropzone_msg_area.removeClass('in')
            setTimeout ->
              dropzone_msg_area.empty()
              result_text = i18n_text()['index']['parse_result_html']
              result_text = result_text
                .replace('#{uploading_filename}', uploading_filename)
                .replace('#{encoding}', file_encoding)
                .replace('#{diff_server}', diff_server)
                .replace('#{diff_client}', diff_client)
                .replace('#{errorCount}', errorCount)
                .replace('#{file_size}', number_with_commas(file_size))
                .replace('#{file_lines}', file_lines)
              result_msg = $('<div class="result-msg">')
              result_msg.html(result_text)
              dropzone_msg_area.append(result_msg)

              ptree_desc = $('<div class="ptree-description">')
              ptree_desc.html(i18n_text()['index']['what_is_parse_tree'])
              dropzone_msg_area.append(ptree_desc)

              dropzone_msg_area.addClass('in')

              if errorCount > 0
                error_text = """
                    #{i18n_text()['index']['error']['caption']}<br />
                    <table class='errors'>
                    """
                for val, i in CST.errors()
                  escaped_msg = $('<div>').text(val.msg).html()
                  error_text += """
                      <tr><td>#{i18n_text()['index']['error']['line']}#{val.line}</td><td>#{val.pos}#{i18n_text()['index']['error']['bytes']}</td><td>#{escaped_msg}</td></tr>
                      """

                error_text += """
                    </table>
                    """

                parse_error.html(error_text)
                parse_error.addClass('in')

              current_file_id = file_id
              refresh_share_btn()
            ,20
          ,100
        ,100


      # Initialize dropzone.js
      uploaded_file_id = null
      dropzone = null
      Dropzone.autoDiscover = false;

      $('.dropzone').dropzone
        url: 'parse'
        maxFiles: 1
        maxFilesize: 10
        method: 'POST'
        autoDiscover: false
        autoProcessQueue: true
        addRemoveLinks: false
        dictDefaultMessage: i18n_text()['index']['drophere']
        paramName: 'file'
        headers:
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')

        init: ()->
          dropzone = this

          start_time = 0
          end_time = 0
          uploading_filename = ''

          this.on 'addedfile', (file) ->
            uploading_filename = file.name
            dropzone_msg_area.empty()
            dropzone_msg_area.append("<div id='comment'><img src='#{image_path('hourglass.gif')}'>#{i18n_text()['index']['parsing']}</div>")
            dropzone_msg_area.addClass('in')

            parse_error.empty()
            parse_error.removeClass('in')

            $('#note').addClass('cover').empty()

          this.on 'success', (file, res)->
            diff_server = Math.round(res.total_time * 1000)
            file_encoding = res.encoding
            file_id = res.file

            render_parse_tree(file_id, diff_server, file_encoding)

            dropzone.removeFile(file) if file and dropzone

          this.on 'error', (file, error)->
            alert(error.message)
            dropzone_msg_area.removeClass('in')
            dropzone_msg_area.empty()
            $("#note").addClass("cover")
            dropzone.removeFile(file)

      # When parse tree file hash is specified render it
      parsetree = $('#parsetree')
      if parsetree.data('hash')
        $('.nav > li > a[data-target=parsetree]').trigger('click')
        setTimeout ->
          render_parse_tree(parsetree.data('hash'))
        ,200

$(init_script)
