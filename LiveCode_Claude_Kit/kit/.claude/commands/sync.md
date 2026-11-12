---
description: Pull every script from the running LiveCode IDE and show what the owner changed
---
1. Run `tools/lc.sh ping`. If it fails, stop and ask the owner to run `APP.init`
   (or `Lib.Load "DEVSERVER"` then `DevServer.Start`) in LiveCode.
2. Run `tools/lc.sh pull-all`.
3. Run `git status --short` and `git diff --stat`. For files that changed, read the
   diff and summarize in plain words what the owner changed in the IDE (new handlers,
   fixes, renamed things). Point out anything that conflicts with docs/livecode-gotchas.md.
4. Read the newest entry of docs/session-log.md and say what was planned next.
Don't edit any file in this command.
