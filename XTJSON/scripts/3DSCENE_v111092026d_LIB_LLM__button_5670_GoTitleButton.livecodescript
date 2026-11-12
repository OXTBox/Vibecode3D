--// increase glow when MouseEnters
on mouseEnter
   set the outerGlow["spread"] of me to 50
   set the outerGlow["size"] of me to 15
end mouseEnter
--// decrease glow when mouse leaves

on mouseLeave
   set the outerGlow["spread"] of me to 25
   set the outerGlow["size"] of me to 25
end mouseLeave


on mouseDown
   set the outerGlow["spread"] of me to 100
   set the outerGlow["size"] of me to 25
end mouseDown

on mouseUP
   set the outerGlow["spread"] of me to 50
   set the outerGlow["size"] of me to 15
   if there is a group "PauseMenuGroup"  then hide group "PauseMenuGroup"
  if there is a card "Title" then
Go Card "Title"
else
go card 1
end if	
end mouseUP
