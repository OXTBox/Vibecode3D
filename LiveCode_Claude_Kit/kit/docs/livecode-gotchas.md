# LiveCode 9.6.3 gotchas

Every item here cost a debugging round on this project. Check new code against them.
The `livecode-reviewer` agent uses this file.

## Syntax traps

- `does not begin with` does not exist. Use `not (x begins with y)`, or
  `char 1 to 5 of x is not "Play."`.
- A one-line `if c then x` followed by an `else` line takes that else as its own.
  Mixing one-line and block `if` around an `else` gives silently wrong logic. Use
  block form whenever there is an else.
- Reserved / built-in names you can't use for variables, properties or params:
  - `engine` (engine graphics carry the custom property `Entity` = true);
  - `pi`, which is case-insensitive, so `pI` can't be a parameter (use `pIter`);
  - `size`, `mode`.
- A missing `end if` can hide behind an extra one elsewhere. When a switch/case
  behaves strangely, count the ifs.
- Watch for typos in keywords (`Fnction`): the compiler often reports a line
  far from the real mistake.
- Function vs command: a handler declared `function` must be called as `X()`
  inside an expression, a command as a statement. Calling one as the other is
  "can't find handler".
- `dispatch` sets `it` to handled/unhandled/passed; the return value is in
  `the result`. `dispatch function "F" to obj with p` for functions.

## Objects and groups

- **Setting a group's rect MOVES its contents.** It doesn't just resize the frame.
  Never set the rect of a group holding placed objects. If you must, put each
  child's rect back afterwards (see `Entities.PutBackChildren`).
- The "User" group on game cards is card-sized: anchors ATL/ATR/ABL/ABR, margins
  0, lockLoc true (`Entities.UserGroup`). Capture skips the anchors.
- A group can only be deleted with `cantDelete` false. Delete groups from
  `closeCard`, which is where `Menu.Purge` runs; deleting during other handlers
  errors.
- Only top-level groups can be `place`d. A group nested in another can't be
  placed: AudioPlayers lives INSIDE the Viewport (a background group).
- Background groups (`backgroundBehavior` true) appear on new cards
  automatically. Don't capture or copy them as user objects.
- `relayer control id N to front of group "G"` moves a control into a group;
  `... to front of this card` moves it out. Save and restore its rect around it.
- `create graphic "X" in group "G"` creates inside a group.
- `the owner of x` gives the direct parent. Use it to tell direct children from
  grandchildren when walking a group's controls.

## Properties and custom properties

- Custom property names must start with a letter: "1983" -> "Preset_1983".
- **Always set the customPropertySet back to empty** after using a set, or later
  code reads the wrong set.
- Array custom properties held in a set:
  `do "set the" && tName && "of tObj to tV"` / `do "put the" && tName && "of tObj into tV"`.
- `the keys of the outerGlow of x` can't be inline: `put the outerGlow of x into
  tFX`, then `the keys of tFX`.
- Graphic effects (outerGlow, dropShadow): set one key at a time. Use
  blendMode "normal": colorDodge is invisible on a black background.
- `effective foregroundColor` can be a colour name, not an RGB triple. Convert
  with `Color.ToRGB`.
- Glow is cropped at the edge of its group's rect (hence the card-sized User group).

## Message path and scripts

- Card scripts can't see stack-script **locals**. Share through globals or handlers.
- A library stack (`start using`) is in EVERY message path, so it catches openCard,
  mouseUp etc. for every card: never put system-message handlers in LIB_ cards.
- Handlers in a library stack can't reach the main stack's script by plain calls.
  Use `dispatch ... to stack (the mainStack of this stack)` (see `DevServer.Exec`).
- `set the script of x` reports compile errors in `the result`. A library can't
  replace its own script while one of its handlers is running: `send` it later.
- Setting the stack script resets its script locals: run `APP.init` after.
- `create stack` makes the new stack the defaultStack: save and restore it.
- Going to a card to prepare it: `lock screen` + `lock messages`, then go back.
  Without that, handlers run on the wrong card, as Game.Prepare.Card once did.

## Timing, network, input

- `post`/`get url` block, and time out after the `socketTimeoutInterval` (10 s
  default). Use tsNet async (`tsNetPost` + callback) for slow servers, as
  LIB_LLM does.
- Text to and from the network: `textEncode(x,"UTF-8")` / `textDecode(x,"UTF-8")`.
- `filter` keeps or drops whole LINES. Use `replaceText` to strip characters.
- Duplicate handler names in one script: the second copy is a bug waiting to happen.
- FPS mouse look: screenMouseLoc / lockCursor. Only grab the pointer while this
  stack is the topStack (the IDE or an error dialog must get it back).
- Escape key: debounce it (the engine keeps a 1 s expiry, sEscMS).

## Performance notes

- The renderer draws in colour batches (`Batch_<colour>`) with depth bands
  (`_d2.._d4`). Avoid one graphic per object.
- Destroy effects: pooled dashed graphics (`Derez1..8`). Don't create graphics per
  frame.
- `lock screen` around anything that touches many controls.
