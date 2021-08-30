import ast, token, lox

proc isNumber(n: Node): bool = n.ntype == ntNumber
proc isString(n: Node): bool = n.ntype == ntString
proc isBool(n: Node): bool = n.ntype == ntBool
proc isNil(n: Node): bool = n.ntype == ntNil
proc isTerminal(n: Node): bool = n.ntype in [ntNumber, ntString, ntBool, ntNil]

proc equalVals(lx: var Lox, l, r: Node, op: Token): Node = # ==, !=
  if not l.isTerminal or not r.isTerminal:
    lx.newError(runtimeErr, "Cannot compare type " & $l.ntype & " with type " & $r.ntype, op.line)
    return Node(ntype: ntBool, boolVal: false)
  if l.ntype != r.ntype: result = Node(ntype: ntBool, boolVal: false)
  else: result = Node(ntype: ntBool, boolVal:
    case l.ntype
    of ntBool: l.boolVal == r.boolVal
    of ntNumber: l.numVal == r.numVal
    of ntString: l.strVal == r.strVal
    of ntNil: true
    else: false)
  if op.ttype == ttBangEqual: result.boolVal = not result.boolVal

proc compareVals(lx: var Lox, l, r: Node, op: Token): Node = # <, >, <=, >=
  if not l.isNumber or not r.isNumber:  
    lx.newError(runtimeErr, "Cannot compare type " & $l.ntype & " with type " & $r.ntype, op.line)
    return Node(ntype: ntBool, boolVal: false)
  result = case op.ttype
  of ttLess: Node(ntype: ntBool, boolVal: l.numVal < r.numVal)
  of ttGreater: Node(ntype: ntBool, boolVal: l.numVal > r.numVal)
  of ttLessEqual: Node(ntype: ntBool, boolVal: l.numVal <= r.numVal)
  of ttGreaterEqual: Node(ntype: ntBool, boolVal: l.numVal >= r.numVal)
  else: Node(ntype: ntBool, boolVal: false)

proc addVals(lx: var Lox, l, r: Node, op: Token): Node = # +, -
  if l.isNumber and r.isNumber: 
    if op.ttype == ttPlus: return Node(ntype: ntNumber, numVal: l.numVal + r.numVal)
    else: return Node(ntype: ntNumber, numVal: l.numVal - r.numVal)
  elif l.isString and r.isString and op.ttype == ttPlus:
    return Node(ntype: ntString, strVal: l.strVal & r.strVal)
  else:
    let opStr = if op.ttype == ttMinus: "subtract" else: "add or concatenate"
    lx.newError(runtimeErr, "Cannot " & opStr &  " type " & $l.ntype & " and type " & $r.ntype, op.line)
    return Node(ntype: ntNumber, numVal: 0)

proc multVals(lx: var Lox, l, r: Node, op: Token): Node = # *, /
  if l.isNumber and r.isNumber: 
    if op.ttype == ttStar: return Node(ntype: ntNumber, numVal: l.numVal * r.numVal)
    else: return Node(ntype: ntNumber, numVal: l.numVal / r.numVal)
  else:
    let opStr = if op.ttype == ttStar: "multiply" else: "divide"
    lx.newError(runtimeErr, "Cannot " & opStr &  " type " & $l.ntype & " and type " & $r.ntype, op.line)
    return Node(ntype: ntNumber, numVal: 0)

proc trimInt(x: float32): string = 
  var s = $x
  if s[s.len-2..s.len-1 ] == ".0": 
    return s[0..s.len-3]
  else: return s

proc stringify*(lx: var Lox, n: Node): string =
  result = case n.ntype
  of ntNumber: trimInt n.numVal
  of ntString: n.strVal
  of ntBool: $n.boolVal
  of ntNil: "nil"
  else: ""
  if result == "":
    lx.newError(runtimeErr, "failed to evaluate ast")

proc evalUnary(lx: var Lox, n: Node): Node
proc evalBinary(lx: var Lox, n: Node): Node
# proc execute(lx: var Lox, stmts: seq[Node])

proc eval*(lx: var Lox, n: Node): Node = 
  result = case n.ntype
  of ntNumber, ntString, ntBool, ntNil: n
  of ntPrintStmt: lx.eval(n.printExp)
  of ntGroup, ntExprStmt: lx.eval(n.exp)
  of ntUnary: lx.evalUnary(n)
  of ntEquality, ntComparison, ntAddition, ntMultiplication: lx.evalBinary(n)
  else: n

proc evalUnary(lx: var Lox, n: Node): Node =
  let r: Node = lx.eval(n.unRight)
  case n.unOp.ttype
  of ttBang: # !
    if r.isBool: return Node(ntype: ntBool, boolVal: not r.boolVal)
    elif r.isNil: return Node(ntype: ntBool, boolVal: true)
    elif r.isString: return Node(ntype: ntBool, boolVal: false)
    else: return Node(ntype: ntBool, boolVal: false)
  of ttMinus: # -
    if r.isNumber: return Node(ntype: ntNumber, numVal: -r.numVal)
    else: 
      lx.newError(runtimeErr, "Cannot negate type " & $r.ntype, n.unOp.line)
      return n
  else: return n # unreachable

proc evalBinary(lx: var Lox, n: Node): Node = 
  let l = lx.eval(n.left)
  let r = lx.eval(n.right)
  let op = n.binOp
  result = case n.ntype
  of ntEquality: lx.equalVals(l, r, op)
  of ntComparison: lx.compareVals(l, r, op)
  of ntAddition: lx.addVals(l, r, op)
  of ntMultiplication: lx.multVals(l, r, op)
  else: n


