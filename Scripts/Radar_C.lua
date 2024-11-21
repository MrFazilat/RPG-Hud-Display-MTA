RadarData = {}

RadarData.PosX = screenW * (20/1920)
RadarData.PosY = screenH * (870/1080)
RadarData.ScaleX = screenW * (265/1920)
RadarData.ScaleY = screenH * (190/1080)
RadarData.ArrowSizeX = screenW * (25/1920)
RadarData.ArrowSizeY = screenH * (25/1080)
RadarData.ExecBSizeX = screenW * 0.0125
RadarData.ArrowHalfX = RadarData.ArrowSizeX / 2
RadarData.ArrowHalfY = RadarData.ArrowSizeY / 2
RadarData.MaskTexture = dxCreateTexture("Files/Radar/RadarMask.png", "DXT5")
--BackGround Radar
RadarData.RadarMask = dxCreateShader("Files/Radar/hud_mask.fx")
dxSetShaderValue( RadarData.RadarMask, "sMaskTexture", RadarData.MaskTexture )
dxSetShaderValue( RadarData.RadarMask, "gUVScale", 0.1, 0.1 )
RadarData.BgTexture = dxCreateTexture("Files/Radar/Radar.dds" , "DXT1")
dxSetShaderValue( RadarData.RadarMask, "sPicTexture", RadarData.BgTexture )
--Blips Va Radar Area Ha
RadarData.RenderTarget = dxCreateRenderTarget( 3000 , 3000 , true )
RadarData.RenderMask = dxCreateShader("Files/Radar/hud_mask.fx")
dxSetShaderValue( RadarData.RenderMask, "sMaskTexture", RadarData.MaskTexture )
dxSetShaderValue( RadarData.RenderMask, "gUVScale", 0.1, 0.1 )
dxSetShaderValue( RadarData.RenderMask, "sPicTexture", RadarData.RenderTarget )

RadarData.Zone = {}
RadarData.Zone["Image"] = guiCreateStaticImage(20/1920, 830/1080, 265/1920, 35/1080, "Files/Radar/RadarZone.png", true)
RadarData.Zone["Label"] = guiCreateLabel(35/265, 0/35, 230/265, 35/35, "", true, RadarData.Zone["Image"])
guiSetFont(RadarData.Zone["Label"], guiCreateFont("Files/Font/bold.woff", respc(10)))
guiLabelSetVerticalAlign(RadarData.Zone["Label"], "center")
guiMoveToBack(RadarData.Zone["Image"])
guiSetEnabled(RadarData.Zone["Image"], false)

--Blip Textures
local BlipTextures = { }
for i=0, 63 do
	if fileExists("Files/Radar/Blips/"..i..".png") then
		BlipTextures[i] = dxCreateTexture( "Files/Radar/Blips/"..i..".png" , "DXT5" , false , "clamp" )
	end
end

--Radar Zoom System
RadarData.NowZoom = 1
RadarData.InInt = false
RadarData.RadarZoomData = {
	--{"Zoom Text",ShaderScale,BlipSize,BlipFix,BlipRange},
	--{"0.5x",0.05,14,7,200},
	{"1x",0.1,28,14,400},
	{"1.5x",0.15,35,21,600},
	{"2x",0.2,56,28,800},
	{"3x",0.3,84,43,1200},
}

function dxDrawBorder(x, y, w, h, size, color, postGUI)
	size = size or 2;
	dxDrawRectangle(x - size, y, size, h, color or tocolor(0, 0, 0, 180), postGUI);
	dxDrawRectangle(x + w, y, size, h, color or tocolor(0, 0, 0, 180), postGUI);
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color or tocolor(0, 0, 0, 180), postGUI);
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color or tocolor(0, 0, 0, 180), postGUI);
end

function getVectorRotation(X, Y, X2, Y2)
	local rotation = 6.2831853071796 - math.atan2(X2 - X, Y2 - Y) % 6.2831853071796;
	return -rotation;
end

function getCamRot ( )
	local cameraX, cameraY, _, rotateX, rotateY = getCameraMatrix();
	local camRotation = getVectorRotation(cameraX, cameraY, rotateX, rotateY);
	return camRotation;
end

function Get2DPositionForRadar ( X , Y )
	local X2D , Y2D = 1500 + ( X / 2 ) , 1500 - ( Y / 2 )
	return X2D , Y2D
end

function findRotation(x1, y1, x2, y2)
	local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
	if t < 0 then
		t = t + 360
	end
	return t
end

function getPointFromDistanceRotation(x, y, dist, angle)
	local a = math.rad(90 - angle)
	local dx = math.cos(a) * dist
	local dy = math.sin(a) * dist
	return x + dx, y + dy
end

function getRotation()
	local cameraX, cameraY, _, rotateX, rotateY = getCameraMatrix()
	local camRotation = getVectorRotation(cameraX, cameraY, rotateX, rotateY)
	
	return camRotation
end

local TurfsData = { }
local BlipsExec = { }
local BlipsData = { }
local IsF11Active = false

function DoRadarMaths ( )
	if getElementInterior(localPlayer) == 0 then
		local MyX , MyY , MyZ = getElementPosition(localPlayer)
	--Add Kardan Turf Ha Be Render
        TurfsData = { }
        for index,Turfs in ipairs(getElementsByType("radararea")) do
            local tX, tY = getElementPosition(Turfs)
            local tSizeX , tSizeY = getRadarAreaSize ( Turfs )
            local TurfCenterX , TurfCenterY = tX + tSizeX / 2 , tY + tSizeY / 2
            if getDistanceBetweenPoints2D( TurfCenterX , TurfCenterY , MyX , MyY ) < 1000 then
                local tX2D , tY2D = Get2DPositionForRadar ( tX , tY )
                local tR , tG , tB = getRadarAreaColor ( Turfs )
                TurfsData[Turfs] = { tX2D , tY2D , tSizeX / 2 , - ( tSizeY / 2 ) , tR , tG , tB , isRadarAreaFlashing ( Turfs ) }
            end
        end
	--Add Kardan Blip Ha Be Render
		BlipsExec = { }
		BlipsData = { }
		for index,Blips in ipairs(getElementsByType("blip")) do
			local bX, bY = getElementPosition(Blips)
			local BlipVisibleDistance = getBlipVisibleDistance(Blips)
			if getElementData(Blips, "exclusiveBlip") then
				local BlipDistance = getDistanceBetweenPoints2D( bX , bY , MyX , MyY )
				if BlipDistance < RadarData.RadarZoomData[RadarData.NowZoom][5] then
					local NowX2D , NowY2D = Get2DPositionForRadar ( bX , bY )
					BlipsData[Blips] = {NowX2D-RadarData.RadarZoomData[RadarData.NowZoom][4],NowY2D-RadarData.RadarZoomData[RadarData.NowZoom][4],getBlipIcon(Blips)}
				else
					BlipsExec[Blips] = { bX , bY , getBlipIcon(Blips) }
				end
			else
				local BlipDistance = getDistanceBetweenPoints2D( bX , bY , MyX , MyY )
				if BlipDistance < RadarData.RadarZoomData[RadarData.NowZoom][5] then
					local NowX2D , NowY2D = Get2DPositionForRadar ( bX , bY )
					BlipsData[Blips] = {NowX2D-RadarData.RadarZoomData[RadarData.NowZoom][4],NowY2D-RadarData.RadarZoomData[RadarData.NowZoom][4],getBlipIcon(Blips)}
				end
			end
		end
		guiSetText(RadarData.Zone["Label"], getZoneName(MyX , MyY , MyZ)..", "..getZoneName(MyX , MyY , MyZ, true))
	else
		if IsF11Active then 
			IsF11Active = false
		end
	end
end

setTimer(DoRadarMaths, 800, 0)

addEventHandler("onClientElementInteriorChange", localPlayer, function(oldInterior, newInterior)
	RadarData.InInt = newInterior > 0 and true or false
	guiSetVisible(RadarData.Zone["Image"], not RadarData.InInt)
end)

--CalCulations For Excelusive Blips
RadarData.BorderTop = RadarData.PosY - RadarData.ArrowHalfY
RadarData.BorderBot = RadarData.PosY + RadarData.ScaleY - RadarData.ArrowHalfY
RadarData.BorderLeft = RadarData.PosX - RadarData.ArrowHalfX
RadarData.BorderRight = RadarData.PosX + RadarData.ScaleX - RadarData.ArrowHalfX
local cX, cY = (RadarData.BorderRight + RadarData.BorderLeft) / 2, (RadarData.BorderTop + RadarData.BorderBot) / 2

--F11 Map CalCulations
RadarData.F11X = (screenW - screenH) / 2
RadarData.F11Meghyas = 6000 / screenH
RadarData.screenHNesf = screenH / 2
local F11Blips , F11Turfs = { } , { }

function Get2DPositionForF11 ( X , Y )
	local X2D , Y2D = RadarData.F11X + (RadarData.screenHNesf + ( X / RadarData.F11Meghyas )) , RadarData.screenHNesf - ( Y / RadarData.F11Meghyas )
	return X2D , Y2D
end

addEventHandler('onClientKey', root,function(Key, State) 
	if Key == 'F11' and State then
		cancelEvent()
		if getElementInterior(localPlayer) == 0 then
			if IsF11Active then
				IsF11Active = false
				F11Turfs = { }
				F11Blips = { }
			else
				IsF11Active = true
				for index,Turfs in ipairs(getElementsByType("radararea")) do
					local tX, tY = getElementPosition(Turfs)
					local tX2D , tY2D = Get2DPositionForF11 ( tX , tY )
					local tSizeX , tSizeY = getRadarAreaSize ( Turfs )
					local tR , tG , tB = getRadarAreaColor ( Turfs )
					F11Turfs[Turfs] = { tX2D , tY2D , tSizeX / RadarData.F11Meghyas , - ( tSizeY / RadarData.F11Meghyas ) , tR , tG , tB , isRadarAreaFlashing ( Turfs ) }
				end
				for index,Blips in ipairs(getElementsByType("blip")) do
					local bX, bY = getElementPosition(Blips)
					local bX2D , bY2D = Get2DPositionForF11 ( bX , bY )
					F11Blips[Blips] = { bX2D - 8 , bY2D - 8 , getBlipIcon(Blips) }
				end
			end
			showCursor(IsF11Active)
			showChat(not IsF11Active)
			guiSetVisible(RadarData.Zone["Image"], not IsF11Active)
		end
	end
end)

--Mark Roye Map Va GPS

local MarkedBlip = false

function DestroyMarkedBlip( )
	if MarkedBlip then
		if F11Blips[MarkedBlip] then 
			F11Blips[MarkedBlip] = nil 
		end
		destroyElement ( MarkedBlip )
		MarkedBlip = nil
	end
end

function Get3DPositionFrom2DF11 ( rX , rY )
	local X1 , Y1 = rX*screenW , rY*screenH
	if X1 < RadarData.F11X or RadarData.F11X+screenH < X1 then return false end
	local X2 , Y2 = ( X1 - RadarData.F11X ) * RadarData.F11Meghyas - 3000 , -(Y1 * RadarData.F11Meghyas - 3000)
	return X1 , Y1 , X2 , Y2
end

addEventHandler("onClientDoubleClick", root,
function ( Button , rX , rY )
	if IsF11Active then
		if Button == "left" then 
			local X2DF11 , Y2DF11 , X3DBlip , Y3DBlip = Get3DPositionFrom2DF11 ( getCursorPosition() )
			if X2DF11 then
				DestroyMarkedBlip( )
				MarkedBlip = createBlip( X3DBlip, Y3DBlip, 0, 41, 2, 255, 255, 255 )
				--setBlipVisibleDistance(MarkedBlip, 16383)
				setElementData(MarkedBlip, "exclusiveBlip", true)
				F11Blips[MarkedBlip] = { X2DF11 - 8 , Y2DF11 - 8 , 41 }
				playSoundFrontEnd(5)
				if isPedInVehicle( localPlayer ) then
					triggerServerEvent( "Radar:RequestMark" , localPlayer , X3DBlip , Y3DBlip )
				end
			end
		elseif Button == "right" then 
			DestroyMarkedBlip( )
			playSoundFrontEnd(2)
		end
	end
end)

function RenderRadar( )
	local FlashAlpha = 130 * math.abs(getTickCount() % 1000 - 500) / 500
	local pX,pY = getElementPosition(localPlayer)
	if IsF11Active then
		dxDrawImage( RadarData.F11X,0,screenH,screenH, RadarData.BgTexture, 0,0,0, tocolor(255,255,255,190) )
		for Turfs, Index in pairs(F11Turfs) do
			if F11Turfs[Turfs][8] then
				dxDrawRectangle( F11Turfs[Turfs][1], F11Turfs[Turfs][2], F11Turfs[Turfs][3], F11Turfs[Turfs][4], tocolor(F11Turfs[Turfs][5],F11Turfs[Turfs][6],F11Turfs[Turfs][7],FlashAlpha) )
			else
				dxDrawRectangle( F11Turfs[Turfs][1], F11Turfs[Turfs][2], F11Turfs[Turfs][3], F11Turfs[Turfs][4], tocolor(F11Turfs[Turfs][5],F11Turfs[Turfs][6],F11Turfs[Turfs][7],130) )
			end
		end
		for Blips, Index in pairs(F11Blips) do
			if isElement(Blips) then
				dxDrawImage( F11Blips[Blips][1], F11Blips[Blips][2], 20, 20, BlipTextures[F11Blips[Blips][3]], 0,0,0, tocolor(getBlipColor(Blips)) )
			end
		end
		local MyX2D , MyY2D = Get2DPositionForF11 ( pX , pY )
		local Rot = getPedRotation(localPlayer)
		dxDrawImage(MyX2D-10, MyY2D-10, 25, 25, "Files/Radar/Blips/Arrow.png", (-Rot) % 360)
	else
		if not RadarData.InInt then
		--Update Player Location On Radar
			local rX , rY = ( pX ) / 6000 , ( pY ) / -6000
			dxSetShaderValue( RadarData.RadarMask, "gUVPosition", rX , rY )
			dxSetShaderValue( RadarData.RenderMask, "gUVPosition", rX , rY )
		--Update Map Direction
			local _,_,camrot = getElementRotation( getCamera() )
			local CamRot1 = math.rad(-camrot)
			dxSetShaderValue( RadarData.RadarMask , "gUVRotAngle", CamRot1 )
			dxSetShaderValue( RadarData.RenderMask , "gUVRotAngle", CamRot1 )
			dxSetRenderTarget(RadarData.RenderTarget, true)
		--Render Turfs
			dxSetBlendMode('modulate_add')
			for Turfs, Index in pairs(TurfsData) do
				if TurfsData[Turfs][8] then
					dxDrawRectangle( TurfsData[Turfs][1], TurfsData[Turfs][2], TurfsData[Turfs][3], TurfsData[Turfs][4], tocolor(TurfsData[Turfs][5],TurfsData[Turfs][6],TurfsData[Turfs][7],FlashAlpha) )
				else
					dxDrawRectangle( TurfsData[Turfs][1], TurfsData[Turfs][2], TurfsData[Turfs][3], TurfsData[Turfs][4], tocolor(TurfsData[Turfs][5],TurfsData[Turfs][6],TurfsData[Turfs][7],130) )
				end
			end
			dxSetBlendMode('blend')
		--Render Blips
			local BlipRot = camrot*-1
			dxSetBlendMode('modulate_add')
			for Blips, Index in pairs(BlipsData) do
				if isElement(Blips) then
					dxDrawImage( BlipsData[Blips][1], BlipsData[Blips][2], RadarData.RadarZoomData[RadarData.NowZoom][3], RadarData.RadarZoomData[RadarData.NowZoom][3] + 5, BlipTextures[BlipsData[Blips][3]] , BlipRot , 0 , 0 , tocolor(getBlipColor(Blips)) )
				end
			end
			dxSetRenderTarget( )
		--Render
			dxDrawImage( RadarData.PosX,RadarData.PosY,RadarData.ScaleX,RadarData.ScaleY, RadarData.RadarMask, 0,0,0, tocolor(255,255,255,220) )
			dxDrawImage( RadarData.PosX,RadarData.PosY,RadarData.ScaleX,RadarData.ScaleY, RadarData.RenderMask, 0,0,0, tocolor(255,255,255,255) )
			dxDrawImage((RadarData.PosX + (RadarData.ScaleX / 2)) - RadarData.ArrowHalfX, (RadarData.PosY + (RadarData.ScaleY / 2)) - RadarData.ArrowHalfY, RadarData.ArrowSizeX, RadarData.ArrowSizeY, "Files/Radar/Blips/Arrow.png", math.deg(-getCamRot()) - getPedRotation(localPlayer))
		--Render Excelusive Blips
			for Blips, Index in pairs(BlipsExec) do
				if isElement(Blips) then
					local ExecRot = findRotation(BlipsExec[Blips][1], BlipsExec[Blips][2], pX, pY) - camrot
					local ExecBlipX, ExecBlipY = getPointFromDistanceRotation(cX, cY, RadarData.RadarZoomData[RadarData.NowZoom][5], ExecRot)
					local ExecBlipX = math.max(RadarData.BorderLeft, math.min(RadarData.BorderRight, ExecBlipX))
					local ExecBlipY = math.max(RadarData.BorderTop, math.min(RadarData.BorderBot, ExecBlipY))
					dxDrawImage( ExecBlipX,ExecBlipY,RadarData.ExecBSizeX,RadarData.ArrowSizeY, BlipTextures[BlipsExec[Blips][3]], 0,0,0, tocolor(getBlipColor(Blips)) )
				end
			end
		end
	end
end

function zoomIn()
	playSoundFrontEnd(12)
	if RadarData.NowZoom == 4 then return end
	RadarData.NowZoom = RadarData.NowZoom + 1
	DoRadarMaths( )
	dxSetShaderValue( RadarData.RadarMask, "gUVScale", RadarData.RadarZoomData[RadarData.NowZoom][2], RadarData.RadarZoomData[RadarData.NowZoom][2] )
	dxSetShaderValue( RadarData.RenderMask, "gUVScale", RadarData.RadarZoomData[RadarData.NowZoom][2], RadarData.RadarZoomData[RadarData.NowZoom][2] )
end
bindKey("num_sub", "down", zoomIn)
bindKey("-", "down", zoomIn)

function zoomOut()
	playSoundFrontEnd(12)
	if RadarData.NowZoom == 1 then return end
	RadarData.NowZoom = RadarData.NowZoom - 1
	DoRadarMaths( )
	dxSetShaderValue( RadarData.RadarMask, "gUVScale", RadarData.RadarZoomData[RadarData.NowZoom][2], RadarData.RadarZoomData[RadarData.NowZoom][2] )
	dxSetShaderValue( RadarData.RenderMask, "gUVScale", RadarData.RadarZoomData[RadarData.NowZoom][2], RadarData.RadarZoomData[RadarData.NowZoom][2] )
end
bindKey("num_add", "down", zoomOut)
bindKey("=", "down", zoomOut)