require 'ipaddr'
require 'socket'
require 'browser'
require 'digest'
require 'json'
require 'fileutils'

class RootController < ApplicationController
  layout 'application'

  skip_before_action :verify_authenticity_token

  TREE_GENERATOR = Rails.root.join('lib', 'antlr4', 'bin', 'ParseTreeGenerator.exe').to_s

  def index
    gon.i18n = {
      'drophere': I18n.t('index.drophere'),
      'parsing': I18n.t('index.parsing'),
      'processing_time_in_server': I18n.t('index.processing_time_in_server'),
      'milliseconds': I18n.t('index.milliseconds'),
      'rendering':  I18n.t('index.rendering'),
      'parse_result': I18n.t('index.parse_result_html'),
      'what_is_parse_tree': I18n.t('index.what_is_parse_tree'),
      'error_caption': I18n.t('index.error.caption'),
      'error_line': I18n.t('index.error.line'),
      'error_bytes': I18n.t('index.error.bytes'),
    }
  end

  def parse
    file = params[:file]

    if file.blank?
      return render status: :unprocessable_entity, json: {'message': 'Invalid file'}
    end

    unless File.exists?(file.path)
      return render status: :unprocessable_entity, json: { 'message': 'Failed to process file' }
    end

    tmpdir = Rails.root.join('tmp', 'ptree')
    input_file_path = file.path
    sha256_input_file = Digest::SHA256.file(input_file_path)
    sha256_tree_generator = Digest::SHA256.file(TREE_GENERATOR)
    sha256sum = sha256_input_file.to_s[0,16] + sha256_tree_generator.to_s[0,16]
    output_file_name_js = "#{sha256sum}.js"
    output_file_path_js = Rails.root.join('tmp', 'ptree', output_file_name_js).to_s

    unless Dir.exists?(tmpdir)
      FileUtils::mkdir_p tmpdir
    end

    system('mono ' + TREE_GENERATOR + ' ' + input_file_path + ' ' + output_file_path_js + ' htmlDocument 932')

    # result = File.read(output_file_path_json)

    return render json: {
        file: sha256sum,
        # data: result
    }
  end

  def js
    file = params[:name]
    js_file_path = Rails.root.join('tmp', 'ptree', file + '.js').to_s
    unless File.exists?(js_file_path)
      return render status: :unprocessable_entity, json: { 'message': 'Requested file was not found' }
    end

    send_file(js_file_path, type: 'text/javascript; charset=utf-8', disposition: 'inline')
  end
end