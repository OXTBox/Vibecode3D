######################################################################################
## CARD SCRIPT: "Play.CullingDemo"   HIDING DEMO  (11 18 2026)
## Shows the engine's hiding switch, gCullMode: a tower, a wall, and boxes, cones and
## columns around them on a floor grid, with the camera circling. Pure xTalk math: lines
## that cannot be seen are simply not drawn.
## CONTROLS  0: everything shows through (the engine as it always was)
##           1: back faces hidden (each solid loses its own far side)
##           2: and whole objects hidden when they are wholly behind a solid
##           3: and hidden lines: the part of any line behind a solid is cut away
##           Space: stop / start the camera    Left, Right: turn it by hand    Escape: pause
## RULES     nothing to win. Watch the top line: lines drawn this frame, objects hidden,
##           and the time the line work took. The floor grid is an open sheet: it is never
##           hidden from itself and hides nothing.
######################################################################################

global gCullMode, gCameraYaw, gCameraPitch

local sAngle, sTurning, sKeysWas, sTestKeys, sTicks, sMSSum, sMSCount, sMSShown, sLinesShown, sHiddenShown

constant kOrbit = 640      -- how far the camera circles from the middle
constant kHeight = 190     -- how high it is above the floor's middle
constant kFloorY = 60      -- y is down: the floor is at 60, things stand on it

on Game.OnStart
   local i, tA, tId, tR
   focus on nothing
   Engine.ResetCamera
   Scene.ClearAll
   Particles.Clear
   HUD.Clear
   Collision.ClearRules
   Mesh.Define "CullDemo.Floor", MeshGrid(12, 12, 80)
   Mesh.Define "CullDemo.Tower", MeshBox(170, 230, 170)
   Mesh.Define "CullDemo.Wall", MeshBox(320, 130, 24)
   Mesh.Define "CullDemo.Box", MeshBox(56, 56, 56)
   Mesh.Define "CullDemo.Cone", MeshPyramid(8, 34, 90)
   Mesh.Define "CullDemo.Column", MeshPrism(6, 22, 120)
   Mesh.Define "CullDemo.Ball", MeshSphere(30, 3, 6)
   Mesh.Define "CullDemo.Rock", MeshPyramid(4, 16, 22)
   get Entity.Spawn("CullDemo.Floor", 0, kFloorY, 0, "40,90,60")
   get Entity.Spawn("CullDemo.Tower", 0, kFloorY - 115, 0, "0,255,160")
   -- a ring of things round the tower: each passes behind it as the camera circles
   repeat with i = 0 to 9
      put i * 2 * pi / 10 into tA
      switch i mod 4
         case 0
            put Entity.Spawn("CullDemo.Box", 250 * sin(tA), kFloorY - 28, 250 * cos(tA), "255,200,0") into tId
            SetObjectRotationSpeed tId, 0, 0.02, 0
            break
         case 1
            put Entity.Spawn("CullDemo.Cone", 250 * sin(tA), kFloorY - 45, 250 * cos(tA), "255,90,60") into tId
            break
         case 2
            put Entity.Spawn("CullDemo.Column", 250 * sin(tA), kFloorY - 60, 250 * cos(tA), "120,170,255") into tId
            break
         case 3
            put Entity.Spawn("CullDemo.Ball", 250 * sin(tA), kFloorY - 30, 250 * cos(tA), "255,120,220") into tId
            SetObjectRotationSpeed tId, 0.01, 0.015, 0
            break
      end switch
   end repeat
   -- a wall off to one side with a row of small things behind it
   get Entity.Spawn("CullDemo.Wall", 0, kFloorY - 65, -400, "0,255,160")
   repeat with i = -2 to 2
      put Entity.Spawn("CullDemo.Box", i * 62, kFloorY - 28, -350, "255,200,0") into tId
      SetObjectRotation tId, 0, i * 0.3, 0
   end repeat
   -- small rocks further out
   repeat with i = 1 to 18
      put i * 2 * pi / 18 + 0.17 into tA
      put 380 + 60 * (i mod 3) into tR
      put Entity.Spawn("CullDemo.Rock", tR * sin(tA), kFloorY - 11, tR * cos(tA), "170,170,170") into tId
      SetObjectRotation tId, 0, i * 0.7, 0
   end repeat
   put 0 into sAngle
   put true into sTurning
   put empty into sKeysWas
   put 0 into sTicks
   put 0 into sMSSum
   put 0 into sMSCount
   put "-" into sMSShown
   put 3 into gCullMode
   CullDemo.Camera
   CullDemo.ShowHUD
end Game.OnStart

on Game.OnStop
   put 0 into gCullMode
end Game.OnStop

-- the camera on its circle, looking at the middle (the engine's camera sits at minus CAM)
on CullDemo.Camera
   Engine.SetCam -kOrbit * sin(sAngle), kHeight - kFloorY, kOrbit * cos(sAngle)
   put -sAngle into gCameraYaw
   put -atan2(kHeight - 40, kOrbit) into gCameraPitch
end CullDemo.Camera

function CullDemo.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end CullDemo.Keys

on CullDemo.TestKeys pKeys
   put pKeys into sTestKeys
end CullDemo.TestKeys

function CullDemo.State
   return "mode" && gCullMode && "angle" && round(sAngle, 2) && "lines" && sLinesShown && "hidden" && sHiddenShown && "ms" && sMSShown
end CullDemo.State

on Game.OnUpdate
   local tKeys, tKey, tMS
   add 1 to sTicks
   put CullDemo.Keys() into tKeys
   -- 0 1 2 (top row or keypad): the mode. Space: stop / start the camera (once per press).
   repeat for each item tKey in tKeys
      if tKey is among the items of sKeysWas then next repeat
      switch tKey
         case 48
         case 65456
            put 0 into gCullMode
            break
         case 49
         case 65457
            put 1 into gCullMode
            break
         case 50
         case 65458
            put 2 into gCullMode
            break
         case 51
         case 65459
            put 3 into gCullMode
            break
         case 32
            put not sTurning into sTurning
            break
      end switch
   end repeat
   put tKeys into sKeysWas
   if 65361 is among the items of tKeys then subtract 0.03 from sAngle
   if 65363 is among the items of tKeys then add 0.03 to sAngle
   if sTurning then add 0.008 to sAngle
   CullDemo.Camera
   -- the numbers are the last drawn frame's; the time is averaged so it can be read
   put Engine.Info("sceneMS") into tMS
   if tMS is a number then
      add tMS to sMSSum
      add 1 to sMSCount
   end if
   if sTicks mod 15 is 0 then
      if sMSCount > 0 then put round(sMSSum / sMSCount, 1) into sMSShown
      put 0 into sMSSum
      put 0 into sMSCount
      CullDemo.ShowHUD
   end if
end Game.OnUpdate

on CullDemo.ShowHUD
   local tWhat
   put Engine.Info("edges") into sLinesShown
   put Engine.Info("hidden") into sHiddenShown
   if Engine.Info("cullMode") is empty then
      -- an engine from before 18 Nov 2026: the keys change nothing
      HUD.Set "CullDemo.Mode", "THIS ENGINE HAS NO HIDING YET", 20, 40, 14
      HUD.Set "CullDemo.Nums", "LINES" && sLinesShown, 20, 66, 12
      exit CullDemo.ShowHUD
   end if
   put item gCullMode + 1 of "OFF  EVERYTHING SHOWS THROUGH,BACK FACES HIDDEN,BACK FACES AND WHOLE OBJECTS HIDDEN,HIDDEN LINES" into tWhat
   HUD.Set "CullDemo.Mode", "MODE" && gCullMode && " " && tWhat, 20, 40, 14
   HUD.Set "CullDemo.Nums", "LINES" && sLinesShown && "  HIDDEN OBJECTS" && sHiddenShown && "  LINE WORK" && sMSShown && "MS", 20, 66, 12
   HUD.Set "CullDemo.Keys", "KEYS 0 1 2 3   SPACE STOPS THE CAMERA", 20, 88, 10
end CullDemo.ShowHUD
