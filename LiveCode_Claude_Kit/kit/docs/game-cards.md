# Game cards (`Play.<game>`)

Each game is one card, `Play.<game>`. It has:
- the Viewport background group, which arrives automatically;
- the card-sized group "User", holding the owner's own objects;
- a script stored in `GAME_CARD_SCRIPTS[<game>]`. The file is
  `scripts/cards/Play.<game>.livecodescript`.

The engine owns the loop, the rendering and the menus. The card only answers hooks.

## Hooks the engine dispatches to the card

| hook                         | when                                                   |
|------------------------------|--------------------------------------------------------|
| `Game.OnStart`               | game card prepared / game started: build the world     |
| `Game.OnUpdate`              | every fixed step (33 ms) while playing                  |
| `Game.OnClick x,y,button`    | mouse click in the Viewport (button 3 = right)          |
| `Game.OnKill key,x,y,z`      | `Weapon.FireAt` destroyed something                     |
| `Game.OnPause` / `Game.OnResume` | pause menu opened / closed: release / retake mouse  |
| `Game.OnStop`                | leaving the game: release the mouse, remove own HUD     |
| `Collision.Hit a,b`          | a collision rule fired                                  |

## Rules

- **Game.OnStart starts clean:** `Engine.ResetCamera`, `Scene.ClearAll`,
  `Particles.Clear`, `HUD.Clear`, `Collision.ClearRules`. Then define meshes,
  spawn, set rules, and draw the HUD.
- Read the step length with `Engine.Info("stepMS")`; don't hard-code 33.
- **Prefix every handler, mesh and HUD name with the game name:** `Hunter.Move`,
  `"HEnemy1"`, `"Gem.Ruby"`. All games share one stack-wide message path.
- **Card state lives in script locals (`s...`).** Engine flags are globals:
  `bPaused`, `bPlaying`. Declare the engine globals you use at the top.
- No `openCard` logic for gameplay; the engine calls `Game.OnStart`. Hiding the
  owner's editor groups in openCard is fine.
- Escape and pausing are handled by the engine. Never `go` to another card from
  game code: call `Game.Exit`, which always returns to Developer.
- The header comment block holds the game's title, controls and rules. The owner
  reads it.

## Making a new game (`/new-game Name`)

1. Write `scripts/cards/Play.Name.livecodescript` from the skeleton below.
2. `tools/lc.sh run 'Game.Rebuild "Name", false'` creates the card. The script set
   is still empty at that point, so the card starts blank.
3. `tools/lc.sh push scripts/cards/Play.Name.livecodescript` installs the script
   and saves it to GAME_CARD_SCRIPTS.
4. `tools/lc.sh run 'Menu.Threedots.Build'` adds it to the Game menu.
5. Ask the owner to pick it from the menu and play.

## Skeleton

```livecode
######################################################################################
## CARD SCRIPT: "Play.Name"   TITLE  (date)
## One paragraph: what the game is.
## CONTROLS ...
## RULES ...
######################################################################################

global gObjectTransforms, gSceneObjects
global gCameraYaw, gCameraPitch
global CenterX, CenterY
global bPaused, bPlaying

local sStepMS = 33, sTicks = 0, sScore = 0

on Game.OnStart
   Engine.ResetCamera
   put Engine.Info("stepMS") into sStepMS
   Scene.ClearAll
   Particles.Clear
   HUD.Clear
   Collision.ClearRules
   Name.MakeMeshes
   put 0 into sTicks
   put 0 into sScore
   -- spawn things, add collision rules...
   HUD.Set "score","SCORE 0",20,20,14
end Game.OnStart

on Game.OnUpdate
   add 1 to sTicks
end Game.OnUpdate

on Game.OnClick pX,pY,pButton
   Weapon.FireAt pX,pY
end Game.OnClick

on Game.OnKill pKey,pX,pY,pZ
   add 10 to sScore
   HUD.Set "score","SCORE" && sScore,20,20,14
end Game.OnKill

on Game.OnPause
end Game.OnPause

on Game.OnResume
end Game.OnResume

on Game.OnStop
end Game.OnStop

on Collision.Hit pA,pB
end Collision.Hit

on Name.MakeMeshes
   Mesh.Define "NameShip", MeshPyramid(4,20,40)
end Name.MakeMeshes
```

## Existing games, for reference

- **Canyon** (`Play.Canyon`): a 3D canyon run ported from the owner's 2D
  "Defensive". Lasers, enemy waves, Derez effects.
- **Hunter** (`Play.Hunter`): first person on rolling terrain (`Hunter.HeightAt`).
  Rocks hide gems (`Gem.Diamond/Sapphire/Ruby/Emerald/Amethyst/Topaz`). Enemies
  `HEnemy1..n` come from above. Shields recharge like Halo. 12-shot clip, R reloads.
  Mouse look holds the pointer at the centre.
- **Demo** (`Play.Demo`): engine showcase.
