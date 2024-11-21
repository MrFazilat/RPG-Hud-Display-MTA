--[[  Tel: @Mr_Fazilat
    ███████╗██╗░░██╗░█████╗░░██████╗███████╗██╗░░██╗
    ██╔════╝╚██╗██╔╝██╔══██╗██╔════╝██╔════╝██║░░██║
    █████╗░░░╚███╔╝░███████║╚█████╗░█████╗░░███████║
    ██╔══╝░░░██╔██╗░██╔══██║░╚═══██╗██╔══╝░░██╔══██║
    ███████╗██╔╝╚██╗██║░░██║██████╔╝██║░░░░░██║░░██║
    ╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝░░╚═╝
]]

local localPlayer = getLocalPlayer()
local i = 1
local Texts = {}
local TextColors = {}

for Text in ("B a l t a z a r M T A"):gmatch("%S+") do
    table.insert(Texts, Text)
    table.insert(TextColors, {255, 255, 255})
end

function formatNumber(number)   
    local formatted = number   
    while true do       
        formatted, k = tostring(formatted):gsub("^(-?%d+)(%d%d%d)", '%1,%2')     
        if k == 0 then       
            break   
        end   
    end   
    return formatted 
end

local Font = GuiFont("Files/Font/bold.woff", respc(11))
local BigFont = DxFont("Files/Font/Bangersr.ttf", respc(20))

function NowTextColor()
    if i > 1 then
        TextColors[i - 1] = {255, 255, 255}
    elseif i == 1 then
        TextColors[#Texts] = {255, 255, 255}
    end
    
    TextColors[i] = {0, 255, 255}
    i = i % #Texts + 1
end

local PosX, PosY = screenW - respc(230), respc(10)

function RenderText()
    local Space = 2
    local NowX = PosX
    
    for i, Text in ipairs(Texts) do
        local Color = TextColors[i]
        local R, G, B = Color[1], Color[2], Color[3]
        dxDrawText(Text, NowX, PosY, NowX + 100, PosY + 20, tocolor(R, G, B), 1, BigFont)
        NowX = NowX + BigFont:getTextWidth(Text, 1) + Space
    end

    NowGun = localPlayer:getWeapon()
    if NowGun ~= Gun then
        Gun = NowGun
        GunBG:loadImage("Files/Hud/Weapon/Weapon_"..Gun..".png")
    end
    Clip = localPlayer:getAmmoInClip(getPedWeaponSlot(localPlayer)) 
    Ammo = localPlayer:getTotalAmmo() - Clip
    AmmoText = Clip.." | "..Ammo
    if AmmoText ~= GunText.text then
        GunText.text = AmmoText
    end
end

BG = GuiStaticImage(screenW-respc(320), respc(50), respc(300), respc(228), "Files/Hud/BG.png", false)

--Name
local Name = GuiLabel(0.16, 0.055, 0.5, 0.1, localPlayer.name.."#"..(localPlayer:getData(PlayerID) or 0), true, BG)
Name.font = Font

--Money
local Money = GuiLabel(0.43, 0.055, 0.4, 0.1, "$0", true, BG)
Money:setColor(0, 255, 0)
Money.font = Font
Money.horizontalAlign = "right", false

--HP
local HPX, HPY, HPW, HPH = respc(50), respc(65), respc(95), respc(8)
local HPBG = GuiStaticImage(HPX, HPY, HPW, HPH, "Files/Hud/HP.png", false, BG)
HPBG.alpha = 0.2
HP = GuiStaticImage(0, 0, HPW, HPH, "Files/Hud/HP.png", false, HPBG)

--Armor
local ARX, ARY, ARW, ARH = respc(50), respc(108), respc(95), respc(8)
local ARBG = GuiStaticImage(ARX, ARY, ARW, ARH, "Files/Hud/Armor.png", false, BG)
ARBG.alpha = 0.2
AR = GuiStaticImage(0, 0, ARW, ARH, "Files/Hud/Armor.png", false, ARBG)

--Water
local WRX, WRY, WRW, WRH = respc(155), respc(65), respc(95), respc(8)
local WRBG = GuiStaticImage(WRX, WRY, WRW, WRH, "Files/Hud/Water.png", false, BG)
WRBG.alpha = 0.2
WR = GuiStaticImage(0, 0, WRW, WRH, "Files/Hud/Water.png", false, WRBG)

--Food
local HNX, HNY, HNW, HNH = respc(155), respc(108), respc(95), respc(8)
local HNBG = GuiStaticImage(HNX, HNY, HNW, HNH, "Files/Hud/Food.png", false, BG)
HNBG.alpha = 0.2
HN = GuiStaticImage(0, 0, HNW, HNH, "Files/Hud/Food.png", false, HNBG)

--Set
SetLineSize = Timer(function()
    HP:setSize(HPW/100*localPlayer.health, HPH)
    AR:setSize(ARW/100*localPlayer.armor, ARH)
    local WaterValue = localPlayer:getData(WaterData) or 0
    local FoodValue = localPlayer:getData(FoodData) or 0
    HN:setSize(HNW/100*FoodValue, HNH)
    HN:setPosition(HNW-HNW/100*FoodValue, 0, false)
    WR:setSize(WRW/100*WaterValue, WRH)
    WR:setPosition(WRW-WRW/100*WaterValue, 0, false)
end, 100, 0)

--Date
local Date = GuiLabel(0.17, 0.67, 0.35, 0.1, "", true, BG)
Date.font = Font

--Hours
local Hours  = GuiLabel(0.57, 0.67, 0.25, 0.1, "", true, BG)
Hours.font = Font
Hours.horizontalAlign = "right", false

--Wanted
local Wanted = 0
local WantedBG = GuiStaticImage(0, respc(190), respc(185), respc(35), "Files/Hud/Wanted_"..Wanted..".png", false, BG)
WantedBG.alpha = 0.38

--Gun
Gun = 0
GunBG = GuiStaticImage(respc(260), respc(197), respc(25), respc(25), "Files/Hud/Weapon/Weapon_"..Gun..".png", false, BG)
GunText = GuiLabel(respc(202), respc(200), respc(55), respc(18), "0 | 0", false, BG)
GunText.horizontalAlign = "center", false


-- Timer Set Clock
BGTimer = Timer(function()
    local Time = getRealTime()
    local Day = Time.monthday
    local Month = Time.month + 1
    local Year = Time.year + 1900
    local Hour = Time.hour
    local Min = Time.minute
    local Sec = Time.second
    local NowDate = ("%04d-%02d-%02d"):format(Year, Month, Day)
    local NowTime = ("%02d:%02d:%02d"):format(Hour, Min, Sec)
    
    --Set Clock
    if NowDate ~= Date.text then
        Date.text = NowDate
    end
    Hours.text = NowTime
    
    --Set Name
    local NowName = localPlayer.name.."#"..(localPlayer:getData(PlayerID) or 0)
    if NowName ~= Name.text then
        Name.text = NowName
    end
    
    --Set Money
    local NowMoney = "$"..formatNumber(localPlayer.getMoney())
    if NowMoney ~= Money.text then
        Money.text = NowMoney
    end
    --Set Wanted
    local NowWanted = localPlayer.getWantedLevel()
    if NowWanted ~= Wanted then
        Wanted = NowWanted
        WantedBG:loadImage("Files/Hud/Wanted_"..Wanted..".png")
    end
end, 1000, 0)


local FPS = 0
addEventHandler("onClientPreRender", root,
function (Frame)
    FPS = math.floor((1 / Frame) * 1000)
end)

local Size = dxGetTextWidth("MTA:SA 1.6")
local NowFPS = 0
TextFPS = GuiLabel( 0, 0, screenW, screenH, " ", false)
TextFPS.alpha = 0.5
Timer(function()
	Text = "FPS: "..FPS.." | ".."Baltazar MTA 1.0 |  "
	TextFPS.text = Text
	local vSize = dxGetTextWidth(Text)
	TextFPS:setPosition(screenW - Size - vSize, screenH - 14, false)
    TextFPS:setSize(TextFPS.textExtent + 5, 15, false)
end, 1000, 0 )

bindKey("insert", "down",
function()
    if Hide then
		Hide = false
        showChat(true)
        SetState(true) 
	else
		Hide = true
	   	showChat(false) 
        SetState(false)
	end
end)

Timer(function()
    local Food = tonumber(localPlayer:getData("Food"))
    local Water = tonumber(localPlayer:getData("Water"))
    local HP = localPlayer.health

    if Food then
        if Food > 0 then
            localPlayer:setData("Food", Food-1)
        else
            localPlayer.health = HP - 5
        end
    end

    if Water then
        if Water > 0 then
            localPlayer:setData("Water", Water - 1)
        else
            localPlayer.health = HP - 5
        end
    end
end, 90000, 0)