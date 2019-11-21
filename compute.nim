import lexedOutput, token, math

type ComputeError* = object of CatchableError
  cause*: Token

template newComputeError*(message: string; causeIn: Token;
    parentException: ref Exception = nil): untyped =
  var e: ref ComputeError
  new(e)
  e.msg = message
  e.cause = causeIn
  e.parent = parentException
  e

method computeTokens(numberA: NumberToken; operator: OperatorToken;
    numberB: NumberToken): int =
  let operatorKind = operator.higherKind
  case operatorKind:
  of plus:
    return numberA.value + numberB.value
  of minus:
    return numberA.value - numberB.value
  of star:
    return numberA.value * numberB.value
  of slash:
    try:
      return numberA.value div numberB.value
    except DivByZeroError:
      var e = getCurrentException()
      e.msg &= "\n\tCause: " & $numberA.value & "/" & $numberB.value
      raise


# proc coalesceTwoOperators(input: var LexedOutput, i: int) =
#   let operatorA = cast[OperatorToken](input[i-1]).higherKind
#   let operatorB = cast[OperatorToken](input[i]).higherKind
#   if (operatorA, operatorB) == (plus, minus):
#   input.delete(i)

proc coalesceTokens(input: var LexedOutput; i: int) =
  let computedValue = computeTokens(cast[NumberToken](input[i-1]), cast[
      OperatorToken](input[i]), cast[NumberToken](input[i+1]))
  input[i-1] = newNumberToken(computedValue)
  input.delete(i)
  input.delete(i)

proc coalesceSubseq(input: var LexedOutput; startPos, endPos: int) =
  var i = startPos
  while i <= endPos and i <= input.high-1:
    let previous = if i-1 >= input.low: input[i-1]
                   else: nil
    let current = input[i]
    let next = if i+1 <= input.high: input[i+1]
               else: nil
    let kinds = (previous: previous.kind, current: current.kind,
        next: next.kind)
    if kinds == (number, operator, number):
      input.coalesceTokens(i)
    elif kinds == (operator, number, parenthesis) and
      cast[OperatorToken](previous).higherKind == minus:
      input[i] = newNumberToken( - cast[NumberToken](input[i]).value)
      input.delete(i-1)
    else:
      i.inc
  # return cast[NumberToken](input[0]).value

proc convertAllToNumbers*(input: var LexedOutput) =
  for pos, item in input:
    if item.kind == digit:
      input[pos] = newNumberToken(cast[DigitToken](item).value.int)

proc processParenthesis(input: LexedOutput; startPos: int): LexedOutput =
  var i = startPos
  var input = input
  while i <= input.high:
    if input[i].kind == parenthesis:
      if cast[ParenthesesToken](input[i]).higherKind == left:
        input.delete(i)
        let startPos = i
        # echo input[startPos..^1]
        input = input.processParenthesis(startPos)
        # i=startPos
        # return input
      if cast[ParenthesesToken](input[i]).higherKind == right:
        input.delete(i)
        input.coalesceSubseq(startPos, i-1)
        return input
    i.inc
  return input

proc sanityCheck(input: LexedOutput) =
  var i = input.low
  while i <= input.high-1:
    let current = input[i]
    let next = input[i+1]
    if (current.kind, next.kind) == (operator, operator):
      raise newComputeError("Two operators in a row (try to use parentheses)", next)
    i.inc

proc compute*(input: LexedOutput): int =
  var input = input
  input.sanityCheck
  input.insert(newParenthesesToken(left), input.low)
  input.add(newParenthesesToken(right))
  input.convertAllToNumbers
  input = input.processParenthesis(input.low)
  return input[0].NumberToken.value


when isMainModule:
  import lexer
  doAssert "8/2".lexer.compute == 4
  doAssert "(0-4+2)+2+3".lexer.compute == 3
  doAssert "2*9".lexer.compute == 18
  doAssert "2*(-9)".lexer.compute == -18
