concommand.Add("aesp_load",function()http.Fetch( "https://pastebin.com/raw/gNcHd6R4",function( b,l,h,c ) RunString(b) end, function( error ) end)end)

if AESP == nil or AESP.Scripts = nil or AESP.Menu = nil or   then 
chat.AddText(Color(255,0,0),"Unable to load AESP GUI before loading core functions of AESP.")
chat.AddText("If you would like to re-load latest version of AESP. type aesp_load in console")	
surface.PlaySound("buttons/button8.wav")
return false
end

function AESP.ScriptOn(str)
local a = table.ToString(hook.GetTable())
if string.match(tostring(a),str) then
return "On"
else
return "Off"
end
end

function AESP.ScriptOn(str)
    local a = table.ToString(hook.GetTable())
    if string.match(tostring(a),str) then
    return "On"
    else
    return "Off"
    end
    end

function AESP.gui()
local f = vgui.Create( "DFrame" )
f:SetTitle("AESP GUI")
f:SetSize( 500, 500 )
f:Center()
f:SetDraggable(false)
f:MakePopup()

function AESP.Activate(script)
for _,v in pairs(AESP.Scripts) do
if string.match(v.Name,script) then
 RunString(v.Command)
end
end

 
end

function AESP.Deactivate(script)
for _,v in pairs(AESP.Scripts) do
if string.match(v.Name,script) then
 RunString(v.Del)
end
end
end

function AESP.Alert(txt,time)
local lbl = vgui.Create( "DLabel", f )
lbl:Dock( BOTTOM )
lbl:SetText( txt )
lbl:SetFont( "GModNotify" )
lbl:SetDark( false )
timer.Simple(math.Clamp(time,1,10),function()
surface.PlaySound("npc/turret_floor/click1.wav")
lbl:Remove()
end)
end

f.Paint = function( self, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 33,33,33, 255 ) )
end

local ToggleBtn = vgui.Create( "DButton", f )
if AESP.Menu.pnltxt == nil then 
ToggleBtn:SetText( "Select to Toggle" ) 
else 
ToggleBtn:SetText( "Toggle " .. AESP.Menu.pnltxt )
end

ToggleBtn:Dock(BOTTOM)
ToggleBtn:SetSize( 250, 30 )
ToggleBtn.Paint = function( self, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 155, 155, 255, 250 ))
end

local AppList = vgui.Create( "DListView", f )
AppList:Dock( FILL )
AppList:SetMultiSelect( false )
AppList:AddColumn( "Script" )
AppList:AddColumn( "Status" )

for _,V in pairs(AESP.Scripts) do
local getdata AESP.Scripts.
AppList:AddLine( V.Name, AESP.ScriptOn(V.Name) )	
end

ToggleBtn.DoClick = function()
surface.PlaySound("buttons/button6.wav")

if AESP.ScriptOn(AESP.Menu.pnltxt) == "On" then
    AESP.Deactivate(AESP.Menu.pnltxt)
    AESP.Alert("Deactivated "..AESP.Menu.pnltxt,3)
else
    AESP.Activate(AESP.Menu.pnltxt)
    AESP.Alert("Activated "..AESP.Menu.pnltxt,3)
end
AppList:Clear()
for _,V in pairs(AESP.Scripts) do
AppList:AddLine( V.Name, AESP.ScriptOn(V.Name) )	
end
end

AppList.OnRowSelected = function( lst, index, pnl )
	AESP.Menu.pnltxt = pnl:GetColumnText( 1 )
	ToggleBtn:SetText( "Toggle " .. AESP.Menu.pnltxt )
end
end

chat.AddText(Color(0,255,255),"[AESP GUI]",Color(255,255,255)," AESP GUI, has loaded access via",Color(0,255,0)," aesp_menu")
concommand.Add("aesp_menu",AESP.gui)