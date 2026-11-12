on mouseup
   put fld 1 of this card into tList
   replace "-" with ".minus_" in tList
   replace "+" with ".plus_"  in tList
   replace numtochar(42) with ".multiplied_"  in tList
   replace numtochar(47) with ".divided_"  in tList
   repeat for each line L in  tList
      if number of words of L  < 2 then 
         put L into tCategory
      else
         put word 1 of L && tCategory &"_" & word 2 to -1 of L & cr after tOut
      end if
   end repeat
   put tOut into fld 2
end mouseup
