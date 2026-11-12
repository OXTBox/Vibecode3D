---
description: Rebuild a game card and check it with a report
argument-hint: <game name, e.g. Hunter>
---
1. `tools/lc.sh run 'Game.Rebuild "$ARGUMENTS", false'`
2. `tools/lc.sh report 'Play.$ARGUMENTS'`. Check that the card exists, that it has one
   Viewport, that the User group is `0,0,<card width>,<card height>`, and that no
   duplicate menu groups were left behind.
3. `tools/lc.sh eval 'the number of lines of the keys of gObjectTransforms'` is a
   rough count of the scene (the IDE only knows globals declared in the stack script).
4. Summarize. Then ask the owner to choose the game from the threedots menu, play it,
   and tell you how it looks and feels: you can't see the screen.
