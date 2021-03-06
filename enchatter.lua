--[[
 Enchat 3.0 + Chatter ("Enchatter")
 Get with:
  wget https://github.com/LDDestroier/enchat/raw/master/enchatter.lua enchatter
  
  This is a beta release. You git
--]]

local scr_x, scr_y = term.getSize()

enchat = {
	version = 3.0,
	isBeta = true,
	url = "https://github.com/LDDestroier/enchat/raw/master/enchatter.lua",
	betaurl = "https://github.com/LDDestroier/enchat/raw/master/enchatter.lua",
}

enchatSettings = {
	animDiv = 2,				--divisor of text animation speed (scrolling from left)
	doAnimate = true,			--whether or not to animate text moving from left side of screen
	reverseScroll = false,			--whether or not to make scrolling up really scroll down
	redrawDelay = 0.05,			--delay between redrawing
	useSetVisible = true,			--whether or not to use term.current().setVisible(), which has performance and flickering improvements
	pageKeySpeed = 4,			--how far PageUP or PageDOWN should scroll
	doNotif = true,				--whether or not to use oveerlay glasses for notifications, if possible
	doKrazy = true,				--whether or not to add &k obfuscation
	hostname = "chat.nothy.se:1337",	--server for chatter
	hostnameCB = "chat.nothy.se:6789",	--server for chatter, when using chatboxes
	useChatBox = false			--whether or not to even use chatboxes
}

local initcolors = {
	bg = term.getBackgroundColor(),
	txt = term.getTextColor()
}

local tArg = {...}

local yourName

yourName = tArg[1]
enchatSettings.hostname = tArg[2] or enchatSettings.hostname
local ableToRefresh, ableToRefreshID = true

local palate = {
	bg = colors.black,		--background color
	txt = colors.white,		--text color (should contrast with bg)
	promptbg = colors.gray,		--chat prompt background
	prompttxt = colors.white,	--chat prompt text
	scrollMeter = colors.lightGray,	--scroll indicator
	chevron = colors.black,		--color of ">" left of text prompt
	title = colors.lightGray	--color of title, if available
}

UIconf = {
	promptY = scr_y - 1,	--Y position of read prompt
	chevron = ">",			--symbol before read prompt
	chatlogTop = 1,			--top of where chatlog is written to screen
	title = "",				--overwritten every render, don't bother here
	doTitle = false,		--whether or not to draw UIconf.title at the top of the screen
	nameDecolor = false,	--if true, sets all names to palate.chevron color
}

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

local isConnected = true


local checkValidName = function(nayme)
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

if not checkValidName(yourName) then --not so fast, evildoers
	yourName = nil
end

-- JSON API START (thank you ElvishJerricco) --

local apipath
if shell then apipath = fs.combine(shell.dir(),"json") else apipath = "json" end
if (not fs.exists(apipath)) then
	print("JSON API not found! Downloading...")
	local prog = http.get("https://raw.githubusercontent.com/LDDestroier/enchat/master/json")
	if not prog then error("FAIL!") end
	local file = fs.open(apipath,"w")
	file.write(prog.readAll())
	file.close()
end
if not json.jdecode then --gotta have this specific version god damn it
	local res = os.loadAPI(apipath)
	if not res then error("Didn't load JSON API!") end
end

-- JSON API STOP (thanks again) --

local log = {} --Records all sorts of data on text.
local renderlog = {} --Only records straight terminal output. Generated from 'log'

local scroll = 0
local maxScroll = 0

local chatbox = peripheral.find("chat_box") --computronics OR minimalperipherals chatbox
local SAY
if chatbox then
	if chatbox.setTitle then --if using computronics
		chatbox.setTitle("EC")
		SAY = chatbox.say
	else --if using minimalperipherals
		SAY = function(text)
			local players = chatbox.getPlayerList()
			for i = 1, #players do
				chatbox.tell(players[i], text)
			end
		end
	end
end

local encrite = function(input) --standardized encryption function, but it's unused in chatter
	return input
end

local decrite = function(input)
	return input
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

local currentY = 2

if not yourName then
	prettyClearScreen()
end

if not yourName then
	yourName = prettyPrompt("Enter your name.", currentY)
	if not checkValidName(yourName) then
		while true do
			yourName = prettyPrompt("That name isn't valid. Enter another.", currentY)
			if checkValidName(yourName) then
				break
			end
		end
	end
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

local colors_strnames = { --primarily for use when coloring palate
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

local moveOn
textToBlit = function(_str,onlyString,initTxt,initBg,_checkPos,ignoreEmotes) --returns output for term.blit, or blitWrap, with formatting codes for color selection. Modified for use specifically with Enchat.
	checkPos = _checkPos or -1
	if (not _str) then
		if onlyString then
			return ""
		else
			return "","",""
		end
	end
	local str = tostring(_str)
	if not ignoreEmotes then
		local emoteList = {
			[":heart:"] = "\3",
			[":fem:"] = "\12",
			[":mal:"] = "\11",
			[":smile:"] = "\2",
			[":double_exclaim:"] = "\19",
			[":2!:"] = "\19",
			[":mus_note:"] = "\15",
			[":up_arrow:"] = "\24",
			[":up:"] = "\24",
			[":down_arrow:"] = "\25",
			[":down:"] = "\25",
			[":right_arrow:"] = "\26",
			[":right:"] = "\26",
			[":left_arrow:"] = "\27",
			[":left:"] = "\27",
			[":deg:"] = "\176",
			[":degree:"] = "\176"
		}
		for k,v in pairs(emoteList) do
			str = str:gsub(k, v)
		end
	end
	local p = 1
	local output, txcolorout, bgcolorout = "", "", ""
	local txcode = "&"
	local bgcode = "~"
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
	while p <= #str do
		if str:sub(p,p) == txcode then
			if tocolors[str:sub(p+1,p+1)] and doFormatting then
				txcol = str:sub(p+1,p+1)
				usedformats.txcol = true
				p = p + 1
			elseif codeNames[str:sub(p+1,p+1)] then
				if str:sub(p+1,p+1) == "r" and doFormatting then
					txcol = origTX
					isKrazy = false
					p = p + 1
				elseif str:sub(p+1,p+1) == "{" and doFormatting then
					doFormatting = false
					p = p + 1
				elseif str:sub(p+1,p+1) == "}" and not doFormatting then
					doFormatting = true
					p = p + 1
				elseif str:sub(p+1,p+1) == "k" and doFormatting and enchatSettings.doKrazy then
					isKrazy = true
					usedformats.krazy = true
					p = p + 1
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
			elseif codeNames[str:sub(p+1,p+1)] and (str:sub(p+1,p+1) == "r") and doFormatting then
				bgcol = origBG
				p = p + 1
			elseif str:sub(p+1,p+1) == "k" and doFormatting then
				isKrazy = false
				p = p + 1
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
		return {output, txcol:rep(#output), bgcol:rep(#output)}
	else
		return {output, txcolorout, bgcolorout}
	end
end

local inAnimate = function(buff, frame, maxFrame, length)
	local char, text, back = buff[1], buff[2], buff[3]
	if enchatSettings.doAnimate and frame >= 0 then
		return {
			char:sub((length or #char) - ((frame/maxFrame)*(length or #char))),
			text:sub((length or #text) - ((frame/maxFrame)*(length or #text))),
			back:sub((length or #back) - ((frame/maxFrame)*(length or #back))),
		}
	else
		return {char,text,back}
	end
end

local genRenderLog = function()
	local buff, prebuff, maxLength
	local scrollToBottom = scroll == maxScroll
	renderlog = {}
	term.setTextColor(palate.txt)
	term.setBackgroundColor(palate.bg)
	for a = 1, #log do
		term.setCursorPos(1,1)
		if UIconf.nameDecolor then
			local dcName = textToBlit(table.concat({log[a].prefix,log[a].name,log[a].suffix}), true)[1]
			local dcMessage = textToBlit(log[a].message)
			prebuff = {
				dcName..dcMessage[1],
				toblit[palate.chevron]:rep(#dcName)..dcMessage[2],
				toblit[palate.bg]:rep(#dcName)..dcMessage[3]
			}
		else
			prebuff = textToBlit(table.concat({log[a].prefix,"&r~r",log[a].name,"&r~r",log[a].suffix,"&r~r",log[a].message}))
		end
		if (log[a].frame == 0) and (canvas and enchatSettings.doNotif) then
			notif.newNotification(prebuff[1],prebuff[2],prebuff[3],notif.time * 4)
		end
		if log[a].maxFrame == true then
			log[a].maxFrame = math.floor(math.min(#prebuff[1], scr_x) / enchatSettings.animDiv)
		end
		buff, maxLength = blitWrap(unpack(prebuff))
		--repeat every line in multiline entries
		for l = 1, #buff do
			renderlog[#renderlog + 1] = inAnimate(buff[l], log[a].frame, log[a].maxFrame, maxLength)
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
	term.setBackgroundColor(palate.bg)
	for y = UIconf.chatlogTop, UIconf.promptY - 1 do
		ry = (y + scroll - (UIconf.chatlogTop - 1))
		term.setCursorPos(1,y)
		term.clearLine()
		if renderlog[ry] then
			term.blit(unpack(renderlog[ry]))
		end
	end
	if UIconf.promptY ~= scr_y then
		term.setCursorPos(1,scr_y)
		term.setTextColor(palate.scrollMeter)
		term.clearLine()
		term.write(scroll.." / "..maxScroll.." "..(isConnected and "" or "(disconnected)").."  ")
	end
	
	UIconf.title = yourName.." on "..enchatSettings.hostname
	
	if UIconf.doTitle then
		term.setTextColor(palate.chevron)
		if UIconf.nameDecolor then
			cwrite((" "):rep(scr_x)..textToBlit(UIconf.title, true)[1]..(" "):rep(scr_x), 1)
		else
			local blTitle = textToBlit(UIconf.title)
			term.setCursorPos((scr_x/2) - math.ceil(#blTitle[1]/2), 1)
			term.clearLine()
			term.blit(unpack(blTitle))
		end
	end
	tsv(true)
end

local logadd = function(name, message)
	log[#log + 1] = {
		prefix = name and "<" or "",
		suffix = name and "> " or "",
		name = name and name or "",
		message = message or "",
		frame = 0,
		maxFrame = true
	}
end

local messageCount, lastSent, msgTimerID = {}, {}

local enchatSend = function(name, message, color, server)
	local res, mess = http.request("http://"..(server or enchatSettings.hostname).."/",nil,{
		["data"] = textToBlit(message,true)[1],
		["user"] = textToBlit(name,true)[1],
		["msgcolor"] = tonumber(color) or 1
	})
	local evt, yorl, response
	local timeoutID = os.startTimer(5)
	while true do
		evt, yorl, response = os.pullEvent()
		if (evt == "timer") and (yorl == timeoutID) then
			return false, "timed out"
		elseif evt == "http_failure" then
			return false, "failed to connect"
		elseif evt == "http_success" then
			return true, response.readAll()
		end
	end
end

local getTableLength = function(tbl)
	local output = 0
	for k,v in pairs(tbl) do
		output = output + 1
	end
	return output
end

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
	os.queueEvent("enchat_send", "*", "&8'"..yourName.."&r~r' buggered off. (disconnect)", colors.lightGray)
	return "exit"
end
commands.me = function(msg)
	if msg then
		os.queueEvent("enchat_send", "&2*", yourName.."~r&2 "..msg, colors.pink)
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
commands.nick = function(newName)
	if newName then
		if checkValidName(newName) then
			if newName == yourName then
				logadd("*","But you're already called that!")
			else
				os.queueEvent("enchat_send", "*","'"..yourName.."&r~r' is now known as '"..newName.."&r~r'.")
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
commands.palate = function(_argument)
	local argument = _argument or ""
	if argument:gsub("%s","") == "" then
		local buff = ""
		for k,v in pairs(palate) do
			buff = buff..k..", "
		end
		buff = buff:sub(1,-3)
		logadd("*","/palate "..buff.." <colorcode>")
	else
		argument = explode(" ",argument)
		if #argument == 1 then
			if argument[1]:gsub("%s",""):lower() == "reset" then
				palate = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.gray,
					prompttxt = colors.white,
					scrollMeter = colors.lightGray,
					chevron = colors.black,
					title = colors.lightGray
				}
				UIconf = {
					promptY = scr_y - 1,
					chevron = ">",
					chatlogTop = 1,
					title = "",
					doTitle = false,
					nameDecolor = false,
				}
				term.setBackgroundColor(palate.bg)
				term.clear()
				logadd("*","You cleansed your palate.")
			elseif argument[1]:gsub("%s",""):lower() == "enchat2" then
				palate = {
					bg = colors.gray,
					txt = colors.white,
					promptbg = colors.white,
					prompttxt = colors.black,
					scrollMeter = colors.white,
					chevron = colors.lightGray,
					title = colors.lightGray
				}
				UIconf = {
					promptY = scr_y - 1,
					chevron = ">",
					chatlogTop = 1,
					title = "",
					doTitle = false,
					nameDecolor = false,
				}
				term.setBackgroundColor(palate.bg)
				term.clear()
				logadd("*","Switched to the old Enchat2 palate.")
			elseif argument[1]:gsub("%s",""):lower() == "chat.lua" then
				palate = {
					bg = colors.black,
					txt = colors.white,
					promptbg = colors.black,
					prompttxt = colors.white,
					scrollMeter = colors.white,
					chevron = colors.yellow,
					title = colors.yellow
				}
				UIconf = {
					promptY = scr_y,
					chevron = ": ",
					chatlogTop = 2,
					title = "",
					doTitle = true,
					nameDecolor = true,
				}
				term.setBackgroundColor(palate.bg)
				term.clear()
				logadd("*","Switched to /rom/programs/rednet/chat.lua palate.")
			else
				if not palate[argument[1]] then
					logadd("*","There's no such palate option.")
				else
					logadd("*","'"..argument[1].."' = '"..toblit[palate[argument[1]]].."'")
				end
			end
		else
			if #argument > 2 then
				argument = {argument[1], table.concat(argument," ",2)}
			end
			argument[1] = argument[1]:lower()
			local newcol = argument[2]:lower()
			if not palate[argument[1]] then
				logadd("*","That's not a valid palate choice.")
			else
				if not (tocolors[newcol] or colors_strnames[newcol]) then
					logadd("*","That isn't a valid color code. (0-f)")
				else
					palate[argument[1]] = (tocolors[newcol] or colors_strnames[newcol])
					logadd("*","Palate changed.",false)
				end
			end
		end
	end
end
commands.clear = function()
	log = {}
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
			nick = "Give yourself a different username.",
			whoami = "Tells you your current username.",
			key = "Change the current encryption key. Tells you the key, if without argument.",
			clear = "Clears the log. Not your inventory, I swear.",
			ping = "Pong. *sigh*",
			set = "Changes config options during the current session. Lists all options, if without argument.",
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
	nickname = commands.nick,
	["?"] = commands.help,
	porn = function() logadd("*","Yeah, no.") end,
	whoareyou = function() logadd("*", "I'm Enchat. But surely, you know this?") end,
	fuck = function() logadd("*","A mind is a terrible thing to waste.") end,
	hello = function() logadd("*","Hey.") end,
	hi = function() logadd("*","Hiya.") end,
	bye = function() logadd("*","You know, you can use /exit.") end,
	die = function() logadd("*","You would die, but the paperwork is too much.") end,
	nap = function() logadd("*","The time for napping has passed.") end,
	sorry = function() logadd("*","That's okay.") end,
	jump = function() logadd("*","Sorry. This program is in a NO JUMPING zone.") end,
	enchat = function() logadd("*","At your service!") end,
	win = function() logadd("*","Naturally!") end,
	lose = function() logadd("*","Preposterous!") end,
	xyzzy = function() logadd("*","A hollow voice says \"Fool.\"") end,
	wait = function() logadd("*","Time passes...") end,
	OrElseYouWill = function()
		enchatSend("*", "&8'"..yourName.."&r~r' buggered off. (disconnect)",colors.lightGray)
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
	term.setBackgroundColor(palate.bg)
	term.clear()
	os.queueEvent("render_enchat")
	local mHistory = {}
	
	while true do
		
		term.setCursorPos(1, UIconf.promptY)
		term.setBackgroundColor(palate.promptbg)
		term.clearLine()
		term.setTextColor(palate.chevron)
		term.write(UIconf.chevron)
		term.setTextColor(palate.prompttxt)
		ableToRefreshID = os.startTimer(2)
		
		local input = read(nil,mHistory) --replace later with fancier input
		if UIconf.promptY == scr_y then
			term.scroll(1)
		end
		if input:gsub(" ","") ~= "" then --if you didn't just press ENTER or a bunch of spaces
			if checkIfCommand(input) then
				local res = parseCommand(input)
				if res == "exit" then
					return "exit"
				end
			else
				os.queueEvent("enchat_send", yourName, input)
			end
			if mHistory[#mHistory] ~= input then
				mHistory[#mHistory+1] = input
			end
			if ableToRefresh then
				os.queueEvent("enchat_refresh")
			end
			ableToRefresh = false
		end
		os.queueEvent("render_enchat")
		
	end
	
end

local handleReceiveMessage = function(user, message)
	local isAtBottom = (scroll == maxScroll)
	logadd(user, message)
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
		elseif evt[1] == "timer" then
			if evt[2] == ableToRefreshID then
				ableToRefresh = true
			end
		elseif evt[1] == "chat_message" and enchatSettings.useChatBox then --computronics
			local usr, message = evt[3], evt[4]
			messageCount[enchatSettings.hostnameCB] = messageCount[enchatSettings.hostnameCB] + 1
			os.queueEvent("enchat_send", usr, message, nil, enchatSettings.hostnameCB)
		elseif evt[1] == "chat" and enchatSettings.useChatBox then --minimalperipherals
                        local usr, message = evt[2], evt[3]
                        messageCount[enchatSettings.hostnameCB] = messageCount[enchatSettings.hostnameCB] + 1
                        os.queueEvent("enchat_send", usr, message, nil, enchatSettings.hostnameCB)

                end
	end
end

local enchatSendThread = function()
	while true do
		local evt, name, message, color, server = os.pullEvent("enchat_send")
		if type(name) == "string" and type(message) == "string" then
			enchatSend(name, message, color, server)
		end
	end
end

local keepRedrawing = function()
	while true do
		sleep(enchatSettings.redrawDelay)
		os.queueEvent("render_enchat")
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

local getMessages = function(server, _messageCount, _lastSent, useChatBox, ignoreIt)
	local messageCount, lastSent = _messageCount, _lastSent
	local res, msg = enchatSend(yourName, "._client.getMessages", nil, server)
	if (not res) or (msg == "") or (not msg:find("{")) then
		isConnected = false
	else
		local ilog = json.jdecode( msg ) --why oh why is it ever jdecode
		if type(ilog) == "table" then
			isConnected = true
			for i = messageCount+1, #ilog do
				if type(ilog[i].usr) == "string" and type(ilog[i].message) == "string" then
					if (messageCount < #ilog) or lastSent ~= ilog[i].sent then
						if not ignoreIt then
							if useChatBox then
								if chatbox then
									SAY("<"..ilog[i].usr.."> "..ilog[i].message)
									logadd("[CB]&"..toblit[tonumber(ilog[i].color) or 1]..ilog[i].usr, "&"..toblit[tonumber(ilog[i].msgcolor) or 1]..ilog[i].message)
								end
							else
								logadd("&"..toblit[tonumber(ilog[i].color) or 1]..ilog[i].usr, "&"..toblit[tonumber(ilog[i].msgcolor) or 1]..ilog[i].message)
							end
						end
						lastSent = ilog[i].sent
						messageCount = messageCount + 1
					end
				end
			end
		end
	end
	return messageCount, lastSent
end

local keepGettingMessages = function()
	local evt, inid
	messageCount[enchatSettings.hostname], lastSent[enchatSettings.hostname] = getMessages(enchatSettings.hostname, messageCount[enchatSettings.hostname] or 0, lastSent[enchatSettings.hostname] or "")
	messageCount[enchatSettings.hostnameCB], lastSent[enchatSettings.hostnameCB] = getMessages(enchatSettings.hostnameCB, messageCount[enchatSettings.hostnameCB] or 0, lastSent[enchatSettings.hostnameCB] or "", enchatSettings.hostnameCB, messageCount[enchatSettings.hostnameCB] or 0, lastSent[enchatSettings.hostnameCB] or "", chatbox and enchatSettings.useChatBox, true)
	
	msgTimerID = os.startTimer(5)
	while true do
		evt, inid = os.pullEvent()
		if (evt == "timer" and inid == msgTimerID) or (evt == "enchat_refresh") then
			if enchatSettings.useChatBox then
				messageCount[enchatSettings.hostnameCB], lastSent[enchatSettings.hostnameCB] = getMessages(enchatSettings.hostnameCB, messageCount[enchatSettings.hostnameCB] or 0, lastSent[enchatSettings.hostnameCB] or "", chatbox and enchatSettings.useChatBox)
			end
			messageCount[enchatSettings.hostname], lastSent[enchatSettings.hostname] = getMessages(enchatSettings.hostname, messageCount[enchatSettings.hostname] or 0, lastSent[enchatSettings.hostname] or "")
			msgTimerID = os.startTimer(5)
		end
	end
end

enchatSend("*", "'"..yourName.."&r~r' has moseyed on over.", colors.yellow)

parallel.waitForAny(main, handleEvents, keepRedrawing, handleNotifications, keepGettingMessages, enchatSendThread)

term.setCursorPos(1,scr_y)
term.setBackgroundColor(initcolors.bg)
term.setTextColor(initcolors.txt)
term.clearLine()
tsv(true) --in case it's false
