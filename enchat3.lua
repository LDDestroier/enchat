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
	betaurl = "https://github.com/LDDestroier/enchat/raw/beta/enchat3.lua",
	ignoreModem = false,
	dataDir = "/.enchat"
}

local enchatSettings = {	-- DEFAULT settings.
	animDiv = 4,		-- divisor of text animation speed (scrolling from left)
	doAnimate = true,	-- whether or not to animate text moving from left side of screen
	reverseScroll = false,	-- whether or not to make scrolling up really scroll down
	redrawDelay = 0.25,	-- delay between redrawing
	useSetVisible = true,	-- whether or not to use term.current().setVisible(), which has performance and flickering improvements
	pageKeySpeed = 8,	-- how far PageUP or PageDOWN should scroll
	doNotif = true,		-- whether or not to use oveerlay glasses for notifications, if possible
	doKrazy = true,		-- whether or not to add &k obfuscation
	useSkynet = false,	-- whether or not to use gollark's Skynet in addition to modem calls
	extraNewline = true,	-- adds an extra newline after every message since setting to true
	acceptPictoChat = true	-- whether or not to allow tablular enchat input, which is what /picto uses
}

local palette = {
	bg = colors.black,		-- background color
	txt = colors.white,		-- text color (should contrast with bg)
	promptbg = colors.gray,		-- chat prompt background
	prompttxt = colors.white,	-- chat prompt text
	scrollMeter = colors.lightGray,	-- scroll indicator
	chevron = colors.black,		-- color of ">" left of text prompt
	title = colors.lightGray	-- color of title, if available
}

UIconf = {
	promptY = 1,		-- Y position of read prompt, relative to bottom of screen
	chevron = ">",		-- symbol before read prompt
	chatlogTop = 1,		-- where chatlog is written to screen, relative to top of screen
	title = "",		-- overwritten every render, don't bother here
	doTitle = false,	-- whether or not to draw UIconf.title at the top of the screen
	nameDecolor = false,	-- if true, sets all names to palette.chevron color
}

-- Attempt to get some slight optimization through localizing basic functions.
local mathmax, mathmin, mathrandom = math.max, math.min, math.random
local termblit, termwrite = term.blit, term.write
local termsetCursorPos, termgetCursorPos, termsetCursorBlink = term.setCursorPos, term.getCursorPos, term.setCursorBlink
local termsetTextColor, termsetBackgroundColor = term.setTextColor, term.setBackgroundColor
local termgetTextColor, termgetBackgroundColor = term.getTextColor, term.getBackgroundColor
local termclear, termclearLine = term.clear, term.clearLine
local tableinsert, tableremove, tableconcat = table.insert, table.remove, table.concat
local textutilsserialize, textutilsunserialize = textutils.serialize, textutils.unserialize
local stringsub, stringgsub, stringrep = string.sub, string.gsub, string.rep
local unpack = unpack
-- This better do something.

local saveSettings = function()
	local file = fs.open(fs.combine(enchat.dataDir, "settings"), "w")
	file.write(textutilsserialize({
		enchatSettings = enchatSettings,
		palette = palette,
		UIconf = UIconf
	}))
	file.close()
end

local loadSettings = function()
	local contents
	if not fs.exists(fs.combine(enchat.dataDir, "settings")) then
		saveSettings()
	end
	local file = fs.open(fs.combine(enchat.dataDir, "settings"), "r")
	contents = file.readAll()
	file.close()
	local newSettings = textutilsunserialize(contents)
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
	bg = termgetBackgroundColor(),
	txt = termgetTextColor()
}

local tArg = {...}

local yourName = tArg[1]
local encKey = tArg[2]

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

local pauseRendering = true

-- primarily for use when coloring palette
local colors_strnames = {
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
	["r"] = "reset",		-- Sets either the text (&) or background (~) colors to their original color.
	["{"] = "stopFormatting",	-- Toggles formatting text off
	["}"] = "startFormatting",	-- Toggles formatting text on
	["k"] = "krazy"			-- Makes the font kuh-razy!
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
-- check if using older CC version, omit special characters if it's too old
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

local explode = function(div, str, replstr, includeDiv)
	if (div == '') then
		return false
	end
	local pos, arr = 0, {}
	for st, sp in function() return string.find(str, div, pos, false) end do
		tableinsert(arr, string.sub(replstr or str, pos, st - 1 + (includeDiv and #div or 0)))
		pos = sp + 1
	end
	tableinsert(arr, string.sub(replstr or str, pos))
	return arr
end
local parseKrazy = function(c)
	if kraziez[c] then
		return kraziez[c][mathrandom(1, #kraziez[c])]
	else
		return kraziez.all[mathrandom(1, #kraziez.all)]
	end
end

local textToBlit = function(input, onlyString, initText, initBack, checkPos)
	if not input then return end
	checkPos = checkPos or -1
	initText, initBack = initText or toblit[term.getTextColor()], initBack or toblit[term.getBackgroundColor()]
	tcode, bcode = "&", "~"
	local cpos, cx = 0, 0
	local skip, ignore, krazy, ex = nil, false, false, nil
	local text, back, nex = initText, initBack, nil
	local charOut, textOut, backOut = {}, {}, {}
	local codes = {
		["r"] = function(prev)
			if not ignore then
				if prev == tcode then
					text = initText
				elseif prev == bcode then
					back = initBack
				end
				krazy = false
			else
				return 0
			end
		end,
		["{"] = function(prev)
			if not ignore then
				ignore = true
			else
				return 0
			end
		end,
		["}"] = function(prev)
			if ignore then
				ignore = false
			else
				return 0
			end
		end,
		["k"] = function(prev)
			if not ignore then
				krazy = not krazy
			else
				return 0
			end
		end
	}
	local sx, str = 0
	for cx = 1, #input do
		str = stringsub(input,cx,cx)
		if skip then
			if tocolors[str] and not ignore then
				if skip == tcode then
					text = str
					if sx < checkPos then
						cpos = cpos - 2
					end
				elseif skip == bcode then
					back = str
					if sx < checkPos then
						cpos = cpos - 2
					end
				end
			elseif codes[str] and (not ignore or str == "}") then
				ex = codes[str](skip) or 0
				sx = sx + ex
    			if sx < checkPos then
    				cpos = cpos - ex - 2
                end
			else
                sx = sx + 1
                charOut[sx] = krazy and parseKrazy(prev..str) or (skip..str)
                textOut[sx] = stringrep(text,2)
                backOut[sx] = stringrep(back,2)
            end
			skip = nil
		else
			if (str == tcode or str == bcode) and (codes[stringsub(input, 1+cx, 1+cx)] or tocolors[stringsub(input,1+cx,1+cx)]) then
				skip = str
			else
				sx = sx + 1
				charOut[sx] = krazy and parseKrazy(str) or str
				textOut[sx] = text
				backOut[sx] = back
			end
		end
	end
	if onlyString then
		return tableconcat(charOut), (checkPos > -1) and cpos or nil
	else
		return {tableconcat(charOut), tableconcat(textOut), tableconcat(backOut)}, (checkPos > -1) and cpos or nil
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
	local cx, cy = termgetCursorPos()
	local x, xscroll = 1, 1
	local ctrlDown = false
	termsetCursorBlink(true)
	local evt, key, bout, xmod, timtam
	while true do
		termsetCursorPos(cx, cy)
		bout, xmod = textToBlit(output, false, nil, nil, x)
		for a = 1, #bout do
			bout[a] = bout[a]:sub(xscroll, xscroll + scr_x - cx)
		end
		termblit(unpack(bout))
		termwrite((" "):rep(scr_x - cx))
		termsetCursorPos(cx + x + xmod - xscroll, cy)
		evt = {os.pullEvent()}
		if evt[1] == "char" or evt[1] == "paste" then
			output = (output:sub(1, x-1)..evt[2]..output:sub(x)):sub(1, maxLength or -1)
			x = mathmin(x + #evt[2], #output+1)
		elseif evt[1] == "key" then
			key = evt[2]
			if key == keys.leftCtrl then
				ctrlDown = true
			elseif key == keys.left then
				x = mathmax(x - 1, 1)
			elseif key == keys.right then
				x = mathmin(x + 1, #output+1)
			elseif key == keys.backspace then
				if x > 1 then
					repeat
						output = output:sub(1,x-2)..output:sub(x)
						x = x - 1
					until output:sub(x-1,x-1) == " " or (not ctrlDown) or (x == 1)
				end
			elseif key == keys.delete then
				if x < #output+1 then
					repeat
						output = output:sub(1,x-1)..output:sub(x+1)
					until output:sub(x,x) == " " or (not ctrlDown) or (x == #output+1)
				end
			elseif key == keys.enter then
				termsetCursorBlink(false)
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
		elseif evt[1] == "key_up" then
			if evt[2] == keys.leftCtrl then
				ctrlDown = false
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
		xscroll = math.max(1, xscroll)
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
	termsetTextColor(colors.lightGray)
	termsetBackgroundColor(colors.gray)
	if _VERSION then
		for y = start or 1, stop or scr_y do
			termsetCursorPos(1,y)
			if y == (start or 1) then
				termwrite(("\135"):rep(scr_x))
			elseif y == (stop or scr_y) then
				termsetTextColor(colors.gray)
				termsetBackgroundColor(colors.lightGray)
				termwrite(("\135"):rep(scr_x))
			else
				termclearLine()
			end
		end
	else
		termclear()
	end
end

local cwrite = function(text, y)
	local cx, cy = termgetCursorPos()
	termsetCursorPos((scr_x/2) - math.ceil(#text/2), y or cy)
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
	local cy, cx = termgetCursorPos()
	termsetBackgroundColor(colors.gray)
	termsetTextColor(colors.white)
	local yadj = 1 + prettyCenterWrite(prompt, y or cy)
	termsetCursorPos(1, y + yadj)
	termsetBackgroundColor(colors.lightGray)
	termclearLine()
	local output
	if doColor then
		output = colorRead()
	else
		output = read(replchar)
	end
	return output
end

local fwrite = function(text)
	local b = textToBlit(text)
	return termblit(unpack(b))
end

local cfwrite = function(text, y)
	local cx, cy = termgetCursorPos()
	termsetCursorPos((scr_x/2) - math.ceil(#textToBlit(text,true)/2), y or cy)
	return fwrite(text)
end

if not checkValidName(yourName) then -- not so fast, evildoers
	yourName = nil
end

local currentY = 2

if not (yourName and encKey) then
	prettyClearScreen()
end

if not yourName then
    cfwrite("&8~7Text = &, Background = ~", scr_y-2)
    cfwrite("&7~00~11~22~33~44~55~66&8~77&7~88~99~aa~bb~cc~dd~ee~ff", scr_y-1)
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

-- prevent terminating. It is reversed upon exit.
local oldePullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local bottomMessage = function(text)
	termsetCursorPos(1,scr_y)
	termsetTextColor(colors.gray)
	termclearLine()
	termwrite(text)
end

loadSettings()
saveSettings()

termsetBackgroundColor(colors.black)
termclear()

-- AES API START (thank you SquidDev) --

local apipath = fs.combine(enchat.dataDir,"/api/aes")
if (not fs.exists(apipath)) then
	bottomMessage("AES API not found! Downloading...")
	local prog = http.get("http://pastebin.com/raw/9E5UHiqv")
	if not prog then
		bottomMessage("Failed to download AES. Abort.")
		termsetCursorPos(1,1)
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
		termsetCursorPos(1,1)
		return
	end
end

-- AES API STOP (thanks again) --

-- SKYNET API START (thanks gollark) --

local skynet
local downloadSkynet = function()
	skynet = true
	local apipath = fs.combine(enchat.dataDir,"/api/skynet")
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
		_G.skynet_CBOR_path = fs.combine(enchat.dataDir,"/api/cbor")
		skynet = dofile(apipath) -- require my left asshole
		if encKey then
			bottomMessage("Connecting to Skynet...")
			local success, msg = pcall(skynet.open, enchat.skynetPort)
			if not success then
				bottomMessage("Failed to connect to skynet. ("..(msg or "?")..")")
				skynet = nil
			end
		end
	end
end

downloadSkynet()

-- SKYNET API STOP (thanks again) --

local log = {} 		-- Records all sorts of data on text.
local renderlog = {} 	-- Only records straight terminal output. Generated from 'log'
local IDlog = {} 	-- Really only used with skynet, will prevent duplicate messages.

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

local encrite = function(input) -- standardized encryption function
	if not input then return input end
	return aes.encrypt(encKey, textutilsserialize(input))
end

local decrite = function(input) -- redundant comments cause tuberculosis
	if not input then return input end
	return textutilsunserialize(aes.decrypt(encKey, input) or "")
end

local dab = function(func, ...) -- "do and back", not...never mind
	local x, y = termgetCursorPos()
	local b, t = termgetBackgroundColor(), termgetTextColor()
	local output = {func(...)}
	termsetCursorPos(x,y)
	termsetTextColor(t)
	termsetBackgroundColor(b)
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

local blitWrap = function(char, text, back, noWrite) -- where ALL of the onscreen wrapping is done
	local cWords = splitStrTbl(explode(" ",char,nil, true), scr_x)
	local tWords = splitStrTbl(explode(" ",char,text,true), scr_x)
	local bWords = splitStrTbl(explode(" ",char,back,true), scr_x)

	local ox,oy = termgetCursorPos()
	local cx,cy,ty = ox,oy,1
	local output = {}
	local length = 0
	local maxLength = 0
	for a = 1, #cWords do
		length = length + #cWords[a]
		maxLength = mathmax(maxLength, length)
		if ((cx + #cWords[a]) > scr_x) then
			cx = 1
			length = 0
			if (cy == scr_y) then
				term.scroll(1)
			end
			cy = mathmin(cy+1, scr_y)
			ty = ty + 1
		end
		if not noWrite then
			termsetCursorPos(cx,cy)
			termblit(cWords[a],tWords[a],bWords[a])
		end
		cx = cx + #cWords[a]
		output[ty] = output[ty] or {"","",""}
		output[ty][1] = output[ty][1]..cWords[a]
		output[ty][2] = output[ty][2]..tWords[a]
		output[ty][3] = output[ty][3]..bWords[a]
	end
	return output, maxLength
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

	termsetBackgroundColor(colors.gray)
	termsetTextColor(colors.black)
	for y = 1, scr_y do
		termsetCursorPos(1, y)
		termwrite(("/"):rep(scr_x))
	end
	cwrite(" [ENTER] to finish. ", scr_y)
	cwrite("Push a key to change char.", scr_y-1)

	local cx, cy = math.floor((scr_x/2)-(xsize/2)), math.floor((scr_y/2)-(ysize/2))

	local allCols = "0123456789abcdef"
	local tPos, bPos = 16, 1
	local char, text, back = " ", allCols:sub(tPos,tPos), allCols:sub(bPos,bPos)

	local render = function()
		termsetTextColor(colors.white)
		termsetBackgroundColor(colors.black)
		local mx, my
		for y = 1, ysize do
			for x = 1, xsize do
				mx, my = x+cx+-1, y+cy+-1
				termsetCursorPos(mx,my)
				termblit(output[1][y][x], output[2][y][x], output[3][y][x])
			end
		end
		termsetCursorPos((scr_x/2)-5,ysize+cy+1)
		termwrite("Char = '")
		termblit(char, text, back)
		termwrite("'")
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
				tPos = mathmax(1, mathmin(16, tPos + evt[2]))
			else
				bPos = mathmax(1, mathmin(16, bPos + evt[2]))
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
						tableremove(output[1],1)
						tableremove(output[2],1)
						tableremove(output[3],1)
					else
						for y = #output[1], 1, -1 do
							if output[1][y] == (" "):rep(xsize) and output[3][y] == (" "):rep(xsize) then
								tableremove(output[1],y)
								tableremove(output[2],y)
								tableremove(output[3],y)
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
					tPos = mathmax(1, mathmin(16, tPos + (evt[2] == keys.right and 1 or -1)))
				else
					bPos = mathmax(1, mathmin(16, bPos + (evt[2] == keys.right and 1 or -1)))
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
			nList[#nList+1] = {char,text,back,time,1} -- the last one is the alpha multiplier
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
			for n = mathmin(#nList,16), 1, -1 do
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
								nList[n][5] = mathmax(nList[n][5] - 0.2, 0)
								notif.displayNotifications(false)
								if nList[n][5] == 0 then break else sleep(0.05) end
							end
						end
						tableremove(nList,n)
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
			toblit[fadeList[mathmax(1,math.ceil((frame/maxFrame)*#fadeList))]]:rep(#text),
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
	for a = 1, #log do
		termsetCursorPos(1,1)
		if UIconf.nameDecolor then
			local dcName = textToBlit(table.concat({log[a].prefix,log[a].name,log[a].suffix}), true, toblit[palette.txt], toblit[palette.bg])
			local dcMessage = textToBlit(log[a].message, false, toblit[palette.txt], toblit[palette.bg])
			prebuff = {
				dcName..dcMessage[1],
				toblit[palette.chevron]:rep(#dcName)..dcMessage[2],
				toblit[palette.bg]:rep(#dcName)..dcMessage[3]
			}
		else
			prebuff = textToBlit(table.concat(
				{log[a].prefix, "&}&r~r", log[a].name, "&}&r~r", log[a].suffix, "&}&r~r", log[a].message}
			), false, toblit[palette.txt], toblit[palette.bg])
		end
		if (log[a].frame == 0) and (canvas and enchatSettings.doNotif) then
			if not (log[a].name == "" and log[a].message == " ") then
				notif.newNotification(prebuff[1],prebuff[2],prebuff[3],notif.time * 4)
			end
		end
		if log[a].maxFrame == true then
			log[a].maxFrame = math.floor(mathmin(#prebuff[1], scr_x) / enchatSettings.animDiv)
		end
		if log[a].ignoreWrap then
			buff, maxLength = {prebuff}, mathmin(#prebuff[1], scr_x)
		else
			buff, maxLength = blitWrap(prebuff[1], prebuff[2], prebuff[3], true)
		end
		-- repeat every line in multiline entries
		for l = 1, #buff do
			-- holy shit, two animations, lookit mr. roxas over here
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
	maxScroll = mathmax(0, #renderlog - (scr_y - 2))
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
	termsetCursorBlink(false)
	genRenderLog(log)
	local ry
	termsetBackgroundColor(palette.bg)
	for y = UIconf.chatlogTop, (scr_y-UIconf.promptY) - 1 do
		ry = (y + scroll - (UIconf.chatlogTop - 1))
		termsetCursorPos(1,y)
		termclearLine()
		if renderlog[ry] then
			termblit(unpack(renderlog[ry]))
		end
	end
	if UIconf.promptY ~= 0 then
		termsetCursorPos(1,scr_y)
		termsetTextColor(palette.scrollMeter)
		termclearLine()
		termwrite(scroll.." / "..maxScroll.."  ")
	end

	UIconf.title = yourName.." on "..encKey

	if UIconf.doTitle then
		termsetTextColor(palette.chevron)
		if UIconf.nameDecolor then
			cwrite((" "):rep(scr_x)..textToBlit(UIconf.title, true)..(" "):rep(scr_x), 1)
		else
			local blTitle = textToBlit(UIconf.title)
			termsetCursorPos((scr_x/2) - math.ceil(#blTitle[1]/2), 1)
			termclearLine()
			termblit(unpack(blTitle))
		end
	end
	termsetCursorBlink(true)
	tsv(true)
end

local logadd = function(name, message, animType, maxFrame, ignoreWrap)
	log[#log + 1] = {
		prefix = name and "<" or "",
		suffix = name and "> " or "",
		name = name or "",
		message = message or " ",
		ignoreWrap = ignoreWrap,
		frame = 0,
		maxFrame = maxFrame or true,
		animType = animType
	}
end

local logaddTable = function(name, message, animType, maxFrame, ignoreWrap)
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
				logadd(name,message[1],animType,maxFrame,ignoreWrap)
				for l = 2, #message do
					logadd(nil,message[l],animType,maxFrame,ignoreWrap)
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

local enchatSend = function(name, message, doLog, animType, maxFrame, crying, recipient, ignoreWrap)
	if doLog then
		if type(message) == "string" then
			logadd(name, message, animType, maxFrame, ignoreWrap)
		else
			logaddTable(name, message, animType, maxFrame, ignoreWrap)
		end
	end
	local messageID = makeRandomString(64)
	local outmsg = encrite({
		name = name,
		message = message,
		animType = animType,
		maxFrame = maxFrame,
		messageID = messageID,
		recipient = recipient,
		ignoreWrap = ignoreWrap,
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

local getPictureFile = function(path) -- ONLY NFP or NFT, fuck BLT
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
-- Commands only have one argument, being a single string.
-- Separate arguments can be extrapolated with the explode() function.
commands.about = function()
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	logadd(nil,"Enchat "..enchat.version.." by LDDestroier.")
	logadd(nil,"'Encrypted, decentralized, &1c&2o&3l&4o&5r&6i&7z&8e&9d&r chat program'")
	logadd(nil,"Made in 2018, out of gum and procrastination.")
	logadd(nil,nil)
	logadd(nil,"AES Lua implementation made by SquidDev.")
	logadd(nil,"'Skynet' (enables HTTP chat) belongs to gollark (osmarks).")
end
commands.exit = function()
	enchatSend("*", "'"..yourName.."&}&r~r' buggered off. (disconnect)")
	return "exit"
end
commands.me = function(msg)
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	if msg then
		enchatSend("&2*", yourName.."~r&2 "..msg, true)
	else
		logadd("*",commandInit.."me [message]")
	end
end
commands.tron = function()
  local url = "https://raw.githubusercontent.com/LDDestroier/CC/master/tron.lua"
  local prog, contents = http.get(url)
  if prog then
    enchatSend("*", yourName .. "&}&r~r has started a game of TRON.")
    contents = prog.readAll()
    pauseRendering = true
    prog = load(contents, nil, nil, _ENV)(enchatSettings.useSkynet and "skynet", "quick", yourName)
  else
    logadd("*","Could not download TRON.")
  end
  pauseRendering = false
  doRender = true
end
commands.colors = function()
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	logadd("*", "&{Color codes: (use & or ~)&}")
	logadd(nil, "  &7~11~22~33~44~55~66~7&87~8&78~99~aa~bb~cc~dd~ee~ff")
end
commands.update = function()
	local res, message = updateEnchat()
	if res then
		enchatSend("*",yourName.."&}&r~r has updated and exited.")
		termsetBackgroundColor(colors.black)
		termsetTextColor(colors.white)
		termclear()
		termsetCursorPos(1,1)
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
			logadd(nil,nil)
			return
		else
			tableinsert(output,1,"")
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
		enchatSend(yourName,output,true,"slideFromLeft",nil,nil,nil,true)
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
	if enchatSettings.extraNewline then
		logadd(nil,nil)
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
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	if newName then
		if checkValidName(newName) then
			if newName == yourName then
				logadd("*","But you're already called that!")
			else
				enchatSend("*","'"..yourName.."&}&r~r' is now known as '"..newName.."&}&r~r'.", true)
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
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	if now == "now" then
		logadd("*","You are still '"..yourName.."&}&r~r'!")
	else
		logadd("*","You are '"..yourName.."&}&r~r'!")
	end
end
commands.key = function(newKey)
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	if newKey then
		if newKey ~= encKey then
			enchatSend("*", "'"..yourName.."&}&r~r' buggered off. (keychange)", false)
			setEncKey(newKey)
			logadd("*", "Key changed to '"..encKey.."&}&r~r'.")
			enchatSend("*", "'"..yourName.."&}&r~r' has moseyed on over.", false)
		else
			logadd("*", "That's already the key, though.")
		end
	else
		logadd("*","Key = '"..encKey.."&}&r~r'")
		logadd("*","Channel = '"..enchat.port.."'")
	end
end
commands.shrug = function(face)
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	enchatSend(yourName, "¯\\_"..(face and ("("..face..")") or "\2").."_/¯", true)
end
commands.asay = function(_argument)
	local sPoint = (_argument or ""):find(" ")
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
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
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
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
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
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
				termsetBackgroundColor(palette.bg)
				termclear()
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
				termsetBackgroundColor(palette.bg)
				termclear()
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
				termsetBackgroundColor(palette.bg)
				termclear()
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
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	logadd(nil, pong or "Pong!")
end
commands.set = function(_argument)
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	argument = _argument or ""
	local collist = {
		["string"] = function() return "0" end,
		["table"] = function() return "5" end,
		["number"] = function() return "0" end,
		["boolean"] = function(val) if val then return "d" else return "e" end end,
		["function"] = function() return "c" end,
		["nil"] = function() return "8" end,
		["thread"] = function() return "d" end,
		["userdata"] = function() return "c" end, -- ha
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
				elseif textutilsunserialize(newval) ~= nil then
					newval = textutilsunserialize(newval)
				end
				if type(enchatSettings[arguments[1]]) == type(newval) then
					enchatSettings[arguments[1]] = newval
					logadd("*","Set '&4"..arguments[1].."&r' to &{"..contextualQuote(newval,textutilsserialize(newval).."&}").." ("..type(newval)..")")
					saveSettings()
				else
					logadd("*","Wrong value type (it's "..type(enchatSettings[arguments[1]])..")")
				end
			else
				logadd("*","'"..arguments[1].."' is set to "..contextualQuote(enchatSettings[arguments[1]],custColorize(enchatSettings[arguments[1]])..textutilsserialize(enchatSettings[arguments[1]]).."&r").." ("..type(enchatSettings[arguments[1]])..")")
			end
		else
			logadd("*","No such setting.")
		end
	end
	if enchatSettings.useSkynet and (not skynet) then
		pauseRendering = true
		termsetBackgroundColor(colors.black)
		termclear()
		downloadSkynet()
		pauseRendering = false
	end
end
commands.help = function(cmdname)
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	if cmdname then
		local helpList = {
			exit = "Exits Enchat and returns to loader (most likely CraftOS)",
			about = "Tells you a bit about this here Enchat.",
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
			tron = "Starts up a game of TRON.",
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
		local output = ""
		for k,v in pairs(commands) do
			output = output.." "..commandInit..k..","
		end
		logadd(nil, output:sub(1,-2))
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
	ldd = function()	logadd(nil,"& that's me") end,
	OrElseYouWill = function()
		enchatSend("*", "'"..yourName.."&}&r~r' buggered off. (disconnect)")
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
	termsetBackgroundColor(palette.bg)
	termclear()
	os.queueEvent("render_enchat")
	local mHistory = {}

	while true do

		termsetCursorPos(1, scr_y-UIconf.promptY)
		termsetBackgroundColor(palette.promptbg)
		termclearLine()
		termsetTextColor(palette.chevron)
		termwrite(UIconf.chevron)
		termsetTextColor(palette.prompttxt)

		local input = colorRead(nil, mHistory)
		if UIconf.promptY == 0 then
			term.scroll(1)
		end
		if textToBlit(input,true):gsub(" ","") ~= "" then -- people who send blank messages in chat programs deserve to die
			if checkIfCommand(input) then
				local res = parseCommand(input)
				if res == "exit" then
					return "exit"
				end
			else
				if enchatSettings.extraNewline then
					logadd(nil,nil) -- readability is key
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
		logadd(nil,nil) -- readability is still key
	end
	logadd(user, message,animations[animType] and animType or nil,(type(maxFrame) == "number") and maxFrame or nil)
	os.queueEvent("render_enchat")
end

local adjScroll = function(distance)
	scroll = mathmin(maxScroll, mathmax(0, scroll + distance))
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
			if (freq == enchat.port) or (freq == enchat.skynetPort) then
				msg = decrite(msg)
				if type(msg) == "table" then
					if (type(msg.name) == "string") then
						if #msg.name <= 32 then
							if msg.messageID and (not IDlog[msg.messageID]) then
								userCryList[msg.name] = true
								IDlog[msg.messageID] = true
								if ((not msg.recipient) or (msg.recipient == yourName or msg.recipient == textToBlit(yourName,true))) then
									if type(msg.message) == "string" then
										handleReceiveMessage(msg.name, tostring(msg.message), msg.animType, msg.maxFrame, msg.ignoreWrap)
									elseif type(msg.message) == "table" and enchatSettings.acceptPictoChat and #msg.message <= 64 then
										logaddTable(msg.name, msg.message, msg.animType, msg.maxFrame, msg.ignoreWrap)
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
		elseif evt[1] == "mouse_scroll" and (not pauseRendering) then
			local dist = evt[2]
			oldScroll = scroll
			adjScroll(enchatSettings.reverseScroll and -dist or dist)
			if scroll ~= oldScroll then
				dab(renderChat)
			end
		elseif evt[1] == "key" and (not pauseRendering) then
			local key = evt[2]
			keysDown[key] = true
			oldScroll = scroll
			local pageSize = (scr_y-UIconf.promptY) - UIconf.chatlogTop
			if key == keys.pageUp then
				adjScroll(-(keysDown[keys.leftCtrl] and pageSize or enchatSettings.pageKeySpeed))
			elseif key == keys.pageDown then
				adjScroll(keysDown[keys.leftCtrl] and pageSize or enchatSettings.pageKeySpeed)
			end
			if scroll ~= oldScroll then
				dab(renderChat)
			end
		elseif evt[1] == "key_up" then
			local key = evt[2]
			keysDown[key] = nil
		elseif (evt[1] == "render_enchat") and (not pauseRendering) then
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

getModem()

enchatSend("*", "'"..yourName.."&}&r~r' has moseyed on over.", true)

local funky = {
	main,
	handleEvents,
	keepRedrawing,
	handleNotifications
}

if skynet then
	funky[#funky+1] = function()
		while true do
			if skynet then
				pcall(skynet.listen)
				local success, msg = pcall(skynet.open, enchat.skynetPort)
                        	if not success then
                        		skynet = nil
				end
			end
			sleep(5)
		end
	end
end

pauseRendering = false

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

tsv(true) -- in case it's false, y'know

if not res then
	prettyClearScreen(1,scr_y-1)
	termsetTextColor(colors.white)
	termsetBackgroundColor(colors.gray)
	cwrite("There was an error.",2)
	cfwrite("Report this to &3@LDDestroier#2901&r",3)
	cwrite("on Discord,",4)
	cwrite("if you feel like it.",5)
	termsetCursorPos(1,7)
	printError(outcome)
	termsetTextColor(colors.lightGray)
	cwrite("I'll probably fix it, maybe.",10)
end

termsetCursorPos(1,scr_y)
termsetBackgroundColor(initcolors.bg)
termsetTextColor(initcolors.txt)
termclearLine()
