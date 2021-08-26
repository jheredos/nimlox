import token, util
 
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
iterator tokenize(src: string): (string, int) =
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
      echo "Warning: unexpected character \"" & $src[current] & "\" on line " & $line
      current += 1

# lex() matches the token strings from tokenize() to their corresponding token types,
# returning a seq of Token objects
proc lex*(src: string): seq[Token] =
  for tkn, line in tokenize src:
    var tkntype: TokenType = case tkn
    of "(": ttLeftParen
    of ")": ttRightParen
    of "{": ttLeftBrace
    of "}": ttRightBrace
    of ",": ttComma
    of ".": ttDot
    of "-": ttMinus
    of "+": ttPlus
    of ";": ttSemicolon
    of "/": ttSlash
    of "*": ttStar
    of "!": ttBang
    of "!=": ttBangEqual
    of "=": ttEqual
    of "==": ttEqualEqual
    of ">": ttGreater
    of ">=": ttGreaterEqual
    of "<": ttLess
    of "<=": ttLessEqual
    of "and": ttAnd
    of "class": ttClass
    of "else": ttElse
    of "false": ttFalse
    of "fun": ttFun
    of "for": ttFor
    of "if": ttIf
    of "nil": ttNil
    of "or": ttOr
    of "print": ttPrint
    of "return": ttReturn
    of "super": ttSuper
    of "this": ttThis
    of "true": ttTrue
    of "var": ttVar
    of "while": ttWhile
    elif tkn[0] == '"': ttString
    elif tkn[0] in '0'..'9': ttNumber
    else: ttIdentifier

    result = result & Token(ttype: tkntype, lexeme: tkn, line: line)
