import lox/[ast, interpreter, lexer, parser, token, util, errors]

proc runPrompt() =
  var line: string
  var tokens: seq[Token]
  var tree: Node
  var output: Node
  while true:
    stdout.write "> "
    line = readLine stdin
    var errs = newErrorLog()
    if line == "exit": break
    tokens = lex(line, errs)
    echo "\nTOKENS:"
    errs.printErrors
    for t in tokens:
      echo $t.ttype & ": " & t.lexeme

    echo "\nTREE:"
    errs.printErrors
    tree = parse(tokens, errs)
    echo tree.tree2str

    echo "\nRESULT:"
    errs.printErrors
    output = eval(tree, errs)
    echo stringify output

runPrompt()
