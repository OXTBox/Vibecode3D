
on preopenStack
   pass preOpenstack
end preopenStack
on escapeKey
   send EscapeKey to stack (the mainStack of this stack)
   close stack "QuitStack"
   
end escapeKey
