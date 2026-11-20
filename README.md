# Vibecode3D

The owner's 3D engine and editor written entirely in LiveCode script: vector wireframes in
the style of the 1983 Star Wars arcade and the Vectrex, drawn with LiveCode graphics.
Games: Canyon, Hunter, Demo. Contains **LIB_LLM** (card `LIB_LLM`): an async LM Studio /
OpenAI-style client for local models.

| Path | What it is |
|---|---|
| `3DSCENE_v111092026d_LIB_LLM_548AM.livecode` | The engine stack (2026-11-09 build) |
| `Vibecode3D_STACK_SCRIPT_11112026g.txt` | Its stack script as text (about 8,000 lines) |
| `XTJSON/` | A full harvest of the stack (LIB_XTJSON format): cards, controls, scripts as JSON and text |
| `xtjson_rebuilder.livecode` | The round-trip launcher stack used on this harvest |
| `LiveCode_Claude_Kit/` | The working kit for Claude Code on this engine: `LIB_DEVSERVER` + `tools/lc.sh` (the origin of LIB_MCP) and this engine's `CLAUDE.md` |

Working notes for the engine (world axes +Y down, game card hooks, rebuild of game
cards, LiveCode 9.6.3 pitfalls) are in `LiveCode_Claude_Kit/kit/CLAUDE.md`.

Part of the family of separate libraries listed in `~/projects/LIB_MCP/README.md`.
Repository started 2026-11-11 with the files as they were; nothing was moved or changed.

## Licence

GPL-3.0 (see `LICENSE`), because the xTalk work here is built on the GPL-licensed LiveCode Community 9 engine. Copyright (c) 2026 xAction.
