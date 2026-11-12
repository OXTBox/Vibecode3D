# Session log

Newest first. At the end of each session (`/end-session`), add an entry: what
changed, what was decided, what is broken or unfinished, what's next. Keep each
entry short. Git has the details, so this file holds the *why* and the loose ends.

---

## 2026-11-11: move to Claude Code, local LLM

- **Moved the work to Claude Code in a local project folder**, with a dev-server
  bridge (LIB_DEVSERVER + tools/lc.sh), CLAUDE.md, docs/ and slash commands.
  LIB_DEVSERVER and lc.sh were written in claude.ai. lc.sh was tested against a
  stand-in server only, so the first real run may need fixes.
- **LIB_LLM works** (owner confirmed): async `LLM.Ask` via tsNet, long timeouts,
  Gemma system-prompt folding, a cap on history. It is loaded by the library
  pattern (`Lib.Load`), from LIB_ cards into unsaved library stacks.
- **Stack script version g** = f + the Lib loader + DevServer.Exec/Eval. APP.init
  now calls `Lib.LoadAll`, and starts the dev server in the IDE only.
- **Next:**
  - first live test of the bridge: `ping`, `pull-all`, one `push` round trip;
  - then LLM level recipes for Hunter (docs/level-recipes.md).

## 2026-11-10: rebuild flow, the User group

- `Game.Rebuild` / `Games.Rebuild` delete and recreate game cards. The owner's
  objects are kept in `GAME_ENTITIES[game]["User"]`; the scene snapshot is kept
  in `["GameScripted"]`.
- **Bug fixed:** objects drifted further off on every rebuild, because setting a
  group's rect moves its contents. It used to be done for glow padding.
  - The fix: the "User" group is now card-sized (anchors ATL/ATR/ABL/ABR, margins
    0, lockLoc), and its rect is never set.
  - The owner tested it as a button script first: `0,0,768,696`, nothing moved.
  - Then it was built in (version f): `Entities.UserGroup`, `Entities.GroupUser`,
    `Entities.PutBackChildren`. `Entities.PadForGlow` was removed.
- Threedots menu filled from the stack (`Menu.Threedots.Build`). Glow uses
  blendMode "normal".
- Menus are copied in at runtime from the templates on Edit_Title, Edit_Pause and
  Edit_Options, and removed on closeCard.

## Earlier (2026-11-07 to 11-09), in short

- **Phase 0:** fixed-step game loop.
- **Phase 1:** Mat3 matrix renderer with colour batches and depth bands.
- **Phase 2:** procedural meshes.
- **Phase 3:** entities and batching.
- **Phase 4:** vector look presets.
- **Phase 5:** gameplay systems: collisions, particles, FX, laser.
- **Phase 6:** editor features.
- Games written: Canyon (3D port of "Defensive"), Hunter (FPS), Demo.
- Engine and game split: the stack script is the engine, and each game is a
  `Play.<game>` card whose script is kept in `GAME_CARD_SCRIPTS`.
- HUD layout system (Edit_HUD, the Game_Huds set), audio loaded from
  StackDirectory, Title/Pause/Options menus, and the Report tools.
