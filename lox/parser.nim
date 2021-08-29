import token, ast, util, errors

# expression 	-> equality ;
# equality 		-> comparison ( ( "!=" | "==" ) comparison )* ;
# comparison 	-> term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
# term				-> factor ( ( "-" | "+" ) factor )* ;
# factor			-> unary ( ( "/" | "*" ) unary )* ;
# unary				-> ( "!" | "-" ) unary | primary ;
# primary			-> NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" ;

# parse converts a sequence of Tokens to an Abstract Syntax Tree using recursive descent
proc parse*(tokens: seq[Token], errs: var ErrorLog): Node =
  var i = 0

  proc match(ttypes: varargs[TokenType]): bool =
    if i >= tokens.len: return false
    for tt in ttypes:
      if tokens[i].ttype == tt:
        i += 1
        return true
    return false
  
  proc equality(): Node
  proc comparison(): Node
  proc addition(): Node
  proc multiplication(): Node
  proc unary(): Node
  proc primary(): Node

  proc expression(): Node = 
    result = equality()

  proc equality(): Node =
    result = comparison()
    while match(ttEqualEqual, ttBangEqual):
      result = Node(ntype: ntEquality, binOp: tokens[i-1], left: result, right: comparison())

  proc comparison(): Node =
    result = addition()
    while match(ttLess, ttLessEqual, ttGreater, ttGreaterEqual):
      result = Node(ntype: ntComparison, binOp: tokens[i-1], left: result, right: addition())

  proc addition(): Node =
    result = multiplication()
    while match(ttPlus, ttMinus):
      result = Node(ntype: ntAddition, binOp: tokens[i-1], left: result, right: multiplication())

  proc multiplication(): Node =
    result = unary()
    while match(ttStar, ttSlash):
      result = Node(ntype: ntMultiplication, binOp: tokens[i-1], left: result, right: unary())

  proc unary(): Node =
    if match(ttBang, ttMinus):
      return Node(ntype: ntUnary, unOp: tokens[i-1], unRight: unary())
    return primary()

  proc primary(): Node =
    if match ttFalse: return Node(ntype: ntBool, boolVal: false)
    elif match ttTrue: return Node(ntype: ntBool, boolVal: true)
    elif match ttNil: return Node(ntype: ntNil)
    elif match ttNumber: return Node(ntype: ntNumber, numVal: str2float tokens[i-1].lexeme)
    elif match ttString: 
      return Node(ntype: ntString, strVal: tokens[i-1].lexeme[1..tokens[i-1].lexeme.len-2]) # trim quotes
    elif match ttLeftParen: 
      result = Node(ntype: ntGroup, exp: expression())
      discard match ttRightParen
    else:
      # Running into some weird issue about "violating memory safety" here. Not sure why it
      # only affects here and not in the lexer or interpreter.
      # errs.newError(parsingErr, "Unexpected token \"" & tokens[i].lexeme & "\"", tokens[i].line)
      return Node(ntype: ntNil)

  

  return Node(ntype: ntGroup, exp: expression())
