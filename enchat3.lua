--[[
 Enchat 3.0
 Get with:
  wget https://github.com/LDDestroier/enchat/raw/master/enchat3.lua enchat3.lua

This is a stable release. You fool!
--]]

local scr_x, scr_y = term.getSize()
CHATBOX_SAFEMODE = nil

-- non-changable settings
enchat = {
	connectToSkynet = true,
	version = 3.0,
	isBeta = false,
	port = 11000,
	skynetPort = "enchat3-default",
	url = "https://github.com/LDDestroier/enchat/raw/master/enchat3.lua",
	betaurl = "https://github.com/LDDestroier/enchat/raw/beta/enchat3.lua",
	ignoreModem = false,
	dataDir = "/.enchat",
	useChatbox = false,
	disableChatboxWithRedstone = false,
}

-- changable settings
local enchatSettings = {	-- DEFAULT settings.
	animDiv = 4,			-- divisor of text animation speed (scrolling from left)
	doAnimate = true,		-- whether or not to animate text moving from left side of screen
	reverseScroll = false,	-- whether or not to make scrolling up really scroll down
	redrawDelay = 0.1,		-- delay between redrawing
	useSetVisible = false,	-- whether or not to use term.current().setVisible(), which has performance and flickering improvements
	pageKeySpeed = 8,		-- how far PageUP or PageDOWN should scroll
	doNotif = true,			-- whether or not to use oveerlay glasses for notifications, if possible
	doKrazy = true,			-- whether or not to add &k obfuscation
	useSkynet = true,		-- whether or not to use gollark's Skynet in addition to modem calls
	extraNewline = true,	-- adds an extra newline after every message since setting to true
	acceptPictoChat = true,	-- whether or not to allow tablular enchat input, which is what /picto uses
	noRepeatNames = true,	-- whether or not to display the username in two or more consecutive messages by the same user
}

-- colors for various elements
palette = {
	bg = colors.black,
	txt = colors.white,
	promptbg = colors.gray,
	prompttxt = colors.white,
	scrollMeter = colors.lightGray,
	chevron = colors.black,
	title = colors.lightGray,
	titlebg = colors.gray,
}

-- UI adjustments, used to emulate the appearance of other chat programs
UIconf = {
	promptY = 1,
	chevron = ">",
	chatlogTop = 1,
	title = "Enchat 3",
	doTitle = false,
	titleY = 1,
	nameDecolor = false,
	centerTitle = true,
	prefix = "<",
	suffix = "> "
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

local initcolors = {
	bg = termgetBackgroundColor(),
	txt = termgetTextColor()
}

local tArg = {...}

local yourName = tArg[1]
local encKey = tArg[2]

local setEncKey = function(newKey)
	encKey = newKey
end

local saveSettings = function()
	local file = fs.open(fs.combine(enchat.dataDir, "settings"), "w")
	file.write(
		textutilsserialize({
			enchatSettings = enchatSettings,
			palette = palette,
			UIconf = UIconf,
		})
	)
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

-- disables chat screen updating
local pauseRendering = true

-- primarily for use when using the pallete command, hoh hoh
local colors_strnames = {
	["white"] = colors.white,
	["pearl"] = colors.white,
	["silver"] = colors.white,
	["aryan"] = colors.white,
	["#f0f0f0"] = colors.white,

	["orange"] = colors.orange,
	["carrot"] = colors.orange,
	["fuhrer"] = colors.orange,
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
	["pee"] = colors.yellow,
	["lemon"] = colors.yellow,
	["spongebob"] = colors.yellow,
	["cowardice"] = colors.yellow,
	["#dede6c"] = colors.yellow,

	["lime"] = colors.lime,
	["lightgreen"] = colors.lime,
	["light green"] = colors.lime,
	["slime"] = colors.lime,
	["radiation"] = colors.lime,
	["#7fcc19"] = colors.lime,

	["pink"] = colors.pink,
	["lightishred"] = colors.pink,
	["lightish red"] = colors.pink,
	["communist"] = colors.pink,
	["commie"] = colors.pink,
	["patrick"] = colors.pink,
	["#f2b2cc"] = colors.pink,

	["gray"] = colors.gray,
	["grey"] = colors.gray,
	["graey"] = colors.gray,
	["gunmetal"] = colors.gray,
	["#4c4c4c"] = colors.gray,

	["lightgray"] = colors.lightGray,
	["lightgrey"] = colors.lightGray,
	["light gray"] = colors.lightGray,
	["light grey"] = colors.lightGray,
	["#999999"] = colors.lightGray,

	["cyan"] = colors.cyan,
	["seawater"] = colors.cyan,
	["brine"] = colors.cyan,
	["#4c99b2"] = colors.cyan,

	["purple"] = colors.purple,
	["purble"] = colors.purple,
	["obsidian"] = colors.purple,
	["diviner"] = colors.purple,
	["#b266e5"] = colors.purple,

	["blue"] = colors.blue,
	["blu"] = colors.blue,
	["azure"] = colors.blue,
	["sapphire"] = colors.blue,
	["lapis"] = colors.blue,
	["volnutt"] = colors.blue,
	["blueberry"] = colors.blue,
	["x"] = colors.blue,
	["megaman"] = colors.blue,
	["#3366bb"] = colors.blue,

	["brown"] = colors.brown,
	["shit"] = colors.brown,
	["dirt"] = colors.brown,
	["mud"] = colors.brown,
	["bricks"] = colors.brown,
	["#7f664c"] = colors.brown,

	["green"] = colors.green,
	["grass"] = colors.green,
	["#57a64e"] = colors.green,

	["red"] = colors.red,
	["crimson"] = colors.red,
	["vermillion"] = colors.red,
	["menstration"] = colors.red,
	["blood"] = colors.red,
	["marinara"] = colors.red,
	["zero"] = colors.red,
	["protoman"] = colors.red,
	["communism"] = colors.red,
	["#cc4c4c"] = colors.red,

	["black"] = colors.black,
	["dark"] = colors.black,
	["darkness"] = colors.black,
	["space"] = colors.black,
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

-- indicates which character should turn into which random &k character
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

-- check if using older CC version, and omit special characters if it's too old to avoid crash
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

local makeRandomString = function(length, begin, stop)
	local output = ""
	for a = 1, length do
		output = output .. string.char(math.random(begin or 1, stop or 255))
	end
	return output
end

local personalID = makeRandomString(64, 32, 128)

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

-- my main man, the function that turns unformatted strings into formatted strings
local textToBlit = function(input, onlyString, initText, initBack, checkPos, useJSONformat)
	if not input then return end
	checkPos = checkPos or -1
	initText, initBack = initText or toblit[term.getTextColor()], initBack or toblit[term.getBackgroundColor()]
	tcode, bcode = "&", "~"
	local cpos, cx = 0, 0
	local skip, ignore, ex = nil, false, nil
	local text, back, nex = initText, initBack, nil

	local charOut, textOut, backOut = {}, {}, {}
	local JSONoutput = {}

	local krazy = false
	local bold = false
	local strikethrough = false
	local underline = false
	local italic = false

	local codes = {}
	codes["r"] = function(prev)
		if not ignore then
			if prev == tcode then
				text = initText
				bold = false
				strikethrough = false
				underline = false
				italic = false
			elseif prev == bcode then
				if useJSONformat then
					return 0
				else
					back = initBack
				end
			end
			krazy = false
		else
			return 0
		end
	end
	codes["k"] = function(prev)
		if not ignore then
			krazy = not krazy
		else
			return 0
		end
	end
	codes["{"] = function(prev)
		if not ignore then
			ignore = true
		else
			return 0
		end
	end
	codes["}"] = function(prev)
		if ignore then
			ignore = false
		else
			return 0
		end
	end

	if useJSONformat then
		codes["l"] = function(prev)
			bold = true
		end
		codes["m"] = function(prev)
			strikethrough = true
		end
		codes["n"] = function(prev)
			underline = true
		end
		codes["o"] = function(prev)
			italic = true
		end
	end

	local sx, str = 0
	input = stringgsub(input, "(\\)(%d%d?%d?)", function(cap, val)
		if tonumber(val) < 256 then
			cpos = cpos - #val
			return string.char(val)
		else
			return cap..val
		end
	end)

	local MCcolors = {
		["0"] = "white",
		["1"] = "gold",
		["2"] = "light_purple",
		["3"] = "aqua",
		["4"] = "yellow",
		["5"] = "green",
		["6"] = "light_purple",
		["7"] = "dark_gray",
		["8"] = "gray",
		["9"] = "dark_aqua",
		["a"] = "dark_purple",
		["b"] = "dark_blue",
		["c"] = "gold",
		["d"] = "dark_green",
		["e"] = "red",
		["f"] = "black",
	}

	for cx = 1, #input do
		str = stringsub(input,cx,cx)
		if skip then
			if tocolors[str] and not ignore then
				if skip == tcode then
					text = str == " " and initText or str
					if sx < checkPos then
						cpos = cpos - 2
					end
				elseif skip == bcode then
					back = str == " " and initBack or str
					if sx < checkPos then
						cpos = cpos - 2
					end
				end
			elseif codes[str] and not (ignore and str == "{") then
				ex = codes[str](skip) or 0
				sx = sx + ex
    				if sx < checkPos then
					cpos = cpos - ex - 2
				end
			else
				sx = sx + 1
				if useJSONformat then
					JSONoutput[sx] = {
						text = (skip..str),
						color = onlyString and "f" or MCcolors[text],
						bold = (not onlyString) and bold,
						italic = (not onlyString) and italic,
						underline = (not onlyString) and underline,
						obfuscated = (not onlyString) and krazy,
						strikethrough = (not onlyString) and strikethrough
					}
				else
					charOut[sx] = krazy and parseKrazy(prev..str) or (skip..str)
					textOut[sx] = stringrep(text,2)
					backOut[sx] = stringrep(back,2)
				end
			end
			skip = nil
		else
			if (str == tcode or str == bcode) and (codes[stringsub(input, 1+cx, 1+cx)] or tocolors[stringsub(input,1+cx,1+cx)]) then
				skip = str
			else
				sx = sx + 1
				if useJSONformat then
					JSONoutput[sx] = {
						text = str,
						color = onlyString and "f" or MCcolors[text],
						bold = (not onlyString) and bold,
						italic = (not onlyString) and italic,
						underline = (not onlyString) and underline,
						obfuscated = (not onlyString) and krazy,
						strikethrough = (not onlyString) and strikethrough
					}
				else
					charOut[sx] = krazy and parseKrazy(str) or str
					textOut[sx] = text
					backOut[sx] = back
				end
			end
		end
	end
	if useJSONformat then
		return textutils.serializeJSON(JSONoutput)
	else
		if onlyString then
			return tableconcat(charOut), (checkPos > -1) and cpos or nil
		else
--			return {tableconcat(charOut), tableconcat(textOut):gsub(" ", initText), tableconcat(backOut):gsub(" ", initBack)}, (checkPos > -1) and cpos or nil
			return {tableconcat(charOut), tableconcat(textOut), tableconcat(backOut)}, (checkPos > -1) and cpos or nil
		end
	end
end
_G.textToBlit = textToBlit

-- convoluted read function that renders color codes as they are written.
-- struggles with \123 codes, but hey, fuck you
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
			bout[a] = stringsub(bout[a], xscroll, xscroll + scr_x - cx)
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
_G.colorRead = colorRead

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

-- execution start!

if not checkValidName(yourName) then -- not so fast, evildoers
	yourName = nil
end

local currentY = 2

if not (yourName and encKey) then
	prettyClearScreen()
end

if not yourName then
    cfwrite("&8~7Text = &, Background = ~", scr_y-3)
	cfwrite("&8~7&{Krazy = &k, Reset = &r", scr_y-2)
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

-- prevents terminating. it is reversed upon exit.
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

local getAPI = function(apiname, apipath, apiurl, doDoFile, doScroll)
	apipath = fs.combine(fs.combine(enchat.dataDir,"api"), apipath)
	if (not fs.exists(apipath)) then
		if doScroll then term.scroll(1) end
		bottomMessage(apiname .. " API not found! Downloading...")
		local prog = http.get(apiurl)
		if not prog then
			if doScroll then term.scroll(1) end
			bottomMessage("Failed to download " .. apiname .. " API. Abort.")
			termsetCursorPos(1,1)
			return
		end
		local file = fs.open(apipath,"w")
		file.write(prog.readAll())
		file.close()
	end
	if doDoFile then
		return dofile(apipath)
	else
		os.loadAPI(apipath)
	end
	if not _ENV[fs.getName(apipath)] then
		if doScroll then term.scroll(1) end
		bottomMessage("Failed to load " .. apiname .. " API. Abort.")
		termsetCursorPos(1,1)
		return
	else
		return _ENV[fs.getName(apipath)]
	end
end

local skynet, aes, bigfont
-- _G.skynet_CBOR_path = fs.combine(enchat.dataDir,"/api/cbor")
aes = getAPI("AES", "aes", "http://pastebin.com/raw/9E5UHiqv", false, false)
if enchat.connectToSkynet and http.websocket then
	skynet = getAPI("Skynet", "skynet", "https://raw.githubusercontent.com/LDDestroier/CC/master/API/skynet.lua", true, true)
end
bigfont = getAPI("BigFont", "bigfont", "https://pastebin.com/raw/3LfWxRWh", false, true)

if encKey and skynet and enchat.connectToSkynet then
	bottomMessage("Connecting to Skynet...")
	local success = parallel.waitForAny(
		function()
			skynet.open(enchat.skynetPort)
		end,
		function()
			sleep(3)
		end
	)
	if success == 2 then
		term.scroll(1)
		bottomMessage("Failed to connect to skynet.")
		skynet = nil
		sleep(0.5)
	end
end

local log = {} 			-- Records all sorts of data on text.
local renderlog = {} 	-- Only records straight terminal output. Generated from 'log'
local IDlog = {} 		-- Really only used with skynet, will prevent duplicate messages.

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

local getChatbox = function()
	if enchat.useChatbox then
		if commands then -- oh baby, a command computer, now we're talkin'
			-- mind you, you still need a chatbox to get chat input...
			return {
				say = function(text)
					commands.tellraw("@a", textToBlit(text, false, "0", "f", nil, true))
				end,
				tell = function(player, text)
					commands.tellraw(player, textToBlit(text, false, "0", "f", nil, true))
				end
			}
		else
			local cb = chatbox or peripheral.find("chat_box")
			if cb then
				if cb.setName then -- Computronics
					cb.setName(yourName)
					return {
						say = cb.say,
						tell = cb.say -- why is there no tell command???
					}
				else -- whatever whackjob mod SwitchCraft uses I forget
					return {
						say = function(text, block)
							if CHATBOX_SAFEMODE then
--								if CHATBOX_SAFEMODE ~= block then
									cb.tell(CHATBOX_SAFEMODE, text)
--								end
							else
								local players = cb.getPlayerList()
								for i = 1, #players do
									if players[i] ~= block then
										cb.tell(players[i], text)
									end
								end
							end
						end,
						tell = cb.tell
					}
				end
			else
				return nil
			end
		end
	else
		return nil
	end
end

local modem = getModem()
local chatbox = getChatbox()

if (not modem) and (not enchat.ignoreModem) then
	if ccemux and (not enchat.ignoreModem) then
		ccemux.attach("top", "wireless_modem")
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

-- same as term.blit, but wraps by-word.
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

-- simple picture drawing function, for /picto
local pictochat = function(xsize, ysize)
	local output = {{},{},{}}
	local maxWidth, minMargin = 0, math.huge
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
			text, back = stringsub(allCols,tPos,tPos), stringsub(allCols,bPos,bPos)
			if oldTpos ~= tPos or oldBpos ~= bPos then
				render()
			end
		elseif evt[1] == "key" then
			if evt[2] == keys.enter then
				for y = 1, ysize do
					output[1][y] = table.concat(output[1][y])
					output[2][y] = table.concat(output[2][y])
					output[3][y] = table.concat(output[3][y])
					maxWidth  = math.max(maxWidth,  #stringgsub(output[3][y], " +$", ""))
					minMargin = math.min(minMargin, output[3][y]:find("[^ ]") or math.huge)
				end
				--error(minMargin)
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
				for y = 1, #output[1] do
					output[1][y] = output[1][y]:sub(minMargin, maxWidth)
					output[2][y] = output[2][y]:sub(minMargin, maxWidth)
					output[3][y] = output[3][y]:sub(minMargin, maxWidth)
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

-- notifications will only appear if you have plethora's neural connector and overlay glasses on your person

local notif = {}
notif.alpha = 248
notif.height = 10
notif.width = 6
notif.time = 40
notif.wrapX = 350
notif.maxNotifs = 15
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
			if #nList > notif.maxNotifs then
				tableremove(nList, 1)
			end
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
					output = output + notif.width + (adjList[stringsub(str,a,a)] or 0)
				end
				return output
			end
			canvas.clear()
			local xadj, charadj, wordadj, t, r
			local x, y, words, txtwords, bgwords = 0, 0
			for n = 1, mathmin(#nList, notif.maxNotifs) do
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
						charadj = (adjList[stringsub(char,cx,cx)] or 0)
						r = canvas.addRectangle(xadj+1+(x-1)*notif.width, 1+(y-1)*notif.height, charadj+notif.width, notif.height)
						if stringsub(back,cx,cx) ~= " " then
							r.setAlpha(notif.alpha * nList[n][5])
							r.setColor(unpack(colorTranslate[stringsub(back,cx,cx)]))
						else
							r.setAlpha(100 * nList[n][5])
							r.setColor(unpack(colorTranslate["7"]))
						end
						drawEdgeLine(y,notif.alpha * nList[n][5])
						t = canvas.addText({xadj+1+(x-1)*notif.width,2+(y-1)*notif.height}, stringsub(char,cx,cx))
						t.setAlpha(notif.alpha * nList[n][5])
						t.setColor(unpack(colorTranslate[stringsub(text,cx,cx)]))
						xadj = xadj + charadj
						currentX = currentX + charadj+notif.width
					end
				end
			end
			for n = mathmin(#nList, notif.maxNotifs), 1, -1 do
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

local darkerCols = {
	["0"] = "8",
	["1"] = "c",
	["2"] = "a",
	["3"] = "b",
	["4"] = "1",
	["5"] = "d",
	["6"] = "2",
	["7"] = "f",
	["8"] = "7",
	["9"] = "b",
	["a"] = "7",
	["b"] = "7",
	["c"] = "f",
	["d"] = "7",
	["e"] = "7",
	["f"] = "f"
}

-- used for regular chat. they can be disabled if you hate fun
local animations = {
	slideFromLeft = function(char, text, back, frame, maxFrame, length)
		return {
			stringsub(char, (length or #char) - ((frame/maxFrame)*(length or #char))),
			stringsub(text, (length or #text) - ((frame/maxFrame)*(length or #text))),
			stringsub(back, (length or #back) - ((frame/maxFrame)*(length or #back)))
		}
	end,
	fadeIn = function(char, text, back, frame, maxFrame, length)
		-- a good example:
		-- &1what &2in &3the &4world &5are &6you &7doing &8in &9my &aswamp
		for i = 1, 3 - math.ceil(frame/maxFrame * 3) do
			text = stringgsub(text, ".", darkerCols)
		end
		return {
			char,
			text,
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
	local buff, prebuff, maxLength, lastUser
	local scrollToBottom = scroll == maxScroll
	renderlog = {}
	local dcName, dcMessage
	for a = 1, #log do
		if not ((lastUser == log[a].personalID and log[a].personalID) and log[a].name == "" and log[a].message == " ") then
			termsetCursorPos(1,1)
			if UIconf.nameDecolor then
				if lastUser == log[a].personalID and log[a].personalID then
					dcName = ""
				else
					dcName = textToBlit(table.concat({log[a].prefix,log[a].name,log[a].suffix}), true, toblit[palette.txt], toblit[palette.bg])
				end
				dcMessage = textToBlit(log[a].message, false, toblit[palette.txt], toblit[palette.bg])
				prebuff = {
					dcName..dcMessage[1],
					toblit[palette.chevron]:rep(#dcName)..dcMessage[2],
					toblit[palette.bg]:rep(#dcName)..dcMessage[3]
				}
			else
				if lastUser == log[a].personalID and log[a].personalID then
					prebuff = textToBlit(" " .. log[a].message, false, toblit[palette.txt], toblit[palette.bg])
				else
					prebuff = textToBlit(table.concat({
						log[a].prefix,
						"&}&r~r",
						log[a].name,
						"&}&r~r",
						log[a].suffix,
						"&}&r~r",
						log[a].message
					}),
					false, toblit[palette.txt], toblit[palette.bg])
				end
			end
			if log[a].message ~= " " and enchatSettings.noRepeatNames then
				lastUser = log[a].personalID
			end
			if (log[a].frame == 0) and (canvas and enchatSettings.doNotif) then
				if not (log[a].name == "" and log[a].message == " ") then
					notif.newNotification(prebuff[1], prebuff[2], prebuff[3], notif.time * 4)
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
	end
	maxScroll = mathmax(0, #renderlog - (scr_y - 2))
	if scrollToBottom then
		scroll = maxScroll
	end
end

-- there is probably a much better way of doing this, but I don't care at the moment
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

	local _title = UIconf.title:gsub("YOURNAME", yourName.."&}&r~r"):gsub("ENCKEY", encKey.."&}&r~r"):gsub("PORT", tostring(enchat.port))
	if UIconf.doTitle then
		termsetTextColor(palette.title)
		term.setBackgroundColor(palette.titlebg)
		if UIconf.nameDecolor then
			if UIconf.centerTitle then
				cwrite((" "):rep(scr_x)..textToBlit(_title, true)..(" "):rep(scr_x), UIconf.titleY or 1)
			else
				termsetCursorPos(1, UIconf.titleY or 1)
				termwrite(textToBlit(_title, true)..(" "):rep(scr_x))
			end
		else
			local blTitle = textToBlit(_title)
			termsetCursorPos(UIconf.centerTitle and ((scr_x/2) - math.ceil(#blTitle[1]/2)) or 1, UIconf.titleY or 1)
			termclearLine()
			termblit(unpack(blTitle))
		end
	end
	termsetCursorBlink(true)
	tsv(true)
end

local logadd = function(name, message, animType, maxFrame, ignoreWrap, _personalID)
	log[#log + 1] = {
		prefix = name and UIconf.prefix or "",
		suffix = name and UIconf.suffix or "",
		name = name or "",
		message = message or " ",
		ignoreWrap = ignoreWrap,
		frame = 0,
		maxFrame = maxFrame or true,
		animType = animType,
		personalID = _personalID
	}
end

local logaddTable = function(name, message, animType, maxFrame, ignoreWrap, _personalID)
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
				logadd(name, message[1], animType, maxFrame, ignoreWrap, _personalID)
				for l = 2, #message do
					logadd(nil, message[l], animType, maxFrame, ignoreWrap, _personalID)
				end
			end
		end
	end
end

local enchatSend = function(name, message, option, doLog, animType, maxFrame, crying, recipient, ignoreWrap, omitPersonalID)
	option = option or {}
	if option.doLog then
		if type(message) == "string" then
			logadd(name, message, option.animType, option.maxFrame, option.ignoreWrap, (not option.omitPersonalID) and personalID)
		else
			logaddTable(name, message, option.animType, option.maxFrame, option.ignoreWrap, (not option.omitPersonalID) and personalID)
		end
	end
	local messageID = makeRandomString(64)
	local outmsg = encrite({
		name = name,
		message = message,
		animType = option.animType,
		maxFrame = option.maxFrame,
		messageID = messageID,
		recipient = option.recipient,
		ignoreWrap = option.ignoreWrap,
		personalID = (not option.omitPersonalID) and personalID,
		cry = option.crying,
		simCommand = option.simCommand,
		simArgument = option.simArgument,
	})
	IDlog[messageID] = true
	if not enchat.ignoreModem then
		modemTransmit(enchat.port, enchat.port, outmsg)
	end
	if skynet and enchatSettings.useSkynet then
		skynet.send(enchat.skynetPort, outmsg)
	end
end

local cryOut = function(name, crying)
	enchatSend(name, nil, {crying = crying})
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
local simmableCommands = {
	big = true
}
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
		enchatSend("&2*", yourName.."~r&2 "..msg, {doLog = true})
	else
		logadd("*",commandInit.."me [message]")
	end
end
commands.tron = function()
  local url = "https://raw.githubusercontent.com/LDDestroier/CC/master/tron.lua"
  local prog, contents = http.get(url)
  if prog then
    enchatSend("*", yourName .. "&}&r~r has started a game of TRON.", {doLog = true})
    contents = prog.readAll()
    pauseRendering = true
    prog = load(contents, nil, nil, _ENV)(enchatSettings.useSkynet and "skynet", "quick", yourName)
  else
    logadd("*", "Could not download TRON.")
  end
  pauseRendering = false
  doRender = true
end
commands.colors = function()
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	logadd("*", "&{Color codes: (use & or ~)&}")
	logadd(nil, " &7~11~22~33~44~55~66~7&87~8&78~99~aa~bb~cc~dd~ee~ff")
	logadd(nil, " &{Reset text/BG with &r and ~r.&}")
	logadd(nil, " &{Use &k for krazy text.&}")
end
commands.update = function()
	local res, message = updateEnchat()
	if res then
		enchatSend("*", yourName.."&}&r~r has updated and exited.")
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
				output[#output] = table.concat({
					output[#output],
					"&",
					image[2][y]:sub(x,x),
					"~",
					image[3][y]:sub(x,x),
					image[1][y]:sub(x,x)
				})
				isEmpty = isEmpty and (image[1][y]:sub(x,x) == " " and image[3][y]:sub(x,x) == " ")
			end
		end
	end
	if not isEmpty then
		enchatSend(yourName, output, {doLog = true, animType = "slideFromLeft", ignoreWrap = true})
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
				enchatSend("*", "'"..yourName.."&}&r~r' is now known as '"..newName.."&}&r~r'.", {doLog = true})
				yourName = newName
			end
		else
			if #newName < 2 then
				logadd("*", "That name is too damned small.")
			elseif #newName > 32 then
				logadd("*", "Woah there, that name is too large.")
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
			enchatSend("*", "'"..yourName.."&}&r~r' buggered off. (keychange)")
			setEncKey(newKey)
			logadd("*", "Key changed to '"..encKey.."&}&r~r'.")
			enchatSend("*", "'"..yourName.."&}&r~r' has moseyed on over.", {omitPersonalID = true})
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
	enchatSend(yourName, "¯\\_"..(face and ("("..face..")") or "\2").."_/¯", {doLog = true})
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
				enchatSend(yourName, message, {doLog = true, animType = animType, maxFrame = animFrameMod[animType]})
			else
				logadd("*","That message is no good.")
			end
		else
			logadd("*","Invalid animation type.")
		end
	end
end
commands.big = function(_argument, simUser)
	local sPoint = (_argument or ""):find(" ")
	if enchatSettings.extraNewline then
		logadd(nil,nil)
	end
	if not sPoint then
		logadd("*",commandInit .. "big <size> <text>")
	else
		local fontSize = tonumber(_argument:sub(1,sPoint-1))
		local message = _argument:sub(sPoint+1)
		if not fontSize then
			logadd("*","Size must be number between 0 and 2.")
		elseif fontSize < 0 or fontSize > 2 then
			logadd("*","Size must be number between 0 and 2.")
		else
			fontSize = math.floor(.5+fontSize)
			local tOutput
			if fontSize > 0 then
				message = textToBlit(message, false, "0", "f")
				local output = {{},{},{}}
				local x, y = 1, 1
				local char
				for i = 1, #message[1] do
					char = bigfont.makeBlittleText(
						fontSize,
						stringsub(message[1],i,i),
						stringsub(message[2],i,i),
						stringsub(message[3],i,i)
					)
					x = x + char.width
					if x >= scr_x then
						y = y + char.height
						x = char.width
					end
					for charY = 1, char.height do
						output[1][y+charY-1] = (output[1][y+charY-1] or " ") .. char[1][charY]
						output[2][y+charY-1] = (output[2][y+charY-1] or " ") .. char[2][charY]
						output[3][y+charY-1] = (output[3][y+charY-1] or " ") .. char[3][charY]
					end
				end
				tOutput = {""}
				local yy = 1
				for y = 1, #output[1] do
					tOutput[#tOutput+1] = ""
					for x = 1, #output[1][y] do
						tOutput[#tOutput] = table.concat({tOutput[#tOutput],"&",output[2][yy]:sub(x,x),"~",output[3][yy]:sub(x,x),output[1][yy]:sub(x,x)})
					end
					yy = yy + 1
				end
			else
				tOutput = message
			end
			if simUser then
				logaddTable(simUser, tOutput)
			else
				logaddTable(yourName, tOutput)
				enchatSend(yourName, nil, {simCommand = "big", simArgument = _argument})
			end
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
				enchatSend(yourName, message, {recipient = recipient})
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
			if argument[1]:gsub("%s",""):lower() == "reset" or argument[1]:gsub("%s",""):lower() == "enchat3" then
				palette = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.gray,
					prompttxt = colors.white,
					scrollMeter = colors.lightGray,
					chevron = colors.black,
					title = colors.lightGray,
					titlebg = colors.gray,
				}
				UIconf = {
					promptY = 1,
					chevron = ">",
					chatlogTop = 1,
					title = "Enchat 3",
					doTitle = false,
					titleY = 1,
					nameDecolor = false,
					centerTitle = true,
					prefix = "<",
					suffix = "> "
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
					title = colors.yellow,
					titlebg = colors.gray,
				}
				UIconf = {
					promptY = 1,
					chevron = ">",
					chatlogTop = 1,
					title = "Enchat 2",
					doTitle = false,
					titleY = 1,
					nameDecolor = false,
					centerTitle = false,
					prefix = "<",
					suffix = "> "
				}
				termsetBackgroundColor(palette.bg)
				termclear()
				logadd("*","Switched to the old Enchat2 palette.")
				saveSettings()
			elseif argument[1]:gsub("%s",""):lower() == "enchat1" then
				logadd("*","We don't talk about that one.")
			elseif argument[1]:gsub("%s",""):lower() == "enchat4" then
				logadd("*","Let's leave that to future LDD.")
			elseif argument[1]:gsub("%s",""):lower() == "chat.lua" then
				palette = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.black,
					prompttxt = colors.white,
					scrollMeter = colors.white,
					chevron = colors.yellow,
					title = colors.yellow,
					titlebg = colors.black,
				}
				UIconf = {
					promptY = 0,
					chevron = ": ",
					chatlogTop = 2,
					title = "YOURNAME on ENCKEY",
					doTitle = true,
					titleY = 1,
					nameDecolor = true,
					centerTitle = true,
					prefix = "<",
					suffix = "> "
				}
				termsetBackgroundColor(palette.bg)
				termclear()
				logadd("*","Switched to /rom/programs/rednet/chat.lua palette.")
				saveSettings()
			elseif argument[1]:gsub("%s",""):lower() == "talk" then
				palette = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.black,
					prompttxt = colors.white,
					scrollMeter = colors.white,
					chevron = colors.white,
					title = colors.black,
					titlebg = colors.white,
				}
				UIconf = {
					promptY = 0,
					chevron = "",
					chatlogTop = 1,
					title = " enchat v3.0     channel: ENCKEY:PORT",
					titleY = scr_y - 1,
					doTitle = true,
					nameDecolor = false,
					centerTitle = false,
					prefix = "<",
					suffix = "> "
				}
				termsetBackgroundColor(palette.bg)
				termclear()
				logadd("*","Switched to Talk palette.")
				saveSettings()
			elseif argument[1]:gsub("%s",""):lower() == "darkchat" then
				palette = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.black,
					prompttxt = colors.white,
					scrollMeter = colors.white,
					chevron = colors.white,
					title = colors.white,
					titlebg = colors.blue,
				}
				UIconf = {
					promptY = 0,
					chevron = "Message: ",
					chatlogTop = 1,
					title = "<User: YOURNAME> <Channel: ENCKEY>",
					titleY = scr_y - 1,
					doTitle = true,
					nameDecolor = false,
					centerTitle = true,
					prefix = "",
					suffix = ": "
				}
				termsetBackgroundColor(palette.bg)
				termclear()
				logadd("*","Switched to DarkChat palette.")
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
			big = "Sends your message, but enlarged by a specified amount via Wojbie's BigFont API.",
			help = "Shows every command, or describes a specific command.",
		}
		cmdname = cmdname:gsub(" ",""):gsub("/","")
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
		if textToBlit(input,true):gsub(" ","") ~= "" then -- people who send blank messages in chat programs deserve to die
			if checkIfCommand(input) then
				local res = parseCommand(input)
				if res == "exit" then
					return "exit"
				end
			else
				if enchatSettings.extraNewline then
					logadd(nil,nil,nil,nil,nil,personalID) -- readability is key
				end
				enchatSend(yourName, input, {doLog = true})
			end
			if mHistory[#mHistory] ~= input then
				mHistory[#mHistory+1] = input
			end
		elseif input == "" then
			logadd(nil,nil,nil,nil,nil,personalID)
		end
		os.queueEvent("render_enchat")

	end

end

local handleReceiveMessage = function(user, message, animType, maxFrame, _personalID)
	if enchatSettings.extraNewline then
		logadd(nil,nil,nil,nil,nil,_personalID) -- readability is still key
	end
	logadd(user, message, animations[animType] and animType or nil, (type(maxFrame) == "number") and maxFrame or nil, nil, _personalID)
	os.queueEvent("render_enchat")
end

local adjScroll = function(distance)
	scroll = mathmin(maxScroll, mathmax(0, scroll + distance))
end

local checkRSinput = function()
	return (
		rs.getInput("front") or
		rs.getInput("back")  or
		rs.getInput("left")  or
		rs.getInput("right") or
		rs.getInput("top")   or
		rs.getInput("bottom")
	)
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
		elseif evt[1] == "chat" and ((not checkRSinput()) or (not enchat.disableChatboxWithRedstone)) then
			if enchat.useChatbox then
				if enchatSettings.extraNewline then
					logadd(nil,nil) -- readability is key
				end
				enchatSend(evt[2], evt[3], {doLog = true})
			end
		elseif evt[1] == "chat_message" and ((not checkRSinput()) or (not enchat.disableChatboxWithRedstone)) then -- computronics
			if enchat.useChatbox then
				if enchatSettings.extraNewline then
					logadd(nil,nil) -- readability is key
				end
				enchatSend(evt[3], evt[4], {doLog = true})
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
										handleReceiveMessage(msg.name, tostring(msg.message), msg.animType, msg.maxFrame, msg.personalID)
										if chatbox and enchat.useChatbox and ((not checkRSinput()) or (not enchat.disableChatboxWithRedstone)) then
											chatbox.say(UIconf.prefix .. msg.name .. UIconf.suffix .. msg.message, msg.name)
										end
									elseif type(msg.message) == "table" and enchatSettings.acceptPictoChat and #msg.message <= 64 then
										logaddTable(msg.name, msg.message, msg.animType, msg.maxFrame, msg.ignoreWrap, msg.personalID)
										if enchatSettings.extraNewline then
											logadd(nil,nil)
										end
									elseif commands[msg.simCommand or false] and type(msg.simArgument) == "string" then
										if simmableCommands[msg.simCommand or false] then
											commands[msg.simCommand](msg.simArgument, msg.name)
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
		elseif (evt[1] == "tron_complete") then
			if evt[3] then
				if enchatSettings.extraNewline then
					logadd(nil,nil)
				end
				if evt[2] == "win" then
					enchatSend("*", yourName .. "&}&r~r beat " .. (evt[4] or "someone") .. "&}&r~r in TRON!", {doLog = true})
				elseif evt[2] == "lose" then
					enchatSend("*", (evt[4] or "Someone") .. "&}&r~r beat " .. yourName .. "&}&r~r in TRON!", {doLog = true})
				elseif evt[2] == "tie" then
					enchatSend("*", yourName .. "&}&r~r tied with " .. (evt[4] or "someone") .. "&}&r~r in TRON!", {doLog = true})
				end
			elseif evt[2] == "timeout" then
				if enchatSettings.extraNewline then
					logadd(nil,nil)
				end
				enchatSend("*", yourName .. "&}&r~r timed out against " .. (evt[4] or "someone") .. "&}&r~r in TRON...", {doLog = true})
			end
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

enchatSend("*", "'"..yourName.."&}&r~r' has moseyed on over.", {doLog = true, omitPersonalID = true})

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

termsetCursorPos(1, scr_y)
termsetBackgroundColor(initcolors.bg)
termsetTextColor(initcolors.txt)
termclearLine()
