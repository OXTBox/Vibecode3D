--// increase glow when MouseEnters
on mouseEnter
   set the outerGlow["spread"] of me to 90
end mouseEnter
--// decrease glow when mouse leaves
on mouseLeave
   set the outerGlow["spread"] of me to 55
end mouseLeave
--// send PlayButtonPresssed to script of Card "Title"
on mouseDown
 Toggle.Playing
end mouseDown
