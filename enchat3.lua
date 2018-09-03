--[[
 Enchat 3.0 BETA (well, work in progress really)
 Get with:
  wget https://github.com/LDDestroier/enchat/raw/master/enchat3.lua enchat3
--]]

local tArg = {...}

local yourName = tArg[1]
local encKey = tArg[2]

enchat = {
	version = 3.0,
	isBeta = true
}

-- AES API START (thank you SquidDev) --

local function e(n)
local s=setmetatable({},{__index=_ENV or getfenv()})if setfenv then setfenv(n,s)end;return n(s)or s end
local t=e(function(n,...)local s=math.floor;local h,r
r=function(d,l)return s(d%4294967296/2^l)end
h=function(d,l)return(d*2^l)%4294967296 end
return{bnot=bit.bnot,band=bit.band,bor=bit.bor,bxor=bit.bxor,rshift=r,lshift=h}end)
local a=e(function(n,...)local s=t.bxor;local h=t.lshift;local r=0x100;local d=0xff;local l=0x11b;local u={}local c={}
local function m(k,q)return s(k,q)end;local function f(k,q)return s(k,q)end
local function w(k)if(k==1)then return 1 end;local q=d-c[k]return u[q]end;local function y(k,q)if(k==0 or q==0)then return 0 end;local j=c[k]+c[q]
if(j>=d)then j=j-d end;return u[j]end
local function p(k,q)
if(k==0)then return 0 end;local j=c[k]-c[q]if(j<0)then j=j+d end;return u[j]end
local function v()for k=1,r do print("log(",k-1,")=",c[k-1])end end
local function b()for k=1,r do print("exp(",k-1,")=",u[k-1])end end;local function g()local k=1
for q=0,d-1 do u[q]=k;c[k]=q;k=s(h(k,1),k)if k>d then k=f(k,l)end end end;g()return
{add=m,sub=f,invert=w,mul=y,div=dib,printLog=v,printExp=b}end)
util=e(function(n,...)local s=t.bxor;local h=t.rshift;local r=t.band;local d=t.lshift;local l;local function u(O)O=s(O,h(O,4))
O=s(O,h(O,2))O=s(O,h(O,1))return r(O,1)end
local function c(O,I)if(I==0)then return
r(O,0xff)else return r(h(O,I*8),0xff)end end;local function m(O,I)
if(I==0)then return r(O,0xff)else return d(r(O,0xff),I*8)end end
local function f(O,I,N)local S={}
for H=0,N-1 do
S[H+1]=
m(O[I+ (H*4)],3)+m(O[I+ (H*4)+1],2)+
m(O[I+ (H*4)+2],1)+m(O[I+ (H*4)+3],0)if N%10000 ==0 then l()end end;return S end;local function w(O,I,N,S)S=S or#O;for H=0,S-1 do
for R=0,3 do I[N+H*4+ (3-R)]=c(O[H+1],R)end;if S%10000 ==0 then l()end end
return I end;local function y(O)local I=""
for N,S in
ipairs(O)do I=I..string.format("%02x ",S)end;return I end
local function p(O)local I={}for N=1,#O,2 do I[#I+1]=tonumber(O:sub(N,
N+1),16)end;return I end
local function v(O)local I=type(O)
if(I=="number")then return string.format("%08x",O)elseif
(I=="table")then return y(O)elseif(I=="string")then local N={string.byte(O,1,#O)}
return y(N)else return O end end
local function b(O)local I=#O;local N=math.random(0,255)local S=math.random(0,255)
local H=string.char(N,S,N,S,c(I,3),c(I,2),c(I,1),c(I,0))O=H..O;local R=math.ceil(#O/16)*16-#O;local D=""for L=1,R do D=D..
string.char(math.random(0,255))end;return O..D end
local function g(O)local I={string.byte(O,1,4)}if
(I[1]==I[3]and I[2]==I[4])then return true end;return false end
local function k(O)if(not g(O))then return nil end
local I=
m(string.byte(O,5),3)+
m(string.byte(O,6),2)+m(string.byte(O,7),1)+m(string.byte(O,8),0)return string.sub(O,9,8+I)end;local function q(O,I)for N=1,16 do O[N]=s(O[N],I[N])end end
local function j(O)
local I=16;while true do local N=O[I]+1
if N>=256 then O[I]=N-256;I=(I-2)%16+1 else O[I]=N;break end end end;local x,z,_=os.queueEvent,coroutine.yield,os.time;local E=_()
local function l()local O=_()if O-E>=0.03 then E=O
x("sleep")z("sleep")end end
local function T(O)local I,N,S,H=string.char,math.random,l,table.insert;local R={}for D=1,O do
H(R,N(0,255))if D%10240 ==0 then S()end end;return R end
local function A(O)local I,N,S,H=string.char,math.random,l,table.insert;local R={}for D=1,O do
H(R,I(N(0,255)))if D%10240 ==0 then S()end end
return table.concat(R)end
return
{byteParity=u,getByte=c,putByte=m,bytesToInts=f,intsToBytes=w,bytesToHex=y,hexToBytes=p,toHexString=v,padByteString=b,properlyDecrypted=g,unpadByteString=k,xorIV=q,increment=j,sleepCheckIn=l,getRandomData=T,getRandomString=A}end)
aes=e(function(n,...)local s=util.putByte;local h=util.getByte;local r='rounds'local d="type"local l=1;local u=2
local c={}local m={}local f={}local w={}local y={}local p={}local v={}local b={}local g={}local k={}
local q={0x01000000,0x02000000,0x04000000,0x08000000,0x10000000,0x20000000,0x40000000,0x80000000,0x1b000000,0x36000000,0x6c000000,0xd8000000,0xab000000,0x4d000000,0x9a000000,0x2f000000}
local function j(M)mask=0xf8;result=0
for F=1,8 do result=t.lshift(result,1)
parity=util.byteParity(t.band(M,mask))result=result+parity;lastbit=t.band(mask,1)
mask=t.band(t.rshift(mask,1),0xff)
if(lastbit~=0)then mask=t.bor(mask,0x80)else mask=t.band(mask,0x7f)end end;return t.bxor(result,0x63)end;local function x()
for M=0,255 do if(M~=0)then inverse=a.invert(M)else inverse=M end
mapped=j(inverse)c[M]=mapped;m[mapped]=M end end
local function z()
for M=0,255 do
byte=c[M]
f[M]=
s(a.mul(0x03,byte),0)+s(byte,1)+s(byte,2)+s(a.mul(0x02,byte),3)w[M]=s(byte,0)+s(byte,1)+s(a.mul(0x02,byte),2)+
s(a.mul(0x03,byte),3)y[M]=

s(byte,0)+s(a.mul(0x02,byte),1)+s(a.mul(0x03,byte),2)+s(byte,3)p[M]=

s(a.mul(0x02,byte),0)+s(a.mul(0x03,byte),1)+s(byte,2)+s(byte,3)end end
local function _()
for M=0,255 do byte=m[M]
v[M]=
s(a.mul(0x0b,byte),0)+s(a.mul(0x0d,byte),1)+s(a.mul(0x09,byte),2)+
s(a.mul(0x0e,byte),3)
b[M]=
s(a.mul(0x0d,byte),0)+s(a.mul(0x09,byte),1)+s(a.mul(0x0e,byte),2)+
s(a.mul(0x0b,byte),3)
g[M]=
s(a.mul(0x09,byte),0)+s(a.mul(0x0e,byte),1)+s(a.mul(0x0b,byte),2)+
s(a.mul(0x0d,byte),3)
k[M]=
s(a.mul(0x0e,byte),0)+s(a.mul(0x0b,byte),1)+s(a.mul(0x0d,byte),2)+
s(a.mul(0x09,byte),3)end end;local function E(M)local F=t.band(M,0xff000000)return
(t.lshift(M,8)+t.rshift(F,24))end
local function T(M)return
s(c[h(M,0)],0)+s(c[h(M,1)],1)+s(c[h(M,2)],2)+
s(c[h(M,3)],3)end
local function A(M)local F={}local W=math.floor(#M/4)if(
(W~=4 and W~=6 and W~=8)or(W*4 ~=#M))then
error("Invalid key size: "..tostring(W))return nil end;F[r]=W+6;F[d]=l;for Y=0,W-1
do
F[Y]=
s(M[Y*4+1],3)+s(M[Y*4+2],2)+s(M[Y*4+3],1)+s(M[Y*4+4],0)end
for Y=W,(F[r]+1)*4-1 do
local P=F[Y-1]
if(Y%W==0)then P=E(P)P=T(P)local V=math.floor(Y/W)P=t.bxor(P,q[V])elseif(
W>6 and Y%W==4)then P=T(P)end;F[Y]=t.bxor(F[(Y-W)],P)end;return F end
local function O(M)local F=h(M,3)local W=h(M,2)local Y=h(M,1)local P=h(M,0)
return

s(a.add(a.add(a.add(a.mul(0x0b,W),a.mul(0x0d,Y)),a.mul(0x09,P)),a.mul(0x0e,F)),3)+
s(a.add(a.add(a.add(a.mul(0x0b,Y),a.mul(0x0d,P)),a.mul(0x09,F)),a.mul(0x0e,W)),2)+
s(a.add(a.add(a.add(a.mul(0x0b,P),a.mul(0x0d,F)),a.mul(0x09,W)),a.mul(0x0e,Y)),1)+
s(a.add(a.add(a.add(a.mul(0x0b,F),a.mul(0x0d,W)),a.mul(0x09,Y)),a.mul(0x0e,P)),0)end
local function I(M)local F=h(M,3)local W=h(M,2)local Y=h(M,1)local P=h(M,0)local V=t.bxor(P,Y)
local B=t.bxor(W,F)local G=t.bxor(V,B)G=t.bxor(G,a.mul(0x08,G))
w=t.bxor(G,a.mul(0x04,t.bxor(Y,F)))G=t.bxor(G,a.mul(0x04,t.bxor(P,W)))
return

s(t.bxor(t.bxor(P,G),a.mul(0x02,t.bxor(F,P))),0)+s(t.bxor(t.bxor(Y,w),a.mul(0x02,V)),1)+
s(t.bxor(t.bxor(W,G),a.mul(0x02,t.bxor(F,P))),2)+
s(t.bxor(t.bxor(F,w),a.mul(0x02,B)),3)end
local function N(M)local F=A(M)if(F==nil)then return nil end;F[d]=u;for W=4,(F[r]+1)*4-5 do
F[W]=O(F[W])end;return F end;local function S(M,F,W)
for Y=0,3 do M[Y+1]=t.bxor(M[Y+1],F[W*4+Y])end end
local function H(M,F)
F[1]=t.bxor(t.bxor(t.bxor(f[h(M[1],3)],w[h(M[2],2)]),y[h(M[3],1)]),p[h(M[4],0)])
F[2]=t.bxor(t.bxor(t.bxor(f[h(M[2],3)],w[h(M[3],2)]),y[h(M[4],1)]),p[h(M[1],0)])
F[3]=t.bxor(t.bxor(t.bxor(f[h(M[3],3)],w[h(M[4],2)]),y[h(M[1],1)]),p[h(M[2],0)])
F[4]=t.bxor(t.bxor(t.bxor(f[h(M[4],3)],w[h(M[1],2)]),y[h(M[2],1)]),p[h(M[3],0)])end
local function R(M,F)
F[1]=s(c[h(M[1],3)],3)+s(c[h(M[2],2)],2)+
s(c[h(M[3],1)],1)+s(c[h(M[4],0)],0)
F[2]=s(c[h(M[2],3)],3)+s(c[h(M[3],2)],2)+
s(c[h(M[4],1)],1)+s(c[h(M[1],0)],0)
F[3]=s(c[h(M[3],3)],3)+s(c[h(M[4],2)],2)+
s(c[h(M[1],1)],1)+s(c[h(M[2],0)],0)
F[4]=s(c[h(M[4],3)],3)+s(c[h(M[1],2)],2)+
s(c[h(M[2],1)],1)+s(c[h(M[3],0)],0)end
local function D(M,F)
F[1]=t.bxor(t.bxor(t.bxor(v[h(M[1],3)],b[h(M[4],2)]),g[h(M[3],1)]),k[h(M[2],0)])
F[2]=t.bxor(t.bxor(t.bxor(v[h(M[2],3)],b[h(M[1],2)]),g[h(M[4],1)]),k[h(M[3],0)])
F[3]=t.bxor(t.bxor(t.bxor(v[h(M[3],3)],b[h(M[2],2)]),g[h(M[1],1)]),k[h(M[4],0)])
F[4]=t.bxor(t.bxor(t.bxor(v[h(M[4],3)],b[h(M[3],2)]),g[h(M[2],1)]),k[h(M[1],0)])end
local function L(M,F)
F[1]=s(m[h(M[1],3)],3)+s(m[h(M[4],2)],2)+
s(m[h(M[3],1)],1)+s(m[h(M[2],0)],0)
F[2]=s(m[h(M[2],3)],3)+s(m[h(M[1],2)],2)+
s(m[h(M[4],1)],1)+s(m[h(M[3],0)],0)
F[3]=s(m[h(M[3],3)],3)+s(m[h(M[2],2)],2)+
s(m[h(M[1],1)],1)+s(m[h(M[4],0)],0)
F[4]=s(m[h(M[4],3)],3)+s(m[h(M[3],2)],2)+
s(m[h(M[2],1)],1)+s(m[h(M[1],0)],0)end
local function U(M,F,W,Y,P)W=W or 1;Y=Y or{}P=P or 1;local V={}local B={}if(M[d]~=l)then
error("No encryption key: "..
tostring(M[d])..", expected "..l)return end
V=util.bytesToInts(F,W,4)S(V,M,0)local G=1;while(G<M[r]-1)do H(V,B)S(B,M,G)G=G+1;H(B,V)S(V,M,G)
G=G+1 end;H(V,B)S(B,M,G)G=G+1;R(B,V)S(V,M,G)
util.sleepCheckIn()return util.intsToBytes(V,Y,P)end
local function C(M,F,W,Y,P)W=W or 1;Y=Y or{}P=P or 1;local V={}local B={}
if(M[d]~=u)then error("No decryption key: "..
tostring(M[d]))return end;V=util.bytesToInts(F,W,4)S(V,M,M[r])local G=M[r]-1;while(G>2)do
D(V,B)S(B,M,G)G=G-1;D(B,V)S(V,M,G)G=G-1 end;D(V,B)
S(B,M,G)G=G-1;L(B,V)S(V,M,G)util.sleepCheckIn()return
util.intsToBytes(V,Y,P)end;x()z()_()
return{ROUNDS=r,KEY_TYPE=d,ENCRYPTION_KEY=l,DECRYPTION_KEY=u,expandEncryptionKey=A,expandDecryptionKey=N,encrypt=U,decrypt=C}end)
local o=e(function(n,...)local function s()return{}end;local function h(d,l)table.insert(d,l)end;local function r(d)return
table.concat(d)end;return{new=s,addString=h,toString=r}end)
ciphermode=e(function(n,...)local s={}local h=math.random
function s.encryptString(r,d,l,u)if u then local f={}for w=1,16 do f[w]=u[w]end;u=f else
u={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}end
local c=aes.expandEncryptionKey(r)local m=o.new()for f=1,#d/16 do local w=(f-1)*16+1
local y={string.byte(d,w,w+15)}u=l(c,y,u)
o.addString(m,string.char(unpack(y)))end
return o.toString(m)end;function s.encryptECB(r,d,l)aes.encrypt(r,d,1,d,1)end;function s.encryptCBC(r,d,l)
util.xorIV(d,l)aes.encrypt(r,d,1,d,1)return d end;function s.encryptOFB(r,d,l)
aes.encrypt(r,l,1,l,1)util.xorIV(d,l)return l end;function s.encryptCFB(r,d,l)
aes.encrypt(r,l,1,l,1)util.xorIV(d,l)return d end
function s.encryptCTR(r,d,l)
local u={}for c=1,16 do u[c]=l[c]end;aes.encrypt(r,l,1,l,1)
util.xorIV(d,l)util.increment(u)return u end
function s.decryptString(r,d,l,u)if u then local f={}for w=1,16 do f[w]=u[w]end;u=f else
u={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}end;local c
if l==s.decryptOFB or
l==s.decryptCFB or l==s.decryptCTR then
c=aes.expandEncryptionKey(r)else c=aes.expandDecryptionKey(r)end;local m=o.new()for f=1,#d/16 do local w=(f-1)*16+1
local y={string.byte(d,w,w+15)}u=l(c,y,u)
o.addString(m,string.char(unpack(y)))end
return o.toString(m)end;function s.decryptECB(r,d,l)aes.decrypt(r,d,1,d,1)return l end;function s.decryptCBC(r,d,l)
local u={}for c=1,16 do u[c]=d[c]end;aes.decrypt(r,d,1,d,1)
util.xorIV(d,l)return u end;function s.decryptOFB(r,d,l)
aes.encrypt(r,l,1,l,1)util.xorIV(d,l)return l end;function s.decryptCFB(r,d,l)
local u={}for c=1,16 do u[c]=d[c]end;aes.encrypt(r,l,1,l,1)
util.xorIV(d,l)return u end
s.decryptCTR=s.encryptCTR;return s end)AES128=16;AES192=24;AES256=32;ECBMODE=1;CBCMODE=2;OFBMODE=3;CFBMODE=4;CTRMODE=4
local function i(n,s,h)local r=s;if(s==
AES192)then r=32 end
if(r>#n)then local l=""for u=1,r-#n do
l=l..string.char(0)end;n=n..l else n=string.sub(n,1,r)end;local d={string.byte(n,1,#n)}
n=ciphermode.encryptString(d,n,ciphermode.encryptCBC,h)n=string.sub(n,1,s)return{string.byte(n,1,#n)}end
function encrypt(n,s,h,r,d)assert(n~=nil,"Empty password.")
assert(n~=nil,"Empty data.")local r=r or CBCMODE;local h=h or AES128;local l=i(n,h,d)
local u=util.padByteString(s)
if r==ECBMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptECB,d)elseif r==CBCMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptCBC,d)elseif r==OFBMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptOFB,d)elseif r==CFBMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptCFB,d)elseif r==CTRMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptCTR,d)else error("Unknown mode",2)end end
function decrypt(n,s,h,r,d)local r=r or CBCMODE;local h=h or AES128;local l=i(n,h,d)local u
if r==ECBMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptECB,d)elseif r==CBCMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptCBC,d)elseif r==OFBMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptOFB,d)elseif r==CFBMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptCFB,d)elseif r==CTRMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptCTR,d)else error("Unknown mode",2)end;result=util.unpadByteString(u)
if(result==nil)then return nil end;return result end

-- AES API STOP (thanks again) --

local checkValidName = function(name)
	return (#name >= 2 and #name <= 32)
end

local scr_x, scr_y = term.getSize()

local log = {} --Records all sorts of data on text.
local renderlog = {} --Only records straight terminal output. Generated from 'log'

local scroll = 0
local maxScroll = 0

local getMaxScroll = function()
  return math.max(0, #renderlog - (scr_y - 1))
end

local modem
local getModem = function()
  --modem = peripheral.find("modem")
  modem = {transmit = function() end}
end

local encrite = function(input, key) --standardized encryption function
  return input
end

local decrite = function(input, key)
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
end

local currentY = 2

if not (yourName and encKey) then
	prettyClearScreen()
end

if not yourName then
	yourName = prettyPrompt("Enter your name.", currentY)
	local isValid = checkValidName(yourName)
	if not isValid then
		repeat
			yourName = prettyPrompt("Invalid name. Enter another.", currentY)
			isValid = checkValidName(yourName)
		until isValid
	end
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
				end
			elseif cur == backCode and nex then
				if tocolors[nex:lower()] then
					back = nex:lower()
					x = x + 1
				else
					char = nex
				end
			else
				char = cur
			end

			charout = charout..char
			textout = textout..text
			backout = backout..back
		else
			break
		end
	end
	return charout, textout, backout
end

local genRenderLog = function()
	local buff, prebuff
	renderlog = {}
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)
	for a = 1, #log do
		term.setCursorPos(1,1)
		prebuff = {textToBlit(log[a].prefix .. log[a].name .. log[a].suffix .. log[a].message)}
		buff = blitWrap(unpack(prebuff))
		for l = 1, #buff do
			renderlog[#renderlog + 1] = buff[l]
		end
	end
end

local renderChat = function(scroll)
	genRenderLog(log)
	local y = 1
	term.setBackgroundColor(colors.gray)
	term.clear()
	for a = (scroll + 1), -1 + scroll + scr_y do
		if renderlog[a] then
			term.setCursorPos(1, y)
			--term.clearLine()
			term.blit(unpack(renderlog[a]))
		end
		y = y + 1
	end
end

local logadd = function(name, message)
	log[#log + 1] = {
		prefix = "<",
		suffix = "> ",
		name = name,
		message = message
	}
end

local enchatSend = function(name, message, doLog)
	if doLog then
		logadd(name or "shit", message)
		renderChat(scroll)
	end
	modem.transmit(enchat.port, enchat.port, encrite({
		name = name,
		message = message
	}))
end

local commands = {
	--Commands only have one argument -- a single string.
	--Separate arguments can be extrapolated with the explode() function.
	exit = function(farewell)
		enchatSend("*", yourName.." has buggered off."..(farewell and (" ("..farewell..")") or ""))
		return "exit"
	end,
	me = function(msg)
		enchatSend("*", yourName.." "..msg)
		renderChat(scroll)
	end,
	nick = function(newName)
		local isValid = checkValidName(newName)
	end
}

local main = function()
	term.setBackgroundColor(colors.gray)
	term.clear()
	renderChat(scroll)
	while true do
		term.setCursorPos(1, scr_y - 1)
		term.setBackgroundColor(colors.lightGray)
		term.setTextColor(colors.black)
		term.clearLine()
		local input = read() --replace later with fancier input
		enchatSend(yourName, input, true)
	end
end

local handleEvents = function()
	while true do
		local evt = {os.pullEvent()}
		maxScroll = getMaxScroll()
		if evt == "enchat_receive" then
			local user, message = evt[2], evt[3]
			logadd(user, message)
			renderChat(scroll)
		elseif evt == "enchat_send" then
			local user, message, doLog = evt[2], evt[3], evt[4]
			enchatSend(user, message, doLog)
		elseif evt == "modem_message" then
			local side, freq, repfreq, distance, msg = evt[2], evt[3], evt[4], evt[5], evt[6]
			msg = decrite(msg)
			if type(msg) == "table" then
				if (type(msg.name) == "string") and (type(msg.message) == "string") then
					os.queueEvent("enchat_receive", msg.name, msg.receive)
				end
			end
		elseif evt == "mouse_scroll" then
			local dist = evt[2]
			scroll = math.min(maxScroll, math.max(0, scroll + dist))
			renderChat(scroll)
		end
	end
end

getModem()

parallel.waitForAny(main, handleEvents)
