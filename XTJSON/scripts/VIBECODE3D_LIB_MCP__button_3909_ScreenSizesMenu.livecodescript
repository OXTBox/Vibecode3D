on menuPick mPick
   put mPick into field "ScreenSizeValueLabel"
   replace " x "  with  comma in mPick
   set the label of me to "Screen Size"
   set the newResolution of stack (the mainStack of this stack) to  mPick
end menuPick
