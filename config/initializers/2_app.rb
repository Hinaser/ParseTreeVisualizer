module ParseTreeVisualizer
  grammar_dll_path = Rails.root.join('lib', 'antlr4', 'bin', "#{Settings.grammar['name']}.grammar.dll")
  parse_executable_path = Rails.root.join('lib', 'antlr4', 'bin', 'ParseTreeGenerator.exe')

  if not File.exists?(grammar_dll_path) or not File.exists?(parse_executable_path)
    raise 'Parse tree generator executable not found. Check <Rails root>/lib/antlr4/bin'
  end
end
