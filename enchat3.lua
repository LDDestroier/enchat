 
--[[
 Enchat 3.0 BETA
 Get with:
  wget https://github.com/LDDestroier/enchat/raw/master/enchat3.lua enchat3
--]]

enchat = {
	version = 3.0,
	isBeta = true,
	port = 11000,
	url = "https://github.com/LDDestroier/enchat/raw/master/enchat3.lua",
	betaurl = "https://github.com/LDDestroier/enchat/raw/master/enchat3beta.lua",
}

enchatSettings = {
	animDiv = 2,		--divisor of text animation speed (scrolling from left)
	doAnimate = true,	--whether or not to animate text moving from left side of screen
	reverseScroll = false,	--whether or not to make scrolling up really scroll down
	redrawDelay = 0.05,	--delay between redrawing
	useSetVisible = true,	--whether or not to use term.current().setVisible(), which has performance and flickering improvements
	pageKeySpeed = 4,	--how far PageUP or PageDOWN should scroll
	doNotif = true		--whether or not to use oveerlay glasses for notifications, if possible
}

local tsv = function(visible)
	if term.current() and enchatSettings.useSetVisible then
		return term.current().setVisible(visible)
	end
end

local tArg = {...}

local yourName, encKey

yourName = tArg[1]
encKey = tArg[2]

local palate = {
	bg = colors.black,		--background color
	txt = colors.white,		--text color (should contrast with bg)
	promptbg = colors.gray,		--chat prompt background
	prompttxt = colors.white,	--chat prompt text
	scrollMeter = colors.lightGray,	--scroll indicator
	chevron = colors.black,		--color of ">" left of text prompt
}

local updateEnchat = function(doBeta)
	local pPath = shell.getRunningProgram()
	local h = http.get(doBeta and enchat.betaurl or enchat.url)
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

local checkValidName = function(nayme)
	if type(nayme) ~= "string" then
		return false
	else
		return (nayme >= 2 and nayme <= 32 and nayme:gsub(" ","") ~= "")
	end
end

if tArg[1] == "update" then
	local res, message = updateEnchat(tArg[2] == "beta")
	return print(message)
end

if not checkValidName(yourName) then --not so fast, evildoers
	yourName = nil
end

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
notif.time = 30
notif.wrapX = 400
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
				l.setColor(table.unpack(colorTranslate["0"]))
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
				words = explode(" ",nList[n][1],_,true)
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
							r.setColor(table.unpack(colorTranslate[back:sub(cx,cx)]))
						else
							r.setAlpha(100 * nList[n][5])
							r.setColor(table.unpack(colorTranslate["7"]))
						end
						drawEdgeLine(y,notif.alpha * nList[n][5])
						t = canvas.addText({xadj+1+(x-1)*notif.width,2+(y-1)*notif.height}, char:sub(cx,cx))
						t.setAlpha(notif.alpha * nList[n][5])
						t.setColor(table.unpack(colorTranslate[text:sub(cx,cx)]))
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

local textToBlit = function(input, _inittext, _initback)
	local inittext = _inittext or toblit[term.getTextColor()]
	local initback = _initback or toblit[term.getBackgroundColor()]
	local char, text, back = "", inittext, initback
	local charout, textout, backout = "", "", ""
	local textCode = "&"
	local backCode = "~"

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
				if tocolors[nex:lower()] and (nex ~= textCode) then
					text = nex:lower()
					x = x + 1
				elseif nex:lower() == "r" then
					text = inittext
					x = x + 1
				else
					char = cur
					x = (nex == textCode) and (x + 1) or x
					progress()
				end
			elseif cur == backCode and nex then
				if tocolors[nex:lower()] and (nex ~= backCode) then
					back = nex:lower()
					x = x + 1
				elseif nex:lower() == "r" then
					back = initback
					x = x + 1
				else
					char = cur
					x = (nex == backCode) and (x + 1) or x
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

local inAnimate = function(buff, frame, maxFrame, length)
	local char, text, back = buff[1], buff[2], buff[3]
	if enchatSettings.doAnimate then
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
	term.setBackgroundColor(palate.bg)
	term.setTextColor(palate.txt)
	for a = 1, #log do
		term.setCursorPos(1,1)
		prebuff = {textToBlit(table.concat({log[a].prefix,"&r~r",log[a].name,"&r~r",log[a].suffix,"&r~r",log[a].message}))}
		if (log[a].frame == 0) and (canvas and enchatSettings.doNotif) then
			notif.newNotification(
				prebuff[1],
				prebuff[2],
				prebuff[3],
				notif.time*4
			)
		end
		if log[a].maxFrame == true then
			log[a].maxFrame = math.floor(math.min(#prebuff[1], scr_x) / enchatSettings.animDiv)
		end
		buff, maxLength = blitWrap(unpack(prebuff))
		--repeat every line in multiline entries
		for l = 1, #buff do
			renderlog[#renderlog + 1] = inAnimate(buff[l], log[a].frame, log[a].maxFrame, maxLength)
		end
		if log[a].frame < log[a].maxFrame then
			log[a].frame = log[a].frame + 1
		end
	end
	maxScroll = math.max(0, #renderlog - (scr_y - 2))
	if scrollToBottom then
		scroll = maxScroll
	end
end

local renderChat = function()
	tsv(false)
	genRenderLog(log)
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
	term.setCursorPos(1,scr_y)
	term.setTextColor(palate.scrollMeter)
	term.clearLine()
	term.write(scroll.." / "..maxScroll.."  ")
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

local enchatSend = function(name, message, doLog)
	if doLog then
		logadd(name, message)
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

commands.exit = function(farewell)
	enchatSend("*", "'"..yourName.."&r~r' has buggered off."..(farewell and (" ("..farewell..")") or ""))
	return "exit"
end
commands.me = function(msg)
	if msg then
		enchatSend(nil, "&2 * "..yourName.."~r&2 "..msg, true)
	else
		logadd("*",commandInit.."me [message]")
	end
end
commands.colors = function()
	logadd("*", "Color codes: (use && or ~~)")
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
commands.list = function()
	userCryList = {}
	local tim = os.startTimer(0.1)
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
			encKey = newKey
			logadd("*", "Key changed to '"..encKey.."&r~r'.")
			enchatSend("*", "'"..yourName.."&r~r' has moseyed on over.", false)
		else
			logadd("*", "That's already the key, though.")
		end
	else
		logadd("Key = '"..encKey.."&r~r'")
		logadd("Channel = '"..enchat.port.."'")
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
				}
				logadd("*","You cleansed your palate.")
			elseif argument[1]:gsub("%s",""):lower() == "enchat2" then
				palate = {
					bg = colors.gray,
					txt = colors.white,
					promptbg = colors.white,
					prompttxt = colors.black,
					scrollMeter = colors.white,
					chevron = colors.lightGray
				}
				logadd("*","Switched to the old Enchat2 palate.")
			else
				logadd("*","Give me a color code next time.")
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
			list = "Lists all users in range using the same key.",
			nick = "Give yourself a different username.",
			whoami = "Tells you your current username.",
			key = "Tells you the encryption key. Can also be used to change it.",
			clear = "Clears the log. Not your inventory, I swear.",
			ping = "Pong. *sigh*",
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
	["?"] = commands.help,
	porn = function()
		logadd("*","Yeah, no.")
	end,
	whoareyou = function()
		logadd("*", "I'm Enchat. But surely, you know this?")
	end,
	fuck = function()
		logadd("*","A mind is a terrible thing to waste.")
	end,
	die = function()
		logadd("*","You would die, but the paperwork is too much.")
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
		
		term.setCursorPos(1, scr_y - 1)
		term.setBackgroundColor(palate.promptbg)
		term.clearLine()
		term.setTextColor(palate.chevron)
		term.write(">")
		term.setTextColor(palate.prompttxt)
		
		local input = read(nil,mHistory) --replace later with fancier input
		if input:gsub(" ","") ~= "" then --if you didn't just press ENTER or a bunch of spaces
			if checkIfCommand(input) then
				local res = parseCommand(input)
				if res == "exit" then
					return "exit"
				end
			else
				enchatSend(yourName, input, true)
			end
			if mHistory[#mHistory] ~= input then
				mHistory[#mHistory+1] = input
			end
			os.queueEvent("render_enchat")
		end
		
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
	while true do
		local evt = {os.pullEvent()}
		if evt[1] == "modem_message" then
			local side, freq, repfreq, msg, distance = evt[2], evt[3], evt[4], evt[5], evt[6]
			msg = decrite(msg)
			if type(msg) == "table" then
				if (type(msg.name) == "string") then
					userCryList[msg.name] = true
					if (type(msg.message) == "string") then
						handleReceiveMessage(msg.name, tostring(msg.message))
					end
					if (msg.cry == true) then
						cryOut(yourName, false)
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
			oldScroll = scroll
			if key == keys.pageUp then
				adjScroll(-enchatSettings.pageKeySpeed)
			elseif key == keys.pageDown then
				adjScroll(enchatSettings.pageKeySpeed)
			elseif key == keys.home then
				scroll = 0
			elseif key == keys["end"] then
				scroll = maxScroll
			end
			if scroll ~= oldScroll then
				dab(renderChat)
			end
		elseif (evt[1] == "render_enchat") then
			dab(renderChat)
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

getModem()

enchatSend("*", "'"..yourName.."&r~r' has moseyed on over.", true)

parallel.waitForAny(main, handleEvents, keepRedrawing, handleNotifications)

term.setCursorPos(1,scr_y)
term.setBackgroundColor(initcolors.bg)
term.setTextColor(initcolors.txt)
term.clearLine()
tsv(true) --in case it's false
