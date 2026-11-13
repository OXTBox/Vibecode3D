on MouseUp
   put "0,0,114,24" into myRect
   if the mouseLoc is within myRect then
   if the height of me > 24 then
      set the height of me to 24
      set the label of me to "KEY CONTROLS"
   else
      set the height of me to 696
      set the label of me to the keyControlsText of me
   end if
   end if
   set the top of me to -4
end MouseUp
