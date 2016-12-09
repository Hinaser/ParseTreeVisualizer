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
    if args[:grammar].blank?
      puts 'Usage: rake antlr4:compile_grammar[<grammar>]'
      puts '  <grammar>: Name of grammar.'
      next
    end

    grammar = args[:grammar].downcase

    output_dir = Rails.root.join('lib', 'antlr4', 'grammars', grammar)
    Dir.chdir(output_dir) do
      system("java -classpath #{G4_COMPILER_PATH} org.antlr.v4.Tool #{output_dir}/*.g4 -Dlanguage=CSharp_v4_5")
      system("mcs -t:library -out:#{grammar}.grammar.dll -r:#{ANTLR4_RUNTIME_PATH} #{output_dir}/\\*.cs")
      system("mv #{grammar}.grammar.dll #{ANTLR4_BIN_DIR}/")
    end
  end

  desc 'Compile grammar analyzer tool'
  task :compile_tool, [:grammar] do |t, args|
    if args[:grammar].blank?
      puts 'Usage: rake antlr4:compile_tool[<grammar>]'
      puts '  <grammar>: Name of grammar.'
      next
    end

    grammar = args[:grammar].downcase

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
    modifying_src = File.read(ORG_PROGRAM_CS_PATH)
    modifying_src.gsub!(/CUSTOM_LEXER/, "#{grammar.upcase}Lexer")
    modifying_src.gsub!(/CUSTOM_PARSER/, "#{grammar.upcase}Parser")

    File.open(PROGRAM_CS_PATH, 'w') do |out|
      out << modifying_src
    end
  end
end
