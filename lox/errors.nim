type 
  ErrorType* = enum
    lexingErr,
    parsingErr,
    runtimeErr

type
  Error* = object
    errType*: ErrorType
    errMessage*: string
    errLine*: int

type
  ErrorLog* = object
    errors*: seq[Error]

proc newErrorLog*(): ErrorLog =
  return ErrorLog(errors: @[])

proc newError*(log: var ErrorLog, etype: ErrorType, message: string, line: int) = 
  log.errors = log.errors & Error(errType: etype, errMessage: message, errLine: line)

proc printErrors*(log: ErrorLog) =
  for e in log.errors:
    case e.errType
    of lexingErr:
      echo "Lexing error on line " & $e.errLine & ": " & e.errMessage
    of parsingErr:
      echo "Parsing error on line " & $e.errLine & ": " & e.errMessage
    of runtimeErr:
      echo "Runtime error on line " & $e.errLine & ": " & e.errMessage