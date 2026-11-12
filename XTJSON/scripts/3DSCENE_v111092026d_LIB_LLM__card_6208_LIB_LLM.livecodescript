## ============================================================================
## LIB_LLM  -  Local LLM library (LM Studio, OpenAI-compatible API)  11/11/2026
## Lives in card "LIB_LLM"; Lib.Load "LLM" (stack script) copies it into the
## in-memory library stack "LIB_LLM_SCRIPT", so every card and stack can call it.
##
## LIBRARY RULES (all LIB_ cards):
##  - No GUI references (no fld/btn/grp): results go back by message to a caller.
##  - No system-message handlers (openCard, preOpenStack, mouseUp ...): a library
##    sits in EVERY message path, so it would catch them for every card.
##  - Script locals here belong to the library stack, not to any card.
##
## WHY IT TIMED OUT: "post ... to url" blocks and gives up after the
## socketTimeoutInterval (10 seconds by default). A model that thinks longer, or that
## LM Studio is still loading into the GPU, never answers in time. This library posts
## ASYNCHRONOUSLY with tsNet (the game loop keeps running) and raises the timeouts.
##
## USE (from anywhere):
##   LLM.Init "http://localhost:1234", "gemma-2-2b-it-abliterated"
##   LLM.SetSystem "You are the grumpy quartermaster of a rebel base."
##   put LLM.Ask("Any ammo left?", the long id of this card, "Game.OnLLM") into tId
##   -- later, on that card:
##   on Game.OnLLM pReply, pId, pError
##      if pError is not empty then UI.Message pError
##      else UI.Message pReply
##   end Game.OnLLM
##
##   LLM.Ping()          -> "OK" & model list, or "ERROR: ..."  (quick, blocking)
##   LLM.AskSync(text)   -> reply (blocking, long timeout: GUI tools, not gameplay)
##   LLM.Busy()  LLM.Cancel  LLM.Clear  LLM.Set key,value  LLM.Get(key)
##   Old names still work: LM_Init, LM_SendChat, LM_ClearHistory, LM_SetSystemPrompt
## ============================================================================

local sLLM          -- settings: url, model, temperature, maxTokens, maxHistory, timeoutMS, systemAsUser
local sLLM_System   -- system prompt text
local sLLM_History  -- one JSON message object per line: {"role":..,"content":..}
local sLLM_Req      -- the request in flight: id, target, msg, text, startMS

## ---------------------------------------------------------------- SETUP

on LLM.Init pURL, pModel
   LLM.Defaults
   if pURL is not empty then put pURL into sLLM["url"]
   if pModel is not empty then put pModel into sLLM["model"]
   -- Gemma's chat template rejects the "system" role: fold it into the first user turn.
   put (sLLM["model"] contains "gemma") into sLLM["systemAsUser"]
   put empty into sLLM_History
   LLM.ApplyTimeouts
end LLM.Init

on LLM.Defaults
   if sLLM["url"] is empty then put "http://localhost:1234" into sLLM["url"]
   if sLLM["model"] is empty then put "local-model" into sLLM["model"]
   if sLLM["temperature"] is empty then put 0.8 into sLLM["temperature"]
   if sLLM["maxTokens"] is empty then put 256 into sLLM["maxTokens"]
   if sLLM["maxHistory"] is empty then put 20 into sLLM["maxHistory"]  -- messages kept
   if sLLM["timeoutMS"] is empty then put 300000 into sLLM["timeoutMS"]  -- 5 minutes
   if sLLM["systemAsUser"] is empty then put false into sLLM["systemAsUser"]
end LLM.Defaults

on LLM.Set pKey, pValue
   LLM.Defaults
   put pValue into sLLM[pKey]
   if pKey is "timeoutMS" then LLM.ApplyTimeouts
end LLM.Set

function LLM.Get pKey
   LLM.Defaults
   if pKey is empty then return sLLM
   return sLLM[pKey]
end LLM.Get

## Long timeouts for both the blocking libURL calls and tsNet.
on LLM.ApplyTimeouts
   LLM.Defaults
   set the socketTimeoutInterval to sLLM["timeoutMS"]
   try
      -- DNS, connect, whole transfer, low-speed time, low-speed limit, continue
      tsNetSetTimeouts 10000, 10000, sLLM["timeoutMS"], 0, 0, 1000
   catch tErr
   end try
end LLM.ApplyTimeouts

on LLM.SetSystem pText
   put pText into sLLM_System
end LLM.SetSystem

on LLM.Clear
   put empty into sLLM_History
end LLM.Clear

function LLM.Busy
   return sLLM_Req["id"] is not empty
end LLM.Busy

## ---------------------------------------------------------------- HISTORY / BODY

on LLM.AddMessage pRole, pText
   local tMsgA
   if pText is empty then exit LLM.AddMessage
   put pRole into tMsgA["role"]
   put pText into tMsgA["content"]
   put jsonExport(tMsgA) into tLine
   replace cr with empty in tLine
   put tLine & cr after sLLM_History
   -- Keep the newest maxHistory messages (the prompt grows slower every turn).
   put the number of lines of sLLM_History into tCount
   if tCount > sLLM["maxHistory"] then
      delete line 1 to (tCount - sLLM["maxHistory"]) of sLLM_History
      -- Never start on an assistant turn.
      if line 1 of sLLM_History contains quote & "assistant" & quote then delete line 1 of sLLM_History
   end if
end LLM.AddMessage

## The messages array as JSON: system prompt (or folded into the first user turn) + history.
function LLM.MessagesJSON
   local tSysA, tFirstA
   put empty into tItems
   put sLLM_History into tHistory
   if sLLM_System is not empty then
      if sLLM["systemAsUser"] then
         put jsonImport(line 1 of tHistory) into tFirstA
         put sLLM_System & cr & cr & tFirstA["content"] into tFirstA["content"]
         put jsonExport(tFirstA) into tLine
         replace cr with empty in tLine
         put tLine into line 1 of tHistory
      else
         put "system" into tSysA["role"]
         put sLLM_System into tSysA["content"]
         put jsonExport(tSysA) into tLine
         replace cr with empty in tLine
         put tLine & comma after tItems
      end if
   end if
   repeat for each line tLine in tHistory
      if tLine is not empty then put tLine & comma after tItems
   end repeat
   delete char -1 of tItems
   return "[" & tItems & "]"
end LLM.MessagesJSON

function LLM.Body
   LLM.Defaults
   put "{" & quote & "model" & quote & ":" & quote & sLLM["model"] & quote into tBody
   put "," & quote & "messages" & quote & ":" & LLM.MessagesJSON() after tBody
   put "," & quote & "temperature" & quote & ":" & sLLM["temperature"] after tBody
   put "," & quote & "max_tokens" & quote & ":" & sLLM["maxTokens"] after tBody
   put "," & quote & "stream" & quote & ":false}" after tBody
   return textEncode(tBody, "UTF-8")
end LLM.Body

function LLM.Headers
   return "Content-Type: application/json" & cr & "Authorization: Bearer no-key-needed"
end LLM.Headers

## Server answer (raw bytes) -> reply text; "ERROR: ..." if it isn't one.
function LLM.ParseReply pData
   local tA
   if pData is empty then return "ERROR: empty answer from server"
   try
      put jsonImport(textDecode(pData, "UTF-8")) into tA
   catch tErr
      return "ERROR: not JSON:" && char 1 to 200 of pData
   end try
   if tA["error"] is not empty then
      if tA["error"] is an array then return "ERROR:" && tA["error"]["message"]
      return "ERROR:" && tA["error"]
   end if
   return tA["choices"][1]["message"]["content"]
end LLM.ParseReply

## ---------------------------------------------------------------- ASYNC (game-safe)

## Send pText; returns a request id at once. When the model answers, pMsg is
## dispatched to pTarget with: reply, id, error (error empty on success).
## Returns empty if a request is already running (check LLM.Busy() first).
function LLM.Ask pText, pTarget, pMsg
   LLM.Defaults
   if LLM.Busy() then return empty
   if pMsg is empty then put "LLM.OnReply" into pMsg
   LLM.AddMessage "user", pText
   put "LLM" & the milliseconds into tId
   put tId into sLLM_Req["id"]
   put pTarget into sLLM_Req["target"]
   put pMsg into sLLM_Req["msg"]
   put the milliseconds into sLLM_Req["startMS"]
   try
      put tsNetPost(tId, sLLM["url"] & "/v1/chat/completions", LLM.Headers(), LLM.Body(), "LLM.tsNetDone") into tErr
   catch tCatch
      put "tsNet not available:" && tCatch into tErr
   end try
   if tErr is not empty then
      LLM.Finish empty, "ERROR:" && tErr
      return empty
   end if
   return tId
end LLM.Ask

## tsNet calls this (in the library stack) when the transfer ends.
on LLM.tsNetDone pId, pResult, pBytes, pCurlCode
   if pId is not sLLM_Req["id"] then
      try
         tsNetCloseConn pId
      catch tErr
      end try
      exit LLM.tsNetDone
   end if
   put empty into tErr
   put tsNetRetrieveData(pId, tErr) into tData
   if pCurlCode is not 0 then
      try
         put tsNetRetrieveError(pId) into tErr
      catch tCatch
      end try
      if tErr is empty then put "connection failed (curl" && pCurlCode & ")" into tErr
   end if
   try
      tsNetCloseConn pId
   catch tCatch
   end try
   if tErr is not empty then
      LLM.Finish empty, "ERROR:" && tErr
   else if pResult is not 200 then
      LLM.Finish empty, "ERROR: HTTP" && pResult && LLM.ParseReply(tData)
   else
      LLM.Finish LLM.ParseReply(tData), empty
   end if
end LLM.tsNetDone

## Record the reply and hand it to whoever asked.
on LLM.Finish pReply, pError
   if pReply begins with "ERROR:" then
      put pReply into pError
      put empty into pReply
   end if
   if pError is empty then LLM.AddMessage "assistant", pReply
   put sLLM_Req["id"] into tId
   put sLLM_Req["target"] into tTarget
   put sLLM_Req["msg"] into tMsg
   put (the milliseconds - sLLM_Req["startMS"]) into sLLM["lastMS"]
   put empty into sLLM_Req
   if tTarget is not empty and exists(tTarget) then
      dispatch tMsg to tTarget with pReply, tId, pError
   end if
end LLM.Finish

on LLM.Cancel
   if not LLM.Busy() then exit LLM.Cancel
   try
      tsNetCloseConn sLLM_Req["id"]
   catch tErr
   end try
   -- The unanswered user turn would confuse the next one.
   delete line -1 of sLLM_History
   put empty into sLLM_Req
end LLM.Cancel

## ---------------------------------------------------------------- BLOCKING

## Waits for the answer (GUI tools, editors). Not for use while a game is running.
function LLM.AskSync pText
   LLM.Defaults
   LLM.ApplyTimeouts
   LLM.AddMessage "user", pText
   set the httpHeaders to LLM.Headers()
   post LLM.Body() to url (sLLM["url"] & "/v1/chat/completions")
   put the result into tErr
   put it into tData
   set the httpHeaders to empty
   if tErr is not empty then
      delete line -1 of sLLM_History
      return "ERROR:" && tErr
   end if
   put LLM.ParseReply(tData) into tReply
   if tReply begins with "ERROR:" then
      delete line -1 of sLLM_History
   else
      LLM.AddMessage "assistant", tReply
   end if
   return tReply
end LLM.AskSync

## Is the server up, and which models does it offer? (5 second limit)
function LLM.Ping
   LLM.Defaults
   put the socketTimeoutInterval into tOld
   set the socketTimeoutInterval to 5000
   put url (sLLM["url"] & "/v1/models") into tData
   put the result into tErr
   set the socketTimeoutInterval to tOld
   if tErr is not empty then return "ERROR:" && tErr
   try
      put jsonImport(textDecode(tData, "UTF-8")) into tA
   catch tCatch
      return "ERROR: not JSON"
   end try
   put "OK" into tOut
   repeat with i = 1 to the number of elements of tA["data"]
      put cr & tA["data"][i]["id"] after tOut
   end repeat
   return tOut
end LLM.Ping

## ---------------------------------------------------------------- OLD NAMES

on LM_Init pURL, pModel
   LLM.Init pURL, pModel
end LM_Init

function LM_SendChat pUserMessage
   return LLM.AskSync(pUserMessage)
end LM_SendChat

on LM_SetSystemPrompt pText
   LLM.SetSystem pText
end LM_SetSystemPrompt

on LM_ClearHistory
   LLM.Clear
end LM_ClearHistory

function LM_GetMessagesJSON
   return LLM.MessagesJSON()
end LM_GetMessagesJSON

## ---------------------------------------------------------------- TEXT HELPERS

function strip.illegal.file.characters tString
   set itemDel to comma
   put "[,],(,),{,},:" into tNotGoodItems
   repeat for each item I in tNotGoodItems
      replace I with cr in tString
   end repeat
   replace space with "_" in tString
   return line 1 of tString
end strip.illegal.file.characters

function strip.brace.characters tFilepath
   set itemDel to "/"
   put item -1 of tFilepath into tFileName
   set itemDel to "."
   put item 1 of tFileName into tNoExt
   set itemDel to "("
   put item 1 of tNoExt into tNoParen
   set itemDel to "["
   put item 1 of tNoParen into tNoBrack
   set itemDel to "{"
   put item 1 of tNoBrack into tNoBrace
   return tNoBrace
end strip.brace.characters

function sanitizeKey tString
   replace space with "_" in tString
   put replaceText(tString, "[^A-Za-z0-9_]", empty) into tString
   repeat while tString contains "__"
      replace "__" with "_" in tString
   end repeat
   repeat while char 1 of tString is "_"
      delete char 1 of tString
   end repeat
   repeat while char -1 of tString is "_"
      delete char -1 of tString
   end repeat
   if char 1 of tString is not in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" then put "X" before tString
   return tString
end sanitizeKey

function getBracedData tString
   put empty into tData
   set itemDel to "("
   if the number of items of tString > 1 then
      put item 2 of tString into tPart
      set itemDel to ")"
      put item 1 of tPart into tData
      replace space with empty in tData
   end if
   return tData
end getBracedData
