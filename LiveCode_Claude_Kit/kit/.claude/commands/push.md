---
description: Push a script file to LiveCode and fix compile errors until it compiles
argument-hint: <scripts/... file>
---
Push `$ARGUMENTS` to the running IDE with `tools/lc.sh push $ARGUMENTS`.

- If the answer is `OK`, report it. If the file is the stack script, run
  `tools/lc.sh run APP.init` afterwards (its script locals were reset) and report the result.
- If it is a `COMPILE ERROR`, the first numbers are the error code, then line and column.
  Read the file around that line, fix the cause (check docs/livecode-gotchas.md:
  one-line if/else, reserved words, missing end if, function called as a command),
  and push again. Stop after 5 rounds and show the owner the error and what you tried.
- Never "fix" an error by deleting the owner's code.
