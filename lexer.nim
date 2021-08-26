import token

func tail(s: string): string = return if s.len == 0: "" else: s[1..s.len-1]
func tail(s: string, start: int): string = return if s.len == 0 and s.len > start: "" else: s[start..s.len-1]
  
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

func scanString(s: string): string =
  result = $s[0]
  for c in s.tail:
    result = result & $c
    if c == '"': break

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
iterator tokenize(src: string): string =
  var current = 0
  while current < src.len:
    case src[current]
    of ' ', '\t', '\n': current += 1 # whitespace
    of '('..'/', ':'..'>', '{', '}', '!':  # single-char
      if current < src.len - 1 and src[current+1] == '=': # two-char (>=, <=, !=, ==)
        case src[current] 
        of '!', '<', '>', '=': 
          yield src[current..current+1]
          current += 1
        else: yield $src[current]
      else: yield $src[current]
      current += 1
    of '0'..'9': # numbers
      let n = scanNumber src.tail(current)
      current += n.len
      yield n
    of 'a'..'z', 'A'..'Z', '_': # identifiers
      let i = scanIdent src.tail(current)
      current += i.len
      yield i
    of '"': # strings
      let s = scanString src.tail(current)
      current += s.len
      yield s
    of '#': # comments
      let com = scanComment src.tail(current)
      current += com.len
      yield com
    else: current += 1

# lex() matches the token strings from tokenize() to their corresponding token types,
# returning a seq of Token objects
func lex*(src: string): seq[Token] =
  for t in tokenize src:
    var tkn: TokenType = case t:
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
    elif t[0] == '"': ttString
    elif t[0] in '0'..'9': ttNumber
    else: ttIdentifier

    result = result & Token(ttype: tkn, lexeme: t)

# some pseudocode for testing
var pseudocode: string =
  """
var abc = 123;

if(abc != 456 and true != false) {
  do.something()
}else{
  do.somethingElse()
}

fun double(x) = {
  return x * 2
}

print double(7)
"""

var tokens = lex pseudocode

for t in tokens:
  echo $t.ttype & ": " & t.lexeme