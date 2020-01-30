function widget:GetInfo()
	return {
		name		= "Top Bar",
		desc		= "Shows Resources, wind speed, commander counter, and various options.",
		author		= "Floris",
		date		= "Feb, 2017",
		license		= "GNU GPL, v2 or later",
        layer		= -9999999,
		enabled		= true, --enabled by default
		handler		= true, --can use widgetHandler:x()
	}
end

local ui_opacity = tonumber(Spring.GetConfigFloat("ui_opacity",0.66) or 0.66)

local fontfile = LUAUI_DIRNAME .. "fonts/" .. Spring.GetConfigString("bar_font", "Poppins-Regular.otf")
local vsx,vsy = Spring.GetViewGeometry()
local fontfileScale = (0.7 + (vsx*vsy / 7000000))
local fontfileSize = 36
local fontfileOutlineSize = 9
local fontfileOutlineStrength = 1.35
local font = gl.LoadFont(fontfile, fontfileSize*fontfileScale, fontfileOutlineSize*fontfileScale, fontfileOutlineStrength)
local fontfile2 = LUAUI_DIRNAME .. "fonts/" .. Spring.GetConfigString("bar_font2", "Exo2-SemiBold.otf")
local font2 = gl.LoadFont(fontfile2, fontfileSize*fontfileScale, fontfileOutlineSize*fontfileScale, fontfileOutlineStrength)

local height = 44
local relXpos = 0.3
local borderPadding = 5
local showConversionSlider = true
local bladeSpeedMultiplier = 0.2

local armcomDefID = UnitDefNames.armcom.id
local corcomDefID = UnitDefNames.corcom.id

local playSounds = true
local leftclick = 'LuaUI/Sounds/tock.wav'
local resourceclick = 'LuaUI/Sounds/buildbar_click.wav'
local middleclick = 'LuaUI/Sounds/buildbar_click.wav'
local rightclick = 'LuaUI/Sounds/buildbar_rem.wav'

local bgcorner = ":l:LuaUI/Images/bgcorner.png"
local barbg = ":l:LuaUI/Images/resbar.dds"
local barGlowCenterTexture = ":l:LuaUI/Images/barglow-center.png"
local barGlowEdgeTexture = ":l:LuaUI/Images/barglow-edge.png"
local bladesTexture = ":l:LuaUI/Images/blades.png"
local poleTexture = ":l:LuaUI/Images/pole.png"
local comTexture = ":l:LuaUI/Images/comIcon.png"
local glowTexture = ":l:LuaUI/Images/glow.dds"

local vsx, vsy = gl.GetViewSizes()
local widgetScale = (0.80 + (vsx*vsy / 6000000))
local xPos = vsx*relXpos
local currentWind = 0
local currentTidal = 0
local gameStarted = false
local displayComCounter = false

local glTranslate = gl.Translate
local glColor = gl.Color
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glTexture = gl.Texture
local glRect = gl.Rect
local glTexRect = gl.TexRect
local glText = gl.Text
local glRotate = gl.Rotate
local glCreateList = gl.CreateList
local glCallList = gl.CallList
local glDeleteList = gl.DeleteList

local spGetSpectatingState = Spring.GetSpectatingState
local spGetTeamResources = Spring.GetTeamResources
local spGetMyTeamID = Spring.GetMyTeamID
local spGetMouseState = Spring.GetMouseState
local spGetWind = Spring.GetWind

local spec = spGetSpectatingState()
local myAllyTeamID = Spring.GetMyAllyTeamID()
local myTeamID = Spring.GetMyTeamID()
local myPlayerID = Spring.GetMyPlayerID()
local isReplay = Spring.IsReplay()

local sformat = string.format

local minWind = Game.windMin
local maxWind = Game.windMax
local windRotation = 0

local startComs = 0
local lastFrame = -1
local topbarArea = {}
local barContentArea = {}
local resbarArea = {metal={}, energy={}}
local resbarDrawinfo = {metal={}, energy={}}
local shareIndicatorArea = {metal={}, energy={}}
local dlistResbar = {metal={}, energy={}}
local energyconvArea = {}
local windArea = {}
local comsArea = {}
local rejoinArea = {}
local buttonsArea = {}
local dlistWindText = {}
local dlistResValues = {metal={},energy={}}
local currentResValue = {metal=1000,energy=1000}
local currentStorageValue = {metal=-1,energy=-1}

local r = {metal={spGetTeamResources(myTeamID,'metal')}, energy={spGetTeamResources(myTeamID,'energy')}}


local showOverflowTooltip = {}

local allyComs = 0
local enemyComs = 0 -- if we are counting ourselves because we are a spec
local enemyComCount = 0 -- if we are receiving a count from the gadget part (needs modoption on)
local prevEnemyComCount = 0

local guishaderEnabled = false
local guishaderCheckUpdateRate = 0.5
local nextGuishaderCheck = guishaderCheckUpdateRate
local now = os.clock()
local gameFrame = Spring.GetGameFrame()

local draggingShareIndicatorValue = {}

local chobbyLoaded = false
if Spring.GetMenuName and string.find(string.lower(Spring.GetMenuName()), 'chobby') ~= nil then
	chobbyLoaded = true
	Spring.SendLuaMenuMsg("disableLobbyButton")
end

local numAllyTeams = #Spring.GetAllyTeamList()-1
local singleTeams = false
if #Spring.GetTeamList()-1 == numAllyTeams then
	singleTeams = true
end

local allyteamOverflowingMetal = false
local allyteamOverflowingEnergy = false
local overflowingMetal = false
local overflowingEnergy = false

local isCommander = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	if unitDef.customParams.iscommander then
		isCommander[unitDefID] = true
	end
end

--------------------------------------------------------------------------------
-- Rejoin
--------------------------------------------------------------------------------
local showRejoinUI = false --//variable:indicate whether UI is shown or hidden.

local CATCH_UP_THRESHOLD = 10 * Game.gameSpeed -- only show the window if behind this much
local UPDATE_RATE_F = 10 -- frames
local MOVING_AVG_COUNT = 30 -- update periods

local UPDATE_RATE_S = UPDATE_RATE_F / Game.gameSpeed
local serverFrame

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function isInBox(mx, my, box)
	return mx > box[1] and my > box[2] and mx < box[3] and my < box[4]
end

function widget:ViewResize(n_vsx,n_vsy)
	vsx, vsy = gl.GetViewSizes()
	widgetScale = (vsy / height) * 0.043	-- using 734 because redui-console uses this value too
	xPos = vsx*relXpos

  local newFontfileScale = (0.5 + (vsx*vsy / 5700000))
  if (fontfileScale ~= newFontfileScale) then
    fontfileScale = newFontfileScale
	gl.DeleteFont(font)
	font = gl.LoadFont(fontfile, fontfileSize*fontfileScale, fontfileOutlineSize*fontfileScale, fontfileOutlineStrength)
    gl.DeleteFont(font2)
    font2 = gl.LoadFont(fontfile2, fontfileSize*fontfileScale, fontfileOutlineSize*fontfileScale, fontfileOutlineStrength)
  end

    for n,_ in pairs(dlistWindText) do
        glDeleteList(dlistWindText[n])
    end
    dlistWindText = {}
	for n,_ in pairs(dlistResValues['metal']) do
		glDeleteList(dlistResValues['metal'][n])
	end
	dlistResValues['metal'] = {}
	for n,_ in pairs(dlistResValues['energy']) do
		glDeleteList(dlistResValues['energy'][n])
	end
	dlistResValues['energy'] = {}

	init()
end


local function DrawRectRound(px,py,sx,sy,cs, tl,tr,br,bl)
    gl.TexCoord(0.8,0.8)
    gl.Vertex(px+cs, py, 0)
    gl.Vertex(sx-cs, py, 0)
    gl.Vertex(sx-cs, sy, 0)
    gl.Vertex(px+cs, sy, 0)

    gl.Vertex(px, py+cs, 0)
    gl.Vertex(px+cs, py+cs, 0)
    gl.Vertex(px+cs, sy-cs, 0)
    gl.Vertex(px, sy-cs, 0)

    gl.Vertex(sx, py+cs, 0)
    gl.Vertex(sx-cs, py+cs, 0)
    gl.Vertex(sx-cs, sy-cs, 0)
    gl.Vertex(sx, sy-cs, 0)

    local offset = 0.07		-- texture offset, because else gaps could show

    -- bottom left
    if ((py <= 0 or px <= 0)  or (bl ~= nil and bl == 0)) and bl ~= 2   then o = 0.5 else o = offset end
    gl.TexCoord(o,o)
    gl.Vertex(px, py, 0)
    gl.TexCoord(o,1-offset)
    gl.Vertex(px+cs, py, 0)
    gl.TexCoord(1-offset,1-offset)
    gl.Vertex(px+cs, py+cs, 0)
    gl.TexCoord(1-offset,o)
    gl.Vertex(px, py+cs, 0)
    -- bottom right
    if ((py <= 0 or sx >= vsx) or (br ~= nil and br == 0)) and br ~= 2   then o = 0.5 else o = offset end
    gl.TexCoord(o,o)
    gl.Vertex(sx, py, 0)
    gl.TexCoord(o,1-offset)
    gl.Vertex(sx-cs, py, 0)
    gl.TexCoord(1-offset,1-offset)
    gl.Vertex(sx-cs, py+cs, 0)
    gl.TexCoord(1-offset,o)
    gl.Vertex(sx, py+cs, 0)
    -- top left
    if ((sy >= vsy or px <= 0) or (tl ~= nil and tl == 0)) and tl ~= 2   then o = 0.5 else o = offset end
    gl.TexCoord(o,o)
    gl.Vertex(px, sy, 0)
    gl.TexCoord(o,1-offset)
    gl.Vertex(px+cs, sy, 0)
    gl.TexCoord(1-offset,1-offset)
    gl.Vertex(px+cs, sy-cs, 0)
    gl.TexCoord(1-offset,o)
    gl.Vertex(px, sy-cs, 0)
    -- top right
    if ((sy >= vsy or sx >= vsx)  or (tr ~= nil and tr == 0)) and tr ~= 2   then o = 0.5 else o = offset end
    gl.TexCoord(o,o)
    gl.Vertex(sx, sy, 0)
    gl.TexCoord(o,1-offset)
    gl.Vertex(sx-cs, sy, 0)
    gl.TexCoord(1-offset,1-offset)
    gl.Vertex(sx-cs, sy-cs, 0)
    gl.TexCoord(1-offset,o)
    gl.Vertex(sx, sy-cs, 0)
end
function RectRound(px,py,sx,sy,cs, tl,tr,br,bl)		-- (coordinates work differently than the RectRound func in other widgets)
    gl.Texture(bgcorner)
    gl.BeginEnd(GL.QUADS, DrawRectRound, px,py,sx,sy,cs, tl,tr,br,bl)
    gl.Texture(false)
end


local function short(n,f)
	if (f == nil) then
		f = 0
	end
	if (n > 9999999) then
		return sformat("%."..f.."fm",n/1000000)
	elseif (n > 9999) then
		return sformat("%."..f.."fk",n/1000)
	else
		return sformat("%."..f.."f",n)
	end
end


local function updateRejoin()
	local area = rejoinArea

	local catchup = gameFrame / serverFrame

	-- add background blur
	if dlistRejoinGuishader ~= nil then
		if WG['guishader'] then
			WG['guishader'].RemoveDlist('topbar_rejoin')
		end
		glDeleteList(dlistRejoinGuishader)
	end
	dlistRejoinGuishader = glCreateList( function()
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
	end)


	if dlistRejoin ~= nil then
		glDeleteList(dlistRejoin)
	end
	dlistRejoin = glCreateList( function()
	
		-- background
		glColor(0,0,0,ui_opacity)
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
		local bgpadding = 3*widgetScale
		glColor(1,1,1,ui_opacity*0.055)
		RectRound(area[1]+bgpadding, area[2]+bgpadding, area[3]-bgpadding, area[4], bgpadding*1.25)

		if WG['guishader'] then
			WG['guishader'].InsertDlist(dlistRejoinGuishader, 'topbar_rejoin')
		end
		
		local barHeight = (height*widgetScale/10)
		local barHeighPadding = 7*widgetScale --((height/2) * widgetScale) - (barHeight/2)
		local barLeftPadding = 7* widgetScale
		local barRightPadding = 7 * widgetScale
		local barArea = {area[1]+barLeftPadding, area[2]+barHeighPadding, area[3]-barRightPadding, area[2]+barHeight+barHeighPadding}
		local barWidth = barArea[3] - barArea[1]
		
		glColor(0.0,0.5,0,0.33)
		glTexture(barbg)
		glTexRect(barArea[1], barArea[2], barArea[3], barArea[4])

		-- Bar value
		glColor(0, 1, 0, 1)
		glTexture(barbg)
		glTexRect(barArea[1], barArea[2], barArea[1]+(catchup * barWidth), barArea[4])
		
		-- Bar value glow
		local glowSize = barHeight * 6
		glColor(0, 1, 0, 0.09)
		glTexture(barGlowCenterTexture)
		glTexRect(barArea[1], barArea[2] - glowSize, barArea[1]+(catchup * barWidth), barArea[4] + glowSize)
		glTexture(barGlowEdgeTexture)
		glTexRect(barArea[1]-(glowSize*2), barArea[2] - glowSize, barArea[1], barArea[4] + glowSize)
		glTexRect((barArea[1]+(catchup * barWidth))+(glowSize*2), barArea[2] - glowSize, barArea[1]+(catchup * barWidth), barArea[4] + glowSize)
		
		-- Text
		local fontsize = 12*widgetScale
        font2:Begin()
        font2:Print('\255\225\255\225Catching up', area[1]+((area[3]-area[1])/2), area[2]+barHeight*2+fontsize, fontsize, 'cor')
        font2:End()
		
	end)
	if WG['tooltip'] ~= nil then
		WG['tooltip'].AddTooltip('rejoin', area, "Displays the catchup progress")
	end
end


local function updateButtons()
	local area = buttonsArea
	
	local totalWidth = area[3] - area[1]

	local text = '    '

	if (WG['scavengerinfo'] ~= nil) then text = text..'Scavengers   ' end
	if (WG['teamstats'] ~= nil) then text = text..'Stats   ' end
    if (WG['commands'] ~= nil) then text = text..'Cmd   ' end
    if (WG['keybinds'] ~= nil) then text = text..'Keys   ' end
    if (WG['changelog'] ~= nil) then text = text..'Changes   ' end
    if (WG['options'] ~= nil) then text = text..'Settings   ' end
	if chobbyLoaded then
		text = text..'Lobby  '
	else
		text = text..'Quit  '
	end

	local fontsize = totalWidth / font2:GetTextWidth(text)
	if fontsize > (height*widgetScale)/3 then
		fontsize = (height*widgetScale)/3
	end

	-- add background blur
	if dlistButtonsGuishader ~= nil then
		if WG['guishader'] then
			WG['guishader'].RemoveDlist('topbar_buttons')
		end
		glDeleteList(dlistButtonsGuishader)
	end
	dlistButtonsGuishader = glCreateList( function()
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
	end)


	if dlistButtons1 ~= nil then
		glDeleteList(dlistButtons1)
	end
	dlistButtons1 = glCreateList( function()
	
		-- background
		glColor(0,0,0,ui_opacity)
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
		local bgpadding = 3*widgetScale
		glColor(1,1,1,ui_opacity*0.055)
		RectRound(area[1]+bgpadding, area[2]+bgpadding, area[3], area[4], bgpadding*1.25)
		
		if WG['guishader'] then
			WG['guishader'].InsertDlist(dlistButtonsGuishader, 'topbar_buttons')
		end
		
		if buttonsArea['buttons'] == nil then
			buttonsArea['buttons'] = {}
			
			local margin = height*widgetScale / 11
			local offset = margin
			local width = 0
            local buttons = 0

			if (WG['scavengerinfo'] ~= nil) then
				buttons = buttons + 1
				if buttons > 1 then offset = offset+width end
				width = font2:GetTextWidth('  Scavengers ') * fontsize
				buttonsArea['buttons']['scavengers'] = {area[1]+offset, area[2]+margin, area[1]+offset+width, area[4]}
			end
            if (WG['teamstats'] ~= nil) then
                buttons = buttons + 1
                if buttons > 1 then offset = offset+width end
                width = font2:GetTextWidth('   Stats ') * fontsize
                buttonsArea['buttons']['stats'] = {area[1]+offset, area[2]+margin, area[1]+offset+width, area[4] }
            end
            if (WG['commands'] ~= nil) then
                buttons = buttons + 1
                if buttons > 1 then offset = offset+width end
                width = font2:GetTextWidth('  Cmd ') * fontsize
                buttonsArea['buttons']['commands'] = {area[1]+offset, area[2]+margin, area[1]+offset+width, area[4]}
			end
            if (WG['keybinds'] ~= nil) then
                buttons = buttons + 1
                if buttons > 1 then offset = offset+width end
                width = font2:GetTextWidth('  Keys ') * fontsize
                buttonsArea['buttons']['keybinds'] = {area[1]+offset, area[2]+margin, area[1]+offset+width, area[4]}
            end
            if (WG['changelog'] ~= nil) then
                buttons = buttons + 1
                if buttons > 1 then offset = offset+width end
                width = font2:GetTextWidth('  Changes ') * fontsize
                buttonsArea['buttons']['changelog'] = {area[1]+offset, area[2]+margin, area[1]+offset+width, area[4]}
            end
            if (WG['options'] ~= nil) then
                buttons = buttons + 1
                if buttons > 1 then offset = offset+width end
                width = font2:GetTextWidth('  Settings ') * fontsize
                buttonsArea['buttons']['options'] = {area[1]+offset, area[2]+margin, area[1]+offset+width, area[4]}
            end
			if chobbyLoaded then
				offset = offset+width
				width = font2:GetTextWidth('  Lobby  ') * fontsize
				buttonsArea['buttons']['quit'] = {area[1]+offset, area[2]+margin, area[3], area[4]}
			else
				offset = offset+width
				width = font2:GetTextWidth('  Quit  ') * fontsize
				buttonsArea['buttons']['quit'] = {area[1]+offset, area[2]+margin, area[3], area[4]}
			end
		end
	end)
	
	if dlistButtons2 ~= nil then
		glDeleteList(dlistButtons2)
	end
	dlistButtons2 = glCreateList( function()
        font2:Begin()
        font2:Print('\255\210\210\210'..text, area[1], area[2]+((area[4]-area[2])/2)-(fontsize/5), fontsize, 'o')
        font2:End()
	end)
end


local function updateComs(forceText)
	local area = comsArea

	-- add background blur
	if dlistComsGuishader ~= nil then
		if WG['guishader'] then
			WG['guishader'].RemoveDlist('topbar_coms')
		end
		glDeleteList(dlistComsGuishader)
	end
	dlistComsGuishader = glCreateList( function()
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
	end)

	if dlistComs1 ~= nil then
		glDeleteList(dlistComs1)
	end
	dlistComs1 = glCreateList( function()
	
		-- background
		glColor(0,0,0,ui_opacity)
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
		local bgpadding = 3*widgetScale
		glColor(1,1,1,ui_opacity*0.055)
		RectRound(area[1]+bgpadding, area[2]+bgpadding, area[3]-bgpadding, area[4], bgpadding*1.25)
		
		if WG['guishader'] then
			WG['guishader'].InsertDlist(dlistComsGuishader, 'topbar_coms')
		end
	end)

	if dlistComs2 ~= nil then
		glDeleteList(dlistComs2)
	end
	dlistComs2 = glCreateList( function()
		-- Commander icon
		local sizeHalf = (height/2.75)*widgetScale

		glTexture(comTexture)
		glTexRect(area[1]+((area[3]-area[1])/2)-sizeHalf, area[2]+((area[4]-area[2])/2)-sizeHalf, area[1]+((area[3]-area[1])/2)+sizeHalf, area[2]+((area[4]-area[2])/2)+sizeHalf)
        glTexture(false)

		-- Text
		if gameFrame > 0 or forceText then
            font2:Begin()
			local fontsize = (height/2.85)*widgetScale
            font2:Print('\255\255\000\000'..enemyComCount, area[3]-(2.8*widgetScale), area[2]+(4.5*widgetScale), fontsize, 'or')
			
			fontSize = (height/2.15)*widgetScale
            font2:Print("\255\000\255\000"..allyComs, area[1]+((area[3]-area[1])/2), area[2]+((area[4]-area[2])/2.05)-(fontSize/5), fontSize, 'oc')
            font2:End()
		end
	end)
	comcountChanged = nil

	if WG['tooltip'] ~= nil then
		WG['tooltip'].AddTooltip('coms', area, "\255\215\255\215Commander Counter\n\255\240\240\240Displays the number of ally\nand enemy commanders")
	end
end


local function updateWind()
	local area = windArea

	local xPos =  area[1]
	local yPos =  area[2] + ((area[4] - area[2])/3.5)
	local oorx = 10*widgetScale
	local oory = 13*widgetScale

	local bgpadding = 3*widgetScale

	local poleWidth = 6 * widgetScale
	local poleHeight = 14 * widgetScale

	-- add background blur
	if dlistWindGuishader ~= nil then
		if WG['guishader'] then
			WG['guishader'].RemoveDlist('topbar_wind')
		end
		glDeleteList(dlistWindGuishader)
	end
	dlistWindGuishader = glCreateList( function()
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
	end)

	if dlistWind1 ~= nil then
		glDeleteList(dlistWind1)
	end
	dlistWind1 = glCreateList( function()

		-- background
		glColor(0,0,0,ui_opacity)
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
		glColor(1,1,1,ui_opacity*0.055)
		RectRound(area[1]+bgpadding, area[2]+bgpadding, area[3]-bgpadding, area[4], 5*widgetScale)

		if WG['guishader'] then
			WG['guishader'].InsertDlist(dlistWindGuishader, 'topbar_wind')
		end

		glPushMatrix()
			glTranslate(xPos, yPos, 0)
			glTranslate(11*widgetScale, -((height*widgetScale)/4.4), 0) -- Spacing of icon
			glPushMatrix() -- Blades
				glTranslate(1*widgetScale, 9*widgetScale, 0)
				glTranslate(oorx, oory, 0)
	end)

	if dlistWind2 ~= nil then
		glDeleteList(dlistWind2)
	end
	dlistWind2 = glCreateList( function()
				glTranslate(-oorx, -oory, 0)
				glColor(1,1,1,0.3)
				glTexture(bladesTexture)
				glTexRect(0, 0, 27*widgetScale, 28*widgetScale)
				glTexture(false)
			glPopMatrix()

			x,y = 9*widgetScale, 2*widgetScale -- Pole
			glTexture(poleTexture)
			glTexRect(x, y, (7*widgetScale)+x, y+(18*widgetScale))
			glTexture(false)
		glPopMatrix()

		-- min and max wind
		local fontsize = (height/3.7)*widgetScale
        font2:Begin()
        font2:Print("\255\140\140\140"..minWind, area[3]-(2.8*widgetScale), area[4]-(4.5*widgetScale)-(fontsize/2), fontsize, 'or')
        font2:Print("\255\140\140\140"..maxWind, area[3]-(2.8*widgetScale), area[2]+(4.5*widgetScale), fontsize, 'or')
        font2:Print("\255\140\140\140"..maxWind, area[3]-(2.8*widgetScale), area[2]+(4.5*widgetScale), fontsize, 'or')
        font2:End()

	end)

	if WG['tooltip'] ~= nil then
		WG['tooltip'].AddTooltip('wind', area, "\255\215\255\215Wind Display\n\255\240\240\240Displays current wind strength\n\255\240\240\240also minimum ("..minWind..") and maximum ("..maxWind..")\n\255\255\215\215Rather build solars when average\n\255\255\215\215wind is below 5 (arm) or 6 (core)")
	end
end


local function updateResbarText(res)

	if dlistResbar[res][4] ~= nil then
		glDeleteList(dlistResbar[res][4])
	end
	dlistResbar[res][4] = glCreateList( function()
		local bgpadding = 3*widgetScale
		RectRound(resbarArea[res][1]+bgpadding, resbarArea[res][2]+bgpadding, resbarArea[res][3]-bgpadding, resbarArea[res][4], bgpadding*1.25)
		RectRound(resbarArea[res][1], resbarArea[res][2], resbarArea[res][3], resbarArea[res][4], 5.5*widgetScale)
	end)
	if dlistResbar[res][5] ~= nil then
		glDeleteList(dlistResbar[res][5])
	end
	dlistResbar[res][5] = glCreateList( function()
		RectRound(resbarArea[res][1], resbarArea[res][2], resbarArea[res][3], resbarArea[res][4], 5.5*widgetScale)
	end)

	-- storage changed!
	if currentStorageValue[res] ~= r[res][2] then
		-- flush old dlist caches
		for n,_ in pairs(dlistResValues[res]) do
			glDeleteList(dlistResValues[res][n])
		end
		dlistResValues[res] = {}

		-- storage
		if dlistResbar[res][6] ~= nil then
			glDeleteList(dlistResbar[res][6])
		end
		dlistResbar[res][6] = glCreateList( function()
			font2:Begin()
			font2:Print("\255\150\150\150"..short(r[res][2]), resbarDrawinfo[res].textStorage[2], resbarDrawinfo[res].textStorage[3], resbarDrawinfo[res].textStorage[4], resbarDrawinfo[res].textStorage[5])
			font2:End()
		end)
	end

	if dlistResbar[res][3] ~= nil then
		glDeleteList(dlistResbar[res][3])
	end
    dlistResbar[res][3] = glCreateList( function()
        font2:Begin()
        -- Text: pull
        font2:Print("\255\210\100\100"..short(r[res][3]), resbarDrawinfo[res].textPull[2], resbarDrawinfo[res].textPull[3], resbarDrawinfo[res].textPull[4], resbarDrawinfo[res].textPull[5])
		-- Text: expense
		local textcolor = "\255\150\135\110"
		if r[res][3] == r[res][5] then
			textcolor = "\255\166\115\110"
		end
        font2:Print(textcolor..short(r[res][5]), resbarDrawinfo[res].textExpense[2], resbarDrawinfo[res].textExpense[3], resbarDrawinfo[res].textExpense[4], resbarDrawinfo[res].textExpense[5])
		-- income
		font2:Print("\255\100\210\100"..short(r[res][4]), resbarDrawinfo[res].textIncome[2], resbarDrawinfo[res].textIncome[3], resbarDrawinfo[res].textIncome[4], resbarDrawinfo[res].textIncome[5])
		font2:End()

		if not spec and gameFrame > 90 then

			-- display overflow notification
			if (res == 'metal' and (allyteamOverflowingMetal or overflowingMetal)) or (res == 'energy' and (allyteamOverflowingEnergy or overflowingEnergy)) then
				if showOverflowTooltip[res] == nil then
					showOverflowTooltip[res] = os.clock() + 0.5
				end
				if showOverflowTooltip[res] < os.clock() then
					local bgpadding = 2.5*widgetScale
					local text = ''
					if res == 'metal' then
						text = (allyteamOverflowingMetal and 'Wasting Metal' or 'Overflowing')
						if WG['voicenotifs'] and allyteamOverflowingMetal then
							WG['voicenotifs'].addEvent('TeamWastingMetal')
						end
					else
						text = (allyteamOverflowingEnergy and 'Wasting Energy' or 'Overflowing')
						if WG['voicenotifs'] and allyteamOverflowingEnergy then
							WG['voicenotifs'].addEvent('TeamWastingEnergy')
						end
					end
					local textWidth = (bgpadding*2) + 15 + (font2:GetTextWidth(text) * 11.5) * widgetScale

					-- background
					if res == 'metal' then
						if allyteamOverflowingMetal then
							glColor(0.3,0,0,0.6)
						else
							glColor(0.3,0.3,0.3,0.4)
						end
					else
						if allyteamOverflowingEnergy then
							glColor(0.3,0,0,0.6)
						else
							glColor(0.3,0.25,0,0.6)
						end
					end
					RectRound(resbarArea[res][3]-textWidth, resbarArea[res][4]-15.5*widgetScale, resbarArea[res][3], resbarArea[res][4], 4*widgetScale)
					if res == 'metal' then
						if allyteamOverflowingMetal then
							glColor(1,0.3,0.3,0.2)
						else
							glColor(1,1,1,0.15)
						end
					else
						if allyteamOverflowingEnergy then
							glColor(1,0.3,0.3,0.2)
						else
							glColor(1,0.88,0,0.2)
						end
					end
					RectRound(resbarArea[res][3]-textWidth+bgpadding, resbarArea[res][4]-15.5*widgetScale+bgpadding, resbarArea[res][3]-bgpadding, resbarArea[res][4], bgpadding*1.25)

                    font2:Begin()
                    font2:SetTextColor(1,0.88,0.88,1)
                    font2:SetOutlineColor(0.2,0,0,0.6)
                    font2:Print(text, resbarArea[res][3]-5*widgetScale, resbarArea[res][4]-9.5*widgetScale, 11.5*widgetScale, 'or')
                    font2:End()
				end
			else
				showOverflowTooltip[res] = nil
			end
		end
	end)
end


local function updateResbar(res)
	local area = resbarArea[res]
	
	if dlistResbar[res][1] ~= nil then
		glDeleteList(dlistResbar[res][1])
		glDeleteList(dlistResbar[res][2])
	end
	local barHeight = (height*widgetScale/10)
	local barHeighPadding = 9*widgetScale --((height/2) * widgetScale) - (barHeight/2)
	--local barLeftPadding = 2 * widgetScale
	local barLeftPadding = 41 * widgetScale
	local barRightPadding = 10 * widgetScale
	local barArea = {area[1]+(height*widgetScale)+barLeftPadding, area[2]+barHeighPadding, area[3]-barRightPadding, area[2]+barHeight+barHeighPadding}
	local sliderHeightAdd = barHeight / 2.2
	local shareSliderWidth = barHeight + sliderHeightAdd + sliderHeightAdd
	local barWidth = barArea[3] - barArea[1]
	local glowSize = barHeight * 6

	if not showQuitscreen and resbarHover ~= nil and resbarHover == res then
		sliderHeightAdd = barHeight/0.77
		shareSliderWidth = barHeight + sliderHeightAdd + sliderHeightAdd
	end

	if res == 'metal' then
		resbarDrawinfo[res].barColor = {1,1,1,1}
	else
		resbarDrawinfo[res].barColor = {1,1,0,1}
	end
	resbarDrawinfo[res].barArea = barArea
	
	resbarDrawinfo[res].barTexRect = {barArea[1], barArea[2], barArea[1]+((r[res][1]/r[res][2]) * barWidth), barArea[4]}
	resbarDrawinfo[res].barGlowMiddleTexRect = {resbarDrawinfo[res].barTexRect[1], resbarDrawinfo[res].barTexRect[2] - glowSize, resbarDrawinfo[res].barTexRect[3], resbarDrawinfo[res].barTexRect[4] + glowSize}
	resbarDrawinfo[res].barGlowLeftTexRect = {resbarDrawinfo[res].barTexRect[1]-(glowSize*2), resbarDrawinfo[res].barTexRect[2] - glowSize, resbarDrawinfo[res].barTexRect[1], resbarDrawinfo[res].barTexRect[4] + glowSize}
	resbarDrawinfo[res].barGlowRightTexRect = {resbarDrawinfo[res].barTexRect[3]+(glowSize*2), resbarDrawinfo[res].barTexRect[2] - glowSize, resbarDrawinfo[res].barTexRect[3], resbarDrawinfo[res].barTexRect[4] + glowSize}
	
	resbarDrawinfo[res].textCurrent	= {short(r[res][1]), barArea[1]+barWidth/2, barArea[2]+barHeight*2, (height/2.75)*widgetScale, 'ocd'}
	resbarDrawinfo[res].textStorage	= {"\255\150\150\150"..short(r[res][2]), barArea[3], barArea[2]+barHeight*2, (height/3.2)*widgetScale, 'ord'}
	resbarDrawinfo[res].textPull	= {"\255\210\100\100"..short(r[res][3]), barArea[1]-(8*widgetScale), barArea[2]+barHeight*2.7, (height/3.2)*widgetScale, 'ord'}
	resbarDrawinfo[res].textExpense	= {"\255\210\100\100"..short(r[res][5]), barArea[1]+(10*widgetScale), barArea[2]+barHeight*2.7, (height/3.2)*widgetScale, 'old'}
	resbarDrawinfo[res].textIncome	= {"\255\100\210\100"..short(r[res][4]), barArea[1]-(8*widgetScale), barArea[2]-barHeight/1.2, (height/3.2)*widgetScale, 'ord'}

	-- add background blur
	if dlistResbar[res][0] ~= nil then
		if WG['guishader'] then
			WG['guishader'].RemoveDlist('topbar_'..res)
		end
		glDeleteList(dlistResbar[res][0])
	end
	dlistResbar[res][0] = glCreateList( function()
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
	end)

	dlistResbar[res][1] = glCreateList( function()

		-- background
		glColor(0,0,0,ui_opacity)
		RectRound(area[1], area[2], area[3], area[4], 5.5*widgetScale)
		local bgpadding = 3*widgetScale
		glColor(1,1,1,ui_opacity*0.055)
		RectRound(area[1]+bgpadding, area[2]+bgpadding, area[3]-bgpadding, area[4], bgpadding*1.25)
		
		if WG['guishader'] then
			WG['guishader'].InsertDlist(dlistResbar[res][0], 'topbar_'..res)
		end
		
		-- Icon
		glColor(1,1,1,1)
		local iconPadding = (area[4] - area[2]) / 9
		if res == 'metal' then
			glTexture(":l:LuaUI/Images/metal.png")
		else
			glTexture(":l:LuaUI/Images/energy.png")
		end
		glTexRect(area[1]+iconPadding, area[2]+iconPadding, area[1]+(height*widgetScale)-iconPadding, area[4]-iconPadding)
		glTexture(false)
		
		-- Bar background
		if res == 'metal' then
			glColor(0.5,0.5,0.5,0.33)
		else
			glColor(0.5,0.5,0,0.33)
		end
		glTexture(barbg)
		glTexRect(barArea[1], barArea[2], barArea[3], barArea[4])
	end)

	dlistResbar[res][2] = glCreateList( function()
		-- Metalmaker Conversion slider
		if showConversionSlider and res == 'energy' then
            local convValue = Spring.GetTeamRulesParam(myTeamID, 'mmLevel')
            if draggingConversionIndicatorValue ~= nil then
                convValue = draggingConversionIndicatorValue/100
			end
			if convValue == nil then
				convValue = 1
			end
			conversionIndicatorArea = {barArea[1]+(convValue * barWidth)-(shareSliderWidth/2), barArea[2]-sliderHeightAdd, barArea[1]+(convValue * barWidth)+(shareSliderWidth/2), barArea[4]+sliderHeightAdd}
			glTexture(barbg)
			if not showQuitscreen and resbarHover ~= nil and resbarHover == res then
				local padding = shareSliderWidth/8
				glColor(0.8, 0.8, 0.5, 1)
				RectRound(conversionIndicatorArea[1], conversionIndicatorArea[2], conversionIndicatorArea[3], conversionIndicatorArea[4],8*widgetScale)
				glColor(0.7, 0.7, 0.47, 1)
				RectRound(conversionIndicatorArea[1]+padding, conversionIndicatorArea[2]+padding, conversionIndicatorArea[3]-padding, conversionIndicatorArea[4]-padding,6.5*widgetScale)
			else
				glColor(0.85, 0.85, 0.55, 1)
				glTexRect(conversionIndicatorArea[1], conversionIndicatorArea[2], conversionIndicatorArea[3], conversionIndicatorArea[4])
			end
		end
		-- Share slider
        local value = r[res][6]
        if draggingShareIndicatorValue[res] ~= nil then
            value = draggingShareIndicatorValue[res]
        end
		shareIndicatorArea[res] = {barArea[1]+(value * barWidth)-(shareSliderWidth/2), barArea[2]-sliderHeightAdd, barArea[1]+(value * barWidth)+(shareSliderWidth/2), barArea[4]+sliderHeightAdd}
		glTexture(barbg)
		if not showQuitscreen and resbarHover ~= nil and resbarHover == res then
			local padding = shareSliderWidth/8
			glColor(0.66, 0, 0, 1)
			RectRound(shareIndicatorArea[res][1], shareIndicatorArea[res][2], shareIndicatorArea[res][3], shareIndicatorArea[res][4],2.5*widgetScale)
			glColor(0.6, 0, 0, 1)
			RectRound(shareIndicatorArea[res][1]+padding, shareIndicatorArea[res][2]+padding, shareIndicatorArea[res][3]-padding, shareIndicatorArea[res][4]-padding,2.5*widgetScale)
		else
			glColor(0.8, 0, 0, 1)
			glTexRect(shareIndicatorArea[res][1], shareIndicatorArea[res][2], shareIndicatorArea[res][3], shareIndicatorArea[res][4])
		end
		glTexture(false)
	end)
	
	-- add tooltips
	if WG['tooltip'] ~= nil and conversionIndicatorArea then
		if res == 'energy' then
			WG['tooltip'].AddTooltip(res..'_share_slider', {resbarDrawinfo[res].barArea[1], shareIndicatorArea[res][2], conversionIndicatorArea[1], shareIndicatorArea[res][4]}, "\255\215\255\215"..res:sub(1,1):upper()..res:sub(2).." Share Slider\n\255\240\240\240Overflowing to your team when \n"..res.." goes beyond this point")
			WG['tooltip'].AddTooltip(res..'_share_slider2', {conversionIndicatorArea[3], shareIndicatorArea[res][2], resbarDrawinfo[res].barArea[3], shareIndicatorArea[res][4]}, "\255\215\255\215"..res:sub(1,1):upper()..res:sub(2).." Share Slider\n\255\240\240\240Overflowing to your team when \n"..res.." goes beyond this point")

			WG['tooltip'].AddTooltip(res..'_metalmaker_slider', conversionIndicatorArea, "\255\215\255\215Energy Conversion slider\n\255\240\240\240Excess energy beyond this point will be\nconverted to metal\n(by your Energy Convertor units)")
		else
			WG['tooltip'].AddTooltip(res..'_share_slider', {resbarDrawinfo[res].barArea[1], shareIndicatorArea[res][2], resbarDrawinfo[res].barArea[3], shareIndicatorArea[res][4]}, "\255\215\255\215"..res:sub(1,1):upper()..res:sub(2).." Share Slider\n\255\240\240\240Overflowing to your team when \n"..res.." goes beyond this point")
		end
		WG['tooltip'].AddTooltip(res..'_pull', {resbarDrawinfo[res].textPull[2]-(resbarDrawinfo[res].textPull[4]*2.5), resbarDrawinfo[res].textPull[3], resbarDrawinfo[res].textPull[2]+(resbarDrawinfo[res].textPull[4]*0.5), resbarDrawinfo[res].textPull[3]+resbarDrawinfo[res].textPull[4]}, ""..res.." pull")
		WG['tooltip'].AddTooltip(res..'_income', {resbarDrawinfo[res].textIncome[2]-(resbarDrawinfo[res].textIncome[4]*2.5), resbarDrawinfo[res].textIncome[3], resbarDrawinfo[res].textIncome[2]+(resbarDrawinfo[res].textIncome[4]*0.5), resbarDrawinfo[res].textIncome[3]+resbarDrawinfo[res].textIncome[4]}, ""..res.." income")
		WG['tooltip'].AddTooltip(res..'_expense', {resbarDrawinfo[res].textExpense[2]-(4*widgetScale),	resbarDrawinfo[res].textExpense[3], resbarDrawinfo[res].textExpense[2]+(30*widgetScale), resbarDrawinfo[res].textExpense[3]+resbarDrawinfo[res].textExpense[4]}, ""..res.." expense")
		WG['tooltip'].AddTooltip(res..'_storage', {resbarDrawinfo[res].textStorage[2]-(resbarDrawinfo[res].textStorage[4]*2.75), resbarDrawinfo[res].textStorage[3], resbarDrawinfo[res].textStorage[2], resbarDrawinfo[res].textStorage[3]+resbarDrawinfo[res].textStorage[4]}, ""..res.." storage")
		WG['tooltip'].AddTooltip(res..'_curent', {resbarDrawinfo[res].textCurrent[2]-(resbarDrawinfo[res].textCurrent[4]*1.75), resbarDrawinfo[res].textCurrent[3], resbarDrawinfo[res].textCurrent[2]+(resbarDrawinfo[res].textCurrent[4]*1.75), resbarDrawinfo[res].textCurrent[3]+resbarDrawinfo[res].textCurrent[4]}, "\255\215\255\215"..string.upper(res).."\n\255\240\240\240Share "..res.." to a specific player by...\n1) Using the (adv)playerlist,\n    dragging up the "..res.." icon at the rightside.\n2) An interface brought up with the H key.")
	end
end




function init()

	r = {metal={spGetTeamResources(myTeamID,'metal')}, energy={spGetTeamResources(myTeamID,'energy')}}

	topbarArea = {xPos, math.floor(vsy-(borderPadding*widgetScale)-(height*widgetScale)), vsx, vsy}
	barContentArea = {xPos+(borderPadding*widgetScale), math.floor(vsy-(height*widgetScale)), vsx, vsy}
	
	local filledWidth = 0
	local totalWidth = barContentArea[3] - barContentArea[1]
	local areaSeparator = (borderPadding*widgetScale)

	if dlistBackground then
		glDeleteList(dlistBackground)
	end
	dlistBackground = glCreateList( function()
		
		--glColor(0, 0, 0, 0.66)
		--RectRound(topbarArea[1], topbarArea[2], topbarArea[3], topbarArea[4], 6*widgetScale)
		--
		--glColor(1,1,1,0.025)
		--RectRound(barContentArea[1], barContentArea[2], barContentArea[3], barContentArea[4]+(10*widgetScale), 5*widgetScale)

	end)
	
	-- metal
	local width = (totalWidth/4)
	resbarArea['metal'] = {barContentArea[1]+filledWidth, barContentArea[2], barContentArea[1]+filledWidth+width, barContentArea[4]}
	filledWidth = filledWidth + width + areaSeparator
	updateResbar('metal')
	
	--energy
	resbarArea['energy'] = {barContentArea[1]+filledWidth, barContentArea[2], barContentArea[1]+filledWidth+width, barContentArea[4]}
	filledWidth = filledWidth + width + areaSeparator
	updateResbar('energy')
	
	-- wind
	width = ((height*1.18)*widgetScale)
	windArea = {barContentArea[1]+filledWidth, barContentArea[2], barContentArea[1]+filledWidth+width, barContentArea[4]}
	filledWidth = filledWidth + width + areaSeparator
	updateWind()

	-- coms
	if displayComCounter then
		comsArea = {barContentArea[1]+filledWidth, barContentArea[2], barContentArea[1]+filledWidth+width, barContentArea[4]}
		filledWidth = filledWidth + width + areaSeparator
        updateComs()
	end

	-- rejoin
	width = (totalWidth/4) / 3.3
	rejoinArea = {barContentArea[1]+filledWidth, barContentArea[2], barContentArea[1]+filledWidth+width, barContentArea[4]}
	filledWidth = filledWidth + width + areaSeparator
	
	-- buttons
	width = (totalWidth/4)
	buttonsArea = {barContentArea[3]-width, barContentArea[2], barContentArea[3], barContentArea[4]}
	filledWidth = filledWidth + width + areaSeparator
	updateButtons()
	
	WG['topbar'].GetPosition = function()
		return {topbarArea[1], topbarArea[2], topbarArea[3], topbarArea[4], widgetScale, barContentArea[2]}
	end

	updateResbarText('metal')
	updateResbarText('energy')
end

function checkStatus()
	myAllyTeamID = Spring.GetMyAllyTeamID()
    myTeamID = Spring.GetMyTeamID()
	myPlayerID = Spring.GetMyPlayerID()
end


function widget:GameStart()
	gameStarted = true
	checkStatus()
	if displayComCounter then
		countComs(true)
	end
end


function widget:GameFrame(n)
	spec = spGetSpectatingState()

    windRotation = windRotation + (currentWind * bladeSpeedMultiplier)
    gameFrame = n

    --functionContainer(n) --function that are able to remove itself. Reference: gui_take_reminder.lua (widget by EvilZerggin, modified by jK)
end

local uiOpacitySec = 0
local sec = 0
local sec2 = 0
local secComCount = 0
local t = UPDATE_RATE_S
local blinkDirection = true
local blinkProgress = 0
function widget:Update(dt)
	if chobbyInterface then return end
	
    local prevMyTeamID = myTeamID
    if spec and spGetMyTeamID() ~= prevMyTeamID then  -- check if the team that we are spectating changed
        checkStatus()
    end

	local mx,my = spGetMouseState()

	uiOpacitySec = uiOpacitySec + dt
	if uiOpacitySec>0.5 then
		uiOpacitySec = 0
		if ui_opacity ~= Spring.GetConfigFloat("ui_opacity",0.66) then
			ui_opacity = Spring.GetConfigFloat("ui_opacity",0.66)
			init()
		end
	end

	if blinkDirection then
		blinkProgress = blinkProgress + (dt*9)
		if blinkProgress > 1 then
			blinkProgress = 1
			blinkDirection = false
		end
	else
		blinkProgress = blinkProgress - (dt/(blinkProgress*1.5))
		if blinkProgress < 0 then
			blinkProgress = 0
			blinkDirection = true
		end
	end

    now = os.clock()
	if now > nextGuishaderCheck and widgetHandler.orderList["GUI Shader"] ~= nil then
        nextGuishaderCheck = now+guishaderCheckUpdateRate
		if guishaderEnabled == false and widgetHandler.orderList["GUI Shader"] ~= 0 then
			guishaderEnabled = true
			init()
		elseif guishaderEnabled and (widgetHandler.orderList["GUI Shader"] == 0) then
			guishaderEnabled = false
		end
	end

	sec = sec + dt
	if sec > 0.033 then
		sec = 0
		r = {metal={spGetTeamResources(myTeamID,'metal')}, energy={spGetTeamResources(myTeamID,'energy')}}
		if not spec and not showQuitscreen then
			if isInBox(mx, my, resbarArea['energy']) then
				if resbarHover == nil then
					resbarHover = 'energy'
					updateResbar('energy')
				end
			elseif resbarHover ~= nil and resbarHover == 'energy' then
				resbarHover = nil
				updateResbar('energy')
			end
			if isInBox(mx, my, resbarArea['metal']) then
				if resbarHover == nil then
					resbarHover = 'metal'
					updateResbar('metal')
				end
			elseif resbarHover ~= nil and resbarHover == 'metal' then
				resbarHover = nil
				updateResbar('metal')
			end
		elseif spec and myTeamID ~= prevMyTeamID then  -- check if the team that we are spectating changed
			draggingShareIndicatorValue = {}
			draggingConversionIndicatorValue = nil
			if sec ~= 0 then
				r = {metal={spGetTeamResources(myTeamID,'metal')}, energy={spGetTeamResources(myTeamID,'energy')}}
			end
			updateResbar('metal')
			updateResbar('energy')
		end
	end

	sec2 = sec2 + dt
	if sec2 >= 1 then
		sec2 = 0
		updateResbarText('metal')
		updateResbarText('energy')
		updateAllyTeamOverflowing()
	end

	-- wind
	if (gameFrame ~= lastFrame) then
		currentWind = sformat('%.1f', select(4,spGetWind()))
	end


 	-- coms
	if displayComCounter then
        secComCount = secComCount + dt
        if secComCount>0.5 then
            secComCount = 0
            countComs()
        end
	end

	-- rejoin
	if not isReplay and serverFrame then
		t = t - dt
		if t <= 0 then
			t = t + UPDATE_RATE_S

			--Estimate Server Frame
			local speedFactor, _, isPaused = Spring.GetGameSpeed()
			if gameStarted and not isPaused then
				serverFrame = serverFrame + math.ceil(speedFactor * UPDATE_RATE_F)
			end

			local framesLeft = serverFrame - gameFrame
			if framesLeft > CATCH_UP_THRESHOLD then
				showRejoinUI = true
				updateRejoin()
			elseif showRejoinUI then
				showRejoinUI = false
				updateRejoin()
			end
		end
	end
end

function drawResbarValues(res)
	local barWidth = resbarDrawinfo[res].barArea[3] - resbarDrawinfo[res].barArea[1]
	local glowSize = (resbarDrawinfo[res].barArea[4] - resbarDrawinfo[res].barArea[2]) * 5.5

	local cappedCurRes = r[res][1]	-- limit so when production dies the value wont be much larger than what you can store
	if r[res][1] > r[res][2]*1.07 then
		cappedCurRes = r[res][2]*1.07
	end
	if res == 'energy' then
		glColor(1,1,0, 0.04)
		glTexture(glowTexture)
		local iconPadding = (resbarArea[res][4] - resbarArea[res][2])
		glTexRect(resbarArea[res][1]+iconPadding, resbarArea[res][2]+iconPadding, resbarArea[res][1]+(height*widgetScale)-iconPadding, resbarArea[res][4]-iconPadding)
	end

	-- Bar value
	glColor(resbarDrawinfo[res].barColor)
	glTexture(barbg)
	glTexRect(resbarDrawinfo[res].barTexRect[1], resbarDrawinfo[res].barTexRect[2], resbarDrawinfo[res].barTexRect[1]+((cappedCurRes/r[res][2]) * barWidth), resbarDrawinfo[res].barTexRect[4])

	-- Bar value glow
	glColor(resbarDrawinfo[res].barColor[1], resbarDrawinfo[res].barColor[2], resbarDrawinfo[res].barColor[3], 0.09)
	glTexture(barGlowCenterTexture)
	glTexRect(resbarDrawinfo[res].barGlowMiddleTexRect[1], resbarDrawinfo[res].barGlowMiddleTexRect[2], resbarDrawinfo[res].barGlowMiddleTexRect[1] + ((cappedCurRes/r[res][2]) * barWidth), resbarDrawinfo[res].barGlowMiddleTexRect[4])
	glTexture(barGlowEdgeTexture)
	glTexRect(resbarDrawinfo[res].barGlowLeftTexRect[1], resbarDrawinfo[res].barGlowLeftTexRect[2], resbarDrawinfo[res].barGlowLeftTexRect[3], resbarDrawinfo[res].barGlowLeftTexRect[4])
	glTexRect((resbarDrawinfo[res].barGlowMiddleTexRect[1]+((cappedCurRes/r[res][2]) * barWidth))+(glowSize*2), resbarDrawinfo[res].barGlowRightTexRect[2], resbarDrawinfo[res].barGlowMiddleTexRect[1]+((cappedCurRes/r[res][2]) * barWidth), resbarDrawinfo[res].barGlowRightTexRect[4])

	currentResValue[res] = short(cappedCurRes)
	if not dlistResValues[res][currentResValue[res]] then
		dlistResValues[res][currentResValue[res]] = glCreateList( function()
			-- Text: current
            font2:Begin()
            font2:Print(currentResValue[res], resbarDrawinfo[res].textCurrent[2], resbarDrawinfo[res].textCurrent[3], resbarDrawinfo[res].textCurrent[4], resbarDrawinfo[res].textCurrent[5])
            font2:End()
        end)
	end
	glCallList(dlistResValues[res][currentResValue[res]])
end

function widget:RecvLuaMsg(msg, playerID)
	if msg:sub(1,18) == 'LobbyOverlayActive' then
		chobbyInterface = (msg:sub(1,19) == 'LobbyOverlayActive1')
	end
end

function updateAllyTeamOverflowing()
	allyteamOverflowingMetal = false
	allyteamOverflowingEnergy = false
	overflowingMetal = false
	overflowingEnergy = false
	local totalEnergy = 0
	local totalEnergyStorage = 0
	local totalMetal = 0
	local totalMetalStorage = 0
	local energyPercentile, metalPercentile
	for i, teamID in pairs(Spring.GetTeamList(Spring.GetMyAllyTeamID())) do
		local energy, energyStorage,_,_,_,energyShare, energySent = spGetTeamResources(teamID, "energy")
		totalEnergy = totalEnergy + energy
		totalEnergyStorage = totalEnergyStorage + energyStorage
		local metal, metalStorage,_,_,_,metalShare, metalSent = spGetTeamResources(teamID, "metal")
		totalMetal = totalMetal + metal
		totalMetalStorage = totalMetalStorage + metalStorage
		if teamID == myTeamID then
			energyPercentile = energySent / totalEnergyStorage
			metalPercentile = metalSent / totalMetalStorage
			if energyPercentile > 0.0001 then
				overflowingEnergy = energyPercentile * (1/0.025)
				if overflowingEnergy > 1 then overflowingEnergy = 1 end
			end
			if metalPercentile > 0.0001 then
				overflowingMetal = metalPercentile * (1/0.025)
				if overflowingMetal > 1 then overflowingMetal = 1 end
			end
		end
	end
	energyPercentile = totalEnergy / totalEnergyStorage
	metalPercentile = totalMetal / totalMetalStorage
	if energyPercentile > 0.975 then
		allyteamOverflowingEnergy = (energyPercentile - 0.975) * (1/0.025)
		if allyteamOverflowingEnergy > 1 then allyteamOverflowingEnergy = 1 end
	end
	if metalPercentile > 0.975 then
		allyteamOverflowingMetal = (metalPercentile - 0.975) * (1/0.025)
		if allyteamOverflowingMetal > 1 then allyteamOverflowingMetal = 1 end
	end
end

function widget:DrawScreen()
	if chobbyInterface then return end

	glPushMatrix()
	if dlistBackground then
		glCallList(dlistBackground)
	end

	local now = os.clock()
	local x,y,b = spGetMouseState()

	local res = 'metal'
	if dlistResbar[res][1] and dlistResbar[res][2] and dlistResbar[res][3] then
		glCallList(dlistResbar[res][1])

		if not spec and gameFrame > 90 then
			if allyteamOverflowingMetal then
				glColor(1,0,0,0.13*allyteamOverflowingMetal*blinkProgress)
			elseif overflowingMetal then
				glColor(1,1,1,0.05*overflowingMetal*(0.6+(blinkProgress*0.4)))
			end
			if allyteamOverflowingMetal or overflowingMetal then
				glCallList(dlistResbar[res][4])
			end
		end
		-- low energy background
		if r[res][1] < 1000 then
			process = (r[res][1]/r[res][2]) * 13
			if process < 1 then
				process = 1 - process
				glColor(0.9,0.4,1,0.08*process)
				glCallList(dlistResbar[res][5])
			end
		end
		drawResbarValues(res)
		glCallList(dlistResbar[res][6])
     	glCallList(dlistResbar[res][3])
		glCallList(dlistResbar[res][2])
	end
	res = 'energy'
	if dlistResbar[res][1] and dlistResbar[res][2] and dlistResbar[res][3] then
		glCallList(dlistResbar[res][1])

		if not spec and gameFrame > 90 then
			if allyteamOverflowingEnergy then
				glColor(1,0,0,0.13*allyteamOverflowingEnergy*blinkProgress)
			elseif overflowingEnergy then
				glColor(1,1,0,0.05*overflowingEnergy*(0.6+(blinkProgress*0.4)))
			end
			if allyteamOverflowingEnergy or overflowingEnergy then
				glCallList(dlistResbar[res][4])
			end
			-- low energy background
			if r[res][1] < 2000 then
				process = (r[res][1]/r[res][2]) * 13
				if process < 1 then
					process = 1 - process
					glColor(0.9,0.55,1,0.08*process)
					glCallList(dlistResbar[res][5])
				end
			end
		end
		drawResbarValues(res)
		glCallList(dlistResbar[res][6])
      	glCallList(dlistResbar[res][3])
		glCallList(dlistResbar[res][2])
	end

	if dlistWind1 then
		glPushMatrix()
		glCallList(dlistWind1)
		glRotate(windRotation, 0, 0, 1)
		glCallList(dlistWind2)
		glPopMatrix()
		-- current wind
		if gameFrame > 0 then
			local fontSize = (height/2.66)*widgetScale
			if not dlistWindText[currentWind] then
				dlistWindText[currentWind] = glCreateList( function()
                    font2:Begin()
                    font2:Print("\255\255\255\255"..currentWind, windArea[1]+((windArea[3]-windArea[1])/2), windArea[2]+((windArea[4]-windArea[2])/2.05)-(fontSize/5), fontSize, 'oc') -- Wind speed text
                    font2:End()
                end)
			end
			glCallList(dlistWindText[currentWind])
		else
			if now < 60 and WG['tooltip'] ~= nil then
				if (minWind + maxWind)/2 < 5.5 then
					WG['tooltip'].ShowTooltip('topbar_windinfo', 'Wind isnt worth', windArea[1], windArea[2]-13*widgetScale)
				elseif (minWind + maxWind)/2 >= 5.5 and (minWind + maxWind)/2 < 7 then
					WG['tooltip'].ShowTooltip('topbar_windinfo', 'Wind is viable', windArea[1], windArea[2]-13*widgetScale)
				elseif (minWind + maxWind)/2 >= 7 and (minWind + maxWind)/2 < 8.5 then
					WG['tooltip'].ShowTooltip('topbar_windinfo', 'Average wind is okay', windArea[1], windArea[2]-13*widgetScale)
				elseif (minWind + maxWind)/2 >= 8.5 and (minWind + maxWind)/2 < 10 then
					WG['tooltip'].ShowTooltip('topbar_windinfo', 'Average wind is good', windArea[1], windArea[2]-13*widgetScale)
				elseif (minWind + maxWind)/2 >= 10  and (minWind + maxWind)/2 < 15 then
					WG['tooltip'].ShowTooltip('topbar_windinfo', 'Average wind is really good', windArea[1], windArea[2]-13*widgetScale)
				elseif (minWind + maxWind)/2 >= 15 then
					WG['tooltip'].ShowTooltip('topbar_windinfo', 'Wind is insanely good', windArea[1], windArea[2]-13*widgetScale)
				end
			end
		end
	end

	if displayComCounter and dlistComs1 then
		glCallList(dlistComs1)
		if allyComs == 1 and (gameFrame % 12 < 6) then
			glColor(1,0.6,0,0.6)
		else
			glColor(1,1,1,0.3)
		end
		glCallList(dlistComs2)
	end

	if dlistRejoin and showRejoinUI then
		glCallList(dlistRejoin)
	elseif dlistRejoin ~= nil then
		if dlistRejoin ~= nil then
			glDeleteList(dlistRejoin)
			dlistRejoin = nil
		end
		if WG['guishader'] then
			WG['guishader'].RemoveDlist('topbar_rejoin')
		end
		if WG['tooltip'] ~= nil then
			WG['tooltip'].RemoveTooltip('rejoin')
		end
	end

	if dlistButtons1 then
		glCallList(dlistButtons1)
		-- hovered?
		if not showQuitscreen and buttonsArea['buttons'] ~= nil and IsOnRect(x, y, buttonsArea[1], buttonsArea[2], buttonsArea[3], buttonsArea[4]) then
			buttonsAreaHovered = nil
			for button, pos in pairs(buttonsArea['buttons']) do
				if IsOnRect(x, y, pos[1], pos[2], pos[3], pos[4]) then
					if b then
						glColor(1,1,1,0.32)
					else
						glColor(1,1,1,0.25)
					end
					RectRound(buttonsArea['buttons'][button][1], buttonsArea['buttons'][button][2], buttonsArea['buttons'][button][3], buttonsArea['buttons'][button][4], 3.5*widgetScale)
					break
				end
			end
		end
		glCallList(dlistButtons2)
	end

    if dlistQuit ~= nil then
        if WG['guishader'] then
            WG['guishader'].removeRenderDlist(dlistQuit)
        end
        glDeleteList(dlistQuit)
        dlistQuit = nil
    end
	if showQuitscreen ~= nil then
		local fadeoutBonus = 0
		local fadeTime = 0.2
		local fadeProgress = (now - showQuitscreen) / fadeTime
		if fadeProgress > 1 then fadeProgress = 1 end

		Spring.SetMouseCursor('cursornormal')

        dlistQuit = glCreateList( function()
			if WG['guishader'] then
            	glColor(0,0,0,(0.18*fadeProgress))
			else
				glColor(0,0,0,(0.35*fadeProgress))
			end
            glRect( 0, 0, vsx, vsy)

            if hideQuitWindow == nil then	-- when terminating spring, keep the faded screen

                local width = 320*widgetScale
                local height = width/3.5
                local padding = width/70
                local buttonPadding = width/90
                local buttonMargin = width/30
                local buttonHeight = height*0.55

                quitscreenArea = {(vsx/2)-(width/2), (vsy/1.8)-(height/2), (vsx/2)+(width/2), (vsy/1.8)+(height/2)}
                quitscreenResignArea = {(vsx/2)-(width/2)+buttonMargin, (vsy/1.8)-(height/2)+buttonMargin, (vsx/2)-(buttonMargin/2), (vsy/1.8)-(height/2)+buttonHeight-buttonMargin}
                quitscreenQuitArea = {(vsx/2)+(buttonMargin/2), (vsy/1.8)-(height/2)+buttonMargin, (vsx/2)+(width/2)-buttonMargin, (vsy/1.8)-(height/2)+buttonHeight-buttonMargin}

                -- window
                glColor(1,1,1,0.5+(0.36*fadeProgress))
                RectRound(quitscreenArea[1], quitscreenArea[2], quitscreenArea[3], quitscreenArea[4], 5.5*widgetScale)
                glColor(0,0,0,0.035+(0.035*fadeProgress))
                RectRound(quitscreenArea[1]+padding, quitscreenArea[2]+padding, quitscreenArea[3]-padding, quitscreenArea[4]-padding, padding)

                local fontSize = height/6
                font:Begin()
                font:SetTextColor(0,0,0,1)
                if not spec then
                    font:Print("Want to resign or quit to desktop?", quitscreenArea[1]+((quitscreenArea[3]-quitscreenArea[1])/2), quitscreenArea[4]-padding-padding-padding-fontSize, fontSize, "cn")
                else
                    font:Print("Really want to quit?", quitscreenArea[1]+((quitscreenArea[3]-quitscreenArea[1])/2), quitscreenArea[4]-padding-padding-padding-padding-fontSize, fontSize, "cn")
                end

                -- quit button
                if IsOnRect(x, y, quitscreenQuitArea[1], quitscreenQuitArea[2], quitscreenQuitArea[3], quitscreenQuitArea[4]) then
                    glColor(0.66,0.05,0.05,0.4+(0.5*fadeProgress))
                else
                    glColor(0.45,0,0,0.35+(0.4*fadeProgress))
                end
                RectRound(quitscreenQuitArea[1], quitscreenQuitArea[2], quitscreenQuitArea[3], quitscreenQuitArea[4], 3.5*widgetScale)
                glColor(0,0,0,0.07+(0.05*fadeProgress))
                RectRound(quitscreenQuitArea[1]+buttonPadding, quitscreenQuitArea[2]+buttonPadding, quitscreenQuitArea[3]-buttonPadding, quitscreenQuitArea[4]-buttonPadding, 2.8*widgetScale)
				font:End()

                fontSize = fontSize*0.92
				font2:Begin()
                font2:SetTextColor(1,1,1,1)
                font2:SetOutlineColor(0,0,0,0.23)
                font2:Print("Quit", quitscreenQuitArea[1]+((quitscreenQuitArea[3]-quitscreenQuitArea[1])/2), quitscreenQuitArea[2]+((quitscreenQuitArea[4]-quitscreenQuitArea[2])/2)-(fontSize/3), fontSize, "con")

                -- resign button
                if not spec then
                    if IsOnRect(x, y, quitscreenResignArea[1], quitscreenResignArea[2], quitscreenResignArea[3], quitscreenResignArea[4]) then
                        glColor(0.55,0.55,0.55,0.4+(0.5*fadeProgress))
                    else
                        glColor(0.3,0.3,0.3,0.4+(0.4*fadeProgress))
                    end
                    RectRound(quitscreenResignArea[1], quitscreenResignArea[2], quitscreenResignArea[3], quitscreenResignArea[4], 3.5*widgetScale)
                    glColor(0,0,0,0.07+(0.05*fadeProgress))
                    RectRound(quitscreenResignArea[1]+buttonPadding, quitscreenResignArea[2]+buttonPadding, quitscreenResignArea[3]-buttonPadding, quitscreenResignArea[4]-buttonPadding, 2.8*widgetScale)

                    font2:Print("Resign", quitscreenResignArea[1]+((quitscreenResignArea[3]-quitscreenResignArea[1])/2), quitscreenResignArea[2]+((quitscreenResignArea[4]-quitscreenResignArea[2])/2)-(fontSize/3), fontSize, "con")
                end
                font2:End()
            end
        end)

        -- background
        if WG['guishader'] then
            WG['guishader'].setScreenBlur(true)
            WG['guishader'].insertRenderDlist(dlistQuit)
        else
            glCallList(dlistQuit)
        end
    end
	glColor(1,1,1,1)
	glPopMatrix()
end


function IsOnRect(x, y, BLcornerX, BLcornerY,TRcornerX,TRcornerY)
	return x >= BLcornerX and x <= TRcornerX and y >= BLcornerY and y <= TRcornerY
end


local function adjustSliders(x, y)
	if draggingShareIndicator ~= nil and not spec then
		local shareValue =	(x - resbarDrawinfo[draggingShareIndicator]['barArea'][1]) / (resbarDrawinfo[draggingShareIndicator]['barArea'][3] - resbarDrawinfo[draggingShareIndicator]['barArea'][1])
		if shareValue < 0 then shareValue = 0 end
		if shareValue > 1 then shareValue = 1 end
		Spring.SetShareLevel(draggingShareIndicator, shareValue)
        draggingShareIndicatorValue[draggingShareIndicator] = shareValue
		updateResbar(draggingShareIndicator)
	end
	if showConversionSlider and draggingConversionIndicator and not spec then
		local convValue = math.floor((x - resbarDrawinfo['energy']['barArea'][1]) / (resbarDrawinfo['energy']['barArea'][3] - resbarDrawinfo['energy']['barArea'][1]) * 100)
		if convValue < 12 then convValue = 12 end
		if convValue > 88 then convValue = 88 end
		Spring.SendLuaRulesMsg(sformat(string.char(137)..'%i', convValue))
        draggingConversionIndicatorValue = convValue
		updateResbar('energy')
	end
end

function widget:MouseMove(x, y)
	adjustSliders(x, y)
end


local function hideWindows()
	if (WG['options'] ~= nil) then
		WG['options'].toggle(false)
	end
	if (WG['scavengerinfo'] ~= nil) then
		WG['scavengerinfo'].toggle(false)
	end
	if (WG['changelog'] ~= nil) then
		WG['changelog'].toggle(false)
	end
	if (WG['keybinds'] ~= nil) then
		WG['keybinds'].toggle(false)
	end
	if (WG['commands'] ~= nil) then
		WG['commands'].toggle(false)
	end
	if (WG['gameinfo'] ~= nil) then
		WG['gameinfo'].toggle(false)
	end
    if (WG['teamstats'] ~= nil) then
        WG['teamstats'].toggle(false)
	end
	showQuitscreen = nil
	if WG['guishader'] then
		WG['guishader'].setScreenBlur(false)
	end
end

local function applyButtonAction(button)

	if playSounds then
		Spring.PlaySoundFile(leftclick, 0.8, 'ui')
	end

	local isvisible = false
	if button == 'quit' then
		if chobbyLoaded then
			Spring.SendLuaMenuMsg("showLobby")
		else
			local oldShowQuitscreen
			if showQuitscreen ~= nil then
				oldShowQuitscreen = showQuitscreen
				isvisible = true
			end
			hideWindows()
			if oldShowQuitscreen ~= nil then
				if isvisible ~= true then
					showQuitscreen = oldShowQuitscreen
					if WG['guishader'] then
						WG['guishader'].setScreenBlur(true)
					end
				end
			else
				showQuitscreen = os.clock()
			end
		end
	elseif button == 'options' then
		if (WG['options'] ~= nil) then
			isvisible = WG['options'].isvisible()
		end
		hideWindows()
		if (WG['options'] ~= nil and isvisible ~= true) then
			WG['options'].toggle()
		end
	elseif button == 'scavengers' then
		if (WG['scavengerinfo'] ~= nil) then
			isvisible = WG['scavengerinfo'].isvisible()
		end
		hideWindows()
		if (WG['scavengerinfo'] ~= nil and isvisible ~= true) then
			WG['scavengerinfo'].toggle()
		end
	elseif button == 'changelog' then
		if (WG['changelog'] ~= nil) then
			isvisible = WG['changelog'].isvisible()
		end
		hideWindows()
		if (WG['changelog'] ~= nil and isvisible ~= true) then
			WG['changelog'].toggle()
		end
	elseif button == 'keybinds' then
		if (WG['keybinds'] ~= nil) then
			isvisible = WG['keybinds'].isvisible()
		end
		hideWindows()
		if (WG['keybinds'] ~= nil and isvisible ~= true) then
			WG['keybinds'].toggle()
		end
    elseif button == 'commands' then
		if (WG['commands'] ~= nil) then
			isvisible = WG['commands'].isvisible()
		end
        hideWindows()
        if (WG['commands'] ~= nil and isvisible ~= true) then
            WG['commands'].toggle()
        end
    elseif button == 'stats' then
		if (WG['teamstats'] ~= nil) then
			isvisible = WG['teamstats'].isvisible()
		end
        hideWindows()
        if (WG['teamstats'] ~= nil and isvisible ~= true) then
            WG['teamstats'].toggle()
        end
	end
end

function widget:MouseWheel(up,value) --up = true/false , value = -1/1
	if showQuitscreen ~= nil and quitscreenArea ~= nil then
		return true
	end
end

function widget:KeyPress(key)
	if key == 27 then	-- ESC
		if not WG['options'] or (WG['options'].disallowEsc and not WG['options'].disallowEsc()) then
			hideWindows()
		end
	end
	if showQuitscreen ~= nil and quitscreenArea ~= nil then
		return true
	end
end

function widget:MousePress(x, y, button)

	if button == 1 then
		if showQuitscreen ~= nil and quitscreenArea ~= nil then

			if IsOnRect(x, y, quitscreenArea[1], quitscreenArea[2], quitscreenArea[3], quitscreenArea[4]) then

				if IsOnRect(x, y, quitscreenQuitArea[1], quitscreenQuitArea[2], quitscreenQuitArea[3], quitscreenQuitArea[4]) then
					if playSounds then
						Spring.PlaySoundFile(leftclick, 0.75, 'ui')
					end
					Spring.SendCommands("QuitForce")
					showQuitscreen = nil
					hideQuitWindow = os.clock()
					return true
				end
				if not spec and IsOnRect(x, y, quitscreenResignArea[1], quitscreenResignArea[2], quitscreenResignArea[3], quitscreenResignArea[4]) then
					if playSounds then
						Spring.PlaySoundFile(leftclick, 0.75, 'ui')
					end
					Spring.SendCommands("spectator")
					showQuitscreen = nil
					if WG['guishader'] then
						WG['guishader'].setScreenBlur(false)
					end
					return true
				end
				return true
			else
				showQuitscreen = nil
				if WG['guishader'] then
					WG['guishader'].setScreenBlur(false)
				end
				return true
			end

			return true
		end


		if not spec then
			if IsOnRect(x, y, shareIndicatorArea['metal'][1], shareIndicatorArea['metal'][2], shareIndicatorArea['metal'][3], shareIndicatorArea['metal'][4]) then
				draggingShareIndicator = 'metal'
			end
			if IsOnRect(x, y, resbarDrawinfo['metal'].barArea[1], shareIndicatorArea['metal'][2], resbarDrawinfo['metal'].barArea[3], shareIndicatorArea['metal'][4]) then
				draggingShareIndicator = 'metal'
				adjustSliders(x, y)
			end
			if IsOnRect(x, y, shareIndicatorArea['energy'][1], shareIndicatorArea['energy'][2], shareIndicatorArea['energy'][3], shareIndicatorArea['energy'][4]) then
				draggingShareIndicator = 'energy'
			end
			if draggingShareIndicator == nil and showConversionSlider and IsOnRect(x, y, conversionIndicatorArea[1], conversionIndicatorArea[2], conversionIndicatorArea[3], conversionIndicatorArea[4]) then
				draggingConversionIndicator = true
			end
			if draggingConversionIndicator == nil and IsOnRect(x, y, resbarDrawinfo['energy'].barArea[1], shareIndicatorArea['energy'][2], resbarDrawinfo['energy'].barArea[3], shareIndicatorArea['energy'][4]) then
				draggingShareIndicator = 'energy'
				adjustSliders(x, y)
			end
			if draggingShareIndicator or draggingConversionIndicator then
				if playSounds then
					Spring.PlaySoundFile(resourceclick, 0.7, 'ui')
				end
				return true
			end
		end

		if buttonsArea['buttons'] ~= nil then
			for button, pos in pairs(buttonsArea['buttons']) do
				if IsOnRect(x, y, pos[1], pos[2], pos[3], pos[4]) then
					applyButtonAction(button)
					return true
				end
			end
		end
	else
		if showQuitscreen ~= nil and quitscreenArea ~= nil then
			return true
		end
	end
end

function widget:MouseRelease(x, y, button)
	if showQuitscreen ~= nil and quitscreenArea ~= nil then
		return true
	end
	if draggingShareIndicator ~= nil then
		adjustSliders(x, y)
        draggingShareIndicator = nil
	end
	if draggingConversionIndicator ~= nil then
		adjustSliders(x, y)
		draggingConversionIndicator = nil
	end
	
	--if button == 1 then
	--	if buttonsArea['buttons'] ~= nil then	-- reapply again because else the other widgets disable when there is a click outside of their window
	--		for button, pos in pairs(buttonsArea['buttons']) do
	--			if IsOnRect(x, y, pos[1], pos[2], pos[3], pos[4]) then
	--				applyButtonAction(button)
	--			end
	--		end
	--	end
	--end
end

function widget:PlayerChanged()
	spec = spGetSpectatingState()
	checkStatus()
	if displayComCounter then
		countComs(true)
	end
	if spec then
		resbarHover = nil
	end
end


function countComs(forceUpdate)
	-- recount my own ally team coms
	local prevAllyComs = allyComs
	local prevEnemyComs = enemyComs
	allyComs = 0
	local myAllyTeamList = Spring.GetTeamList(myAllyTeamID)
	for _,teamID in ipairs(myAllyTeamList) do
		allyComs = allyComs + Spring.GetTeamUnitDefCount(teamID, armcomDefID) + Spring.GetTeamUnitDefCount(teamID, corcomDefID)
	end

    local newEnemyComCount = Spring.GetTeamRulesParam(myTeamID, "enemyComCount")
    if type(newEnemyComCount) == 'number' then
        enemyComCount = newEnemyComCount
        if enemyComCount ~= prevEnemyComCount then
            comcountChanged = true
            prevEnemyComCount = enemyComCount
        end
    end

	if forceUpdate or allyComs ~= prevAllyComs or enemyComs ~= prevEnemyComs then
		comcountChanged = true
	end

	if comcountChanged then
		updateComs()
	end
end

function widget:UnitCreated(unitID, unitDefID, unitTeam)
	if not isCommander[unitDefID] then
		return
	end
	--record com created
	if select(6,Spring.GetTeamInfo(unitTeam,false)) == myAllyTeamID then
		allyComs = allyComs + 1
	elseif spec then
		enemyComs = enemyComs + 1
	end
	comcountChanged = true
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if not isCommander[unitDefID] then
		return
	end
	--record com died
	if select(6,Spring.GetTeamInfo(unitTeam,false)) == myAllyTeamID then
		allyComs = allyComs - 1
	elseif spec then
		enemyComs = enemyComs - 1
	end
	comcountChanged = true
end


-- used for rejoin progress functionality
function widget:GameProgress (n) -- happens every 300 frames
	serverFrame = n
end

function widget:Initialize()
	gameFrame = Spring.GetGameFrame()
	Spring.SendCommands("resbar 0")

	-- determine if we want to show comcounter
    local allteams   = Spring.GetTeamList()
    local teamN = table.maxn(allteams) - 1               --remove gaia
	if teamN > 2 then
		displayComCounter = true
	end

	WG['topbar'] = {}
	WG['topbar'].showingRejoining = function()
		return showRejoinUI
	end
	WG['topbar'].showingQuit = function()
		return showQuitscreen
	end

	init()

	if gameFrame > 0 then
		widget:GameStart()
	end
end


function widget:Shutdown()
	Spring.SendCommands("resbar 1")
	if dlistBackground ~= nil then
		glDeleteList(dlistWindGuishader)
		glDeleteList(dlistWind1)
		glDeleteList(dlistWind2)
		glDeleteList(dlistComsGuishader)
		glDeleteList(dlistComs1)
		glDeleteList(dlistComs2)
		glDeleteList(dlistButtonsGuishader)
		glDeleteList(dlistButtons1)
		glDeleteList(dlistButtons2)
		glDeleteList(dlistRejoinGuishader)
		glDeleteList(dlistRejoin)
        glDeleteList(dlistQuit)

		for n,_ in pairs(dlistWindText) do
			glDeleteList(dlistWindText[n])
		end
		for n,_ in pairs(dlistResbar['metal']) do
			glDeleteList(dlistResbar['metal'][n])
		end
		for n,_ in pairs(dlistResbar['energy']) do
			glDeleteList(dlistResbar['energy'][n])
		end
		for n,_ in pairs(dlistResValues['metal']) do
			glDeleteList(dlistResValues['metal'][n])
		end
		for n,_ in pairs(dlistResValues['energy']) do
			glDeleteList(dlistResValues['energy'][n])
		end
	end
	gl.DeleteFont(font)
	gl.DeleteFont(font2)
	if WG['guishader'] then
		WG['guishader'].RemoveDlist('topbar_energy')
		WG['guishader'].RemoveDlist('topbar_metal')
		WG['guishader'].RemoveDlist('topbar_wind')
		WG['guishader'].RemoveDlist('topbar_coms')
		WG['guishader'].RemoveDlist('topbar_buttons')
		WG['guishader'].RemoveDlist('topbar_rejoin')
	end
	if WG['tooltip'] ~= nil then
		WG['tooltip'].RemoveTooltip('coms')
		WG['tooltip'].RemoveTooltip('wind')
		WG['tooltip'].RemoveTooltip('rejoin')
		local res = 'energy'
		WG['tooltip'].RemoveTooltip(res..'_share_slider')
		WG['tooltip'].RemoveTooltip(res..'_share_slider2')
		WG['tooltip'].RemoveTooltip(res..'_metalmaker_slider')
		WG['tooltip'].RemoveTooltip(res..'_pull')
		WG['tooltip'].RemoveTooltip(res..'_income')
		WG['tooltip'].RemoveTooltip(res..'_storage')
		WG['tooltip'].RemoveTooltip(res..'_curent')
		res = 'metal'
		WG['tooltip'].RemoveTooltip(res..'_share_slider')
		WG['tooltip'].RemoveTooltip(res..'_share_slider2')
		WG['tooltip'].RemoveTooltip(res..'_pull')
		WG['tooltip'].RemoveTooltip(res..'_income')
		WG['tooltip'].RemoveTooltip(res..'_storage')
		WG['tooltip'].RemoveTooltip(res..'_curent')
	end
	WG['topbar'] = nil
end
