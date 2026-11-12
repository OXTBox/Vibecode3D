---
description: Commit the current working state with git
argument-hint: <short message>
---
1. `tools/lc.sh pull-all`, so the files match the IDE (the owner may have changed
   things since your last push).
2. `git add -A`, then `git commit -m "$ARGUMENTS"`. Add a body line listing the
   scripts that changed.
3. Report the commit hash and the files in one line.
