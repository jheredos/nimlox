import lexer, token, parser, ast, util

proc runPrompt() =
  var line: string
  var tokens: seq[Token]
  var tree: Node
  while true:
    stdout.write "> "
    line = readLine stdin
    tokens = lex line
    echo "\nTOKENS:"
    for t in tokens:
      echo $t.ttype & ": " & t.lexeme

    echo "\nTREE:"
    tree = parse tokens
    echo tree.tree2str

runPrompt()
