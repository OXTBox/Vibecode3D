local vsY
local vsL
local vsR

on mouseDown
   put the loc of graphic "VolumeSlider" into vsLoc
   put item 2 of vsLoc into vsY
   put the left of graphic "VolumeSlider"+1 into vsL
   put the right of graphic "VolumeSlider"+1 into vsR
   put item 1 of the mouseLoc into moX
   set the loc of me to moX,vsY
   dragMove
end mouseDown

on dragMove
   put item 1 of the mouseLoc into moX
   if Mox > VSL + 100 then put VSL + 100 into MoX
   if MoX < VSL then put VSL into MoX
   set the loc of me to moX,vsY
   put  abs(item 1 the loc of me - vsL) into vVal
   if vVal > 100 then put 100 into vVal
   put vVal into field "MusicVolumeValue"
   if the mouse is down then send dragMove to me in 2 milliseconds
   set the OptionsNewVolume of stack (the mainStack of this stack) to vVal
end dragMove

