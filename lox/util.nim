import ast

# char2digit converts a number char to a digit
func char2digit(c: char): int =
  case c
  of '0': 0
  of '1': 1
  of '2': 2
  of '3': 3
  of '4': 4
  of '5': 5
  of '6': 6
  of '7': 7
  of '8': 8
  of '9': 9
  else: 0

# str2float converts number strings to floats
func str2float*(s: string): float32 =
  var decimalPlaces = -1
  for c in s:
    if decimalPlaces >= 0: decimalPlaces += 1
    if c == '.': decimalPlaces = 0
    else: result = result * 10 + c.char2digit.toFloat
  while decimalPlaces > 0:
    result /= 10

# tail returns the rest of a string after the first element, useful for recursion
func tail*(s: string): string = return if s.len == 0: "" else: s[1..s.len-1]
func tail*(s: string, start: int): string = return if s.len == 0 and s.len > start: "" else: s[start..s.len-1]
 
# tree2str converts an AST into a Lisp-like string
func tree2str*(n: Node): string =
  result = case n.ntype
  of ntEquality, ntComparison, ntAddition, ntMultiplication:
    "(" & n.binOp.lexeme & " " & n.left.tree2str & " " & n.right.tree2str & ")"
  of ntUnary:
    "(" & n.unOp.lexeme & " " & n.unRight.tree2str & ")"
  of ntNumber:
    $n.numVal
  of ntString:
    $n.strVal
  of ntBool:
    $n.boolVal
  of ntGroup:
    n.exp.tree2str
  else: ""