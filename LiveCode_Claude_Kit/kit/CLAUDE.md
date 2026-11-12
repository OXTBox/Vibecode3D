# Vector 3D game engine in LiveCode 9.6.3

A primitive 3D engine/editor written entirely in LiveCode script, drawing 1983
Star Wars arcade / Vectrex style wireframes with LiveCode line graphics.
- **Games:**
  - Canyon: a 3D canyon run, ported from the owner's 2D game "Defensive".
  - Hunter: an FPS gem hunt, "Pac-man meets Halo".
  - Demo.
- **Local LLM:** LM Studio, used through LIB_LLM.
- **Who does what:** the owner develops in the LiveCode IDE and plays the games.
  Claude writes and debugs engine and game code from this terminal.

## Read on demand (don't load everything every session)

| When you are...                               | read                        |
|-----------------------------------------------|-----------------------------|
| writing any LiveCode at all                   | `docs/livecode-gotchas.md`  |
| calling or changing engine handlers           | `docs/engine-api.md`        |
| writing or fixing a `Play.<game>` card        | `docs/game-cards.md`        |
| touching LIB_ cards, LLM or the dev server    | `docs/libraries.md`         |
| working on LLM-designed levels                | `docs/level-recipes.md`     |
| starting a session (what happened last time)  | `docs/session-log.md` (newest entries first) |

Slash commands in `.claude/commands/`: `/sync`, `/push <file>`, `/test-game <game>`,
`/new-game <Name>`, `/checkpoint <message>`, `/end-session`. The agent
`livecode-reviewer` checks a diff against the gotchas before a big push.

## The loop

LiveCode runs with `LIB_DEVSERVER` started (APP.init starts it in the IDE).
`tools/lc.sh` talks to it. The scripts live as text files:
`scripts/stack.livecodescript` is the ENGINE (target `stack`).
`scripts/cards/<card>.livecodescript` holds the card scripts (target `card:<card>`).

1. **`tools/lc.sh pull-all` before editing anything**, then `git diff`. The
   owner edits in the IDE too, so the running stack is the truth, not the files.
   Read their changes and keep them. If tools/lc.sh can't connect, ask the owner
   to run `APP.init` (or `DevServer.Start`). Don't edit stale files.
2. **Targeted edits only.** Never regenerate a whole script from memory: the
   stack script is ~8000 lines and holds the owner's own fixes.
3. `tools/lc.sh push <file>` -> `OK` or `COMPILE ERROR: line,col ...`. Fix and
   push again until OK. Play./Edit_ cards are saved to their property set
   automatically; LIB_ cards are reloaded as libraries.
4. Test with `run`, `eval` and `report`. Pushing the stack script resets its
   script locals, so `tools/lc.sh run APP.init` afterwards.
5. Commit when something works (`/checkpoint`).

The owner judges looks, feel and frame rate: ask them to play it. When a change
to the stack script is risky, offer a standalone **button script** to try first.
They like that. Explain changes in plain words; they read everything.

## Never do

- Go to or fall back to a game card on exit/error: always the `Developer` card.
- Set the rect of a group holding objects (it MOVES the contents).
- Put GUI references or system-message handlers (openCard, mouseUp...) in a LIB_ card.
- Write `does not begin with`, or use `engine`, `pi`, `size` or `mode` as names.
- Leave a customPropertySet set: always set it back to empty.
- Start the dev server in a standalone, or commit `.lc_devtoken`.

## Stack at a glance

- **Cards:**
  - `Developer`: home base.
  - `Title`: main menu.
  - `Play.<game>`: one per game, with the Viewport background group, a card-sized
    group "User" and the script from `GAME_CARD_SCRIPTS`.
  - `Edit_*`: editors and menu templates.
  - `LIB_*`: libraries.
- **Property sets on the main stack:**
  - `GAME_CARD_SCRIPTS`, `EDIT_CARD_SCRIPTS`: card scripts;
  - `GAME_ENTITIES[game]["GameScripted"|"User"]`: kept through rebuilds;
  - `ViewPresets`, `Game_Huds`, `Procedural_Geometry`.
- **Rebuild:** `Game.Rebuild game[,goThere]` deletes and recreates a game card.
- **World axes:** +X right, **+Y DOWN** (up is -Y), +Z forward. Fixed step of 33 ms.
