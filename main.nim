import lox/[ast, interpreter, lexer, parser, token, util, lox]

proc runPrompt() =
  echo "Type \"exit\" to leave REPL"

  var lx = new Lox
  var line: string
  var tokens: seq[Token]
  var tree: Node
  var output: Node
  while true:
    lx.errors = @[]
    stdout.write "> "
    line = readLine stdin
    if line == "exit": break

    tokens = lx.lex(line)
    echo "\nTOKENS:"
    for t in tokens:
      echo $t.ttype & ": " & t.lexeme
    lx.printErrors


    tree = lx.parse(tokens)
    echo "\nTREE:"
    echo tree.tree2str
    lx.printErrors

    output = lx.eval(tree)
    echo "\nRESULT:"
    echo lx.stringify(output)
    lx.printErrors



runPrompt()
