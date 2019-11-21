import token

type LexedOutput* = seq[Token]
type LexingError* = object of CatchableError
  cause*: Token

template newLexingError*(message: string; causeIn: Token; parentException: ref Exception = nil): untyped =
  var e: ref LexingError
  new(e)
  e.msg = message
  e.cause = causeIn
  e.parent = parentException
  e  

proc `$`*(input: LexedOutput): string =
  for i in input:
    result &= $i & "\n"