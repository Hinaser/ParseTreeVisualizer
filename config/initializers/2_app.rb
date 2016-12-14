module ParseTreeVisualizer
  grammar_dll_path = Rails.root.join('lib', 'antlr4', 'bin', "#{Settings.grammar['name']}.grammar.dll")
  parse_executable_path = Rails.root.join('lib', 'antlr4', 'bin', 'ParseTreeGenerator.exe')

  if not File.exists?(grammar_dll_path) or not File.exists?(parse_executable_path)
    raise 'Parse tree generator executable not found. Check <Rails root>/lib/antlr4/bin'
  end

  # Check grammar file path
  grammar_dir = Rails.root.join('lib', 'antlr4', 'grammars', "#{Settings.grammar['name']}").to_s
  LEXER_GRAMMAR = Dir["#{grammar_dir}/*Lexer.g4"]
  PARSER_GRAMMAR = Dir["#{grammar_dir}/*Parser.g4"]
  combined_grammar = nil

  if LEXER_GRAMMAR.length + PARSER_GRAMMAR.length == 0
    combined_grammar = Dir["#{grammar_dir}/*.g4"]
  end

  COMBINED_GRAMMAR = combined_grammar

  def lexer_rule
    return nil unless LEXER_GRAMMAR and LEXER_GRAMMAR.length > 0

    File.read(LEXER_GRAMMAR[0])
  end

  def parser_rule
    return nil unless PARSER_GRAMMAR and PARSER_GRAMMAR.length > 0

    File.read(PARSER_GRAMMAR[0])
  end

  def combined_rule
    return nil unless COMBINED_GRAMMAR and COMBINED_GRAMMAR.length > 0

    File.read(COMBINED_GRAMMAR[0])
  end
end
