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
#= require_tree .

$ ->
  data_page = $("body").data('page')

  switch data_page
    when 'root:index'
# Intialize dropzone.js
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
        dictDefaultMessage: '解析したいファイルをここにドラッグ&ドロップしてください'
        paramName: 'file'
        headers:
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')

        init: ()->
          dropzone = this
          message_area = $('#parse-result .message')
          parse_area = $('#parse-result')
          progress_area = $('<div id="parse-progress"><span id="current-count"></span> / <span id="total-count"></span>件処理済みです。 進捗率 <span id="current-progress"></span>%</div>')
          start_time = 0
          end_time = 0
          uploading_filename = ''

          loading_img = $('<div id="loader">')
          loading_img.css('background-image', 'url(' + image_path('ripple.gif') + ')')
          loading_img.css('width', '120px')
          loading_img.css('height', '120px')

          file_add_img = $('<img>')
          file_add_img.attr('src', image_path('file_add.png'))
          $('.dropzone .dz-default').prepend(file_add_img)

          reset_message_area = ->
            message_area.empty()

          onComplete = (file)->
            dropzone.removeFile(file)
            progress_area.remove()
            $('#loader').remove()

          this.on 'addedfile', (file) ->
            uploading_filename = file.name
            $("#note").empty()
            $("#note").removeClass("cover")
            $("#note").append("<div id='comment'>解析サーバにファイルをアップロードして解析処理中... ここにファイル解析結果の解析木が表示されます。</div>")
            $('body').append(loading_img)
            start_time = +new Date()

          this.on 'success', (file, res)->
            end_time = +new Date()
            diff_server = end_time - start_time
            $("#comment").html("<p>サーバでの解析処理時間: #{diff_server} ミリ秒</p><p>解析結果のHTMLをブラウザで生成中... 少し時間がかかります。(最大数分ほど)</p>")

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

            result_text = """
            <p>
            CST(解析木)オブジェクトがページにロードされました。<br />
            &nbsp;&nbsp;&nbsp;&nbsp;解析ファイル名: #{uploading_filename}<br />
            &nbsp;&nbsp;&nbsp;&nbsp;サーバでの解析処理時間: #{diff_server} ミリ秒<br />
            &nbsp;&nbsp;&nbsp;&nbsp;ブラウザの描画処理時間: #{diff_client} ミリ秒<br />
            &nbsp;&nbsp;&nbsp;&nbsp;エラーの数: #{errorCount}<br />
            </p>
            """

            if errorCount > 0
              result_text += """
              エラー内容<br />
              <table class='errors'>
              """
              for val, i in CST.errors()
                escaped_msg = $('<div />').text(val.msg).html()
                result_text += """
                <tr><td>#{val.line}行目</td><td>#{val.pos}バイト目</td><td>#{escaped_msg}</td></tr>
                """

              result_text += """
              </table>
              """

            result_text += """
            <p>
            F12の開発者ツールのコンソールで'CST'とタイプするとCSTオブジェクトの内容を直接確認できます<br />
            &nbsp;&nbsp;&nbsp;&nbsp;CST.errors():&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;解析エラーの一覧。<br />
            &nbsp;&nbsp;&nbsp;&nbsp;CST.tokens():&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;解析結果のトークンの一覧。<br />
            &nbsp;&nbsp;&nbsp;&nbsp;CST.tree():&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CSTの木構造(連結リスト)の本体のデータです
            </p>
            <p>
            下記のCSTの見方<br />
            &nbsp;&nbsp;&nbsp;&nbsp;赤色で太文字:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;解析元ファイル内の文字列<br />
            &nbsp;&nbsp;&nbsp;&nbsp;黒色で先頭小文字:&nbsp;パースルール名<br />
            &nbsp;&nbsp;&nbsp;&nbsp;灰色で先頭大文字:&nbsp;トークン名
            </p>
            """
            $("#comment").html(result_text)

          this.on 'error', (file, error)->
            reset_message_area()
            alert(error)
            $("#note").addClass("cover")
            onComplete(file)
