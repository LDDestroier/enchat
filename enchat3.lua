--[[
 Enchat 3.0
 Get with:
  wget https://github.com/LDDestroier/enchat/raw/master/enchat3.lua enchat3.lua

This is a stable release. You fool!
--]]

local scr_x, scr_y = term.getSize()

enchat = {
	version = 3.0,
	isBeta = false,
	port = 11000,
	skynetPort = "enchat3-default",
	url = "https://github.com/LDDestroier/enchat/raw/master/enchat3.lua",
	betaurl = "https://github.com/LDDestroier/enchat/raw/master/enchat3beta.lua",
	ignoreModem = false,
	dataDir = "/.enchat"
}

local enchatSettings = {	--DEFAULT settings.
	animDiv = 4,		--divisor of text animation speed (scrolling from left)
	doAnimate = true,	--whether or not to animate text moving from left side of screen
	reverseScroll = false,	--whether or not to make scrolling up really scroll down
	redrawDelay = 0.1,	--delay between redrawing
	useSetVisible = true,	--whether or not to use term.current().setVisible(), which has performance and flickering improvements
	pageKeySpeed = 4,	--how far PageUP or PageDOWN should scroll
	doNotif = true,		--whether or not to use oveerlay glasses for notifications, if possible
	doKrazy = true,		--whether or not to add &k obfuscation
	useSkynet = false,	--whether or not to use gollark's Skynet in addition to modem calls
	extraNewline = true,	--adds an extra newline after every message since setting to true
	acceptPictoChat = true	--whether or not to allow tablular enchat input, which is what /picto uses
}

local palette = {
	bg = colors.black,		--background color
	txt = colors.white,		--text color (should contrast with bg)
	promptbg = colors.gray,		--chat prompt background
	prompttxt = colors.white,	--chat prompt text
	scrollMeter = colors.lightGray,	--scroll indicator
	chevron = colors.black,		--color of ">" left of text prompt
	title = colors.lightGray	--color of title, if available
}

UIconf = {
	promptY = 1,		--Y position of read prompt, relative to bottom of screen
	chevron = ">",		--symbol before read prompt
	chatlogTop = 1,		--where chatlog is written to screen, relative to top of screen
	title = "",		--overwritten every render, don't bother here
	doTitle = false,	--whether or not to draw UIconf.title at the top of the screen
	nameDecolor = false,	--if true, sets all names to palette.chevron color
}

local saveSettings = function()
	local file = fs.open(fs.combine(enchat.dataDir,"settings"),"w")
	file.write(textutils.serialize({
		enchatSettings = enchatSettings,
		palette = palette,
		UIconf = UIconf
	}))
	file.close()
end

local loadSettings = function()
	local contents
	if not fs.exists(fs.combine(enchat.dataDir,"settings")) then
		saveSettings()
	end
	local file = fs.open(fs.combine(enchat.dataDir,"settings"),"r")
	contents = file.readAll()
	file.close()
	local newSettings = textutils.unserialize(contents)
	if newSettings then
		for k,v in pairs(newSettings.enchatSettings) do
			enchatSettings[k] = v
		end
		for k,v in pairs(newSettings.palette) do
			palette[k] = v
		end
		for k,v in pairs(newSettings.UIconf) do
			UIconf[k] = v
		end
	else
		saveSettings()
	end
end

local initcolors = {
	bg = term.getBackgroundColor(),
	txt = term.getTextColor()
}

local tArg = {...}

local yourName, encKey

yourName = tArg[1]
encKey = tArg[2]

local updateEnchat = function(doBeta)
	local pPath = shell.getRunningProgram()
	local h = http.get((doBeta or enchat.isBeta) and enchat.betaurl or enchat.url)
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

local setEncKey = function(newKey)
	encKey = newKey
end

pauseRendering = false

local colors_strnames = { --primarily for use when coloring palette
	["white"] = colors.white,
	["pearl"] = colors.white,
	["aryan"] = colors.white,
	["#f0f0f0"] = colors.white,
	["orange"] = colors.orange,
	["carrot"] = colors.orange,
	["pumpkin"] = colors.orange,
	["#f2b233"] = colors.orange,
	["magenta"] = colors.magenta,
	["hotpink"] = colors.magenta,
	["lightpurple"] = colors.magenta,
	["light purple"] = colors.magenta,
	["#e57fd8"] = colors.magenta,
	["lightblue"] = colors.lightBlue,
	["light blue"] = colors.lightBlue,
	["skyblue"] = colors.lightBlue,
	["#99b2f2"] = colors.lightBlue,
	["yellow"] = colors.yellow,
	["piss"] = colors.yellow,
	["lemon"] = colors.yellow,
	["cowardice"] = colors.yellow,
	["#dede6c"] = colors.yellow,
	["lime"] = colors.lime,
	["lightgreen"] = colors.lime,
	["light green"] = colors.lime,
	["slime"] = colors.lime,
	["#7fcc19"] = colors.lime,
	["pink"] = colors.pink,
	["lightishred"] = colors.pink,
	["lightish red"] = colors.pink,
	["communist"] = colors.pink,
	["#f2b2cc"] = colors.pink,
	["gray"] = colors.gray,
	["grey"] = colors.gray,
	["graey"] = colors.gray,
	["#4c4c4c"] = colors.gray,
	["lightgray"] = colors.lightGray,
	["lightgrey"] = colors.lightGray,
	["light gray"] = colors.lightGray,
	["light grey"] = colors.lightGray,
	["#999999"] = colors.lightGray,
	["cyan"] = colors.cyan,
	["seawater"] = colors.cyan,
	["#4c99b2"] = colors.cyan,
	["purple"] = colors.purple,
	["purble"] = colors.purple,
	["obsidian"] = colors.purple,
	["#b266e5"] = colors.purple,
	["blue"] = colors.blue,
	["blu"] = colors.blue,
	["blueberry"] = colors.blue,
	["x"] = colors.blue,
	["megaman"] = colors.blue,
	["#3366bb"] = colors.blue,
	["brown"] = colors.brown,
	["shit"] = colors.brown,
	["dirt"] = colors.brown,
	["#7f664c"] = colors.brown,
	["green"] = colors.green,
	["grass"] = colors.green,
	["#57a64e"] = colors.green,
	["red"] = colors.red,
	["menstration"] = colors.red,
	["blood"] = colors.red,
	["marinara"] = colors.red,
	["zero"] = colors.red,
	["protoman"] = colors.red,
	["communism"] = colors.red,
	["#cc4c4c"] = colors.red,
	["black"] = colors.black,
	["dark"] = colors.black,
	["coal"] = colors.black,
	["onyx"] = colors.black,
	["#191919"] = colors.black,
}

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

local codeNames = {
	["r"] = "reset",	-- Sets either the text (&) or background (~) colors to their original color.
	["{"] = "stopFormatting",	--Toggles formatting text off
	["}"] = "startFormatting",	--Toggles formatting text on
	["k"] = "krazy"	--Makes the font krazy!
}

local kraziez = {
	["l"] = {
		"!",
		"l",
		"1",
		"|",
		"i",
		"I",
		":",
		";",
	},
	["m"] = {
		"M",
		"W",
		"w",
		"m",
		"X",
		"N",
		"_",
		"%",
		"@",
	},
	["all"] = {}
}

for a = 1, #kraziez["l"] do
	kraziez[kraziez["l"][a]] = kraziez["l"]
end
for k,v in pairs(kraziez) do
	for a = 1, #v do
		kraziez[kraziez[k][a]] = v
	end
end
if tonumber(_CC_VERSION or 0) >= 1.76 then
	for a = 1, 255 do
		if (a ~= 32) and (a ~= 13) and (a ~= 10) then
			kraziez["all"][#kraziez["all"]+1] = string.char(a)
		end
	end
else
	for a = 33, 126 do
		kraziez["all"][#kraziez["all"]+1] = string.char(a)
	end
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

local moveOn
textToBlit = function(_str,onlyString,initTxt,initBg,_checkPos) --returns output for term.blit, or blitWrap, with formatting codes for color selection. Modified for use specifically with Enchat.
	checkPos = _checkPos or -1
	if (not _str) then
		if onlyString then
			return ""
		else
			return "","",""
		end
	end
	local str = tostring(_str)
	local p = 1
	local output, txcolorout, bgcolorout = "", "", ""
	local txcode, bgcode = "&", "~"
	local isKrazy = false
	local doFormatting = true
	local usedformats = {}
	local txcol,bgcol = initTxt or toblit[term.getTextColor()], initBg or toblit[term.getBackgroundColor()]
	local origTX,origBG = initTxt or toblit[term.getTextColor()], initBg or toblit[term.getBackgroundColor()]
	local cx,cy
	moveOn = function(tx,bg)
		if isKrazy and (str:sub(p,p) ~= " ") and doFormatting then
			if kraziez[str:sub(p,p)] then
				output = output..kraziez[str:sub(p,p)][math.random(1,#kraziez[str:sub(p,p)])]
			else
				output = output..kraziez.all[math.random(1,#kraziez.all)]
			end
		else
			output = output..str:sub(p,p)
		end
		txcolorout = txcolorout..tx --(doFormatting and tx or origTX)
		bgcolorout = bgcolorout..bg --(doFormatting and bg or origBG)
	end
	local checkMod = 0
	local modifyCheck = function()
		if p < checkPos then
			checkMod = checkMod - 2
		end
		if p == checkPos then
			checkMod = checkMod - 1
		end
	end
	while p <= #str do
		if str:sub(p,p) == txcode then
			if tocolors[str:sub(p+1,p+1)] and doFormatting then
				txcol = str:sub(p+1,p+1)
				usedformats.txcol = true
				p = p + 1
				modifyCheck()
			elseif codeNames[str:sub(p+1,p+1)] then
				if str:sub(p+1,p+1) == "r" and doFormatting then
					txcol = origTX
					isKrazy = false
					p = p + 1
					modifyCheck()
				elseif str:sub(p+1,p+1) == "{" and doFormatting then
					doFormatting = false
					p = p + 1
					modifyCheck()
				elseif str:sub(p+1,p+1) == "}" and not doFormatting then
					doFormatting = true
					p = p + 1
					modifyCheck()
				elseif str:sub(p+1,p+1) == "k" and doFormatting then
					if enchatSettings.doKrazy then
						isKrazy = true
						usedformats.krazy = true
					end
					p = p + 1
					modifyCheck()
				else
					moveOn(txcol,bgcol)
				end
			else
				moveOn(txcol,bgcol)
			end
			p = p + 1
		elseif str:sub(p,p) == bgcode then
			if tocolors[str:sub(p+1,p+1)] and doFormatting then
				bgcol = str:sub(p+1,p+1)
				usedformats.bgcol = true
				p = p + 1
				modifyCheck()
			elseif codeNames[str:sub(p+1,p+1)] and (str:sub(p+1,p+1) == "r") and doFormatting then
				bgcol = origBG
				p = p + 1
				modifyCheck()
			elseif str:sub(p+1,p+1) == "k" and doFormatting then
				isKrazy = false
				p = p + 1
				modifyCheck()
			else
				moveOn(txcol,bgcol)
			end
			p = p + 1
		else
			moveOn(txcol,bgcol)
			p = p + 1
		end
	end
	if onlyString then
		return output, checkMod
	else
		return {output, txcolorout, bgcolorout}, checkMod
	end
end

local colorRead = function(maxLength, _history)
	local output = ""
	local history, _history = {}, _history or {}
	for a = 1, #_history do
		history[a] = _history[a]
	end
	history[#history+1] = ""
	local hPos = #history
	local cx, cy = term.getCursorPos()
	local x = 1
	local xscroll = 1
	local evt, key, bout, xmod, timtam
	term.setCursorBlink(true)
	while true do
		term.setCursorPos(cx,cy)
		bout, xmod = textToBlit(output,false,nil,nil,x)
		for a = 1, #bout do
			bout[a] = bout[a]:sub(xscroll,xscroll+scr_x-cx)
		end
		term.blit(unpack(bout))
		term.write((" "):rep(scr_x-cx))
		term.setCursorPos(cx+x+xmod-xscroll,cy)
		evt = {os.pullEvent()}
		if evt[1] == "char" or evt[1] == "paste" then
			output = (output:sub(1,x-1)..evt[2]..output:sub(x)):sub(1,maxLength or -1)
			x = math.min(x + #evt[2], #output+1)
		elseif evt[1] == "key" then
			key = evt[2]
			if key == keys.left then
				x = math.max(x - 1, 1)
			elseif key == keys.right then
				x = math.min(x + 1, #output+1)
			elseif key == keys.backspace then
				if x > 1 then
					output = output:sub(1,x-2)..output:sub(x)
					x = x - 1
				end
			elseif key == keys.delete then
				if x < #output+1 then
					output = output:sub(1,x-1)..output:sub(x+1)
				end
			elseif key == keys.enter then
				term.setCursorBlink(false)
				return output
			elseif key == keys.home then
				x = 1
			elseif key == keys["end"] then
				x = #output+1
			elseif key == keys.up then
				if history[hPos-1] then
					hPos = hPos - 1
					output = history[hPos]
					x = #output+1
				end
			elseif key == keys.down then
				if history[hPos+1] then
					hPos = hPos + 1
					output = history[hPos]
					x = #output+1
				end
			end
		end
		if hPos > 1 then
			history[hPos] = output
		end
		if x+cx-xscroll+xmod > scr_x then
			xscroll = x-(scr_x-cx)+xmod
		elseif x-xscroll+xmod < 0 then
			repeat
				xscroll = xscroll - 1
			until x-xscroll-xmod >= 0
		end
	end
end

local checkValidName = function(_nayme)
	local nayme = textToBlit(_nayme,true)
	if type(nayme) ~= "string" then
		return false
	else
		return (#nayme >= 2 and #nayme <= 32 and nayme:gsub(" ","") ~= "")
	end
end

if tArg[1] == "update" then
	local res, message = updateEnchat(tArg[2] == "beta")
	return print(message)
end

local prettyClearScreen = function(start, stop)
	term.setTextColor(colors.lightGray)
	term.setBackgroundColor(colors.gray)
	if _VERSION then
		for y = start or 1, stop or scr_y do
			term.setCursorPos(1,y)
			if y == (start or 1) then
				term.write(("\135"):rep(scr_x))
			elseif y == (stop or scr_y) then
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

local prettyPrompt = function(prompt, y, replchar, doColor)
	local cy, cx = term.getCursorPos()
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	local yadj = 1 + prettyCenterWrite(prompt, y or cy)
	term.setCursorPos(1, y + yadj)
	term.setBackgroundColor(colors.lightGray)
	term.clearLine()
	local output
	if doColor then
		output = colorRead()
	else
		output = read(replchar)
	end
	return output
end

if not checkValidName(yourName) then --not so fast, evildoers
	yourName = nil
end

local currentY = 2

if not (yourName and encKey) then
	prettyClearScreen()
end

if not yourName then
	yourName = prettyPrompt("Enter your name.", currentY, nil, true)
	if not checkValidName(yourName) then
		while true do
			yourName = prettyPrompt("That name isn't valid. Enter another.", currentY, nil, true)
			if checkValidName(yourName) then
				break
			end
		end
	end
	currentY = currentY + 3
end

if not encKey then
	setEncKey(prettyPrompt("Enter an encryption key.", currentY, "*"))
	currentY = currentY + 3
end

--prevent terminating. It is reversed upon exit.
local oldePullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local bottomMessage = function(text)
	term.setCursorPos(1,scr_y)
	term.setTextColor(colors.gray)
	term.clearLine()
	term.write(text)
end

term.setBackgroundColor(colors.black)
term.clear()

-- AES API START (thank you SquidDev) --

local apipath = fs.combine(enchat.dataDir,"/api/aes")
if (not fs.exists(apipath)) then
	bottomMessage("AES API not found! Downloading...")
	local prog = http.get("http://pastebin.com/raw/9E5UHiqv")
	if not prog then
		bottomMessage("Failed to download AES. Abort.")
		term.setCursorPos(1,1)
		return
	end
	local file = fs.open(apipath,"w")
	file.write(prog.readAll())
	file.close()
end
if not aes then
	local res = os.loadAPI(apipath)
	if not res then
		bottomMessage("Failed to load AES. Abort.")
		term.setCursorPos(1,1)
		return
	end
end

-- AES API STOP (thanks again) --

-- SKYNET API START (thanks gollark) --

local skynet = true
apipath = fs.combine(enchat.dataDir,"/api/skynet")
if not fs.exists(apipath) then
	bottomMessage("Skynet API not found! Downloading...")
	local prog = http.get("https://raw.githubusercontent.com/osmarks/skynet/master/client.lua")
	if prog then
		local file = fs.open(apipath,"w")
		file.write(prog.readAll())
		file.close()
	else
		bottomMessage("Failed to download Skynet. Ignoring.")
		skynet = nil
	end
end
if skynet then
	skynet = dofile(apipath) --require my left asshole
	if encKey then
		bottomMessage("Connecting to Skynet...")
		skynet.open(enchat.skynetPort)
	end
end

-- SKYNET API STOP (thanks again) --

local log = {} --Records all sorts of data on text.
local renderlog = {} --Only records straight terminal output. Generated from 'log'
local IDlog = {} --Really only used with skynet, will prevent duplicate messages.

local scroll = 0
local maxScroll = 0

local getModem = function()
	if enchat.ignoreModem then
		return nil
	else
		local modems = {peripheral.find("modem")}
		return modems[1]
	end
end

local modem = getModem()
if (not modem) and (not enchat.ignoreModem) then
	if ccemux and (not enchat.ignoreModem) then
		ccemux.attach("top","wireless_modem")
		modem = getModem()
	elseif not skynet then
		error("You should get a modem.")
	end
end

if modem then modem.open(enchat.port) end

local modemTransmit = function(freq, repfreq, message)
	if modem then
		modem.transmit(freq, repfreq, message)
	end
end

local encrite = function(input) --standardized encryption function
	if not input then return input end
	return aes.encrypt(encKey, textutils.serialize(input))
end

local decrite = function(input)
	if not input then return input end
	return textutils.unserialize(aes.decrypt(encKey, input) or "")
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

local splitStr = function(str, maxLength)
	local output = {}
	for l = 1, #str, maxLength do
		output[#output+1] = str:sub(l,l+maxLength+-1)
	end
	return output
end

local splitStrTbl = function(tbl, maxLength)
	local output, tline = {}
	for w = 1, #tbl do
		tline = splitStr(tbl[w], maxLength)
		for t = 1, #tline do
			output[#output+1] = tline[t]
		end
	end
	return output
end

local blitWrap = function(char, text, back, noWrite)
	local cWords = splitStrTbl(explode(" ",char,nil, true), scr_x)
	local tWords = splitStrTbl(explode(" ",char,text,true), scr_x)
	local bWords = splitStrTbl(explode(" ",char,back,true), scr_x)
	
	local ox,oy = term.getCursorPos()
	local cx,cy,ty = ox,oy,1
	local scr_x, scr_y = term.getSize()
	local output = {}
	local length = 0
	local maxLength = 0
	for a = 1, #cWords do
		length = length + #cWords[a]
		maxLength = math.max(maxLength, length)
		if ((cx + #cWords[a]) > scr_x) then
			cx = 1
			length = 0
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
	return output, maxLength
end

local fwrite = function(text)
	term.blit(unpack(textToBlit(text)))
end

local cfwrite = function(text, y)
	local cx, cy = term.getCursorPos()
	term.setCursorPos((scr_x/2) - math.ceil(#textToBlit(text,true)/2), y or cy)
	fwrite(text)
end

local pictochat = function(xsize, ysize)
	local output = {{},{},{}}
	for y = 1, ysize do
		output[1][y] = {}
		output[2][y] = {}
		output[3][y] = {}
		for x = 1, xsize do
			output[1][y][x] = " "
			output[2][y][x] = " "
			output[3][y][x] = " "
		end
	end

	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.black)
	for y = 1, scr_y do
		term.setCursorPos(1,y)
		term.write(("/"):rep(scr_x))
	end
	cwrite(" [ENTER] to finish. ",scr_y)

	local cx, cy = math.floor((scr_x/2)-(xsize/2)), math.floor((scr_y/2)-(ysize/2))

	local allCols = "0123456789abcdef"
	local tPos, bPos = 16, 1
	local char, text, back = " ", allCols:sub(tPos,tPos), allCols:sub(bPos,bPos)

	local render = function()
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
		local mx, my
		for y = 1, ysize do
			for x = 1, xsize do
				mx, my = x+cx+-1, y+cy+-1
				term.setCursorPos(mx,my)
				term.blit(output[1][y][x], output[2][y][x], output[3][y][x])
			end
		end
		term.setCursorPos((scr_x/2)-5,ysize+cy+1)
		term.write("Char = '")
		term.blit(char, text, back)
		term.write("'")
	end
	local evt, butt, mx, my
	local isShiftDown = false

	render()

	while true do
		evt = {os.pullEvent()}
		if evt[1] == "mouse_click" or evt[1] == "mouse_drag" then
			butt, mx, my = evt[2], evt[3]-cx+1, evt[4]-cy+1
			if mx >= 1 and mx <= xsize and my >= 1 and my <= ysize then
				if butt == 1 then
					output[1][my][mx] = char
					output[2][my][mx] = text
					output[3][my][mx] = back
				elseif butt == 2 then
					output[1][my][mx] = " "
					output[2][my][mx] = " "
					output[3][my][mx] = " "
				end
				render()
			end
		elseif evt[1] == "mouse_scroll" then
			local oldTpos, oldBpos = tPos, bPos
			if isShiftDown then
				tPos = math.max(1, math.min(16, tPos + evt[2]))
			else
				bPos = math.max(1, math.min(16, bPos + evt[2]))
			end
			text, back = allCols:sub(tPos,tPos), allCols:sub(bPos,bPos)
			if oldTpos ~= tPos or oldBpos ~= bPos then
				render()
			end
		elseif evt[1] == "key" then
			if evt[2] == keys.enter then
				for y = 1, ysize do
					output[1][y] = table.concat(output[1][y])
					output[2][y] = table.concat(output[2][y])
					output[3][y] = table.concat(output[3][y])
				end
				local croppedOutput = {}
				local touched = false
				local crY = 0
				for a = 1, ysize do
					if output[1][1] == (" "):rep(xsize) and output[3][1] == (" "):rep(xsize) then
						table.remove(output[1],1)
						table.remove(output[2],1)
						table.remove(output[3],1)
					else
						for y = #output[1], 1, -1 do
							if output[1][y] == (" "):rep(xsize) and output[3][y] == (" "):rep(xsize) then
								table.remove(output[1],y)
								table.remove(output[2],y)
								table.remove(output[3],y)
							else
								break
							end
						end
						break
					end
				end
				return output
			elseif evt[2] == keys.leftShift then
				isShiftDown = true
			elseif evt[2] == keys.left or evt[2] == keys.right then
				local oldTpos, oldBpos = tPos, bPos
				if isShiftDown then
					tPos = math.max(1, math.min(16, tPos + (evt[2] == keys.right and 1 or -1)))
				else
					bPos = math.max(1, math.min(16, bPos + (evt[2] == keys.right and 1 or -1)))
				end
				text, back = allCols:sub(tPos,tPos), allCols:sub(bPos,bPos)
				if oldTpos ~= tPos or oldBpos ~= bPos then
					render()
				end
			end
		elseif evt[1] == "key_up" then
			if evt[2] == keys.leftShift then
				isShiftDown = false
			end
		elseif evt[1] == "char" then
			if char ~= evt[2] then
				char = evt[2]
				render()
			end
		end
	end
end

local notif = {}
notif.alpha = 248
notif.height = 10
notif.width = 6
notif.time = 40
notif.wrapX = 300
local nList = {}
local colorTranslate = {
	[" "] = {240, 240, 240},
	["0"] = {240, 240, 240},
	["1"] = {242, 178, 51 },
	["2"] = {229, 127, 216},
	["3"] = {153, 178, 242},
	["4"] = {222, 222, 108},
	["5"] = {127, 204, 25 },
	["6"] = {242, 178, 204},
	["7"] = {76,  76,  76 },
	["8"] = {153, 153, 153},
	["9"] = {76,  153, 178},
	["a"] = {178, 102, 229},
	["b"] = {51,  102, 204},
	["c"] = {127, 102, 76 },
	["d"] = {87,  166, 78 },
	["e"] = {204, 76,  76 },
	["f"] = {25,  25,  25 }
}
local interface, canvas = peripheral.find("neuralInterface")
if interface then
	if interface.canvas then
		canvas = interface.canvas()
		notif.newNotification = function(char, text, back, time)
			nList[#nList+1] = {char,text,back,time,1} --last one is alpha multiplier
		end
		notif.displayNotifications = function(doCountDown)
			local adjList = {
				["i"] = -4,
				["l"] = -3,
				["I"] = -1,
				["t"] = -2,
				["k"] = -1,
				["!"] = -4,
				["|"] = -4,
				["."] = -4,
				[","] = -4,
				[":"] = -4,
				[";"] = -4,
				["f"] = -1,
				["'"] = -3,
				["\""] = -1,
				["<"] = -1,
				[">"] = -1,
			}
			local drawEdgeLine = function(y,alpha)
				local l = canvas.addRectangle(notif.wrapX, 1+(y-1)*notif.height, 1, notif.height)
				l.setColor(unpack(colorTranslate["0"]))
				l.setAlpha(alpha / 2)
			end
			local getWordWidth = function(str)
				local output = 0
				for a = 1, #str do
					output = output + notif.width + (adjList[str:sub(a,a)] or 0)
				end
				return output
			end
			canvas.clear()
			local xadj, charadj, wordadj, t, r
			local x, y, words, txtwords, bgwords = 0, 0
			for n = math.min(#nList,16), 1, -1 do
				xadj, charadj = 0, 0
				y = y + 1
				x = 0
				words = explode(" ",nList[n][1],nil,true)
				txtwords = explode(" ",nList[n][1],nList[n][2],true)
				bgwords = explode(" ",nList[n][1],nList[n][3],true)
				local char, text, back
				local currentX = 0
				for w = 1, #words do
					char = words[w]
					text = txtwords[w]
					back = bgwords[w]
					if currentX + getWordWidth(char) > notif.wrapX then
						y = y + 1
						x = 2
						xadj = 0
						currentX = x * notif.width
					end
					for cx = 1, #char do
						x = x + 1
						charadj = (adjList[char:sub(cx,cx)] or 0)
						r = canvas.addRectangle(xadj+1+(x-1)*notif.width, 1+(y-1)*notif.height, charadj+notif.width, notif.height)
						if back:sub(cx,cx) ~= " " then
							r.setAlpha(notif.alpha * nList[n][5])
							r.setColor(unpack(colorTranslate[back:sub(cx,cx)]))
						else
							r.setAlpha(100 * nList[n][5])
							r.setColor(unpack(colorTranslate["7"]))
						end
						drawEdgeLine(y,notif.alpha * nList[n][5])
						t = canvas.addText({xadj+1+(x-1)*notif.width,2+(y-1)*notif.height}, char:sub(cx,cx))
						t.setAlpha(notif.alpha * nList[n][5])
						t.setColor(unpack(colorTranslate[text:sub(cx,cx)]))
						xadj = xadj + charadj
						currentX = currentX + charadj+notif.width
					end
				end
				if doCountDown then
					if nList[n][4] > 1 then
						nList[n][4] = nList[n][4] - 1
					else
						if nList[n][5] > 0 then
							while true do
								nList[n][5] = math.max(nList[n][5] - 0.2, 0)
								notif.displayNotifications(false)
								if nList[n][5] == 0 then break else sleep(0.05) end
							end
						end
						table.remove(nList,n)
					end
				end
			end
		end
	end
end

local animations = {
	slideFromLeft = function(char, text, back, frame, maxFrame, length)
		return {
			char:sub((length or #char) - ((frame/maxFrame)*(length or #char))),
			text:sub((length or #text) - ((frame/maxFrame)*(length or #text))),
			back:sub((length or #back) - ((frame/maxFrame)*(length or #back)))
		}
	end,
	fadeIn = function(char, text, back, frame, maxFrame, length)
		local fadeList = { -- works best on a black background with white text
			colors.gray,
			colors.lightGray,
			palette.txt
		}
		return {
			char,
			toblit[fadeList[math.max(1,math.ceil((frame/maxFrame)*#fadeList))]]:rep(#text),
			back
		}
	end,
	flash = function(char, text, back, frame, maxFrame, length)
		local t = palette.txt
		if frame ~= maxFrame then
			t = (frame % 2 == 0) and t or palette.bg
		end
		return {
			char,
			toblit[t]:rep(#text),
			(frame % 2 == 0) and back or (" "):rep(#back)
		}
	end,
	none = function(char, text, back, frame, maxFrame, length)
		return {
			char,
			text,
			back
		}
	end
}

local inAnimate = function(animType, buff, frame, maxFrame, length)
	local char, text, back = buff[1], buff[2], buff[3]
	if enchatSettings.doAnimate and (frame >= 0) and (maxFrame > 0) then
		return animations[animType or "slideFromleft"](char, text, back, frame, maxFrame, length)
	else
		return {char,text,back}
	end
end

local genRenderLog = function()
	local buff, prebuff, maxLength
	local scrollToBottom = scroll == maxScroll
	renderlog = {}
	term.setTextColor(palette.txt)
	term.setBackgroundColor(palette.bg)
	for a = 1, #log do
		term.setCursorPos(1,1)
		if UIconf.nameDecolor then
			local dcName = textToBlit(table.concat({log[a].prefix,log[a].name,log[a].suffix}), true)
			local dcMessage = textToBlit(log[a].message)
			prebuff = {
				dcName..dcMessage[1],
				toblit[palette.chevron]:rep(#dcName)..dcMessage[2],
				toblit[palette.bg]:rep(#dcName)..dcMessage[3]
			}
		else
			prebuff = textToBlit(table.concat({log[a].prefix,"&r~r",log[a].name,"&r~r",log[a].suffix,"&r~r",log[a].message}))
		end
		if (log[a].frame == 0) and (canvas and enchatSettings.doNotif) then
			if not (log[a].name == "" and log[a].message == "") then
				notif.newNotification(prebuff[1],prebuff[2],prebuff[3],notif.time * 4)
			end
		end
		if log[a].maxFrame == true then
			log[a].maxFrame = math.floor(math.min(#prebuff[1], scr_x) / enchatSettings.animDiv)
		end
		buff, maxLength = blitWrap(unpack(prebuff))
		--repeat every line in multiline entries
		for l = 1, #buff do
			--holy shit, two animations at once
			if log[a].animType then
				renderlog[#renderlog + 1] = inAnimate(log[a].animType, buff[l], log[a].frame, log[a].maxFrame, maxLength)
			else
				renderlog[#renderlog + 1] = inAnimate("fadeIn", inAnimate("slideFromLeft", buff[l], log[a].frame, log[a].maxFrame, maxLength), log[a].frame, log[a].maxFrame, maxLength)
			end
		end
		if (log[a].frame < log[a].maxFrame) and log[a].frame >= 0 then
			log[a].frame = log[a].frame + 1
		else
			log[a].frame = -1
		end
	end
	maxScroll = math.max(0, #renderlog - (scr_y - 2))
	if scrollToBottom then
		scroll = maxScroll
	end
end

local tsv = function(visible)
	if term.current().setVisible and enchatSettings.useSetVisible then
		return term.current().setVisible(visible)
	end
end

local renderChat = function(doScrollBackUp)
	tsv(false)
	genRenderLog(log)
	local ry
	term.setBackgroundColor(palette.bg)
	for y = UIconf.chatlogTop, (scr_y-UIconf.promptY) - 1 do
		ry = (y + scroll - (UIconf.chatlogTop - 1))
		term.setCursorPos(1,y)
		term.clearLine()
		if renderlog[ry] then
			term.blit(unpack(renderlog[ry]))
		end
	end
	if UIconf.promptY ~= 0 then
		term.setCursorPos(1,scr_y)
		term.setTextColor(palette.scrollMeter)
		term.clearLine()
		term.write(scroll.." / "..maxScroll.."  ")
	end
	
	UIconf.title = yourName.." on "..encKey
	
	if UIconf.doTitle then
		term.setTextColor(palette.chevron)
		if UIconf.nameDecolor then
			cwrite((" "):rep(scr_x)..textToBlit(UIconf.title, true)..(" "):rep(scr_x), 1)
		else
			local blTitle = textToBlit(UIconf.title)
			term.setCursorPos((scr_x/2) - math.ceil(#blTitle[1]/2), 1)
			term.clearLine()
			term.blit(unpack(blTitle))
		end
	end
	tsv(true)
end

local logadd = function(name, message, animType, maxFrame)
	log[#log + 1] = {
		prefix = name and "<" or "",
		suffix = name and "> " or "",
		name = name or "",
		message = message or " ",
		frame = 0,
		maxFrame = maxFrame or true,
		animType = animType
	}
end

local logaddTable = function(name, message, animType, maxFrame)
	if type(message) == "table" and type(name) == "string" then
		if #message > 0 then
			local isGood = true
			for l = 1, #message do
				if type(message[l]) ~= "string" then
					isGood = false
					break
				end
			end
			if isGood then
				logadd(name,message[1],animType,maxFrame)
				for l = 2, #message do
					logadd(nil,message[l],animType,maxFrame)
				end
			end
		end
	end
end

local makeRandomString = function(length)
	local output = ""
	for a = 1, length do
		output = output .. string.char(math.random(1,255))
	end
	return output
end

local enchatSend = function(name, message, doLog, animType, maxFrame, crying, recipient)
	if doLog then
		if type(message) == "string" then
			logadd(name, message, animType, maxFrame)
		else
			logaddTable(name, message, animType, maxFrame)
		end
	end
	local messageID = makeRandomString(64)
	local outmsg = encrite({
		name = name,
		message = message,
		version = enchat.version,
		animType = animType,
		maxFrame = maxFrame,
		messageID = messageID,
		recipient = recipient,
		cry = crying
	})
	IDlog[messageID] = true
	if not enchat.ignoreModem then modemTransmit(enchat.port, enchat.port, outmsg) end
	if skynet and enchatSettings.useSkynet then
		skynet.send(enchat.skynetPort, outmsg)
	end
end

local cryOut = function(name, crying)
	enchatSend(name, nil, false, nil, nil, crying)
end

local getPictureFile = function(path) --ONLY NFP or NFT
	if not fs.exists(path) then
		return false, "No such image."
	else
		local file = fs.open(path,"r")
		local content = file.readAll()
		file.close()
		local output
		if content:find("\31") and content:find("\30") then
			output = explode("\n",content:gsub("\31","&"):gsub("\30","~"),nil,false)
		else
			if content:lower():gsub("[0123456789abcdef\n ]","") ~= "" then
				return false, "Invalid image."
			else
				output = explode("\n",content:gsub("[^\n]","~%1 "),nil,false)
			end
		end
		return output
	end
end

local getTableLength = function(tbl)
	local output = 0
	for k,v in pairs(tbl) do
		output = output + 1
	end
	return output
end

local userCryList = {}

local commandInit = "/"
local commands = {}
--Commands only have one argument -- a single string.
--Separate arguments can be extrapolated with the explode() function.
commands.about = function()
	logadd(nil,"Enchat "..enchat.version.." by LDDestroier.")
	logadd(nil,"'Encrypted, decentralized chat program'")
	logadd(nil,"Made in 2018, out of gum and procrastination.")
end
commands.exit = function()
	enchatSend("*", "'"..yourName.."&r~r' buggered off. (disconnect)")
	return "exit"
end
commands.me = function(msg)
	if msg then
		enchatSend("&2*", yourName.."~r&2 "..msg, true)
	else
		logadd("*",commandInit.."me [message]")
	end
end
commands.colors = function()
	logadd("*", "&{Color codes: (use & or ~)&}")
	logadd(nil, "  &7~11~22~33~44~55~66~7&87~8&78~99~aa~bb~cc~dd~ee~ff")
end
commands.update = function()
	local res, message = updateEnchat()
	if res then
		enchatSend("*",yourName.."&r~r has updated and exited.")
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.clear()
		term.setCursorPos(1,1)
		print(message)
		return "exit"
	else
		logadd("*", res)
	end	
end
commands.picto = function(filename)
	local image, output, res
	local isEmpty
	if filename then
		output, res = getPictureFile(filename)
		if not output then
			logadd("*",res)
			return
		else
			table.insert(output,1,"")
		end
	else
		isEmpty = true
		output = {""}
		pauseRendering = true
		local image = pictochat(26,11)
		pauseRendering = false
		for y = 1, #image[1] do
			output[#output+1] = ""
			for x = 1, #image[1][1] do
				output[#output] = table.concat({output[#output],"&",image[2][y]:sub(x,x),"~",image[3][y]:sub(x,x),image[1][y]:sub(x,x)})
				isEmpty = isEmpty and (image[1][y]:sub(x,x) == " " and image[3][y]:sub(x,x) == " ")
			end
		end
	end
	if not isEmpty then
		enchatSend(yourName,output,true,"slideFromLeft")
	end
end
commands.list = function()
	userCryList = {}
	local tim = os.startTimer(0.5)
	cryOut(yourName, true)
	while true do
		local evt = {os.pullEvent()}
		if evt[1] == "timer" then
			if evt[2] == tim then
				break
			end
		end
	end
	if getTableLength(userCryList) == 0 then
		logadd(nil,"Nobody's there.")
	else
		for k,v in pairs(userCryList) do
			logadd(nil,"+'"..k.."'")
		end
	end
end
commands.nick = function(newName)
	if newName then
		if checkValidName(newName) then
			if newName == yourName then
				logadd("*","But you're already called that!")
			else
				enchatSend("*","'"..yourName.."&r~r' is now known as '"..newName.."&r~r'.", true)
				yourName = newName
			end
		else
			if #newName < 2 then
				logadd("*","That name is too damned small.")
			elseif #newName > 32 then
				logadd("*","Woah there, that name is too large.")
			end
		end
	else
		logadd("*",commandInit.."nick [newName]")
	end
end
commands.whoami = function(now)
	if now == "now" then
		logadd("*","You are still '"..yourName.."&r~r'!")
	else
		logadd("*","You are '"..yourName.."&r~r'!")
	end
end
commands.key = function(newKey)
	if newKey then
		if newKey ~= encKey then
			enchatSend("*", "'"..yourName.."&r~r' buggered off. (keychange)", false)
			setEncKey(newKey)
			logadd("*", "Key changed to '"..encKey.."&r~r'.")
			enchatSend("*", "'"..yourName.."&r~r' has moseyed on over.", false)
		else
			logadd("*", "That's already the key, though.")
		end
	else
		logadd("*","Key = '"..encKey.."&r~r'")
		logadd("*","Channel = '"..enchat.port.."'")
	end
end
commands.shrug = function(more)
	enchatSend(yourName, "¯\\_(?)_/¯"..(more or ""), true)
end
commands.asay = function(_argument)
	local sPoint = (_argument or ""):find(" ")
	if not sPoint then
		logadd("*","Animation types:")
		for k,v in pairs(animations) do
			logadd(nil," '"..k.."'")
		end
	else
		local animType = _argument:sub(1,sPoint-1)
		local message = _argument:sub(sPoint+1)
		local animFrameMod = {
			flash = 8,
			fadeIn = 4,
		}
		if animations[animType] then
			if textToBlit(message,true):gsub(" ","") ~= "" then
				enchatSend(yourName, message, true, animType, animFrameMod[animType])
			else
				logadd("*","That message is no good.")
			end
		else
			logadd("*","Invalid animation type.")
		end
	end
end
commands.msg = function(_argument)
	local sPoint = (_argument or ""):find(" ")
	if not sPoint then
		logadd("*",commandInit.."msg <recipient> <message>")
	else
		local recipient = _argument:sub(1,sPoint-1)
                local message = _argument:sub(sPoint+1)
		if not message then
			logadd("*","You got half of the arguments down pat, at least.")
		else
			if textToBlit(message,true):gsub(" ","") == "" then
				logadd("*","That message is no good.")
			else
				enchatSend(yourName, message, false, nil, nil, false, recipient)
				logadd("*","to '"..recipient.."': "..message)
			end
		end
	end
end
commands.palette = function(_argument)
	local argument = _argument or ""
	if argument:gsub("%s","") == "" then
		local buff = ""
		for k,v in pairs(palette) do
			buff = buff..k..", "
		end
		buff = buff:sub(1,-3)
		logadd("*",commandInit.."palette "..buff.." <colorcode>")
	else
		argument = explode(" ",argument)
		if #argument == 1 then
			if argument[1]:gsub("%s",""):lower() == "reset" then
				palette = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.gray,
					prompttxt = colors.white,
					scrollMeter = colors.lightGray,
					chevron = colors.black,
					title = colors.lightGray
				}
				UIconf = {
					promptY = 1,
					chevron = ">",
					chatlogTop = 1,
					title = "",
					doTitle = false,
					nameDecolor = false,
				}
				term.setBackgroundColor(palette.bg)
				term.clear()
				logadd("*","You cleansed your palette.")
				saveSettings()
			elseif argument[1]:gsub("%s",""):lower() == "enchat2" then
				palette = {
					bg = colors.gray,
					txt = colors.white,
					promptbg = colors.white,
					prompttxt = colors.black,
					scrollMeter = colors.white,
					chevron = colors.lightGray,
					title = colors.lightGray
				}
				UIconf = {
					promptY = 1,
					chevron = ">",
					chatlogTop = 1,
					title = "",
					doTitle = false,
					nameDecolor = false,
				}
				term.setBackgroundColor(palette.bg)
				term.clear()
				logadd("*","Switched to the old Enchat2 palette.")
				saveSettings()
			elseif argument[1]:gsub("%s",""):lower() == "chat.lua" then
				palette = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.black,
					prompttxt = colors.white,
					scrollMeter = colors.white,
					chevron = colors.yellow,
					title = colors.yellow
				}
				UIconf = {
					promptY = 0,
					chevron = ": ",
					chatlogTop = 2,
					title = "",
					doTitle = true,
					nameDecolor = true,
				}
				term.setBackgroundColor(palette.bg)
				term.clear()
				logadd("*","Switched to /rom/programs/rednet/chat.lua palette.")
				saveSettings()
			else
				if not palette[argument[1]] then
					logadd("*","There's no such palette option.")
				else
					logadd("*","'"..argument[1].."' = '"..toblit[palette[argument[1]]].."'")
				end
			end
		else
			if #argument > 2 then
				argument = {argument[1], table.concat(argument," ",2)}
			end
			argument[1] = argument[1]:lower()
			local newcol = argument[2]:lower()
			if not palette[argument[1]] then
				logadd("*","That's not a valid palette choice.")
			else
				if not (tocolors[newcol] or colors_strnames[newcol]) then
					logadd("*","That isn't a valid color code. (0-f)")
				else
					palette[argument[1]] = (tocolors[newcol] or colors_strnames[newcol])
					logadd("*","Palette changed.",false)
					saveSettings()
				end
			end
		end
	end
end
commands.clear = function()
	log = {}
	IDlog = {}
end
commands.ping = function(pong)
	logadd(nil, pong or "Pong!")
end
commands.set = function(_argument)
	argument = _argument or ""
	local collist = {
		["string"] = function() return "0" end,
		["table"] = function() return "5" end,
		["number"] = function() return "0" end,
		["boolean"] = function(val) if val then return "d" else return "e" end end,
		["function"] = function() return "c" end,
		["nil"] = function() return "8" end,
		["thread"] = function() return "d" end,
		["userdata"] = function() return "c" end, --ha
	}
	local custColorize = function(input)
		return "&"..collist[type(input)](input)
	end
	local contextualQuote = function(judgetxt,txt)
		if type(judgetxt) == "string" then
			return table.concat({"'",txt,"'"})
		else
			return txt
		end
	end
	local arguments = explode(" ",argument)
	if #argument == 0 then
		for k,v in pairs(enchatSettings) do
			logadd(nil,"&4'"..k.."'&r = "..contextualQuote(v,custColorize(v)..tostring(v).."&r"))
		end
	else
		if enchatSettings[arguments[1]] ~= nil then
			if #arguments >= 2 then
				local newval = table.concat(arguments," ",2)
				if tonumber(newval) then
					newval = tonumber(newval)
				elseif textutils.unserialize(newval) ~= nil then
					newval = textutils.unserialize(newval)
				end
				if type(enchatSettings[arguments[1]]) == type(newval) then
					enchatSettings[arguments[1]] = newval
					logadd("*","Set '&4"..arguments[1].."&r' to &{"..contextualQuote(newval,textutils.serialize(newval).."&}").." ("..type(newval)..")")
					saveSettings()
				else
					logadd("*","Wrong value type (it's "..type(enchatSettings[arguments[1]])..")")
				end
			else
				logadd("*","'"..arguments[1].."' is set to "..contextualQuote(enchatSettings[arguments[1]],custColorize(enchatSettings[arguments[1]])..textutils.serialize(enchatSettings[arguments[1]]).."&r").." ("..type(enchatSettings[arguments[1]])..")")
			end
		else
			logadd("*","No such setting.")
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
			nick = "Give yourself a different username.",
			whoami = "Tells you your current username.",
			key = "Change the current encryption key. Tells you the key, if without argument.",
			clear = "Clears the local chat log. Not your inventory, I swear.",
			ping = "Pong. *sigh*",
			shrug = "Sends out a shrugging emoticon.",
			set = "Changes config options during the current session. Lists all options, if without argument.",
			msg = "Sends a message that is only logged by a specific user.",
			picto = "Opens an image maker and sends the result. Use the scroll wheel to change color, and hold left shift to change text color. If argument given, will look for an image at the given path and use that instead.",
			help = "Shows every command, or describes a specific command.",
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
commandAliases = {
	quit = commands.exit,
	colours = commands.colors,
	ls = commands.list,
	cry = commands.list,
	nickname = commands.nick,
	channel = commands.key,
	palate = commands.palette,
	tell = commands.msg,
	whisper = commands.msg,
	["?"] = commands.help,
	porn = function() 	logadd("*","Yeah, no.") end,
	whoareyou = function() 	logadd("*", "I'm Enchat. But surely, you know this?") end,
	fuck = function() 	logadd("*","A mind is a terrible thing to waste.") end,
	hello = function() 	logadd("*","Hey.") end,
	hi = function() 	logadd("*","Hiya.") end,
	hey = function() 	logadd("*","That's for horses.") end,
	bye = function() 	logadd("*","You know, you can use /exit.") end,
	die = function() 	logadd("*","You wish.") end,
	nap = function() 	logadd("*","The time for napping has passed.") end,
	sorry = function() 	logadd("*","That's okay.") end,
	jump = function() 	logadd("*","Sorry. This program is in a NO JUMPING zone.") end,
	enchat = function() 	logadd("*","At your service!") end,
	win = function() 	logadd("*","Naturally!") end,
	lose = function() 	logadd("*","Preposterous!") end,
	xyzzy = function() 	logadd("*","A hollow voice says \"Fool.\"") end,
	wait = function() 	logadd("*","Time passes...") end,
	stop = function() 	logadd("*","Hammertime!","fadeIn") end,
	shit = function() 	logadd("*","Man, you're telling me!") end,
	eat = function() 	logadd("*","You're not hungry.") end,
	what = function() 	logadd("*","What indeed.") end,
	OrElseYouWill = function()
		enchatSend("*", "'"..yourName.."&r~r' buggered off. (disconnect)")
		error("DIE")
	end
}

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
	local CMD = commands[cmdName] or commandAliases[cmdName]
	if CMD then
		res = CMD(cmdArgs)
		if res == "exit" then
			return "exit"
		end
	else
		logadd("*", "No such command.")
	end
end

local main = function()
	term.setBackgroundColor(palette.bg)
	term.clear()
	os.queueEvent("render_enchat")
	local mHistory = {}
	
	while true do
		
		term.setCursorPos(1, scr_y-UIconf.promptY)
		term.setBackgroundColor(palette.promptbg)
		term.clearLine()
		term.setTextColor(palette.chevron)
		term.write(UIconf.chevron)
		term.setTextColor(palette.prompttxt)
		
		local input = colorRead(nil, mHistory)
		if UIconf.promptY == 0 then
			term.scroll(1)
		end
		if textToBlit(input,true):gsub(" ","") ~= "" then --people who send blank messages in chat programs deserve to die
			if checkIfCommand(input) then
				local res = parseCommand(input)
				if res == "exit" then
					return "exit"
				end
			else
				if enchatSettings.extraNewline then
					logadd(nil,nil) --readability
				end
				enchatSend(yourName, input, true)
			end
			if mHistory[#mHistory] ~= input then
				mHistory[#mHistory+1] = input
			end
		elseif input == "" then
			logadd(nil,nil)
		end
		os.queueEvent("render_enchat")
		
	end
	
end

local handleReceiveMessage = function(user, message, animType, maxFrame)
	if enchatSettings.extraNewline then
		logadd(nil,nil) --readability
	end
	logadd(user, message,animations[animType] and animType or nil,(type(maxFrame) == "number") and maxFrame or nil)
	os.queueEvent("render_enchat")
end

local adjScroll = function(distance)
	scroll = math.min(maxScroll, math.max(0, scroll + distance))
end

local handleEvents = function()
	local oldScroll
	local keysDown = {}
	while true do
		local evt = {os.pullEvent()}
		if evt[1] == "enchat_receive" then
			if type(evt[2]) == "string" and type(evt[3]) == "string" then
				handleReceiveMessage(evt[2], evt[3])
			end
		elseif (evt[1] == "modem_message") or (evt[1] == "skynet_message" and enchatSettings.useSkynet) then
			local side, freq, repfreq, msg, distance
			if evt[1] == "modem_message" then
				side, freq, repfreq, msg, distance = evt[2], evt[3], evt[4], evt[5], evt[6]
			else
				freq, msg = evt[2], evt[3]
			end
			msg = decrite(msg)
			if (freq == enchat.port) or (freq == enchat.skynetPort) then
				if type(msg) == "table" then
					if (type(msg.name) == "string") then
						if #msg.name <= 32 then
							if msg.messageID and (not IDlog[msg.messageID]) then
								userCryList[msg.name] = true
								IDlog[msg.messageID] = true
								if ((not msg.recipient) or (msg.recipient == yourName or msg.recipient == textToBlit(yourName,true))) then
									if type(msg.message) == "string" then
										handleReceiveMessage(msg.name, tostring(msg.message), msg.animType, msg.maxFrame)
									elseif type(msg.message) == "table" and enchatSettings.acceptPictoChat and #msg.message <= 64 then
										logaddTable(msg.name, msg.message)
										if enchatSettings.extraNewline then
											logadd(nil,nil)
										end
									end
								end
								if (msg.cry == true) then
									cryOut(yourName, false)
								end
							end
						end
					end
				end
			end
		elseif evt[1] == "mouse_scroll" then
			local dist = evt[2]
			oldScroll = scroll
			adjScroll(enchatSettings.reverseScroll and -dist or dist)
			if scroll ~= oldScroll then
				dab(renderChat)
			end
		elseif evt[1] == "key" then
			local key = evt[2]
			keysDown[key] = true
			oldScroll = scroll
			if key == keys.pageUp then
				adjScroll(-enchatSettings.pageKeySpeed)
			elseif key == keys.pageDown then
				adjScroll(enchatSettings.pageKeySpeed)
			end
			if scroll ~= oldScroll then
				dab(renderChat)
			end
		elseif evt[1] == "key_up" then
			local key = evt[2]
			keysDown[key] = nil
		elseif (evt[1] == "render_enchat") then
			dab(renderChat)
		elseif evt[1] == "terminate" then
			return "exit"
		end
	end
end

local keepRedrawing = function()
	while true do
		sleep(enchatSettings.redrawDelay)
		if not pauseRendering then
			os.queueEvent("render_enchat")
		end
	end
end

local handleNotifications = function()
	while true do
		os.pullEvent("render_enchat")
		if canvas and enchatSettings.doNotif then
			notif.displayNotifications(true)
		end
	end
end

loadSettings()
saveSettings()

getModem()

enchatSend("*", "'"..yourName.."&r~r' has moseyed on over.", true)

local funky = {
	main,
	handleEvents,
	keepRedrawing,
	handleNotifications
}

if skynet then
	funky[#funky+1] = skynet.listen
end

local res, outcome = pcall(function()
	return parallel.waitForAny(unpack(funky))
end)

os.pullEvent = oldePullEvent
if skynet then
	if skynet.socket then
		skynet.socket.close()
	end
end

if canvas then
	canvas.clear()
end

tsv(true) --in case it's false

if not res then
	prettyClearScreen(1,scr_y-1)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.gray)
	cwrite("There was an error.",2)
	cfwrite("Report this to &3@LDDestroier#2901&r",3)
	cwrite("on Discord,",4)
	cwrite("if you feel like it.",5)
	term.setCursorPos(1,7)
	printError(outcome)
	term.setTextColor(colors.lightGray)
	cwrite("I'll probably fix it, maybe.",10)
end

term.setCursorPos(1,scr_y)
term.setBackgroundColor(initcolors.bg)
term.setTextColor(initcolors.txt)
term.clearLine()
