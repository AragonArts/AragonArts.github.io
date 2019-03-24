ahud = {}

local DrawFont = "Trebuchet24"

local HealthMat = Material( "ahud/ahud-health.png" )
local ArmourMat = Material( "ahud/ahud-armour.png" )
local ModeMat = Material( "ahud/ahud-mode.png" )
local AmmoMat = Material( "ahud/ahud-ammo.png" )



function ahud.DrawBox(x,y,w,h)
draw.RoundedBox( 1, x, y , w, h, Color(22,22,22,235) ) 
end

function ahud.DrawText(text,font,x,y)
draw.SimpleText(text,font, x,y, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) 
end

function ahud.TextLen(text)
surface.SetFont(DrawFont)	
return surface.GetTextSize(text)
end

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

local function PaintHud()
surface.SetFont(DrawFont)	

if !LocalPlayer():Alive() then
return end

local PlayerHealth = math.Round(LocalPlayer():Health() / LocalPlayer():GetMaxHealth() * 100) .. "%"
local PlayerShield = math.Round(LocalPlayer():Armor() / 100 * 100) .. "%"

local PlayerAmmo = LocalPlayer():GetActiveWeapon():Clip1().."	/"..LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
//local PlayerSecondaryAmmo = math.Round(LocalPlayer():Armor() / 100 * 100) .. "%"

local HealthText = PlayerHealth
local ArmourText = PlayerShield

// Draw Health and Armour

ahud.DrawBox(15, ScrH() - 50 , ahud.TextLen( HealthText ) + ahud.TextLen( ArmourText ) + 60 , 30)
ahud.DrawText(HealthText,DrawFont,40,ScrH() - 36) -- Draw Health
ahud.DrawText(ArmourText,DrawFont,ahud.TextLen( HealthText ) + 70,ScrH() - 36) -- Draw Armour

---------- DRAW HEALTH ICON
surface.SetDrawColor( 255, 255, 255, 255 )
surface.SetMaterial( HealthMat	)
surface.DrawTexturedRect( 20, ScrH() - 43, 15, 15 )
---------------------------------

---------- DRAW ARMOR ICON
surface.SetDrawColor( 255, 255, 255, 255 )
surface.SetMaterial( ArmourMat	)
surface.DrawTexturedRect( ahud.TextLen( HealthText ) + 50 , ScrH() - 43, 13, 16 )
---------------------------------

---------------------- Mode
//Draw Mode

    if(LocalPlayer():GetNWBool("BuildMode",nil) == true) then
    ahud.DrawBox(ahud.TextLen( HealthText ) + ahud.TextLen( ArmourText ) + 80, ScrH() - 50,surface.GetTextSize( "Build Mode" ) + 25, 30)
	ahud.DrawText("Build Mode",DrawFont,ahud.TextLen( HealthText ) + ahud.TextLen( ArmourText ) + 100, ScrH() - 36)
--	draw.DrawText("Build Mode","DermaLarge",ScrW()/3*1.45, ScrH()/1.1,Color( 81, 219, 170, 255 ),TEXT_ALIGN_CENTER)
    end
    
    if(LocalPlayer():GetNWBool("BuildMode",nil) == false) then
    ahud.DrawBox(ahud.TextLen( HealthText ) + ahud.TextLen( ArmourText ) + 80, ScrH() - 50,ahud.TextLen( "PvP Mode" ) + 25, 30)
	ahud.DrawText("PvP Mode",DrawFont,ahud.TextLen( HealthText ) + ahud.TextLen( ArmourText ) + 100, ScrH() - 36)
    end

---------- DRAW BUILD ICON
surface.SetDrawColor( 255, 255, 255, 255 )
surface.SetMaterial( ModeMat	)
surface.DrawTexturedRect( ahud.TextLen( HealthText ) + ahud.TextLen( ArmourText ) + 85 , ScrH() - 43, 13, 16 )
---------------------------------

---------------------- Ammo

if !LocalPlayer():GetActiveWeapon():Clip1() == -1 then return end
local AmmoText = PlayerAmmo

// Draw Ammo

ahud.DrawBox(ScrW() - ahud.TextLen( AmmoText ) - 60, ScrH() - 50 , ahud.TextLen( AmmoText ) + 40 , 30)
ahud.DrawText(AmmoText,DrawFont,ScrW() - ahud.TextLen( AmmoText ) - 35, ScrH() - 35 )

---------- DRAW AMMO ICON
surface.SetDrawColor( 255, 255, 255, 255 )
surface.SetMaterial( AmmoMat )
surface.DrawTexturedRect(ScrW() - ahud.TextLen( AmmoText ) - 53 , ScrH() - 43, 16, 16 )
---------------------------------


end

// Hooks

hook.Add("HUDPaint","AHUDPAINT",PaintHud)

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
if (hide[name])then return false end
end)