import lexer, lexedOutput, token, compute, strformat, shunting_yard
import os

proc main() =
  let cmdLine = commandLineParams()
  for i in cmdLine:
    try:  
      echo fmt"{i} = {i.lexer.compute}"
      echo fmt"RPN: {i.lexer.shunting_yard}"
    except LexingError:
      let e = cast[ref LexingError](getCurrentException())
      echo "Lexing error: " & e.msg & "\n\tCause: " & $e.cause
    except ComputeError:
      let e = cast[ref LexingError](getCurrentException())
      echo "Compute error: " & e.msg & "\n\tCause: " & $e.cause
    except DivByZeroError:
      let e = getCurrentException()
      echo "Compute error: " & e.msg
    finally:
      echo()

main()