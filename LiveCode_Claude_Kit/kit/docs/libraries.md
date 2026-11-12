# Libraries (`LIB_` cards)

A card named `LIB_<name>` holds a library script, and
`scripts/cards/LIB_<name>.livecodescript` is its file.
- `Lib.Load name` copies the card's script into an unsaved, invisible stack
  `LIB_<name>_SCRIPT` and `start using`s it.
- `Lib.LoadAll` (run from APP.init) loads every LIB_ card.
- `Lib.Unload name` closes it.

The library stack is never saved. The card is the source, so edit the card (or
push the file), and pushing a LIB_ card reloads it.

Rules for library scripts:
- **No GUI references.** No `fld`, `btn` or `grp`. Results go back by `dispatch`
  to a target the caller passes in.
- **No system-message handlers** (openCard, preOpenStack, mouseUp, closeCard...).
  A library sits in every message path and would catch them for every card.
- Script locals belong to the library stack. They are reset when it reloads.
- To call engine handlers from a library, use
  `dispatch "X" to stack (the mainStack of this stack) with ...`.
- Names are prefixed: `LLM.*`, `DevServer.*`.

## LIB_LLM: LM Studio (OpenAI-compatible API)

```
LLM.Init "http://localhost:1234", "gemma-2-2b-it-abliterated"
LLM.SetSystem "You are ..."
put LLM.Ask(text, the long id of this card, "Game.OnLLM") into tId   -- async (tsNet)
-- on that card: on Game.OnLLM pReply, pId, pError
put LLM.AskSync(text) into tReply      -- blocking, long timeout: tools only, not gameplay
LLM.Ping()  LLM.Busy()  LLM.Cancel  LLM.Clear  LLM.Set key,value  LLM.Get(key)
```

- **Settings** (`LLM.Set`):
  - `url`, `model`, `temperature` (0.8);
  - `maxTokens` (256), `maxHistory` (20 messages);
  - `timeoutMS` (300000), `systemAsUser`.
- Gemma's chat template rejects the "system" role, so for gemma models the system
  prompt is put in front of the first user turn.
- **One request at a time.** `LLM.Ask` returns empty while busy.
- **For one-off jobs** (level recipes), run `LLM.Clear` first, so old turns don't
  leak in.
- **Planned:** `LLM.Set "responseFormat", <json>`, which adds `response_format`
  (json_schema) to the request body. LM Studio then forces valid JSON in that
  shape. See `docs/level-recipes.md`.
- **Old names** still work: `LM_Init`, `LM_SendChat` (now sync with the long
  timeout), `LM_SetSystemPrompt`, `LM_ClearHistory`.

## LIB_DEVSERVER: the bridge to this terminal

- **Where it listens:** HTTP on 127.0.0.1 (port 8765). Every request needs the
  header `X-Token`.
- **The token** is new on every start, written with the port to `.lc_devtoken`
  next to the stack file. `tools/lc.sh` reads it.
- **Routes:**
  - `GET /ping`, `GET /list`;
  - `GET|POST /script?target=stack|card:<name>`;
  - `POST /run` (statements), `POST /eval` (expression);
  - `GET /report?filter=`, `POST /lib?name=`.
- **Where code runs:** `/run` and `/eval` run in the STACK script's context
  through `DevServer.Exec` / `DevServer.Eval`, so every engine handler can be reached.
- **Errors:** a `COMPILE ERROR:` or `ERROR:` answer comes back with HTTP 422.
  `catch` errors are LiveCode's numeric error lists: the first number is the
  error code, then line and column.
- **Reloading itself:** pushing `card:LIB_DEVSERVER` restarts it with a new
  token, since lc.sh rereads the file each time. Wait half a second before the
  next call.
- **When it's running:** APP.init starts it only when
  `the environment is "development"`. It runs any code it is sent: development only.
