import lexedOutput
import token
from compute import convertAllToNumbers
import tables

const 
  operatorPrecedence = {
    star: 3,
    slash: 3,
    plus: 2,
    minus: 2
  }.toTable

  operatorChars = [
      (operatorKind.minus, '-'),
      (operatorKind.plus, '+'),
      (operatorKind.star, '*'),
      (operatorKind.slash, '/')
    ].toTable

proc rpnToString(queue: LexedOutput): string =
  for token in queue:
    if token of NumberToken:
      result &= $token.NumberToken.value
    elif token of OperatorToken:
      result &= operatorChars[token.OperatorToken.higherkind]
    result &= " "
  result = result[0..^2]

proc shunting_yard*(input: LexedOutput): string =
  var input = input
  input.convertAllToNumbers

  var i = input.low
  var queue: LexedOutput
  var stack: LexedOutput
  while i <= input.high:
    let token = input[i]
    if token.kind == number:
      queue.add(token)
    if token.kind == operator:
      while stack.len > 0 and stack[stack.high] of OperatorToken and 
        operatorPrecedence[stack[stack.high].OperatorToken.higherKind] > 
        operatorPrecedence[token.OperatorToken.higherKind]:
          queue.add(stack.pop)
      stack.add(token)
    if token.kind == parenthesis and token.ParenthesesToken.higherKind == left:
      stack.add(token)
    if token.kind == parenthesis and token.ParenthesesToken.higherKind == right:
      while stack[stack.high].kind != parenthesis and 
        stack[stack.high].rawValue != "(":
        queue.add(stack.pop)
      discard stack.pop
    i.inc
  while stack.len > 0 and stack[stack.high].kind == operator:
    queue.add(stack.pop)
  return queue.rpnToString

when isMainModule:
  import lexer

  doAssert "12+2*(3*4+10/5)".lexer.shunting_yard == "12 2 3 4 * 10 5 / + * +"
  doAssert "5+(6*7+7*5)/(9+1*3)".lexer.shunting_yard == "5 6 7 * 7 5 * + 9 1 3 * + / +"
  doAssert "3/6+4*3-2/4/3*2".lexer.shunting_yard == "3 6 / 4 3 * 2 4 3 2 * / / - +"