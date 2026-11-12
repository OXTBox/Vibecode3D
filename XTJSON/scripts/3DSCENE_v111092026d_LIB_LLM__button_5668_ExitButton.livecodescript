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
   set the rect of stack "quitStack" to the rect of this stack
   set the loc of group "quitGroup" of stack "QuitStack" to CenterScreen()
   open stack "quitStack"
end mouseUP
