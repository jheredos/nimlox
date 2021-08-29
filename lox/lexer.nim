import token, util, errors
 
func scanNumber(s: string): string =
  var dotSeen = false
  for c in s:
    case c
    of '.': 
      if dotSeen: return
      dotSeen = true
      result = result & $c
    of '0'..'9':
      result = result & $c
    else: return

func scanString(s: string): (string, int) =
  var str = $s[0]
  var lines = 0
  for c in s.tail:
    str = str & $c
    if c == '\n': lines += 1
    if c == '"': break
  return (str, lines)

func scanIdent(s: string): string =
  result = $s[0]
  for c in s.tail:
    case c
    of 'a'..'z', 'A'..'Z', '0'..'9', '_':
      result = result & $c
    else: return

func scanComment(s: string): string =
  for c in s:
    if c == '\n': break
    result = result & $c

# tokenize() yields token strings according to the lexing rules
iterator tokenize(src: string, errs: var ErrorLog): (string, int) =
  var current = 0
  var line = 1
  while current < src.len:
    case src[current]
    of ' ', '\t': current += 1 # whitespace
    of '\n':
      current += 1
      line += 1
    of '('..'/', ':'..'>', '{', '}', '!':  # single-char
      # two-char (>=, <=, !=, ==)
      if current < src.len - 1 and src[current] in ['!', '<', '>', '='] and src[current+1] == '=':
        current += 2
        yield (src[current-2..current-1], line)
      else: 
        current += 1
        yield ($src[current-1], line)
    of '0'..'9': # numbers
      let n = scanNumber src.tail(current)
      current += n.len
      yield (n, line)
    of 'a'..'z', 'A'..'Z', '_': # identifiers
      let i = scanIdent src.tail(current)
      current += i.len
      yield (i, line)
    of '"': # strings
      let (s, lines) = scanString src.tail(current)
      line += lines
      current += s.len
      yield (s, line)
    of '#': # comments
      let com = scanComment src.tail(current)
      current += com.len
      line += 1
      yield (com, line)
    else: 
      errs.newError(lexingErr, "Unexpected character \"" & src[current] & "\"", line)
      current += 1

# lex() matches the token strings from tokenize() to their corresponding token types,
# returning a seq of Token objects
proc lex*(src: string, errs: var ErrorLog): seq[Token] =
  for tkn, line in tokenize(src, errs):
    var tkntype: TokenType 
    case tkn
    of "(": tkntype = ttLeftParen
    of ")": tkntype = ttRightParen
    of "{": tkntype = ttLeftBrace
    of "}": tkntype = ttRightBrace
    of ",": tkntype = ttComma
    of ".": tkntype = ttDot
    of "-": tkntype = ttMinus
    of "+": tkntype = ttPlus
    of ";": tkntype = ttSemicolon
    of "/": tkntype = ttSlash
    of "*": tkntype = ttStar
    of "!": tkntype = ttBang
    of "!=": tkntype = ttBangEqual
    of "=": tkntype = ttEqual
    of "==": tkntype = ttEqualEqual
    of ">": tkntype = ttGreater
    of ">=": tkntype = ttGreaterEqual
    of "<": tkntype = ttLess
    of "<=": tkntype = ttLessEqual
    of "and": tkntype = ttAnd
    of "class": tkntype = ttClass
    of "else": tkntype = ttElse
    of "false": tkntype = ttFalse
    of "fun": tkntype = ttFun
    of "for": tkntype = ttFor
    of "if": tkntype = ttIf
    of "nil": tkntype = ttNil
    of "or": tkntype = ttOr
    of "print": tkntype = ttPrint
    of "return": tkntype = ttReturn
    of "super": tkntype = ttSuper
    of "this": tkntype = ttThis
    of "true": tkntype = ttTrue
    of "var": tkntype = ttVar
    of "while": tkntype = ttWhile
    elif tkn[0] == '"': tkntype = ttString
    elif tkn[0] in '0'..'9': tkntype = ttNumber
    elif tkn[0] in 'a'..'z' or tkn[0] in 'A'..'Z': tkntype = ttIdentifier
    else: 
      errs.newError(lexingErr, "Unexpected token \"" & tkn & "\"", line)
      tkntype = ttIdentifier

    result = result & Token(ttype: tkntype, lexeme: tkn, line: line)
