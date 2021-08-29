import token

type
  NodeType* = enum
    ntEquality, # equality binary expr with ==, !=
    ntComparison, # comparison binary expr with <, <=, >, >=
    ntAddition, # addition/subtraction binary expr with +, -
    ntMultiplication, # multiplication/division binary expr with *, /
    ntUnary, # unary expression with !, -
    ntNumber, # leaf with number value
    ntString, # leaf with string value
    ntBool, # leaf with boolean value
    ntGroup, # parenthesized expression
    ntNil # leaf with nil value
  Node* = ref NodeObj
  NodeObj* = object
    case ntype*: NodeType
    of ntEquality, ntComparison, ntAddition, ntMultiplication: # binary expressions
      left*, right*: Node
      binOp*: Token
    of ntUnary:
      unRight*: Node
      unOp*: Token
    of ntNumber:
      numVal*: float32
    of ntString: 
      strVal*: string
    of ntBool: 
      boolVal*: bool
    of ntGroup: 
      exp*: Node
    else: discard

