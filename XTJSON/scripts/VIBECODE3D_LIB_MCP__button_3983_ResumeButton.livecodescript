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
   send ResumeGame  to stack (the mainStack of this stack) in 200 milliseconds
end mouseUP
