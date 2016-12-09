require 'ipaddr'
require 'socket'
require 'browser'
require 'digest'
require 'json'
require 'fileutils'
require 'charlock_holmes'
require 'benchmark'

class RootController < ApplicationController
  layout 'application'

  skip_before_action :verify_authenticity_token

  TREE_GENERATOR = Rails.root.join('lib', 'antlr4', 'bin', 'ParseTreeGenerator.exe').to_s

  def index
    grammar = Settings.grammar['display_name']

    i18n_text = I18n.backend.send(:translations)
    i18n_text[:en][:index][:preface_html].gsub!('%{grammar}', grammar)
    i18n_text[:ja][:index][:preface_html].gsub!('%{grammar}', grammar)
    i18n_text[:en][:title].gsub!('%{grammar}', grammar)
    i18n_text[:ja][:title].gsub!('%{grammar}', grammar)
    gon.i18n = i18n_text.to_json

    js_hash = params[:name]
    if js_hash.present? and /\A[a-zA-Z0-9]+\z/.match(js_hash)
      @js_hash = js_hash
    end
  end

  def parse
    file = params[:file]

    if file.blank?
      return render status: :unprocessable_entity, json: {'message': 'Invalid file'}
    end

    unless File.exists?(file.path)
      return render status: :unprocessable_entity, json: { 'message': 'Failed to process file' }
    end

    begin
      input_file_path = file.path
      sha256_input_file = Digest::SHA256.file(input_file_path)
      sha256_tree_generator = Digest::SHA256.file(TREE_GENERATOR)
      sha256sum = sha256_input_file.to_s[0,16] + sha256_tree_generator.to_s[0,16]

      saved_input_file_path = Rails.root.join('tmp', 'ptree', sha256sum, 'source_file').to_s
      output_file_dir = Rails.root.join('tmp', 'ptree', sha256sum).to_s
      output_file_name_js = 'parsetree.js'
      output_file_path_js = Rails.root.join('tmp', 'ptree', sha256sum, output_file_name_js).to_s

      unless Dir.exists?(output_file_dir)
        FileUtils::mkdir_p output_file_dir
      end

      # Move posted file to rails tmp dir
      FileUtils.mv(input_file_path, saved_input_file_path)

      # Detect encoding
      encoding = encoding_of(saved_input_file_path)
      codepage = codepage_of(saved_input_file_path)

      process_info = nil

      process_info = Benchmark.measure do
        system("mono #{TREE_GENERATOR} #{saved_input_file_path} #{output_file_path_js} #{codepage}")
      end

      # Save process summary
      File.open(output_file_path_js, 'a') do |f|
        summary = <<-HEREDOC
(function(global, factory){
  "use strict";
  factory(global);
})(window, function(global){
"use strict";
if(!global.CST) global.CST = {};
global.CST.summary = {'encoding': '#{encoding}', 'total_time': #{process_info.total}, 'file': '#{sha256sum}'}
});
        HEREDOC

        f.write(summary)

        render json: {
            file: sha256sum,
            total_time: process_info.total,
            encoding: encoding
        }
      end
    rescue
      render status: :unprocessable_entity, json: { 'message': 'Parsing failed by server internal issue or bug' }
    end
  end

  def js
    file_hash = params[:name]
    js_file_path = Rails.root.join('tmp', 'ptree', file_hash, 'parsetree.js').to_s
    unless File.exists?(js_file_path)
      return render status: :unprocessable_entity, json: { 'message': 'Requested file was not found' }
    end

    send_file(js_file_path, type: 'text/javascript; charset=utf-8', disposition: 'inline')
  end

  private

  # https://msdn.microsoft.com/en-us/library/windows/desktop/dd317756(v=vs.85).aspx
  CODEPAGE_MAP = {
		'IBM037': 37,
		'IBM437': 437,
		'IBM500': 500,
		'ASMO-708': 708,
		'DOS-720': 720,
		'IBM737': 737,
		'IBM775': 775,
		'IBM850': 850,
		'IBM852': 852,
		'IBM855': 855,
		'IBM857': 857,
		'IBM00858': 858,
		'IBM860': 860,
		'IBM861': 861,
		'DOS-862': 862,
		'IBM863': 863,
		'IBM864': 864,
		'IBM865': 865,
		'CP866': 866,
		'IBM869': 869,
		'IBM870': 870,
		'WINDOWS-874': 874,
		'CP875': 875,
		'SHIFT_JIS': 932,
		'GB2312': 936,
		'KS_C_5601-1987': 949,
		'BIG5': 950,
		'IBM1026': 1026,
		'IBM01047': 1047,
		'IBM01140': 1140,
		'IBM01141': 1141,
		'IBM01142': 1142,
		'IBM01143': 1143,
		'IBM01144': 1144,
		'IBM01145': 1145,
		'IBM01146': 1146,
		'IBM01147': 1147,
		'IBM01148': 1148,
		'IBM01149': 1149,
		'UTF-16': 1200,
		'UNICODEFFFE': 1201,
		'WINDOWS-1250': 1250,
		'WINDOWS-1251': 1251,
		'WINDOWS-1252': 1252,
		'WINDOWS-1253': 1253,
		'WINDOWS-1254': 1254,
		'WINDOWS-1255': 1255,
		'WINDOWS-1256': 1256,
		'WINDOWS-1257': 1257,
		'WINDOWS-1258': 1258,
		'JOHAB': 1361,
		'MACINTOSH': 10000,
		'X-MAC-JAPANESE': 10001,
		'X-MAC-CHINESETRAD': 10002,
		'X-MAC-KOREAN': 10003,
		'X-MAC-ARABIC': 10004,
		'X-MAC-HEBREW': 10005,
		'X-MAC-GREEK': 10006,
		'X-MAC-CYRILLIC': 10007,
		'X-MAC-CHINESESIMP': 10008,
		'X-MAC-ROMANIAN': 10010,
		'X-MAC-UKRAINIAN': 10017,
		'X-MAC-THAI': 10021,
		'X-MAC-CE': 10029,
		'X-MAC-ICELANDIC': 10079,
		'X-MAC-TURKISH': 10081,
		'X-MAC-CROATIAN': 10082,
		'UTF-32': 12000,
		'UTF-32BE': 12001,
		'X-CHINESE_CNS': 20000,
		'X-CP20001': 20001,
		'X_CHINESE-ETEN': 20002,
		'X-CP20003': 20003,
		'X-CP20004': 20004,
		'X-CP20005': 20005,
		'X-IA5': 20105,
		'X-IA5-GERMAN': 20106,
		'X-IA5-SWEDISH': 20107,
		'X-IA5-NORWEGIAN': 20108,
		'US-ASCII': 20127,
		'X-CP20261': 20261,
		'X-CP20269': 20269,
		'IBM273': 20273,
		'IBM277': 20277,
		'IBM278': 20278,
		'IBM280': 20280,
		'IBM284': 20284,
		'IBM285': 20285,
		'IBM290': 20290,
		'IBM297': 20297,
		'IBM420': 20420,
		'IBM423': 20423,
		'IBM424': 20424,
		'X-EBCDIC-KOREANEXTENDED': 20833,
		'IBM-THAI': 20838,
		'KOI8-R': 20866,
		'IBM871': 20871,
		'IBM880': 20880,
		'IBM905': 20905,
		'IBM00924': 20924,
		'X-CP20936': 20936,
		'X-CP20949': 20949,
		'CP1025': 21025,
		'KOI8-U': 21866,
		'ISO-8859-1': 28591,
		'ISO-8859-2': 28592,
		'ISO-8859-3': 28593,
		'ISO-8859-4': 28594,
		'ISO-8859-5': 28595,
		'ISO-8859-6': 28596,
		'ISO-8859-7': 28597,
		'ISO-8859-8': 28598,
		'ISO-8859-9': 28599,
		'ISO-8859-13': 28603,
		'ISO-8859-15': 28605,
		'X-EUROPA': 29001,
		'ISO-8859-8-I': 38598,
		'CSISO2022JP': 50221,
		'ISO-2022-JP': 50222,
		'ISO-2022-KR': 50225,
		'X-CP50227': 50227,
		'EUC-JP': 51932,
		'EUC-CN': 51936,
		'EUC-KR': 51949,
		'HZ-GB-2312': 52936,
		'GB18030': 54936,
		'X-ISCII-DE': 57002,
		'X-ISCII-BE': 57003,
		'X-ISCII-TA': 57004,
		'X-ISCII-TE': 57005,
		'X-ISCII-AS': 57006,
		'X-ISCII-OR': 57007,
		'X-ISCII-KA': 57008,
		'X-ISCII-MA': 57009,
		'X-ISCII-GU': 57010,
		'X-ISCII-PA': 57011,
		'UTF-7': 65000,
		'UTF-8': 65001,
  }

  def encoding_of(file)
    return nil unless File.exists?(file)

    contents = File.read(file)
    detection = CharlockHolmes::EncodingDetector.detect(contents)
    detection[:encoding]
  end

  def codepage_of(file)
    encoding = encoding_of(file)
    return '' if encoding.blank?

    CODEPAGE_MAP[encoding.upcase.to_sym]
  end
end
