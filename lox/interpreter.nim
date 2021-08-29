import ast, token, errors

proc isNumber(n: Node): bool = n.ntype == ntNumber
proc isString(n: Node): bool = n.ntype == ntString
proc isBool(n: Node): bool = n.ntype == ntBool
proc isNil(n: Node): bool = n.ntype == ntNil
proc isTerminal(n: Node): bool = n.ntype in [ntNumber, ntString, ntBool, ntNil]

proc equalVals(l, r: Node, op: Token, errs: var ErrorLog): Node = # ==, !=
  if not l.isTerminal or not r.isTerminal:
    errs.newError(runtimeErr, "Cannot compare type " & $l.ntype & " with type " & $r.ntype, op.line)
    return Node(ntype: ntBool, boolVal: false)
  if l.ntype != r.ntype: result = Node(ntype: ntBool, boolVal: false)
  else: result = Node(ntype: ntBool, boolVal:
    case l.ntype
    of ntBool: l.boolVal == r.boolVal
    of ntNumber: l.numVal == r.numVal
    of ntString: l.strVal == r.strVal
    else: false)
  if op.ttype == ttBangEqual: result.boolVal = not result.boolVal

proc compareVals(l, r: Node, op: Token, errs: var ErrorLog): Node = # <, >, <=, >=
  if not l.isNumber or not r.isNumber:  
    errs.newError(runtimeErr, "Cannot compare type " & $l.ntype & " with type " & $r.ntype, op.line)
    return Node(ntype: ntBool, boolVal: false)
  result = case op.ttype
  of ttLess: Node(ntype: ntBool, boolVal: l.numVal < r.numVal)
  of ttGreater: Node(ntype: ntBool, boolVal: l.numVal > r.numVal)
  of ttLessEqual: Node(ntype: ntBool, boolVal: l.numVal <= r.numVal)
  of ttGreaterEqual: Node(ntype: ntBool, boolVal: l.numVal >= r.numVal)
  else: Node(ntype: ntBool, boolVal: false)

proc addVals(l, r: Node, op: Token, errs: var ErrorLog): Node = # +, -
  if l.isNumber and r.isNumber: 
    if op.ttype == ttPlus: return Node(ntype: ntNumber, numVal: l.numVal + r.numVal)
    else: return Node(ntype: ntNumber, numVal: l.numVal - r.numVal)
  elif l.isString and r.isString and op.ttype == ttPlus:
    return Node(ntype: ntString, strVal: l.strVal & r.strVal)
  else:
    let opStr = if op.ttype == ttMinus: "subtract" else: "add or concatenate"
    errs.newError(runtimeErr, "Cannot " & opStr &  " type " & $l.ntype & " and type " & $r.ntype, op.line)
    return Node(ntype: ntNumber, numVal: 0)

proc multVals(l, r: Node, op: Token, errs: var ErrorLog): Node = # *, /
  if l.isNumber and r.isNumber: 
    if op.ttype == ttStar: return Node(ntype: ntNumber, numVal: l.numVal * r.numVal)
    else: return Node(ntype: ntNumber, numVal: l.numVal / r.numVal)
  else:
    let opStr = if op.ttype == ttStar: "multiply" else: "divide"
    errs.newError(runtimeErr, "Cannot " & opStr &  " type " & $l.ntype & " and type " & $r.ntype, op.line)
    return Node(ntype: ntNumber, numVal: 0)

proc trimInt(x: float32): string = 
  var s = $x
  if s[s.len-2..s.len-1 ] == ".0": 
    return s[0..s.len-3]
  else: return s

proc stringify*(n: Node): string =
  return case n.ntype
  of ntNumber: trimInt n.numVal
  of ntString: n.strVal
  of ntBool: $n.boolVal
  of ntNil: "nil"
  else: "Runtime error: failed to evaluate AST"

proc evalUnary(n: Node, errs: var ErrorLog): Node
proc evalBinary(n: Node, errs: var ErrorLog): Node

proc eval*(n: Node, errs: var ErrorLog): Node = 
  result = case n.ntype
  of ntNumber, ntString, ntBool, ntNil: n
  of ntGroup: eval(n.exp, errs)
  of ntUnary: evalUnary(n, errs)
  of ntEquality, ntComparison, ntAddition, ntMultiplication: evalBinary(n, errs)

proc evalUnary(n: Node, errs: var ErrorLog): Node =
  let r: Node = eval(n.unRight, errs)
  case n.unOp.ttype
  of ttBang: # !
    if r.isBool: return Node(ntype: ntBool, boolVal: not r.boolVal)
    elif r.isNil: return Node(ntype: ntBool, boolVal: true)
    elif r.isString: return Node(ntype: ntBool, boolVal: false)
    else: return Node(ntype: ntBool, boolVal: false)
  of ttMinus: # -
    if r.isNumber: return Node(ntype: ntNumber, numVal: -r.numVal)
    else: 
      errs.newError(runtimeErr, "Cannot negate type " & $r.ntype, n.unOp.line)
      return n
  else: return n # unreachable

proc evalBinary(n: Node, errs: var ErrorLog): Node = 
  let l = eval(n.left, errs)
  let r = eval(n.right, errs)
  let op = n.binOp
  result = case n.ntype
  of ntEquality: equalVals(l, r, op, errs)
  of ntComparison: compareVals(l, r, op, errs)
  of ntAddition: addVals(l, r, op, errs)
  of ntMultiplication: multVals(l, r, op, errs)
  else: n


