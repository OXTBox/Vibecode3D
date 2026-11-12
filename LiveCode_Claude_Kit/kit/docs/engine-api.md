# Engine API (stack script)

A map, not the full list. For exact signatures, search the source:
`grep -nE "^(on|function|command) Name" scripts/stack.livecodescript`.
Section banners in the source look like `## ------------...---- NAME`.

## Coordinates and loop

- World: +X right, **+Y DOWN** (up is -Y), +Z away/forward at yaw 0.
- Fixed step: `kStepMS` = 33, so about 30 updates a second.
  - `game.loop.start`, `game.loop.tick`, `game.loop.stop` run the clock;
    `sLoopActive` says whether it is running.
  - Each step: `game.update` (which dispatches `Game.OnUpdate` to the card),
    then `game.render`.
- `Engine.Info(key)` returns e.g. "stepMS". `Engine.ResetCamera`, `Engine.SetCam`.
- Globals:
  - camera: `gCameraYaw`, `gCameraPitch`;
  - objects: `gObjectTransforms[key]`, `gSceneObjects` (lines of
    "Mesh Key [Graphic]");
  - meshes: `gMeshCache[name]`;
  - view: `CenterX`, `CenterY`, `gViewLeft/Top/Right/Bottom`;
  - flags: `bPaused`, `bPlaying`, `bDeveloper`.

## Math and rendering

- `Mat3.RotZYX`, `Mat3.Camera`, `Mat3.Mul`, `Mat3.Apply`. `Xform.Object` returns 12 items.
- `Render.FrameMatrices`, `Render.BeginFrame`, `RenderMeshInto` (with depth bands).
- Picking:
  - `ScreenToCameraRay x,y` returns a unit ray;
  - `RayCastScene(gSceneObjects, rx,ry,rz)` returns "dist key ...";
  - `RayPolygonHit`.

## Meshes

A mesh is an array:
- `count`, plus `vx[i]`, `vy[i]`, `vz[i]`;
- `faces`: one n-gon per line, vertex indices separated by spaces, no triangulation;
- `lines`: optional wire-only edges, "a b" per line.

`Mesh.Finalize` adds `ea`/`eb`/`edgeCount` and `radius`.
- Building by hand: `Mesh.New`, `Mesh.AddVertex @m,x,y,z`, `Mesh.AddFace @m,indices`,
  `Mesh.AddLine @m,a,b`.
- Generators:
  - `MeshBox w,h,d`
  - `MeshPrism sides,r,h`, `MeshPyramid sides,r,h`
  - `MeshLathe profile,sides`, `MeshSphere r,rings,sides`
  - `MeshLoft outlineA,yA,outlineB,yB`, `MeshExtrude outline,depth`
  - `MeshGrid cols,rows,spacing`
- Outlines take one point per line, or `"x,y|x,y|..."`.
- `Mesh.Transform(m,rx,ry,rz,tx,ty,tz,scale)`, `Mesh.Merge(a,b)`.
- `Mesh.Define "Name", mesh` finalizes and caches. `Mesh.Get(name)`,
  `Mesh.Invalidate [name]`. The old stack-stored meshes (Cube, Cylinder, Cone,
  Imported) are built by `Mesh.Build`.

## Scene objects

- Instances: `put Entity.Spawn(mesh,x,y,z,colour) into tId`, keyed "Mesh_N".
  `Entity.Kill tId`, `Entity.Count(mesh)`.
- An object with its own graphic: `Scene.AddObject mesh,graphic,x,y,z,colour`.
- `Scene.Register`, `Scene.Remove key`, `Scene.Has(key)`, `Scene.ClearAll`.
- Movement:
  - placing: `SetObjectPosition key,x,y,z`, `GetObjectPosition(key,axis)`,
    `SetObjectRotation`, `SetObjectRotationSpeed`;
  - velocity: `SetObjectVelocity`, `SetObjectLocalVelocity`,
    `SetObjectLocalAcceleration`, `SetObjectLocalBrake`, `SetObjectMaxWorldSpeed`;
  - other: `Scene.SetBob key,amp,roll,speed`, `Scene.SetBounds key,bounds`.

## Collisions, weapons, effects

- `Collision.SetGroup key,group[,radius]`, `Collision.AddRule groupA,groupB`,
  `Collision.ClearRules`. Hits are dispatched to the card as `Collision.Hit a,b`.
- `Weapon.FireAt x,y` is a hitscan laser from screen point x,y. It returns the hit
  key and dispatches `Game.OnKill key,x,y,z`.
- Effects: `FX.Destroy key`, `FX.Derez` (pooled dashes), `FX.Sparks x,y,z,n,colour`.
- Particles: `Particles.Clear`, `Particles.RemoveAt`.

## HUD, look, sound, UI

- HUD (vector font): `HUD.Set name,text,x,y,size`, `HUD.Remove name`, `HUD.Clear`.
  Layouts per game come from the `Edit_HUD` card: `HUD.ApplyToCard game`,
  `HUD.Layout.NewGame`, `HUD.Strip`.
- Look presets (ViewPresets set):
  - `View.UsePreset name`, `View.SavePreset`, `View.Set key,value`, `View.Toggle`,
    `View.Apply`;
  - `View.PresetList()`, `View.PresetKey()`.
- Audio:
  - `Audio.Init`, `Sound.Play name`, music;
  - the players are in group "AudioPlayers" inside the Viewport;
  - files come from StackDirectory.
- Messages: `UI.Message text` (graphic "Message"), `UI.update.status.display` (graphic "Status").
- Diagnostics: `Report.Compact([cardFilter])` gives a text summary of cards, groups,
  sets and templates.

## Games, cards, menus

- Game flow: `Game.Select name`, `Game.Current()`, `Game.Play`,
  `Game.Prepare.Card [name]`, `Game.Exit` (always to Developer), `Game.Pause`.
- Rebuilding:
  - `Game.Rebuild name[,goThere]` deletes and recreates a game card;
  - `Games.Rebuild [list]` does it for several games;
  - `Games.Fix` repairs cards.
- Card scripts: `save.card.script.to.set card`,
  `load.card.script.from.set card[,dest]`, `Card.ScriptSet(card)`.
- Kept through rebuilds:
  - `Entities.CaptureUser(card)`, `Entities.RestoreUser array`;
  - `Entities.UserGroup()`, `Entities.GroupUser [skip]`;
  - `Entities.Save game,sub,array`, `Entities.Load(game[,sub])`, `Entities.SnapshotScene()`.
- Viewport: `Viewport.Ensure`, `Viewport.Clean`, `Viewport.IsEngineGraphic(ref)`,
  `Viewport.AdoptFromEditCard`.
- Menus:
  - `Menu.Open name`, `Menu.Close`, `Menu.CloseAll`, `Menu.Purge`;
  - `Menu.Info`, `Menu.Available`;
  - `Menu.Threedots.Build` refills the threedots menu.
- Libraries: `Lib.Load name`, `Lib.LoadAll`, `Lib.Unload name`.
- Dev server hooks: `DevServer.Exec code`, `DevServer.Eval(expr)`.
- Startup: `APP.init`.
