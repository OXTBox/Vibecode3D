on mouseUp
   BuildUserGroup the long id of me
end mouseUp

## A fresh "User" group as big as the card (four 2x2 anchors in the corners), then
## every user object moved INTO it without ever touching the group's rect.
## pSkip: a control to leave out (the button running this).
on BuildUserGroup pSkip
   lock screen
   put the width of this card into W
   put the height of this card into H
   
   -- 1. An old "User" group: lift its children out to the card, then delete it.
   if there is a group "User" then
      put the long id of group "User" into tOld
      put the name of tOld into tOldName
      put empty into tKids
      repeat with i = 1 to the number of controls of tOld
         put the long id of control i of tOld into tRef
         if the owner of tRef is tOldName then put the short id of tRef & cr after tKids
      end repeat
      repeat for each line tId in tKids
         put the rect of control id tId into tRect
         relayer control id tId to front of this card
         set the rect of control id tId to tRect
      end repeat
      -- Old anchors go too.
      repeat for each item tA in "ATL,ATR,ABL,ABR"
         if there is a graphic tA then delete graphic tA
      end repeat
      set the cantDelete of tOld to false
      delete tOld
   end if
   
   -- 2. Four invisible anchors in the card's corners, grouped: the group IS the card.
   reset the templateGraphic
   set the style of the templateGraphic to "rectangle"
   set the opaque of the templateGraphic to false
   set the lineSize of the templateGraphic to 0
   set the showBorder of the templateGraphic to false
   create graphic "ATL"
   set the rect of graphic "ATL" to 0,0,2,2
   create graphic "ATR"
   set the rect of graphic "ATR" to W-2,0,W,2
   create graphic "ABL"
   set the rect of graphic "ABL" to 0,H-2,2,H
   create graphic "ABR"
   set the rect of graphic "ABR" to W-2,H-2,W,H
   reset the templateGraphic
   group graphic "ATL" and graphic "ATR" and graphic "ABL" and graphic "ABR"
   put it into tUser
   set the name of tUser to "User"
   set the margins of tUser to 0 -- fit the anchors exactly: 0,0,W,H
   set the lockLoc of tUser to true -- and never resize again
   try
      set the clipsToRect of tUser to true
   catch tErr
   end try
   
   -- 3. Move every user object in, putting each back exactly where it was.
   put empty into tMove
   repeat with i = 1 to the number of controls of this card
      put the long id of control i of this card into tRef
      if word 1 of the owner of tRef is not "card" then next repeat
      if tRef is pSkip then next repeat
      put the short name of tRef into tName
      if tName is among the items of "User,Viewport,AudioPlayers,PauseMenuGroup,OptionsGroup" then next repeat
      if word 1 of tRef is "group" then
         if the backgroundBehavior of tRef then next repeat
      end if
      set the customPropertySet of tRef to empty
      if the HUD of tRef is true then next repeat
      if the Entity of tRef is true then next repeat
      put the short id of tRef & cr after tMove
   end repeat
   repeat for each line tId in tMove
      put the rect of control id tId into tRect
      relayer control id tId to front of group "User"
      set the rect of control id tId to tRect
   end repeat
   set the layer of group "User" to top
   unlock screen
   put "User rect:" && the rect of group "User" && " controls:" && the number of controls of group "User"
end BuildUserGroup
