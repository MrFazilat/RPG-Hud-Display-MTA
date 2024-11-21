--[[  Tel: @Mr_Fazilat
    ███████╗██╗░░██╗░█████╗░░██████╗███████╗██╗░░██╗
    ██╔════╝╚██╗██╔╝██╔══██╗██╔════╝██╔════╝██║░░██║
    █████╗░░░╚███╔╝░███████║╚█████╗░█████╗░░███████║
    ██╔══╝░░░██╔██╗░██╔══██║░╚═══██╗██╔══╝░░██╔══██║
    ███████╗██╔╝╚██╗██║░░██║██████╔╝██║░░░░░██║░░██║
    ╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝░░╚═╝
]]
screenW, screenH = GuiElement.getScreenSize()

--Food-Water-ID Element Name
FoodData = "Food"
WaterData = "Water"
PlayerID = "TarafID"

function reMap(v, low1, high1, low2, high2)
    return low2 + (v - low1) * (high2 - low2) / (high1 - low1)
end

function respc(v)
	return math.ceil(v * (math.min(1, reMap(screenW, 1024, 1920, 0.75, 1))))
end

function Renders()
    RenderText()
    RenderRadar()
end

function SetState(State)
    if State then
        ColorTimer = Timer(NowTextColor, 150, 0)
        addEventHandler("onClientRender", root, Renders)
        BG.visible = true
        RadarData.Zone["Image"].visible = true
    else
        ColorTimer:destroy()
        removeEventHandler("onClientRender", root, Renders)
        BG.visible = false
        RadarData.Zone["Image"].visible = false
    end
end
addEvent("LoadHud", true)
addEventHandler("LoadHud", root, SetState)

addEventHandler("onClientResourceStart", resourceRoot,
function()
    SetState(true)

    setPlayerHudComponentVisible("all", false)
    setPlayerHudComponentVisible("crosshair", true)
end)

addEventHandler("onClientResourceStop", resourceRoot,
function()
    setPlayerHudComponentVisible("all", true)
end)