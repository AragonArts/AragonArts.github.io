AESP = AESP or {}
AESP.version = 13.6
AESP.DistanceToPlayer = 7000
AESP.Menu = AESP.Menu or {}
AESP.Scripts = AESP.Scripts or {}
AESP.Font = "HudHintTextLarge"
AESP.UpdateValue = 0

chat.AddText(Color(0,255,255),"[AESP]",Color(255,255,255)," Loading AESP v"..AESP.version)
chat.AddText(Color(0,255,255),"[AESP]",Color(255,255,255)," Compiling script....")

function AESP.isMeta()
    if aowl == nil then return false else return true end
end

function AESP.TranslateOre(n)
local a = n:GetRarity()
if a == 0 then return "Copper Rarity"  end
if a == 1 then return "Silver Rarity" end
if a == 2 then return "Gold Rarity" end
if n == 3 then return "Unknown Rarity" end
end
 
function AESP.OreColor(n)
local a = n:GetRarity()
if a == 0 then return Color(255,155,0) end -- Coppter
if a == 1 then return Color(185,185,185) end -- Silver
if a == 2 then return Color(255,255,0) end -- Gold
end
 
function AESP.DrawBox(x,y,e)
if e != 0 then surface.SetDrawColor( AESP.OreColor(e) ) else surface.SetDrawColor( Color(255,255,255) ) end
surface.DrawOutlinedRect( x, y, 15,15 )
surface.DrawRect( x+4, y+4, 6,6 )
end
 
function AESP.DrawText(x,y,t,e)
surface.SetFont( AESP.Font )
surface.SetTextColor( AESP.OreColor(e) )
surface.SetTextPos( x + 20, y )
surface.DrawText( t )
end

AESP.Scripts.MineESP = {}
AESP.Scripts.MineESP.Command = [[
hook.Add( "HUDPaint", "AESP_MiningESP", function()
    for _,v in pairs(ents.FindByClass("mining_rock")) do
    // all text varibles for distance and shit
    local orePosX = v:GetPos():ToScreen().x
    local orePosY = v:GetPos():ToScreen().y
    local DistanceToPlayer = v:GetPos():Distance(LocalPlayer():GetPos())
    local oreType = "["..AESP.TranslateOre(v).."] "..v.ClassName.. " ("..math.round(DistanceToPlayer).."m)"
   
    if DistanceToPlayer > AESP.DistanceToPlayer or DistanceToPlayer < 150 then continue end
    /////////////////////////////////////////// Draw Square
    AESP.DrawBox(orePosX,orePosY,v)
   
    ////////////////////////////////////////// Draw Text
    AESP.DrawText(orePosX,orePosY,oreType,v)
    end
   
    for _,v in pairs(ents.FindByClass("mining_ore")) do
    local orePosX = v:GetPos():ToScreen().x
    local orePosY = v:GetPos():ToScreen().y
    local DistanceToPlayer = v:GetPos():Distance(LocalPlayer():GetPos())
    local oreType = "["..AESP.TranslateOre(v).."] "..v.ClassName.. " ("..math.Round(DistanceToPlayer).."m)"
   
    if DistanceToPlayer > AESP.DistanceToPlayer or DistanceToPlayer < 150 then continue end
 
    AESP.DrawBox(orePosX,orePosY,v)
 
    ////////////////////////////////////////// Draw Text
    AESP.DrawText(orePosX,orePosY,oreType,v)
 
    end
end )]]
AESP.Scripts.MineESP.Name = "AESP_MiningESP"
AESP.Scripts.MineESP.MetaOnly = true
AESP.Scripts.MineESP.Del = [[hook.Remove("HUDPaint", "AESP_MiningESP")]]

AESP.Scripts.CoinESP = {}
AESP.Scripts.CoinESP.Command = [[   
hook.Add( "HUDPaint", "AESP_CoinESP", function()
    for _,v in pairs(ents.FindByClass("coin")) do
    // all text varibles for distance and shit
    local orePosX = v:GetPos():ToScreen().x
    local orePosY = v:GetPos():ToScreen().y
    local DistanceToPlayer = v:GetPos():Distance(LocalPlayer():GetPos())
    local oreType = v:GetRealValue() .."$ "..v.ClassName.. " ("..math.round(DistanceToPlayer).."m)"
    if DistanceToPlayer > AESP.DistanceToPlayer or DistanceToPlayer < 150 then continue end

    /////////////////////////////////////////// Draw Square
    surface.SetDrawColor(  0, 255, 0 , 255 )
    surface.DrawOutlinedRect( orePosX, orePosY, 15,15 )
    surface.DrawRect( orePosX+4, orePosY+4, 6,6 )
 
 
    ////////////////////////////////////////// Draw Text
    surface.SetFont( AESP.Font )
    surface.SetTextColor( 0, 255, 0 )
    surface.SetTextPos( orePosX + 20, orePosY )
    surface.DrawText( oreType )
    end
end )]]
AESP.Scripts.CoinESP.Name = "AESP_CoinESP"
AESP.Scripts.CoinESP.MetaOnly = true
AESP.Scripts.CoinESP.Del = [[hook.Remove("HUDPaint", "AESP_CoinESP")]]

AESP.Scripts.BhopStats = {}
AESP.Scripts.BhopStats.Command = [[
local bounce = false
local doBounce = false
local runCmd = {
"autojump 1",
"autojump_speed 9999",
}
for _,v in pairs(runCmd) do
LocalPlayer():ConCommand(v)	
end

local max = 0
hook.Add( "HUDPaint", "AESP_BHOPHud", function()
	local vel = LocalPlayer():GetVelocity()
	vel.z = 0
	local speed = vel:Length()
	local info = ""
	local transp = 255
	local width = speed * 100 / 280
	if(width > 500) then
		width = 500
		info = "You're going real fast"
	end
	if(width > max) then
		max = width
	end
	if((max - 20) > width and speed > 250) then
		max = max - 1
		info = "Losing velocity!"
	end
	if(speed < 250) then
		max = max - 0.4
	end
	draw.DrawText(math.Round(speed).." MPH", "DermaLarge", ScrW() /2, ScrH() - 150, Color( 255, 255, 255, transp ), TEXT_ALIGN_CENTER )
	draw.DrawText(info, "DermaDefault", ScrW() /2, ScrH() - 120, Color( 255, 255, 255, transp ), TEXT_ALIGN_CENTER )
	surface.SetDrawColor( 255, 255, 255, transp )
	surface.DrawRect( ScrW() / 2 - 250, ScrH() - 100 , 500, 25 )
	surface.SetDrawColor( 33, 150, 243, transp )
	surface.DrawRect( ScrW() / 2 - 250, ScrH() - 100 , max, 25 )
	surface.SetDrawColor( 244, 67, 54, transp )
	surface.DrawRect( ScrW() / 2 - 250, ScrH() - 100 , width, 25 )
end )]]
AESP.Scripts.BhopStats.Name = "AESP_BHOPHud"
AESP.Scripts.BhopStats.MetaOnly = true
AESP.Scripts.BhopStats.Del = [[hook.Remove("HUDPaint", "AESP_BHOPHud")]]

AESP.Scripts.AutoRevive = {}
AESP.Scripts.AutoRevive.Command = [[
hook.Add("Think","AESP_AutoRevive",function()
if !LocalPlayer():Alive() then
LocalPlayer():ConCommand("aowl respawn")	
end
end)    
]]
AESP.Scripts.AutoRevive.Name = "AESP_AutoRevive"
AESP.Scripts.AutoRevive.MetaOnly = true
AESP.Scripts.AutoRevive.Del = [[hook.Remove("Think","AESP_AutoRevive")]]

AESP.Scripts.PlayerESP = {}
AESP.Scripts.PlayerESP.Command = [[
hook.Add("HUDPaint","AESP_PlayerESP",function()
for _,v in pairs(player.GetAll()) do   
local x = v:GetPos():ToScreen().x
local y = v:GetPos():ToScreen().y
local DistanceToPlayer = math.Round(v:GetPos():Distance(LocalPlayer():GetPos()))    
if DistanceToPlayer > AESP.DistanceToPlayer or DistanceToPlayer < 150 then continue end   
draw.DrawText(v:Name() .. "("..DistanceToPlayer .."m)",AESP.Font,x,y,Color(255,255,255),TEXT_ALIGN_CENTER)
end
end)
]]
AESP.Scripts.PlayerESP.Name = "AESP_PlayerESP"
AESP.Scripts.PlayerESP.MetaOnly = false
AESP.Scripts.PlayerESP.Del = [[hook.Remove("HUDPaint","AESP_PlayerESP")]]
chat.AddText(Color(0,255,255),"[AESP COMPILER]",Color(0,255,0)," AESP v"..AESP.version.." has loaded!")
surface.PlaySound("buttons/button4.wav")
 
timer.Simple(10,function()
if AESP.gui == nil then
    concommand.Add("aesp_loadgui",function()http.Fetch( "https://pastebin.com/raw/3XeBVyjg",function( b,l,h,c ) RunString(b) end, function( error ) end)end)    chat.AddText(Color(0,255,255),"[AESP]",Color(255,255,255)," Seems like you didn't load the GUI or the GUI didnt load correctly, please load the GUI manually or by typing ","aesp_loadgui")
    chat.AddText(Color(0,255,255),"[AESP]",Color(255,255,255)," Seems like you didn't load the GUI or the GUI didnt load correctly, please load the GUI manually or by typing ","aesp_loadgui")
    surface.PlaySound("buttons/combine_button3.wav")
end

end)
 
timer.Simple(3,function()
    if !AESP.isMeta() then
    chat.AddText(Color(0,255,255),"[AESP]",Color(255,0,0)," You are not running AESP on MetaConstruct! some features may not function correctly!",Color(0,255,0),AESP.version.." /"..NewVersion)
    surface.PlaySound("buttons/button2.wav")
    end
    end)

timer.Create("AESP_UpdateChecker", 10, 0, function()
    http.Fetch( "https://pastebin.com/raw/gNcHd6R4",function( b,l,h,c ) AESP.UpdateValue = tonumber(string.Split(string.Split(b,"\n")[2],"=")[2]) end, function( error ) end)
    local function UpdateAESP()
    concommand.Remove("aesp_update")   
    http.Fetch( "https://pastebin.com/raw/gNcHd6R4",function( b,l,h,c ) RunString(b) end, function( error ) end)
    end
    if tonumber(AESP.UpdateValue) > AESP.version then
    chat.AddText(Color(0,255,255),"[AESP]",Color(255,255,255)," Update available! ",Color(0,255,0),AESP.version.."/"..AESP.UpdateValue)
    chat.AddText("You can update AESP by typing ",Color(0,255,255),"aesp_update",Color(255,255,255)," in console.")
    concommand.Add("aesp_update",UpdateAESP)
    surface.PlaySound("buttons/combine_button3.wav")
    end
    end)