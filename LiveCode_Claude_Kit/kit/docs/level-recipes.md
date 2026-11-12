# LLM-designed levels (plan, not built yet)

Principle: **the small local model chooses, the engine builds.** Gemma 2B is
good at picking from lists and naming things, and bad at arithmetic, coordinates
and strict syntax. So it never writes LiveCode or world coordinates. It fills in
a small JSON "recipe", and LiveCode validates the recipe and builds the level.

## Recipe (Gem Hunter first)

```json
{
  "name": "The Glass Valley",
  "briefing": "Scouts report amethyst under the eastern ridge. Drones patrol at dusk.",
  "style": "Vectrex",
  "terrain": 3,
  "rocks": [
    {"x": 2, "z": 7, "size": "big",   "gem": "Amethyst"},
    {"x": 6, "z": 3, "size": "small", "gem": "none"}
  ],
  "enemies": {"count": 5, "speed": 2, "wave": "from_above"},
  "gemsToWin": 3
}
```

- x and z are cells on a 10x10 grid (0-9), not world units. The player starts at x=5, z=0.
- The engine turns a cell into world X/Z, takes Y from `Hunter.HeightAt` (remember:
  +Y is down), and maps `size` to "Rock" or "Rock4". It then spawns with
  `Entity.Spawn` and sets collision groups.
- `style` must be one of `View.PresetList()`. Use `terrain` 1-5 for roughness.

## Make invalid output impossible

LM Studio accepts `response_format` with a JSON schema and limits what the model
can generate to that shape. That works even for a 2B model, and it is the biggest
reliability win. Use enums for every word, and minimum/maximum for every number:

```json
{"type":"json_schema","json_schema":{"name":"level","strict":true,"schema":{
 "type":"object","additionalProperties":false,
 "required":["name","briefing","style","terrain","rocks","enemies","gemsToWin"],
 "properties":{
  "name":{"type":"string","maxLength":40},
  "briefing":{"type":"string","maxLength":200},
  "style":{"type":"string","enum":["1983","Arcade","Fast","Vectrex"]},
  "terrain":{"type":"integer","minimum":1,"maximum":5},
  "rocks":{"type":"array","maxItems":20,"items":{"type":"object","additionalProperties":false,
    "required":["x","z","size","gem"],"properties":{
     "x":{"type":"integer","minimum":0,"maximum":9},
     "z":{"type":"integer","minimum":0,"maximum":9},
     "size":{"type":"string","enum":["small","big"]},
     "gem":{"type":"string","enum":["Diamond","Sapphire","Ruby","Emerald","Amethyst","Topaz","none"]}}}},
  "enemies":{"type":"object","additionalProperties":false,"required":["count","speed","wave"],
    "properties":{"count":{"type":"integer","minimum":0,"maximum":12},
     "speed":{"type":"integer","minimum":1,"maximum":5},
     "wave":{"type":"string","enum":["from_above","from_edges","guards"]}}},
  "gemsToWin":{"type":"integer","minimum":1,"maximum":20}}}}}
```

Build the style enum from `View.PresetList()` at request time; the presets may change.

## System prompt (short, with one example: small models copy examples)

> You design levels for a vector-graphics treasure-hunting game. Reply with ONE
> JSON object only. The map is a 10x10 grid (x and z from 0 to 9); the player
> starts at x=5, z=0. Put rocks where a player would want to explore; hide the
> rarest gems far from the start. More enemies and higher speed mean harder.
> Example: {...the recipe above...}

The request carries the variety: "Level 4 of 10. Theme: frozen. Difficulty:
hard. The player struggled with fast enemies last level."

## Handlers to build

- In LIB_LLM: `LLM.Set "responseFormat", json`, which puts the JSON into the
  request body as `"response_format":...`.
- In the stack script or the card: `Level.Request game, levelNo, theme, difficulty`
  does `LLM.Clear` then `LLM.Ask`, with temperature about 0.8 and `maxTokens` about 600.
- `Level.OnRecipe reply,id,error` parses and validates the reply. It:
  - limits every number to its range;
  - drops unknown kinds;
  - caps the counts;
  - makes sure there are at least `gemsToWin` gems;
  - if the reply won't parse, asks once more, quoting the error;
  - saves the result to `GAME_ENTITIES[game]["Levels"][n]`.
- `Hunter.BuildFromRecipe tA` maps the recipe onto the existing
  `Hunter.SpawnRocks`, `Hunter.SpawnEnemy` and `View.UsePreset`.
- Request the NEXT level in the background while the current one is played. If
  it isn't ready in time, fall back to the random generator.

## Cheap testing from the terminal

`tools/lc.sh llm '<prompt>'` asks LM Studio directly. Use it to generate dozens
of recipes and run them through the validator, without the owner having to play
each one.
