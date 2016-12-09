module ParseTreeVisualizer
  grammar = nil

  grammar_dll = ParseTreeVisualizer::Popen.popen(%W(find . -name *.grammar.dll), Rails.root.join('lib', 'antlr4', 'bin').to_s)

  if grammar_dll.blank?
    raise 'Parse tree generator executable not found'
  end

  grammar = grammar_dll[0].chomp.gsub(/^.\//, '').split('.')[0]
  GRAMMAR = grammar.upcase
end
