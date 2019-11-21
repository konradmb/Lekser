#[ 
  gramatyka <T,N,S,P>
  T = {0,1,2,3,4,5,6,7,8,9,+,-,/,*,(,), }
  N = {S,B,L,O,N}
  S = {S}
  P:
  S → B // Białe znaki
  S → L // Liczba
  S → O // Operator - symbol działania
  S → N // Nawias
  B → ' ' | ' 'B // Białe znaki - spacja
  O → -|+|*|/
  N → (|)
  L → 0|C|CL
  C → 1|2|3|4|5|6|7|8|9 
]#
type
  tokenKind* = enum
    digit,  # C
    number, # L
    parenthesis,
    operator,
    whiteSpace,
    unknown

  operatorKind* = enum
    plus,
    minus,
    star,
    slash
    #[ addition,
    subtraction,
    multiplication,
    division ]#

  parenthesesKind* = enum
    left,
    right

type
  Token* = ref object of RootObj
    #[ case kind*: tokenKind
      of whiteSpace:
        discard
      of operator:
        operatorKind: operatorKind
      of parenthesis:
        parenthesisKind: parenthesisKind
      of digit:
        digitValue*: uint
      of number:
        numberValue*: int ]#
    kind: tokenKind
    rawValue*: string
    position*: int

proc kind*(token: Token): tokenKind =
  if token == nil:
    return unknown
  token.kind

type
  WhitespaceToken* = ref object of Token
  OperatorToken* = ref object of Token
    higherKind: operatorKind
  ParenthesesToken* = ref object of Token
    higherKind: parenthesesKind
  DigitToken* = ref object of Token
    value: uint
  NumberToken* = ref object of Token
    value: int

proc higherKind*(token: OperatorToken): operatorKind =
  token.higherKind
proc higherKind*(token: ParenthesesToken): parenthesesKind =
  token.higherKind
proc value*(token: NumberToken): int =
  token.value
proc value*(token: DigitToken): uint =
  token.value

template stringifyTokens(input) = return $input[]
method `$`*(input: Token): string {.base.} = 
  when not defined(release):
    echo "Token $ base called " & repr input[]
  input.stringifyTokens
method `$`*(input: WhitespaceToken): string = input.stringifyTokens
method `$`*(input: OperatorToken): string = input.stringifyTokens
method `$`*(input: ParenthesesToken): string = input.stringifyTokens
method `$`*(input: DigitToken): string = input.stringifyTokens
method `$`*(input: NumberToken): string = input.stringifyTokens


# method `$`*(input: DigitToken): string =
#   $input[]

proc newWhitespaceToken*(): WhiteSpaceToken =
  WhitespaceToken(kind: tokenKind.whiteSpace)

proc newOperatorToken*(higherKind: operatorKind): OperatorToken =
  OperatorToken(kind: tokenKind.operator, higherKind: higherKind)

proc newParenthesesToken*(higherKind: parenthesesKind): ParenthesesToken =
  ParenthesesToken(kind: tokenKind.parenthesis, higherKind: higherKind)

proc newDigitToken*(value: uint): DigitToken =
  DigitToken(kind: tokenKind.digit, value: value)

proc newNumberToken*(value: int): NumberToken =
  NumberToken(kind: tokenKind.number, value: value)

template joinTokensBase(newTok, a, b) =
  result = newTok
  result.rawValue = a.rawValue & b.rawValue
  result.position = max(a.position, b.position)

method joinTokens*(a, b: Token): Token {.base.} =
  quit "joinTokens base called " & repr(a) & "\n" & repr(b)
method joinTokens*(a, b: WhitespaceToken): WhitespaceToken =
  result = newWhitespaceToken()
  result.rawValue = a.rawValue & b.rawValue
  result.position = max(a.position, b.position)
template joinTokensNumber(a, b) =
  result.value = a.value.int * 10 + b.value.int
method joinTokens*(a, b: DigitToken): NumberToken =
  joinTokensBase(newNumberToken(0), a, b)
  joinTokensNumber(a, b)
method joinTokens*(a: NumberToken, b: DigitToken): NumberToken =
  joinTokensBase(newNumberToken(0), a, b)
  joinTokensNumber(a, b)



# proc `$`*(input: Token): string =
#   result &= fmt""
#   result &= fmt"rawValue: {input.rawValue}, pos: {input.position})"
import tables
const
  digitChars* = ['1', '2', '3', '4', '5', '6', '7', '8', '9']
  numberChars* = ['0']
  whitespaceChars* = [' ']
  whitespaceNonterminals* = [[tokenKind.whiteSpace, tokenKind.whiteSpace]]
  digitNonterminals* = [[tokenKind.digit, tokenKind.digit],
                      [tokenKind.number, tokenKind.digit]]
  operatorChars* =
    [
      ('-', operatorKind.minus),
      ('+', operatorKind.plus),
      ('*', operatorKind.star),
      ('/', operatorKind.slash)
    ].toTable
  parenthesesChars* =
    {
    '(': parenthesesKind.left,
    ')': parenthesesKind.right
    }.toTable

when(isMainModule):
  var a = Token(kind: tokenKind.whiteSpace)

  import sequtils
  const digits = (1..9).toSeq
  var sd = 5
  case sd:
    of digits:
      echo "ghghghg"
    else:
      echo ":"

  echo Token()[]
