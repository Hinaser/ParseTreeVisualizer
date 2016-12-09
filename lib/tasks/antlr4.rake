namespace :antlr4 do
  ANTLR4_BIN_DIR = Rails.root.join('lib', 'antlr4', 'bin')
  ANTLR4_TOOLS_DIR = Rails.root.join('lib', 'antlr4', 'tools')
  ANTLR4_GRAMMARS_DIR = Rails.root.join('lib', 'antlr4', 'grammars')
  G4_COMPILER_PATH = Rails.root.join('lib', 'antlr4', 'tools', 'antlr4-csharp-4.5.3-complete.jar')
  ANTLR4_RUNTIME_PATH = Rails.root.join('lib', 'antlr4', 'bin', 'Antlr4.Runtime.dll')
  ORG_PROGRAM_CS_PATH = Rails.root.join('lib', 'antlr4', 'tools', 'Program.cs.original')
  PROGRAM_CS_PATH = Rails.root.join('lib', 'antlr4', 'tools', 'Program.cs')

  desc 'Compile grammar file into csharp file and dll'
  task :compile_grammar, [:grammar] do |t, args|
    unless args[:grammar].present? and args[:grammar] =~ /\A[a-zA-Z0-9\-_]+\z/
      puts 'Usage: rake antlr4:compile_grammar[<grammar>]'
      puts '  <grammar>: Name of grammar. Name chars are restricted to alphabet, digit, hyphen, underscore.'
      next
    end

    grammar = args[:grammar]
    grammar.downcase!

    output_dir = Rails.root.join('lib', 'antlr4', 'grammars', grammar)
    Dir.chdir(output_dir) do
      system("java -classpath #{G4_COMPILER_PATH} org.antlr.v4.Tool #{output_dir}/*.g4 -Dlanguage=CSharp_v4_5")
      system("mcs -t:library -out:#{grammar}.grammar.dll -r:#{ANTLR4_RUNTIME_PATH} #{output_dir}/\\*.cs")
      system("mv #{grammar}.grammar.dll #{ANTLR4_BIN_DIR}/")
    end
  end

  desc 'Compile grammar analyzer tool'
  task :compile, [:grammar] do |t, args|
    unless args[:grammar].present? and args[:grammar] =~ /\A[a-zA-Z0-9\-_]+\z/
      puts 'Usage: rake antlr4:compile_tool[<grammar>]'
      puts '  <grammar>: Name of grammar. Name chars are restricted to alphabet, digit, hyphen, underscore.'
      next
    end

    grammar = args[:grammar]
    grammar.downcase!

    # compile .g4 grammar file into .cs csharp file
    Rake::Task['antlr4:compile_grammar'].invoke(grammar)

    embed_grammar(grammar)

    Dir.chdir(ANTLR4_BIN_DIR) do
      system("mcs -r:#{ANTLR4_RUNTIME_PATH},#{ANTLR4_BIN_DIR}/#{grammar}.grammar.dll -out:ParseTreeGenerator.exe #{ANTLR4_TOOLS_DIR}/\\*.cs")
    end
  end

  desc 'Clean files generated by antlr rake task'
  task :clean do
    File.delete(PROGRAM_CS_PATH) if File.exists?(PROGRAM_CS_PATH)
    File.delete("#{ANTLR4_BIN_DIR}/ParseTreeGenerator.exe") if File.exists?("#{ANTLR4_BIN_DIR}/ParseTreeGenerator.exe")
    File.delete(*Dir.glob("#{ANTLR4_BIN_DIR}/*.grammar.dll"))
    File.delete(*Dir.glob("#{ANTLR4_GRAMMARS_DIR}/**/*.cs"))
    File.delete(*Dir.glob("#{ANTLR4_GRAMMARS_DIR}/**/*.tokens"))
  end

  # Replace lexer/parser type string to specified one
  def embed_grammar(grammar)
    require 'parse_tree_visualizer/popen'

    grammar_dir = Rails.root.join('lib', 'antlr4', 'grammars', grammar).to_s
    lexer = ::ParseTreeVisualizer::Popen.popen(%W(find . -name *Lexer.cs), grammar_dir)
    parser = ::ParseTreeVisualizer::Popen.popen(%W(find . -name *Parser.cs), grammar_dir)

    if lexer.blank? or parser.blank? or lexer[0].blank? or parser[0].blank?
      raise 'Error: Lexer or Parser cs file not found'
    end

    lexer = lexer[0].gsub(/\A\.\//, '')
    parser = parser[0].gsub(/\A\.\//, '')

    lexer = lexer[0, lexer.length - '.cs'.length - 1]
    parser = parser[0, parser.length - '.cs'.length - 1]

    modifying_src = File.read(ORG_PROGRAM_CS_PATH)
    modifying_src.gsub!(/CUSTOM_LEXER/, lexer)
    modifying_src.gsub!(/CUSTOM_PARSER/, parser)

    File.open(PROGRAM_CS_PATH, 'w') do |out|
      out << modifying_src
    end
  end
end
