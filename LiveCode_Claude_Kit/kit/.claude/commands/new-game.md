---
description: Create a new Play.<Name> game card from the skeleton
argument-hint: <Name> [one-line idea]
---
Read docs/game-cards.md first. Then, for the game in "$ARGUMENTS":

1. Write `scripts/cards/Play.<Name>.livecodescript` from the skeleton. Fill the header
   (title, controls, rules) from the idea, and prefix every handler and mesh with the name.
2. `tools/lc.sh run 'Game.Rebuild "<Name>", false'`. This creates the card.
3. `tools/lc.sh push scripts/cards/Play.<Name>.livecodescript` (fix any compile errors).
4. `tools/lc.sh run 'Menu.Threedots.Build'`
5. `/checkpoint new game <Name>`. Then ask the owner to play it from the Game menu.
