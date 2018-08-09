local tArg = {...}

local yourName = tArg[1]
local encKey = tArg[2]

enchat = {
	version = 3.0,
	isBeta = true
}

local scr_x, scr_y = term.getSize()

local log = {} --Records all sorts of data on text.
local renderlog = {} --Only records straight terminal output. Generated from 'log'

local scroll = 0

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
		if #buff + words[w] > scr_x then
			cwrite(buff, y + lines)
			buff = ""
			lines = lines + 1
		end
		buff = buff + words[w]
	end
	cwrite(buff, y + lines)
	return lines
end

local prettyPrompt = function(prompt, y, replchar, history)
	local yadj = 1 + prettyCenterWrite(prompt, y)
	term.setCursorPos(1, y + yadj)
	term.setBackgroundColor(colors.lightGray)
	term.clearLine()
	local output = read(replchar, history) --will eventually add fancy colored read function
end

local currentY = 2

if not yourName then
	yourName = prettyPrompt("Enter your name.", currentY)
	currentY = currentY + 3
end

if not encKey then
	encKey = prettyPrompt("Enter an encryption key.", currentY)
	currentY = currentY + 3
end

--need to add textToBlit function

local genRenderLog = function(log)
	local buff, prebuff
	renderlog = {}
	for a = 1, #log do
		prebuff = {textToBlit(log[a].prefix..log[a].name..log[a].suffix..log[a].message)}
		buff = blitWrap(unpack(prebuff))
		for l = 1, #buff do
			renderlog[#renderlog + 1] = buff[l]
		end
	end
end

local renderChat = function(scroll)
	genRenderLog()
	local y = 1
	for a = (scroll + 1), scroll + scr_y do
		if renderlog[a] then
			term.setCursorPos(1, y)
			term.blit(unpack(renderlog[a])
		end
		y = y + 1
	end
end

-- do finish, will ya
