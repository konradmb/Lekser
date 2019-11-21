import unicode, tables, strutils
import token, lexedOutput


proc tokenRecognizer(i: int, input: char): Token =
  case input:
    of whitespaceChars:
      result = newWhitespaceToken()
    of digitChars:
      result = newDigitToken(parseUInt($input))
    of numberChars:
      result = newDigitToken(parseUInt($input))
    elif input in operatorChars:
      result = newOperatorToken(operatorChars[input])
    elif input in parenthesesChars:
      result = newParenthesesToken(parenthesesChars[input])
    else:
      raise newLexingError("Unknown character: "&input, Token(rawValue: $input, position: i))

# proc joinWhitespace(tokens: var LexedOutput, position:int) =
#   var i = position
#   while tokens[i].kind == tokenKind.whiteSpace and i+1 < tokens.high:
#     echo i," " , tokens.high
#     echo tokens[i]
#     if tokens[i].kind == tokenKind.whiteSpace and tokens[i+1].kind == tokenKind.whiteSpace:
#       tokens[i+1] = joinTokens(tokens[i], tokens[i+1])
#       tokens.delete(i)

template joinTokensAndDelete(input, i: untyped, typedescA:typedesc, typedescB:typedesc) =
  input[i] = joinTokens(cast[typedescA](input[i]),cast[typedescB](input[i+1]))
  input.delete(i+1)

proc lookahead(input: var LexedOutput) =
  var i = input.low
  while i+1 <= input.high:
    let currentKind = input[i].kind
    let nextKind = input[i+1].kind
    let kinds = [currentKind, nextKind]
    # echo input[i], " ", input[i+1]
    if kinds == digitNonterminals[0]:
      input.joinTokensAndDelete(i, DigitToken, DigitToken)
    elif kinds == digitNonterminals[1]:
      input.joinTokensAndDelete(i, NumberToken, DigitToken)
    # elif kinds == [tokenKind.number, tokenKind.digit]:
    #   input.joinTokensAndDelete(i, DigitToken, NumberToken)
    elif kinds in whitespaceNonterminals:
      input.joinTokensAndDelete(i, WhitespaceToken, WhitespaceToken)
    else:
      i.inc

proc sanityCheck(input: LexedOutput) =
  var i = input.low
  while i <= input.high:
    let current = input[i]
    # let next = input[i+1]
    if current.rawValue.startsWith("0") and current.rawValue.len>1:
      raise newLexingError("Digit with preceding 0", current)
    i.inc
 
proc lexer*(input: string): LexedOutput =
  var prelexed: LexedOutput
  for i, character in input:
    let characterStr = $character
    var newToken = tokenRecognizer(i, character)

    newToken.rawValue = characterStr
    newToken.position = i

    prelexed.add(newToken)
  prelexed.lookahead()
  prelexed.sanityCheck()
  
  return prelexed

when isMainModule:
  # echo lexer("123 +2*(3)")
  # echo lexer("0123456   ")
  # echo "01".lexer
  try:  
    echo lexer("567")
  except LexingError:
    let e = cast[ref LexingError](getCurrentException())
    echo "Lexing error: " & e.msg & "\n\tCause: " & $e.cause
  doAssert $lexer("6") == "(value: 6, kind: digit, rawValue: \"6\", position: 0)\n"
  doAssert $lexer("4242420") == "(value: 4242420, kind: number, rawValue: \"4242420\", position: 6)\n"


