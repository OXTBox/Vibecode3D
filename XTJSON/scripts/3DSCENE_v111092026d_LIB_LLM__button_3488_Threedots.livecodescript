on menuPick myPick
put numtochar(2714) into chk --  ✔
put myPick into tRealPick
put the text of me into myText
set itemDEl to "|"
if number of items of tRealPick > 1 then put item 2 of tRealPick into tRealPick
put lineOffset(tRealPick, myText) into tNum
put char 1 of line tNum of myText is tab into bSub
   menuPick.threedots myPick
end menuPick
