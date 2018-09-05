 
--[[
 Enchat 3.0 BETA (well, work in progress really)
 Get with:
  wget https://github.com/LDDestroier/enchat/raw/master/enchat3.lua enchat3
--]]

enchat = {
	version = 3.0,
	isBeta = true,
	port = 11000,
	url = "https://github.com/LDDestroier/enchat/raw/master/enchat3.lua"
}

local tArg = {...}

local yourName, encKey

yourName = tArg[1]
encKey = tArg[2]

local palate = {
	bg = colors.black,	--Default background color
	txt = colors.white,	--Default text color (should contrast with bg)
	promptbg = colors.gray,	--Color for the chat prompt background.
	prompttxt = colors.white,	--Color for the chat prompt text.
}

-- AES API START (thank you SquidDev) --

local apipath
if shell then apipath = fs.combine(shell.dir(),"aes") else apipath = "aes" end
if (not aes) and (not fs.exists(apipath)) then
	print("AES API not found! Downloading...")
	local prog = http.get("http://pastebin.com/raw/9E5UHiqv")
	if not prog then error("FAIL!") end
	local file = fs.open(apipath,"w")
	file.write(prog.readAll())
	file.close()
end
if not aes then
	local res = os.loadAPI(apipath)
	if not res then error("Didn't load AES API!") end
end

-- AES API STOP (thanks again) --

local updateEnchat = function()
	local pPath = shell.getRunningProgram()
	local h = http.get(enchat.url)
	if not h then
		return false, "Could not connect."
	else
		local content = h.readAll()
		local file = fs.open(pPath, "w")
		file.write(content)
		file.close()
		return true, "Updated!"
	end
end

local scr_x, scr_y = term.getSize()

local log = {} --Records all sorts of data on text.
local renderlog = {} --Only records straight terminal output. Generated from 'log'

local scroll = 0
local maxScroll = 0

local getModem = function()
	local modems = {peripheral.find("modem")}
	return modems[1]
end

local modem = getModem()
if not modem then
	error("You should get a modem.")
end
modem.open(enchat.port)

local encrite = function(input) --standardized encryption function
	return aes.encrypt(encKey, textutils.serialize(input))
end

local decrite = function(input)
	return textutils.unserialize(aes.decrypt(encKey, input))
end

local dab = function(func, ...) --"no and back", not...never mind
	local x, y = term.getCursorPos()
	local b, t = term.getBackgroundColor(), term.getTextColor()
	local output = {func(...)}
	term.setCursorPos(x,y)
	term.setTextColor(t)
	term.setBackgroundColor(b)
	return unpack(output)
end

local explode = function(div,str,replstr,includeDiv)
	if (div=='') then return false end
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,div,pos,false) end do
		table.insert(arr,string.sub(replstr or str,pos,st-1+(includeDiv and #div or 0)))
		pos = sp + 1
	end
	table.insert(arr,string.sub(replstr or str,pos))
	return arr
end

local blitWrap = function(char, text, back, noWrite)
	local cWords = explode(" ",char,nil, true)
	local tWords = explode(" ",char,text,true)
	local bWords = explode(" ",char,back,true)
	local ox,oy = term.getCursorPos()
	local cx,cy,ty = ox,oy,1
	local scr_x, scr_y = term.getSize()
	local output = {}
	for a = 1, #cWords do
		if ((cx + #cWords[a]) > scr_x) then
			cx = 1
			if (cy == scr_y) then
				term.scroll(1)
			end
			cy = math.min(cy+1, scr_y)
			ty = ty + 1
		end
		if not noWrite then
			term.setCursorPos(cx,cy)
			term.blit(cWords[a],tWords[a],bWords[a])
		end
		cx = cx + #cWords[a]
		output[ty] = output[ty] or {"","",""}
		output[ty][1] = output[ty][1]..cWords[a]
		output[ty][2] = output[ty][2]..tWords[a]
		output[ty][3] = output[ty][3]..bWords[a]
	end
	return output
end

prettyClearScreen = function()
	term.setTextColor(colors.lightGray)
	term.setBackgroundColor(colors.gray)
	if _VERSION then
		for y = 1, scr_y do
			term.setCursorPos(1,y)
			if y == 1 then
				term.write(("\135"):rep(scr_x))
			elseif y == scr_y then
				term.setTextColor(colors.gray)
				term.setBackgroundColor(colors.lightGray)
				term.write(("\135"):rep(scr_x))
			else
				term.clearLine()
			end
		end
	else
		term.clear()
	end
end

local cwrite = function(text, y)
	local cx, cy = term.getCursorPos()
	term.setCursorPos((scr_x/2) - math.ceil(#text/2), y or cy)
	return write(text)
end

local prettyCenterWrite = function(text, y)
	local words = explode(" ", text, nil, true)
	local buff = ""
	local lines = 0
	for w = 1, #words do
		if #buff + #words[w] > scr_x then
			cwrite(buff, y + lines)
			buff = ""
			lines = lines + 1
		end
		buff = buff..words[w]
	end
	cwrite(buff, y + lines)
	return lines
end

local prettyPrompt = function(prompt, y, replchar, history)
	local cy, cx = term.getCursorPos()
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	local yadj = 1 + prettyCenterWrite(prompt, y or cy)
	term.setCursorPos(1, y + yadj)
	term.setBackgroundColor(colors.lightGray)
	term.clearLine()
	local output = read(replchar, history) --will eventually add fancy colored read function
	return output
end

local currentY = 2

if not (yourName and encKey) then
	prettyClearScreen()
end

if not yourName then
	yourName = prettyPrompt("Enter your name.", currentY)
	currentY = currentY + 3
end

if not encKey then
	encKey = prettyPrompt("Enter an encryption key.", currentY, "*")
	currentY = currentY + 3
end

local toblit = {
	[0] = " ",
	[1] = "0",
	[2] = "1",
	[4] = "2",
	[8] = "3",
	[16] = "4",
	[32] = "5",
	[64] = "6",
	[128] = "7",
	[256] = "8",
	[512] = "9",
	[1024] = "a",
	[2048] = "b",
	[4096] = "c",
	[8192] = "d",
	[16384] = "e",
	[32768] = "f"
}
local tocolors = {}
for k,v in pairs(toblit) do
	tocolors[v] = k
end

local textToBlit = function(input, inittext, initback)
	local char, text, back = "", inittext or toblit[term.getTextColor()], initback or toblit[term.getBackgroundColor()]
	local charout, textout, backout = "", "", ""
	local textCode = "&"
	local bgCode = "~"

	local x = 0
	local cur, prev, nex

	local progress = function()
		charout = charout..char
		textout = textout..text
		backout = backout..back
	end
	
	while true do
		x = x + 1

		prev = input:sub(x-1,x-1)
		cur = input:sub(x,x)
		nex = input:sub(x+1,x+1)

		if #cur == 1 then
			if cur == textCode and nex then
				if tocolors[nex:lower()] then
					text = nex:lower()
					x = x + 1
				else
					char = nex
					progress()
				end
			elseif cur == backCode and nex then
				if tocolors[nex:lower()] then
					back = nex:lower()
					x = x + 1
				else
					char = nex
					progress()
				end
			else
				char = cur
				progress()
			end
		else
			break
		end
	end
	return charout, textout, backout
end

local genRenderLog = function()
	local buff, prebuff
	renderlog = {}
	term.setBackgroundColor(palate.bg)
	term.setTextColor(palate.txt)
	for a = 1, #log do
		term.setCursorPos(1,1)
		prebuff = {textToBlit(log[a].prefix .. log[a].name .. log[a].suffix .. log[a].message)}
		buff = blitWrap(unpack(prebuff))
		for l = 1, #buff do
			renderlog[#renderlog + 1] = buff[l]
		end
	end
end

local getMaxScroll = function()
	return math.max(0, #renderlog - (scr_y - 2))
end

local renderChat = function(scroll, scrollToBottom)
	genRenderLog(log)
	if scrollToBottom then
		scroll = getMaxScroll()
	end
	local ry
	term.setBackgroundColor(palate.bg)
	for y = 1, scr_y - 2 do
		ry = y + scroll
		term.setCursorPos(1,y)
		term.clearLine()
		if renderlog[ry] then
			term.blit(unpack(renderlog[ry]))
		end
	end
end

local logadd = function(name, message)
	log[#log + 1] = {
		prefix = name and "<",
		suffix = name and "> ",
		name = name and name or "",
		message = message
	}
end

local enchatSend = function(name, message, doLog)
	if doLog then
		logadd(name or "shit", message)
		--dab(renderChat, scroll)
	end
	modem.transmit(enchat.port, enchat.port, encrite({
		name = name,
		message = message
	}))
end

local cryOut = function(name, crying)
	modem.transmit(enchat.port, enchat.port, encrite({
		name = name,
		cry = crying
	}))
end

local commandInit = "/"
local commands = {}
--Commands only have one argument -- a single string.
--Separate arguments can be extrapolated with the explode() function.

	commands.exit = function(farewell)
		enchatSend("*", yourName.." has buggered off."..(farewell and (" ("..farewell..")") or ""))
		return "exit"
	end
	commands.me = function(msg)
		if msg then
			enchatSend("*", yourName.." "..msg, true)
		else
			logadd("*",commandInit.."me [message]")
	end
	commands.colors = function()
		logadd("*", "Color codes: (use & or ~)")
		logadd(nil, "&7~11~22~33~44~55~66~7&87~8&78~99~aa~bb~cc~dd~ee~ff")
	end
	commands.update = function()
		local res, message = updateEnchat()
		if res then
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			term.clear()
			term.setCursorPos(1,1)
			print(res)
		else
			logadd("*", res)
		end	
	end
	commands.list = function()
		logadd(nil,"Searching...")
		renderChat(scroll)
		local userList = {}
		local tim = os.startTimer(0.5)
		cryOut(yourName, true)
		while true do
			local evt = {os.pullEvent()}
			if evt[1] == "modem_message" then
				local msg = decrite(evt[5])
				if type(msg.name) == "string" and msg.cry == true then
					userList[msg.name] = true
				end
			elseif evt[1] == "timer" then
				if evt[2] == tim then
					break
				end
			end
		end
		if #userList == 0 then
			logadd(nil,"Nobody's there.")
		else
			for k,v in pairs(userList) do
				logadd(nil,"+"..k)
			end
		end
	end
	commands.help = function(cmdname)
		if cmdname then
			local helpList = {
				exit = "Exits Enchat and returns to loader (usually shell)",
				me = "Sends a message in the format of \"* yourName message\"",
				colors = "Lists all the colors you can use.",
				update = "Updates and overwrites Enchat, then exits if successful.",
				list = "Lists all users in range using the same key.",
				help = "Shows every command, or describes a command.",
			}
			cmdname = cmdname:gsub(" ","")
			if helpList[cmdname] then
				logadd("*", helpList[cmdname])
			else
				if commands[cmdname] then
					logadd("*", "No help info for that command.")
				else
					logadd("*", "No such command to get help for.")
				end
			end
		else
			logadd("*","All commands:")
			for k,v in pairs(commands) do
				logadd(nil," "..commandInit..k)
			end
		end
	end

local checkIfCommand = function(input)
	if input:sub(1,#commandInit) == commandInit then
		return true
	else
		return false
	end
end

local parseCommand = function(input)
	local sPos1, sPos2 = input:find(" ")
	local cmdName, cmdArgs
	if sPos1 then
		cmdName = input:sub(#commandInit+1, sPos1-1)
		cmdArgs = input:sub(sPos2+1)
	else
		cmdName = input:sub(#commandInit+1)
		cmdArgs = nil
	end
	
	local res
	if commands[cmdName] then
		res = commands[cmdName](cmdArgs)
		if res == "exit" then
			return "exit"
		end
	else
		logadd("*", "No such command.")
	end
end

local main = function()
	term.setBackgroundColor(palate.bg)
	term.clear()
	renderChat(scroll)
	local isAtBottom
	
	while true do	
		
		term.setCursorPos(1, scr_y - 1)
		term.setBackgroundColor(palate.promptbg)
		term.setTextColor(palate.prompttxt)
		term.clearLine()
		
		local input = read() --replace later with fancier input
		isAtBottom = (scroll == maxScroll)
		if checkIfCommand(input) then
			local res = parseCommand(input)
			if res == "exit" then
				return "exit"
			end
		else
			enchatSend(yourName, input, true)
		end
		dab(renderChat, scroll, isAtBottom)
	end
	
end

local handleReceiveMessage = function(user, message)
	logadd(user, message)
	maxScroll = getMaxScroll()
	dab(renderChat, scroll)
end

local handleEvents = function()
	while true do
		local evt = {os.pullEvent()}
		if evt[1] == "enchat_send" then
			local user, message, doLog = evt[2], evt[3], evt[4]
			if doLog then
				maxScroll = getMaxScroll()
			end
			enchatSend(user, message, doLog)
		elseif evt[1] == "modem_message" then
			local side, freq, repfreq, msg, distance = evt[2], evt[3], evt[4], evt[5], evt[6]
			msg = decrite(msg)
			if type(msg) == "table" then
				if (type(msg.name) == "string") then
					if (type(msg.message) == "string") then
						handleReceiveMessage(msg.name, tostring(msg.message))
					elseif (type(msg.cry) == true) then
						cryOut(yourName, false)
					end
				end
			end
		elseif evt[1] == "mouse_scroll" then
			local dist = evt[2]
			--maxScroll = getMaxScroll()
			scroll = math.min(maxScroll, math.max(0, scroll + dist))
			dab(renderChat, scroll)
		end
	end
end

getModem()

parallel.waitForAny(main, handleEvents)
