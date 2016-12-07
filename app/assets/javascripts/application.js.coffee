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


  switch data_page
    when 'root:index'
      # Initialize nicescroll
      $('html').niceScroll
        autohidemode: true
        cursorwidth: "10px"
        zIndex: 20000
        hidecursordelay: 1000

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
        dictDefaultMessage: gon.i18n['drophere']
        paramName: 'file'
        headers:
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')

        init: ()->
          dropzone = this
          message_area = $('#parse-result .message')
          parse_area = $('#parse-result')
          parse_error = $('#parse-error')
          dropzone_msg_area = $('#dropzone-msg')

          start_time = 0
          end_time = 0
          uploading_filename = ''

          reset_message_area = ->
            message_area.empty()

          onComplete = (file)->
            dropzone.removeFile(file)
            $('#loader').remove()

          this.on 'addedfile', (file) ->
            uploading_filename = file.name
            dropzone_msg_area.empty()
            dropzone_msg_area.append("<div id='comment'><img src='#{image_path('hourglass.gif')}'>#{gon.i18n['parsing']}</div>")
            dropzone_msg_area.addClass('in')

            parse_error.empty()
            parse_error.removeClass('in')

            start_time = +new Date()

          this.on 'success', (file, res)->
            end_time = +new Date()
            diff_server = end_time - start_time

            dropzone_msg_area.removeClass('in')
            setTimeout ->
              dropzone_msg_area.html("<p>#{gon.i18n['processing_time_in_server']} #{diff_server} #{gon.i18n['milliseconds']}</p><p><img src='#{image_path('hourglass.gif')}'>#{gon.i18n['rendering']}</p>")
              dropzone_msg_area.addClass('in')

              setTimeout ->
                $('#note').removeClass("cover")

                start_time = +new Date()

                reset_message_area()
                file_id = res.file
                onComplete(file)
                $("head").append("<script src='/js?name=#{file_id}'>")
                CST.addRuleListener constructTreeView(CST, jQuery)
                CST.walk()

                $("#note").append(CST.treeView);

                $(CST.treeViewRoot).addClass("collapsibleList");
                CollapsibleLists.apply();
                CollapsibleLists.openAll($(".collapsibleList").get(0));

                end_time = +new Date()
                diff_client = end_time - start_time

                errorCount = CST.errors().length

                dropzone_msg_area.removeClass('in')
                setTimeout ->
                  dropzone_msg_area.empty()
                  result_text = gon.i18n['parse_result']
                  result_text = result_text
                                  .replace('#{uploading_filename}', uploading_filename)
                                  .replace('#{diff_server}', diff_server)
                                  .replace('#{diff_client}', diff_client)
                                  .replace('#{errorCount}', errorCount)
                  result_msg = $('<div class="result-msg">')
                  result_msg.html(result_text)
                  dropzone_msg_area.append(result_msg)

                  ptree_desc = $('<div class="ptree-description">')
                  ptree_desc.html(gon.i18n['what_is_parse_tree'])
                  dropzone_msg_area.append(ptree_desc)

                  dropzone_msg_area.addClass('in')

                  if errorCount > 0
                    error_text = """
                    #{gon.i18n['error_caption']}<br />
                    <table class='errors'>
                    """
                    for val, i in CST.errors()
                      escaped_msg = $('<div />').text(val.msg).html()
                      error_text += """
                      <tr><td>#{gon.i18n['error_line']}#{val.line}</td><td>#{val.pos}#{gon.i18n['error_bytes']}</td><td>#{escaped_msg}</td></tr>
                      """

                    error_text += """
                    </table>
                    """

                    parse_error.html(error_text)
                    parse_error.addClass('in')
                ,20
              ,100
            ,100

          this.on 'error', (file, error)->
            reset_message_area()
            alert(error)
            $("#note").addClass("cover")
            onComplete(file)

$ init_script
$(document).on 'turbolinks:load', ->
  init_script()