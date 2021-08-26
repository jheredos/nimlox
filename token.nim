type 
  TokenType* = enum
    ttLeftParen,
    ttRightParen,
    ttLeftBrace,
    ttRightBrace,
    ttComma,
    ttDot,
    ttMinus,
    ttPlus,
    ttSemicolon,
    ttSlash,
    ttStar,
    ttBang,
    ttBangEqual,
    ttEqual,
    ttEqualEqual,
    ttGreater,
    ttGreaterEqual,
    ttLess,
    ttLessEqual,
    ttIdentifier,
    ttString,
    ttNumber,
    ttAnd,
    ttClass,
    ttElse,
    ttFalse,
    ttFun,
    ttFor,
    ttIf,
    ttNil,
    ttOr,
    ttPrint,
    ttReturn,
    ttSuper,
    ttThis,
    ttTrue,
    ttVar,
    ttWhile,
    ttEOF

type
  Token* = object
    ttype*: TokenType
    lexeme*: string
    # literal: object
    line*: int