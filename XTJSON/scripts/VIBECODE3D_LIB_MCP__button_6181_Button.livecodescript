on mouseUp
   PadGroupForGlow "User"
end mouseUp

## Make room for glows / shadows around a group's contents WITHOUT moving them.
## Each side grows only as far as an effect actually reaches past the contents.
on PadGroupForGlow pGroupName
   if there is not a group pGroupName then
      answer "No group" && pGroupName
      exit PadGroupForGlow
   end if
   put the long id of group pGroupName into tGroup
   put the name of tGroup into tGroupName -- e.g. group "User", to spot direct children
   
   -- 1. Start from the contents' own bounds.
   put the formattedRect of tGroup into tNeed
   
   -- 2. Grow only where an effect reaches past them.
   repeat with i = 1 to the number of controls of tGroup
      put the long id of control i of tGroup into tRef
      put 0 into tReach
      put the outerGlow of tRef into tFX
      if the keys of tFX is not empty then
         put max(tReach, tFX["size"], tFX["spread"]) into tReach
      end if
      put the dropShadow of tRef into tFX
      if the keys of tFX is not empty then
         put max(tReach, max(tFX["size"], tFX["spread"]) + tFX["distance"]) into tReach
      end if
      if tReach > 0 then
         add 10 to tReach -- a little over, so nothing is clipped
         put the rect of tRef into r
         put min(item 1 of tNeed, item 1 of r - tReach) into item 1 of tNeed
         put min(item 2 of tNeed, item 2 of r - tReach) into item 2 of tNeed
         put max(item 3 of tNeed, item 3 of r + tReach) into item 3 of tNeed
         put max(item 4 of tNeed, item 4 of r + tReach) into item 4 of tNeed
      end if
   end repeat
   
   -- 3. Remember where the direct children are (nested ones move with them).
   put empty into tKeep
   repeat with i = 1 to the number of controls of tGroup
      put the long id of control i of tGroup into tRef
      if the owner of tRef is not tGroupName then next repeat
      put the short id of tRef & tab & the rect of tRef & cr after tKeep
   end repeat
   
   -- 4. Resize the group, then put every child back where it was.
   lock screen
   set the lockLoc of tGroup to true
   set the rect of tGroup to tNeed
   set itemDel to tab
   repeat for each line tLine in tKeep
      set the rect of control id (item 1 of tLine) of this card to item 2 of tLine
   end repeat
   unlock screen
   put "group" && pGroupName && "rect:" && the rect of tGroup & "  loc:" && the loc of tGroup
end PadGroupForGlow
