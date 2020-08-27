
if addon.InGetInfo then
	return {
		name    = "Main",
		desc    = "displays a simplae loadbar",
		author  = "jK",
		date    = "2012,2013",
		license = "GPL2",
		layer   = 0,
		depend  = {"LoadProgress"},
		enabled = true,
	}
end

-- for guishader
local function CheckHardware()
	if (not (gl.CopyToTexture ~= nil)) then
		return false
	end
	if (not (gl.RenderToTexture ~= nil)) then
		return false
	end
	if (not (gl.CreateShader ~= nil)) then
		return false
	end
	if (not (gl.DeleteTextureFBO ~= nil)) then
		return false
	end
	if (not gl.HasExtension("GL_ARB_texture_non_power_of_two")) then
		return false
	end
	if Platform ~= nil and Platform.gpuVendor == 'Intel' then
	    return false
	end
	return true
end
local guishader = CheckHardware()

local blurIntensity = 0.004
local blurShader
local screencopy
local blurtex
local blurtex2
local stenciltex
local screenBlur = false
local guishaderRects = {}
local guishaderDlists = {}
local oldvs = 0
local vsx, vsy   = Spring.GetViewGeometry()
local ivsx, ivsy = vsx, vsy

------------------------------------------
------------------------------------------

local showTips = false
if (Spring.GetConfigInt("LoadscreenTips",1) or 1) == 0 then
	showTips = false
end

local lastLoadMessage = ""

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
end

------------------------------------------

-- Random tips we can show
local tips = {
	"Have trouble finding metal spots?\nPress F4 to switch to the metal map.",
	"Queue-up multiple consecutive unit actions by holding SHIFT.",
	"Tweak graphic preferences in options (top right corner of the screen).\nWhen your FPS drops, switch to a lower graphic preset.",
	"Radars are cheap. Make them early in the game to effectively counter initial strikes.",
	"To see detailed info about each unit in-game switch on \"Extensive unit info\" via Options menu",
	"In general, vehicles are a good choice for flat and open battlefields. Bots are better on hills.",
	"For wind generators to be worth building, the average wind speed should be over 7. Current, minimum, and maximum wind speeds are shown to the right of the energy bar.",
	"If your economy is based on wind generators, always build an E storage to have a reserve for when the wind speed drops.",
	"Commanders have a manual Dgun weapon, which can decimate every unit with one blow.\nPress D to quickly initiate aiming.",
	"Spread buildings to prevent chain explosions.\nPress ALT+Z and ALT+X to adjust auto-spacing.",
	"It is effective to move your units in spread formations.\nDrag your mouse while initiating a move order to draw multiple waypoints.",
	"Artillery vehicles can move in reverse if you press 'Ctrl' while giving a command behind it. Use this to keep shooting during a retreat.",
	"T2 factories are expensive. Reclaim your T1 lab for metal to fund it",
	"Air strikes and airdrops may come at any time, always have at least one anti-air unit in your base.",
	"With ~(tilde)+doubleclick you can place a label with text on the map.\n~(tilde)+middle mouse button for an empty label.\n~(tilde)+mouse drag to draw lines",
	"Always check your Com-counter (next to resource bars). If you have the last Commander you better hide it quick!",
	"Expanding territory is essential for gaining economic advantage.\nTry to secure as many metal spots and geothermal vents as you can.",
	"Think in advance about reclaiming metal from wrecks piling up at the front.",
	"Nano towers can be picked up by transporters. This way you can move them where you need more buildpower.",
	"When your excessing energy... build metal makers to convert the excess to metal.",
	"Select all units of the same type by pressing CTRL+Z.",
	"Press CTRL+C to quickly select and center the camera on your Commander.",
	"Think ahead and include anti-air and support units in your armada.",
	"Mastering hotkeys is the key to proficiency.\nUse Z,X,C to quickly cycle between most frequently built structures.",
	"To share resources with teammates:\n - Double-click tank icon next to the player's name to share units\n - Click-drag metal/energy bar next to player's name to send resources.\n - Press H to share an exact amount.",
	"It is efficient to support your lab with constructors increasing its build-power.\nRight click on the factory with a constructor selected to guard (assist) with construction",
	"Remember to separate your highly explosive buildings (like metal makers) from the rest of your base.",
	"Most long-ranged units are very vulnerable in close combat. Always keep a good distance from your targets.",
	"Keep all your builders busy.\nPress CTRL+B to select and center camera on your idle constructor.",
	"The best way to prevent air strikes is building fighters and putting them on PATROL in front of your base.",
	"Use radar jammers to hide your units from enemy radar and hinder artillery strikes.",
	"Cloaking your Commander drains 100E stationary and 1000E when walking (every second)",
	"Combine CLOAK with radar jamming to completely hide your units.",
	"Long-ranged units need scouting for accurate aiming.\nGenerate a constant stream of fast, cheap units for better vision.",
	"You can assign units to groups by pressing CTRL+[num].\nSelect the group using numbers (1-9).",
	"When performing a bombing run fly your fighters first to eliminate enemy's fighter-wall.\nUse FIGHT or PATROL command for more effective engagement.",
	"You can disable enemy's anti-nukes using EMP missiles (built by ARMADA T2 cons).",
	"Don't build too much stuff around your Moho-geothermal powerplants or everything will go boom!",
	"Build long range anti-air on an extended front line to slowly dismantle enemy's fighter-wall.",
	"Your commander's Dgun can be used for insta-killing T3 units. Don't forget to CLOAK first.\nFor quickly cloaking press K.",
	"If you are certain of losing some unit in enemy territory, self-destruct it to prevent him from getting the metal. \nPress CTRL+D to initiate the self-destruct countdown.",
	"Mines are super-cheap and quick to build. Remember to make them away from enemy's line of sight.",
	"Enemy's mines, radars, and jammers may be disabled using the Juno - built by both factions with T1 constructors.",
    "Use Alt+0-9 sets autogroup# for selected unit type(s). Newly built units get added to group# equal to their autogroup#. Alt BACKQUOTE (~) remove units.",
}

-- Random unit descriptions we can show
local titleColor = "\255\215\255\215"
local contentColor = "\255\255\255\255"
local unit_descs = {
	"armadack.dds "..titleColor.."Construction Bot (ARMADA T1)\n"..contentColor.."Slightly slower and weaker than vehicle constructor, this constructor can climb steeper hills, effective in expansion on mountainous terrain.",
	"armadaflea.dds "..titleColor.."Flea (ARMADA T1 Bot)\n"..contentColor.."Supercheap and fast, used for scouting and raiding enemy structures in early-game stages. Avoid laser towers and destroy metal extractors to slow down your foe’s expansion!",
	"armadaham.dds "..titleColor.."Hammer (ARMADA T1 Bot)\n"..contentColor.."Deals significant damage with relatively low cost. Used in large numbers to destroy T1 defences. Combine with resurrection Bots (Rector/Necro) for an almost invincible army.",
	"armadajeth.dds "..titleColor.."Jethro (ARMADA T1 Amphibious Bot)\n"..contentColor.."Amphibious mobile anti-air to take down light aircraft. Always send a few with your army to protect it from EMP drones and gunships.",
	"armadapw.dds "..titleColor.."Peewee (ARMADA T1 Bot)\n"..contentColor.."Cheap and having high top speeds but low health. Can be useful for scouting and taking down unguarded metal extractors and eco. In big numbers used to ambush Commanders.",
	"armadarectr.dds "..titleColor.."Rector (ARMADA T1 Bot)\n"..contentColor.."Fast, light Bot that can ressurect destroyed units. Also can quickly reclaim and repair units. Adds a snowballing effect to your attacks",
	"armadarock.dds "..titleColor.."Rocko (ARMADA T1 Bot)\n"..contentColor.."Light rocket Bot used to push the frontline towards opponent's base. Outranges light laser turrets. Less effective against mobile units. Watch out for A.K./Peewees!",
	"armadawar.dds "..titleColor.."Warrior (ARMADA T1 Bot)\n"..contentColor.."Durable Bot armed with a rapid firing double laser. Has high health and can take down multiple light assault units. Combine with resurrection Bots for quick repairing.",
	"corak.dds "..titleColor.."A.K. (CORTEX T1 Bot)\n"..contentColor.."Light infantry Bot which is cheap and quick to build. It is armed with a light, but precise laser which outranges the PeeWee.",
	"corcrash.dds "..titleColor.."Crasher (CORTEX T1 Amphibious Bot)\n"..contentColor.."Amphibious mobile anti-air (AA) Bot that can easily take down light aircraft. Send a few with your army to protect it from EMP drones and gunships.",
	"corstorm.dds "..titleColor.."Storm (CORTEX T1 Bot)\n"..contentColor.."Light rocket Bot used to push the frontline towards opponent's base. Outranges light laser turrets. Slow but stronger than its ARMADA counterpart.",
	"cornecro.dds "..titleColor.."Necro (CORTEX T1 Bot)\n"..contentColor.."Fast, light Bot that can ressurect destroyed units. Also can quickly reclaim and repair units. Adds a snowballing effect to your attacks.",
	"corthud.dds "..titleColor.."Thud ((CORTEX T1 Bot))\n"..contentColor.."Deals significant damage with relatively low cost. Used in big numbers to destroy T1 defences. Works great for defending mountain tops, as elevation increases their range.",
	"armadafav.dds "..titleColor.."Jeffy (ARMADA T1 Vehicle)\n"..contentColor.."Cheap and the fastest unit in the whole game. Evade laser towers and destroy metal extractors to slow down your foe's expansion.",
	"armadaflash.dds "..titleColor.."Flash (ARMADA T1 Vehicle)\n"..contentColor.."A light, fast tank with close combat rapid fire weapon. Slightly more powerful and faster than Peewee and A.K. on flat terrain.",
	"armadaart.dds "..titleColor.."Shellshocker (ARMADA T1 Vehicle)\n"..contentColor.."Artillery vehicle used to take down T1 defenses, esp. Heavy Laser Turrets. It can outrange all T1 defense towers. Always keep them protected by Stumpies/Flashes.",
	"armadabeaver.dds "..titleColor.."Beaver (ARMADA T1 Amphibious Vehicle)\n"..contentColor.."Amphibious construction vehicle, can travel on land and underwater allowing easy expansion between islands, under rivers and across seas. Can build the amphibious factory.",
	"armadacv.dds "..titleColor.."Construction Vehicle (ARMADA T1)\n"..contentColor.."Able to build basic T1 defences and economy. Slightly faster and stronger than Bot constructor. Each Construction vehicle increases the player's energy and metal storage capacity by 50.",
	"armadajanus.dds "..titleColor.."Janus (ARMADA T1 Vehicle)\n"..contentColor.."Heavy dual rocket tank. Slow speed and fire rate makes it vulnerable to fast units. Its large damage, range and AoE make it useful for destroying Commanders. Requires heavy micro and close attention.",
	"armadamlv.dds "..titleColor.."Podger (ARMADA T1 Vehicle)\n"..contentColor.."Stealthy mine-layer and sweeper. Use the attack command to clear mines in an area. REMEMBER that mines use energy to remain cloaked!",
	"armadapincer.dds "..titleColor.."Pincer (ARMADA T1 Amphibious Vehicle)\n"..contentColor.."Light amphibious tank which can travel on land and underwater. Weaker than most tanks. Avoid direct fire exchange and try to surprise enemies by destroying undefended targets near the shoreline.",
	"armadasam.dds "..titleColor.."Samson (ARMADA T1 Vehicle)\n"..contentColor.."Missile truck that can target land and air units. It has a good range and line-of-sight. Good for supporting or destroying light defences.",
	"armadastump.dds "..titleColor.."Stumpy (ARMADA T1 Vehicle)\n"..contentColor.."A general purpose assault tank. Thanks to good armor, it works great as a brute-force skirmish unit.",
	"corcv.dds "..titleColor.."Construction Vehicle (CORTEX T1)\n"..contentColor.."Able to build basic T1 structures. It is slightly faster and stronger than the Bot constructor, but it can't climb steeper hills.",
	"corfav.dds "..titleColor.."Weasel (CORTEX T1 Vehicle)\n"..contentColor.."Cheap and very fast unit used for scouting and early strikes. Evade laser towers and destroy metal extractors to slow down your foe's expansion.",
	"corgarp.dds "..titleColor.."Garpike (CORTEX T1 Amphibious Vehicle)\n"..contentColor.."Light amphibious tank which can travel on land and underwater. Weaker than most tanks. Avoid direct fire exchange and try to surprise enemies by destroying undefended targets near the shoreline.",
	"corgator.dds "..titleColor.."Instigator (CORTEX T1 Vehicle)\n"..contentColor.."Light, fast moving tank armed with a precise laser weapon. Slower than its ARMADA counterpart - Flash, but it has a greater range, so always try to keep the distance.",
	"corlevlr.dds "..titleColor.."Leveler (CORTEX T1 Vehicle) \n"..contentColor.."Powerful tank armed with an impulse weapon that deals AoE damage and repels light units. It makes it highly effective against swarmadas of peewees, flashes etc.",
	"cormist.dds "..titleColor.."Slasher (CORTEX T1 Vehicle)\n"..contentColor.."Long-range light missile truck. Able to outrange most T1 defensive units. They can also serve as basic anti-air defense. Very ineffective in close combat.",
	"cormlv.dds "..titleColor.."Spoiler (CORTEX T1 Vehicle)\n"..contentColor.."Stealthy mine-layer and minesweeper. Use the attack command to clear mines in an area. REMEMBER that mines use energy to remain cloaked!",
	"cormuskrat.dds "..titleColor.."Muskrat (CORTEX T1 Amphibious Vehicle)\n"..contentColor.."Construction vehicle, which can travel on land and underwater. Builds basic defenses and economy for both land and sea. Useful for expansion in water when you don't have ships.",
	"corraid.dds "..titleColor.."Raider (CORTEX T1 Vehicle)\n"..contentColor.."A general purpose assault tank. Thanks to good armadaor, it works great as a brute-force skirmish unit.",
	"corwolv.dds "..titleColor.."Wolverine (CORTEX T1 Vehicle)\n"..contentColor.."The Wolverine is an artillery vehicle used to take down T1 defenses, especially Heavy Laser Turrets. Helpless in close quarters combat.",
	"armadaatlas.dds "..titleColor.."Atlas ARMADA T1 Aircraft\n"..contentColor.."Transportation unit. It can pick up all T1 land based units and smaller T2 units. Cannot load units like the Fatboy or Goliath. Can be used for transporting nano turrets too.",
	"armadaca.dds "..titleColor.."Construction Aircraft (ARMADA T1)\n"..contentColor.."Can make basic T1 defences, economy structures and most importantly the T2 Aircraft Plant. Useful for building and reclaiming in remote areas.",
	"armadafig.dds "..titleColor.."Freedom Fighter (ARMADA T1 Aircraft)\n"..contentColor.."A fighter jet that is designed for eliminating aircraft. Always put your fighters on patrol in front of your base, so they attack any incoming aircraft.",
	"armadakam.dds "..titleColor.."Banshee (ARMADA T1 Aircraft)\n"..contentColor.."A light gunship that can fire at surface units. It has very weak armadaor, so always send them in groups and avoid anti-air (AA). It is best as a weapon of surprise.",
	"armadapeep.dds "..titleColor.."Peeper (ARMADA T1 Aircraft)\n"..contentColor.."A cheap and fast moving air scout. Its weapon is its huge line of sight. It is used to gain intelligence on what your enemy is planning, and where he keeps his most important units.",
	"armadathund.dds "..titleColor.."Thunder (ARMADA T1 Aircraft)\n"..contentColor.."A bomber designed mainly for destroying buildings. A little bit weaker than its CORTEX counterpart (Shadow). It can strike every 9 seconds. Press 'A' for attack and drag your RMB to execute a carpet bombing.",
	"corca.dds "..titleColor.."Construction Aircraft (CORTEX T1)\n"..contentColor.."Can make basic T1 defences, economy structures and most importantly the T2 Aircraft Plant. Useful for building and reclaiming in remote areas.",
	"corshad.dds "..titleColor.."Shadow (CORTEX T1 Aircraft)\n"..contentColor.."A bomber designed mainly for destroying buildings. A little bit stronger than its ARMADA counterpart (Thunder). It can strike every 9 seconds. Press 'A' for attack and drag your RMB to execute carpet bombing.",
	"corvalk.dds "..titleColor.."Valkyrie (CORTEX T1 Aircraft)\n"..contentColor.."Airborne transportation unit. It can pick up all T1 land based units and smaller T2 units. Used for unexpected unit drops bypassing enemy's defense line.",
	"corfink.dds "..titleColor.."Fink (CORTEX T1 Aircraft)\n"..contentColor.."A cheap and fast moving air scout. Its weapon is a huge line of sight. It is used to gain intelligence on what your enemy is planning, and where he keeps his most important units.",
	"corbw.dds "..titleColor.."Bladewing (CORTEX T1 Aircraft)\n"..contentColor.."Small, fast drones armed with EMP lasers. They serve as a great support for your attacks and can quickly turn the tide of war.",
	"corveng.dds "..titleColor.."Avenger(CORTEX T1 Aircraft)\n"..contentColor.."A fighter jet that is designed for eliminating aircraft. Always put your fighters on patrol in front of your base, so they attack any incoming aircraft.",
}

local quotes = {
	{"The two most powerful warriors are patience and time.", "Leo Tolstoy"},
	{"Know thy self, know thy enemy. A thousand battles, a thousand victories.", "Sun Tzu"},
	{"People never lie so much as after a hunt, during a war or before an election.", "Otto von Bismarck"},
	{"The best weapon against an enemy is another enemy.", "Friedrich Nietzsche"},
	{"Thus, what is of supreme importance in war is to attack the enemy's strategy.", "Sun Tzu"},
	{"Great is the guilt of an unnecessary war.", "John Adams"},
	{"I have never advocated war except as a means of peace.", "Ulysses S Grant"},
	{"War is not only a matter of equipment, artillery, group troops or air force; it is largely a matter of spirit, or morale.", "Chiang Kai-Shek"},
	{"In nuclear war all men are cremated equal.", "Dexter Gordon"},
	{"There are no absolute rules of conduct, either in peace or war. Everything depends on circumstances.", "Leon Trotsky"},
	{"Weapons are an important factor in war, but not the decisive one; it is man and not materials that counts.", "Mao Zedong"},
	{"To secure peace is to prepare for war.", "Carl von Clausewitz"},
	{"Quickness is the essence of the war.", "Sun Tzu"},
	{"The whole art of war consists of guessing at what is on the other side of the hill.", "Arthur Wellesley"},
	{"War is a game that is played with a smile. If you can't smile, grin. If you can't grin, keep out of the way till you can.", "Winston Churchill"},
	{"War can only be abolished through war, and in order to get rid of the gun it is necessary to take up the gun.", "Mao Zedong"},
	{"The quickest way of ending a war is to lose it.", "George Orwell"},
	{"Heaven cannot brook two suns, nor earth two masters.", "Alexander the Great"},
	{"People always make war when they say they love peace.", "D H Lawrence"},
	{"This is totally awesome. Wow. great job guys!!", "Chris Taylor"},
	{"War is like love; it always finds a way.", "Bertolt Brecht"},
	{"Ten soldiers wisely led will beat a hundred without a head.", "Euripides"},
	{"In war there is no prize for runner-up.", "Lucius Annaeus Seneca"},
	{"I think there should be holy war against yoga classes.", "Werner herzog"},
	{"An army marches on its stomach.", "Napoleon Bonaparte"},
	{"It is fatal to enter any war without the will to win it.", "Douglas MacArthur"},
	{"You cannot simultaneously prevent and prepare for war.", "Albert Einstein"},
	{"Try not to become a man of success, but rather try to become a man of value.", "Albert Einstein"},
	{"Every failure is a step to success.", "William Whewell"},
	{"If everyone is moving forward together, then success takes care of itself.", "Henry Ford"},
	{"Failure is success if we learn from it.", "Malcolm Forbes"},
	{"It is no use saying, 'We are doing our best.' You have got to succeed in doing what is necessary.", "Winston Churchill"},
	{"Knowledge will give you power, but character respect.", "Bruce Lee"},
	{"In time of war the laws are silent.", "Marcus Tullius Cicero"},
	{"War is a contagion.", "Franklin D Roosevelt"},
	{"War is the unfolding of miscalculations.", "Barbara Tuchman"},
	{"Girl power is about loving yourself and having confidence and strength from within, so even if you're not wearing a sexy outfit, you feel sexy.", "Nicole Scherzinger"},
	{"The most common way people give up their power is by thinking they don't have any.", "Alice Walker"},
	{"Mastering others is strength. Mastering yourself is true power.", "Lao Tzu"},
	{"There is more power in unity than division.", "Emmanuel Cleaver"},
	{"I am not afraid of an army of lions led by a sheep; I am afraid of an army of sheep led by a lion.", "Alexander the Great"},
	{"The power of an air force is terrific when there is nothing to oppose it.", "Winston Churchill"},
	{"You must never underestimate the power of the eyebrow.", "Jack Black"},
	{"Common sense is not so common.", "Voltaire"},
	{"If everyone is thinking alike, then somebody isn't thinking.", "George S Patton"},
	{"Ignorance is bold and knowledge reserved.", "Thucydides"},
	{"Don't find fault, find a remedy.", "Henry Ford"},
	{"There is nothing impossible to him who will try.", "Alexander the Great"},
	{"Peace is produced by war", "Pierre Corneille"},
}


-- Since math.random is not random and always the same, we save a counter to a file and use that.
if showTips then
	local filename = "LuaUI/Config/randomseed.txt"
	local k = os.time() % 1500
	if VFS.FileExists(filename) then
		k = tonumber(VFS.LoadFile(filename))
		if not k then k = 0 end
	end
	k = k + 1
	local file = assert(io.open(filename,'w'), "Unable to save latest randomseed from "..filename)
	if file then
		file:write(k)
		file:close()
		file = nil
	end

	local random_tip_or_desc = unit_descs[((k/2) % #unit_descs) + 1]
	if k%2 == 1 then
		random_tip_or_desc = tips[((math.ceil(k/2)) % #tips) + 1]
	--elseif k%3 == 2 then
	--	random_tip_or_desc = quotes[((math.ceil(k/3)) % #quotes) + 1]
	end
end

local defaultFont = 'Poppins-Regular.otf'
local fontfile = 'fonts/'..Spring.GetConfigString("bar_font", defaultFont)
if not VFS.FileExists(fontfile) then
	Spring.SetConfigString('bar_font', defaultFont)
	fontfile = 'fonts/'..defaultFont
end
local defaultFont2 = 'Exo2-SemiBold.otf'
local fontfile2 = 'fonts/'..Spring.GetConfigString("bar_font2", defaultFont2)
if not VFS.FileExists(fontfile2) then
	Spring.SetConfigString('bar_font2', defaultFont2)
	fontfile2 = 'fonts/'..defaultFont2
end
local fontfile3 = 'fonts/unlisted/Xolonium.otf'

local vsx,vsy = Spring.GetViewGeometry()
local fontScale = (0.5 + (vsx*vsy / 5700000))/2
local font = gl.LoadFont(fontfile, 128*fontScale, 32*fontScale, 1.4)
local font2 = gl.LoadFont(fontfile2, 128*fontScale, 32*fontScale, 1.4)
local font3 = gl.LoadFont(fontfile3, 128*fontScale, 32*fontScale, 1.25)
local loadedFontSize = 128*fontScale


function DrawStencilTexture()
    if next(guishaderRects) or next(guishaderDlists) then
		if stenciltex then
			gl.DeleteTextureFBO(stenciltex)
		end
		stenciltex = gl.CreateTexture(vsx, vsy, {
			border = false,
			min_filter = GL.NEAREST,
			mag_filter = GL.NEAREST,
			wrap_s = GL.CLAMP,
			wrap_t = GL.CLAMP,
			fbo = true,
		})
    else
        gl.RenderToTexture(stenciltex, gl.Clear, GL.COLOR_BUFFER_BIT ,0,0,0,0)
        return
    end

    gl.RenderToTexture(stenciltex, function()
        gl.Clear(GL.COLOR_BUFFER_BIT,0,0,0,0)
        gl.PushMatrix()
        gl.Translate(-1,-1,0)
        gl.Scale(2/vsx,2/vsy,0)
		for _,rect in pairs(guishaderRects) do
			gl.Rect(rect[1],rect[2],rect[3],rect[4])
		end
		for _,dlist in pairs(guishaderDlists) do
			gl.CallList(dlist)
		end
        gl.PopMatrix()
    end)
end

function CreateShaders()

    if (blurShader) then
        gl.DeleteShader(blurShader or 0)
    end

    -- create blur shaders
    blurShader = gl.CreateShader({
        fragment = [[
		#version 150 compatibility
        uniform sampler2D tex2;
        uniform sampler2D tex0;
        uniform float intensity;

        void main(void)
        {
            vec2 texCoord = vec2(gl_TextureMatrix[0] * gl_TexCoord[0]);
            float stencil = texture2D(tex2, texCoord).a;
            if (stencil<0.01)
            {
                gl_FragColor = texture2D(tex0, texCoord);
                return;
            }
            gl_FragColor = vec4(0.0,0.0,0.0,1.0);

            float sum = 0.0;
            for (int i = -1; i <= 1; ++i)
                for (int j = -1; j <= 1; ++j) {
                    vec2 samplingCoords = texCoord + vec2(i, j) * intensity;
                    float samplingCoordsOk = float( all( greaterThanEqual(samplingCoords, vec2(0.0)) ) && all( lessThanEqual(samplingCoords, vec2(1.0)) ) );
                    gl_FragColor.rgb += texture2D(tex0, samplingCoords).rgb * samplingCoordsOk;
                    sum += samplingCoordsOk;
            }
            gl_FragColor.rgb /= sum;
        }
    ]],

        uniformInt = {
            tex0 = 0,
            tex2 = 2,
        },
        uniformFloat = {
            intensity = blurIntensity,
        }
    })

    if (blurShader == nil) then
        --Spring.Log(widget:GetInfo().name, LOG.ERROR, "guishader blurShader: shader error: "..gl.GetShaderLog())
        --widgetHandler:RemoveWidget(self)
        return false
    end

    -- create blurtextures
    screencopy = gl.CreateTexture(vsx, vsy, {
        border = false,
        min_filter = GL.NEAREST,
        mag_filter = GL.NEAREST,
    })
    blurtex = gl.CreateTexture(ivsx, ivsy, {
        border = false,
        wrap_s = GL.CLAMP,
        wrap_t = GL.CLAMP,
        fbo = true,
    })
    blurtex2 = gl.CreateTexture(ivsx, ivsy, {
        border = false,
        wrap_s = GL.CLAMP,
        wrap_t = GL.CLAMP,
        fbo = true,
    })

    intensityLoc = gl.GetUniformLocation(blurShader, "intensity")
end

local function DrawRectRound(px,py,sx,sy,cs, tl,tr,br,bl)
	local csY = cs * (vsx / vsy)

	gl.TexCoord(0.8,0.8)
	if c2 then
		gl.Color(c1[1],c1[2],c1[3],c1[4])
	end
	gl.Vertex(px+cs, py, 0)
	gl.Vertex(sx-cs, py, 0)
	if c2 then
		gl.Color(c2[1],c2[2],c2[3],c2[4])
	end
	gl.Vertex(sx-cs, sy, 0)
	gl.Vertex(px+cs, sy, 0)

	if c2 then
		gl.Color(c1[1],c1[2],c1[3],c1[4])
	end
	gl.Vertex(px, py+csY, 0)
	gl.Vertex(px+cs, py+csY, 0)
	if c2 then
		gl.Color(c2[1],c2[2],c2[3],c2[4])
	end
	gl.Vertex(px+cs, sy-csY, 0)
	gl.Vertex(px, sy-csY, 0)

	if c2 then
		gl.Color(c1[1],c1[2],c1[3],c1[4])
	end
	gl.Vertex(sx, py+csY, 0)
	gl.Vertex(sx-cs, py+csY, 0)
	if c2 then
		gl.Color(c2[1],c2[2],c2[3],c2[4])
	end
	gl.Vertex(sx-cs, sy-csY, 0)
	gl.Vertex(sx, sy-csY, 0)

	local offset = 0.07		-- texture offset, because else gaps could show

	-- bottom left
	if c2 then
		gl.Color(c1[1],c1[2],c1[3],c1[4])
	end
	if ((py <= 0 or px <= 0)  or (bl ~= nil and bl == 0)) and bl ~= 2   then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(px, py, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(px+cs, py, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(px+cs, py+csY, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(px, py+csY, 0)
	-- bottom right
	if ((py <= 0 or sx >= vsx) or (br ~= nil and br == 0)) and br ~= 2   then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(sx, py, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(sx-cs, py, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(sx-cs, py+csY, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(sx, py+csY, 0)
	-- top left
	if c2 then
		gl.Color(c2[1],c2[2],c2[3],c2[4])
	end
	if ((sy >= vsy or px <= 0) or (tl ~= nil and tl == 0)) and tl ~= 2   then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(px, sy, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(px+cs, sy, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(px+cs, sy-csY, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(px, sy-csY, 0)
	-- top right
	if ((sy >= vsy or sx >= vsx)  or (tr ~= nil and tr == 0)) and tr ~= 2   then o = 0.5 else o = offset end
	gl.TexCoord(o,o)
	gl.Vertex(sx, sy, 0)
	gl.TexCoord(o,1-offset)
	gl.Vertex(sx-cs, sy, 0)
	gl.TexCoord(1-offset,1-offset)
	gl.Vertex(sx-cs, sy-csY, 0)
	gl.TexCoord(1-offset,o)
	gl.Vertex(sx, sy-csY, 0)
end
function RectRound(px,py,sx,sy,cs, tl,tr,br,bl, c1,c2)		-- (coordinates work differently than the RectRound func in other widgets)
	gl.Texture(":n:luaui/Images/bgcorner.png")
	gl.BeginEnd(GL.QUADS, DrawRectRound, px,py,sx,sy,cs, tl,tr,br,bl, c1,c2)
	gl.Texture(false)
end

function gradienth(px,py,sx,sy, c1,c2)
	gl.Color(c1)
	gl.Vertex(sx, sy, 0)
	gl.Vertex(sx, py, 0)
	gl.Color(c2)
	gl.Vertex(px, py, 0)
	gl.Vertex(px, sy, 0)
end


local lastLoadMessage = ""
local lastProgress = {0, 0}

local progressByLastLine = {
	["Parsing Map Information"] = {0, 20},
	["Loading Weapon Definitions"] = {10, 50},
	["Loading LuaRules"] = {40, 80},
	["Loading LuaUI"] = {70, 95},
	["Finalizing"] = {100, 100}
}
for name,val in pairs(progressByLastLine) do
	progressByLastLine[name] = {val[1]*0.01, val[2]*0.01}
end

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
	if message:find("Path") then -- pathing has no rigid messages so cant use the table
		lastProgress = {0.8, 1.0}
	end
	lastProgress = progressByLastLine[message] or lastProgress
end

function addon.DrawLoadScreen()
	local loadProgress = SG.GetLoadProgress()
	if loadProgress == 0 then
		loadProgress = lastProgress[1]
	else
		loadProgress = math.min(math.max(loadProgress, lastProgress[1]), lastProgress[2])
	end

	local vsx, vsy = gl.GetViewSizes()

	-- draw progressbar
	local hbw = 3.5/vsx
	local vbw = 3.5/vsy
	local hsw = 0.2
	local vsw = 0.2
	local yPos =  0.125 --0.054
	local yPosTips = yPos + 0.1245
	local loadvalue = 0.2 + (math.max(0, loadProgress) * 0.6)

	if not showTips then
		yPos = 0.165
		yPosTips = yPos
    end


    --bar bg
    local paddingH = 0.004
    local paddingW = paddingH * (vsy/vsx)

	if guishader then
		if not blurShader then
			CreateShaders()

			-- somehow using this method makes all rectround not have corners anymore :/
			--if guishaderDlists['loadprocess'] then
			--	gl.DeleteList(guishaderDlists['loadprocess'])
			--end
			--guishaderDlists['loadprocess'] = gl.CreateList(function()
			--	RectRound((0.2-paddingW)*vsx, (yPos-0.045-paddingH)*vsy, (0.8+paddingW)*vsx, (yPosTips+paddingH)*vsy, 0.007*vsx)
			--end)

			guishaderRects['loadprocess1'] = {(0.2+paddingW)*vsx,(yPos-0.045-paddingH)*vsy,(0.8-paddingW)*vsx,(yPosTips+paddingH)*vsy}
			guishaderRects['loadprocess2'] = {(0.2)*vsx,(yPos-0.045)*vsy,(0.8)*vsx,yPosTips*vsy}
			guishaderRects['loadprocess3'] = {(0.2-paddingW)*vsx,(yPos-0.045+paddingH)*vsy,(0.8+paddingW)*vsx,(yPosTips-paddingH)*vsy}
			DrawStencilTexture()
		end

		if next(guishaderRects) or next(guishaderDlists) then

			gl.Texture(false)
			gl.Color(1,1,1,1)
			gl.Blending(false)

			gl.CopyToTexture(screencopy, 0, 0, 0, 0, vsx, vsy)
			gl.Texture(screencopy)
			gl.TexRect(0,1,1,0)
			gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)

			gl.UseShader(blurShader)
			gl.Uniform(intensityLoc, blurIntensity)
			gl.Texture(2,stenciltex)
			gl.Texture(2,false)

			gl.Texture(blurtex)
			gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
			gl.Texture(blurtex2)
			gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
			gl.UseShader(0)

			if blurIntensity >= 0.0016 then
				gl.UseShader(blurShader)
				gl.Uniform(intensityLoc, blurIntensity*0.5)

				gl.Texture(blurtex)
				gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
				gl.Texture(blurtex2)
				gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
				gl.UseShader(0)
			end

			if blurIntensity >= 0.003 then
				gl.UseShader(blurShader)
				gl.Uniform(intensityLoc, blurIntensity*0.5)

				gl.Texture(blurtex)
				gl.RenderToTexture(blurtex2, gl.TexRect, -1,1,1,-1)
				gl.Texture(blurtex2)
				gl.RenderToTexture(blurtex, gl.TexRect, -1,1,1,-1)
				gl.UseShader(0)
			end

			gl.Texture(blurtex)
			gl.TexRect(0,1,1,0)
			gl.Texture(false)

			gl.Blending(true)
		end
	end

	if blurShader then
		gl.Color(0.1,0.1,0.1,0.66)
	else
		gl.Color(0.085,0.085,0.085,0.925)
	end
	RectRound(0.2-paddingW,yPos-0.045-paddingH,0.8+paddingW,yPosTips+paddingH,0.006)

	if blurShader then
		gl.Color(0,0,0,0.45)
	else
		gl.Color(0,0,0,0.75)
	end
	RectRound(0.2-paddingW,yPos-0.045-paddingH,0.8+paddingW,yPos+paddingH,0.006)


    if loadvalue > 0.215 then
	    -- loadvalue
        gl.Color(0.4-(loadProgress/7),loadProgress*0.4,0,0.4)
        RectRound(0.2,yPos-0.045,loadvalue,yPos,0.0045)

        -- loadvalue gradient
        gl.Texture(false)
        gl.BeginEnd(GL.QUADS, gradienth, 0.2+0.012, yPos-0.045, loadvalue-0.012, yPos, {1-(loadProgress/3)+0.2,loadProgress+0.2,0+0.08,0.13}, {0,0,0,0.13})
		gl.Color(1-(loadProgress/3)+0.2,loadProgress+0.2,0+0.08,0.13)
		RectRound(loadvalue-0.012,yPos-0.045,loadvalue,yPos,0.004, 0,1,1,0)
		gl.Color(0,0,0,0.13)
		RectRound(0.2,yPos-0.045,0.212,yPos,0.004, 1,0,0,1)

        -- loadvalue inner glow
        gl.Color(1-(loadProgress/3.5)+0.15,loadProgress+0.15,0+0.045,0.03)
        gl.Texture(":n:luaui/Images/barglow-center.png")
        gl.TexRect(0.2,yPos-0.045,loadvalue,yPos)

        -- loadvalue glow
        local glowSize = 0.0455
        gl.Color(1-(loadProgress/3)+0.15,loadProgress+0.15,0+0.045,0.07)
        gl.Texture(":n:luaui/Images/barglow-center.png")
        gl.TexRect(0.2,	yPos-0.045-glowSize,	loadvalue,	yPos+glowSize)

        gl.Texture(":n:luaui/Images/barglow-edge.png")
        gl.TexRect(0.2-(glowSize*1.3), yPos-0.045-glowSize, 0.2, yPos+glowSize)
        gl.TexRect(loadvalue+(glowSize*1.3), yPos-0.045-glowSize, loadvalue, yPos+glowSize)
    end

	-- progressbar text
	gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)
		local barTextSize = vsy * 0.026
		--font:Print(lastLoadMessage, vsx * 0.5, vsy * 0.3, 50, "sc")
		--font:Print(Game.gameName, vsx * 0.5, vsy * 0.95, vsy * 0.07, "sca")
		font:Print(lastLoadMessage, vsx * 0.21, vsy * (yPos-0.015), barTextSize * 0.67, "oa")
		if loadProgress>0 then
			font2:Print(("%.0f%%"):format(loadProgress * 100), vsx * 0.5, vsy * (yPos-0.03), barTextSize, "oc")
		else
			font:Print("Loading...", vsx * 0.5, vsy * (yPos-0.0285), barTextSize, "oc")
		end

		-- game name
		font3:Print(Game.gameName, vsx * 0.5, vsy * (yPos-0.113), barTextSize*1.44, "co")
	gl.PopMatrix()


	if showTips then
		-- In this format, there can be an optional image before the tip/description.
		-- Any image ends in .dss, so if such a text piece is found, we extract that and show it as an image.
		local text_to_show = random_tip_or_desc
		yPos = yPosTips
		if random_tip_or_desc[2] then
			text_to_show = random_tip_or_desc[1]
		else
			i, j = string.find(random_tip_or_desc, ".dds")
		end
		local numLines = 1
		local image_text = nil
		local fontSize = barTextSize * 0.77
		local image_size = 0.0485
		local height = 0.123

		if i ~= nil then
			text_to_show = string.sub(text_to_show, j+2)
			local maxWidth = ((0.58-image_size-0.012) * vsx) * (loadedFontSize/fontSize)
			text_to_show, numLines = font:WrapText(text_to_show, maxWidth)
		else
			local maxWidth = (0.585 * vsx) * (loadedFontSize/fontSize)
			text_to_show, numLines = font:WrapText(text_to_show, maxWidth)
		end

		-- Tip/unit description
		-- Background
		--gl.Color(1,1,1,0.033)
		--RectRound(0.2,yPos-height,0.8,yPos,0.005)

		-- Text
		gl.PushMatrix()
		gl.Scale(1/vsx,1/vsy,1)

		if i ~= nil then
			image_text = string.sub(random_tip_or_desc, 0, j)
			gl.Texture(":n:unitpics/" .. image_text)
			gl.Color(1.0,1.0,1.0,0.8)
			gl.TexRect(vsx * 0.21, vsy*(yPos-0.015), vsx*(0.21+image_size), (vsy*(yPos-0.015))-(vsx*image_size),false,true)
			font:Print(text_to_show, vsx * (0.21+image_size+0.012) , vsy * (yPos-0.0175), fontSize, "oa")
		else
			font:Print(text_to_show, vsx * 0.21, vsy * (yPos-0.0175), fontSize, "oa")
		end

		if random_tip_or_desc[2] then
			font:Print('\255\255\222\155'..random_tip_or_desc[2], vsx * 0.79, (vsy * ((yPos-0.0175)-height)) +(fontSize*2.66) , fontSize, "oar")
		end
		gl.PopMatrix()
	end
end


function addon.MousePress(...)
	--Spring.Echo(...)
end


function addon.Shutdown()
	if guishader then
		for id, dlist in pairs(guishaderDlists) do
			gl.DeleteList(dlist)
		end
		if blurtex then
			gl.DeleteTextureFBO(blurtex)
			gl.DeleteTextureFBO(blurtex2)
			gl.DeleteTextureFBO(stenciltex)
		end
		gl.DeleteTexture(screencopy or 0)
		if (gl.DeleteShader) then
			gl.DeleteShader(blurShader or 0)
		end
		blurShader = nil
	end
	gl.DeleteFont(font)
end
