-- game_micro_wars
-- Micro Wars game mode: preset armies, configurable victory, on-screen round timer.

local modOptions = Spring.GetModOptions() or {}

-- modoption values from the host script can arrive as strings ("0"/"1"); parse them safely.
-- (In Lua 0 and "0" are truthy, so a naive `x or false` would read an off-switch as on.)
local function asBool(v, default)
    if v == nil then return default end
    if v == false or v == 0 or v == "0" or v == "false" then return false end
    return true
end

local microWarsEnabled = asBool(modOptions.micro_wars_enabled, false)
if not microWarsEnabled then
    return false  -- inert unless Micro Wars is enabled (applies in both synced and unsynced)
end

-- Settings (set via lobby modoptions or the host script's [MODOPTIONS])
local roundTimeMin   = tonumber(modOptions.round_time) or 5
local roundTime      = math.floor(roundTimeMin * 60 * 30)          -- frames; 0 = no round timer
local wipeoutOnly    = asBool(modOptions.micro_wars_wipeout_only, false)  -- only win by destroying the enemy army
local earlyPct       = tonumber(modOptions.end_round_early_percentage) or 50
local unitsPerRoundMultiplier = tonumber(modOptions.units_per_round) or 1
local selectedComposition = modOptions.preset_army_compositions or "Basic T1 - T3"
local showTimer      = asBool(modOptions.micro_wars_show_timer, true)
local despawnUnits   = asBool(modOptions.micro_wars_despawn, true)
local commanderRadar = asBool(modOptions.micro_wars_commander_radar, false)  -- 50x commander radar

-- Touchdown mode: hold units in the enemy starter zone to score (tug-of-war victory).
local touchdownMode       = asBool(modOptions.micro_wars_touchdown, false)
local touchdownWinScore   = tonumber(modOptions.touchdown_win_score) or 1000
local touchdownZoneRadius = tonumber(modOptions.touchdown_zone_radius) or 400

-- Reinforcements: a starting force plus periodic waves spawned beside each commander.
-- Lists are written as "unitname count, unitname count" (e.g. "armpw 10,armrock 5,armwar 2").
local reinforcementInterval = tonumber(modOptions.reinforcement_interval) or 0   -- seconds; 0 = off

local function parseUnitList(str)
    local list = {}
    if not str or str == "" then return list end
    for entry in string.gmatch(str, "[^,]+") do
        local name, count = string.match(entry, "^%s*([%w_]+)%s+(%d+)%s*$")
        if name and count then
            list[#list + 1] = { unitName = name, count = tonumber(count) }
        end
    end
    return list
end

local reinforcementInitial = parseUnitList(modOptions.reinforcement_initial)
local reinforcementWave    = parseUnitList(modOptions.reinforcement_wave)

function gadget:GetInfo()
    return {
        name    = "Micro Wars",
        desc    = "Micro Wars: preset armies, configurable victory, round timer",
        author  = "Soareverix",
        date    = "2024",
        layer   = 0,
        enabled = true,
    }
end

if gadgetHandler:IsSyncedCode() then
--------------------------------------------------------------------------------
-- SYNCED: game logic
--------------------------------------------------------------------------------

local teams = Spring.GetTeamList()
local gaiaTeamID = Spring.GetGaiaTeamID()

-- Custom unit spawn configuration per round
local unitSpawnConfigs = {
    ["Basic T1 - T3"] = {  -- Already provided in your original script
        [1] = {
			{unitName = "armpw", count = 20},    -- Pawns
			{unitName = "armrock", count = 10},  -- Rocket Bots
			{unitName = "corcrash", count = 2},  -- Trashers
			{unitName = "legmos", count = 2},   -- Mosquitos
		},
		[2] = {
			{unitName = "armpw", count = 30},    -- Pawns
			{unitName = "armrock", count = 15},  -- Rocket Bots
			{unitName = "corcrash", count = 3},  -- Trashers
			{unitName = "corshad", count = 3},   -- Whirlwinds
			{unitName = "armsam", count = 2},    -- Missile Trucks
		},
		[3] = {
			{unitName = "armpw", count = 40},    -- Pawns
			{unitName = "armrock", count = 20},  -- Rocket Bots
			{unitName = "corcrash", count = 4},  -- Trashers
			{unitName = "corshad", count = 4},   -- Whirlwinds
			{unitName = "armsam", count = 4},    -- Missile Trucks
		},
		[4] = {
			{unitName = "armpw", count = 50},    -- Pawns
			{unitName = "armrock", count = 25},  -- Rocket Bots
			{unitName = "corcrash", count = 5},  -- Trashers
			{unitName = "corshad", count = 5},   -- Whirlwinds
			{unitName = "armsam", count = 6},    -- Missile Trucks
			{unitName = "corraid", count = 2},   -- Brutes
		},
		[5] = {
			{unitName = "armpw", count = 60},    -- Pawns
			{unitName = "armrock", count = 30},  -- Rocket Bots
			{unitName = "corcrash", count = 6},  -- Trashers
			{unitName = "corshad", count = 6},   -- Whirlwinds
			{unitName = "armsam", count = 8},    -- Missile Trucks
			{unitName = "corspec", count = 4},   -- Deceivers
		},
		[6] = {
			{unitName = "armpw", count = 70},    -- Pawns
			{unitName = "armrock", count = 35},  -- Rocket Bots
			{unitName = "corcrash", count = 7},  -- Trashers
			{unitName = "corshad", count = 7},   -- Whirlwinds
			{unitName = "armsam", count = 10},   -- Missile Trucks
			{unitName = "corraid", count = 4},   -- Brutes
			{unitName = "corspec", count = 4},   -- Deceivers
		},
		[7] = {
			{unitName = "armpw", count = 80},    -- Pawns
			{unitName = "armrock", count = 40},  -- Rocket Bots
			{unitName = "corcrash", count = 8},  -- Trashers
			{unitName = "corshad", count = 8},   -- Whirlwinds
			{unitName = "armsam", count = 12},   -- Missile Trucks
			{unitName = "corraid", count = 6},   -- Brutes
			{unitName = "corcat", count = 2},    -- Heavy Rocket Bot
		},
		[8] = {
			{unitName = "armpw", count = 90},    -- Pawns
			{unitName = "armrock", count = 45},  -- Rocket Bots
			{unitName = "corcrash", count = 9},  -- Trashers
			{unitName = "corshad", count = 9},   -- Whirlwinds
			{unitName = "armsam", count = 14},   -- Missile Trucks
			{unitName = "corraid", count = 8},   -- Brutes
			{unitName = "corspec", count = 8},   -- Deceivers
			{unitName = "corcat", count = 4},    -- Heavy Rocket Bot
		},
		[9] = {
			{unitName = "armpw", count = 100},   -- Pawns
			{unitName = "armrock", count = 50},  -- Rocket Bots
			{unitName = "corcrash", count = 10}, -- Trashers
			{unitName = "corshad", count = 10},  -- Whirlwinds
			{unitName = "armsam", count = 16},   -- Missile Trucks
			{unitName = "corraid", count = 10},  -- Brutes
			{unitName = "corspec", count = 10},  -- Deceivers
			{unitName = "corcat", count = 6},    -- Heavy Rocket Bot
		},
		[10] = {
			{unitName = "armpw", count = 120},   -- Pawns
			{unitName = "armrock", count = 60},  -- Rocket Bots
			{unitName = "corcrash", count = 12}, -- Trashers
			{unitName = "corshad", count = 12},  -- Whirlwinds
			{unitName = "armsam", count = 20},   -- Missile Trucks
			{unitName = "corraid", count = 12},  -- Brutes
			{unitName = "corspec", count = 12},  -- Deceivers
			{unitName = "corcat", count = 8},    -- Heavy Rocket Bot
			{unitName = "corkarg", count = 1},   -- Karganeth (All-Terrain Assault Mech)
		}
    },
	
    ["Raining Hell"] = {
		[1] = {
			{unitName = "armrock", count = 15},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 10},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 10},  -- Janus (Arm Janus)
		},
		[2] = {
			{unitName = "armrock", count = 15},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 10},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 10},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 15},  -- Trashers (Cor Crash)
		},
		[3] = {
			{unitName = "armrock", count = 25},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 15},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 15},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 15},  -- Trashers (Cor Crash)
		},
		[4] = {
			{unitName = "armrock", count = 25},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 15},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 15},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 15},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 15},    -- Arbiters (Cor Hrk)
		},
		[5] = {
			{unitName = "armrock", count = 25},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 15},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 15},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 20},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 15},    -- Arbiters (Cor Hrk)
			{unitName = "corape", count = 5},     -- Wasps (Cor Ape)
		},
		[6] = {
			{unitName = "armrock", count = 25},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 15},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 15},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 20},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 15},    -- Arbiters (Cor Hrk)
			{unitName = "corape", count = 5},     -- Wasps (Cor Ape)
			{unitName = "corban", count = 7},     -- Banishers (Cor Ban)
		},
		[7] = {
			{unitName = "armrock", count = 25},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 25},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 10},    -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 5},   -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 20},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 10},    -- Arbiters (Cor Hrk)
			{unitName = "corape", count = 5},     -- Wasps (Cor Ape)
			{unitName = "corban", count = 10},    -- Banishers (Cor Ban)
			{unitName = "legmed", count = 3},     -- Medusa (Leg Med)
		},
		[8] = {
			{unitName = "armrock", count = 15},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 15},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 5},     -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 5},   -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 10},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 10},    -- Arbiters (Cor Hrk)
			{unitName = "corape", count = 5},     -- Wasps (Cor Ape)
			{unitName = "corban", count = 10},    -- Banishers (Cor Ban)
			{unitName = "legmed", count = 5},     -- Medusa (Leg Med)
			{unitName = "corvroc", count = 5},    -- Rocket Trucks (Cor Vroc)
		},
		[9] = {
			{unitName = "armrock", count = 15},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 25},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 5},     -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 10},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 10},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 15},    -- Arbiters (Cor Hrk)
			{unitName = "corape", count = 5},     -- Wasps (Cor Ape)
			{unitName = "corban", count = 10},    -- Banishers (Cor Ban)
			{unitName = "legmed", count = 5},     -- Medusa (Leg Med)
			{unitName = "corvroc", count = 5},    -- Rocket Trucks (Cor Vroc)
			{unitName = "corcat", count = 2},     -- Catapults (Cor Cat)
		},
		[10] = {
			{unitName = "armrock", count = 15},   -- Rocket Bots (Arm Rock)
			{unitName = "corstorm", count = 25},  -- Rocket Bots (Cor Storm)
			{unitName = "armsam", count = 5},     -- Missile Trucks (Arm Sam)
			{unitName = "armjanus", count = 10},  -- Janus (Arm Janus)
			{unitName = "legmos", count = 10},    -- Mosquito (Leg Mos)
			{unitName = "corcrash", count = 10},  -- Trashers (Cor Crash)
			{unitName = "corhrk", count = 15},    -- Arbiters (Cor Hrk)
			{unitName = "corape", count = 5},     -- Wasps (Cor Ape)
			{unitName = "corban", count = 10},    -- Banishers (Cor Ban)
			{unitName = "legmed", count = 5},     -- Medusa (Leg Med)
			{unitName = "corvroc", count = 5},    -- Rocket Trucks (Cor Vroc)
			{unitName = "corcat", count = 2},     -- Catapults (Cor Cat)
			{unitName = "corkarg", count = 5},    -- Karganeth (Cor Karg)
		},
	},

	["Royalty"] = {
        [1] = {
			{unitName = "armpw", count = 50},      -- Pawns
			{unitName = "armpwt4", count = 1},     -- Epic Pawn
			{unitName = "armwar", count = 10},     -- Centurion
		},
		[2] = {
			{unitName = "corthud", count = 50},    -- Thugs
			{unitName = "cormando", count = 1},    -- Commando
			{unitName = "corhrk", count = 10},     -- Arbiter
		},
		[3] = {
			{unitName = "legshot", count = 50},    -- Legion Shield Bot
			{unitName = "corgol", count = 1},      -- Tzar
			{unitName = "corhrk", count = 10},     -- Arbiter
		},
		[4] = {
			{unitName = "armpw", count = 100},     -- Pawns
			{unitName = "armpwt4", count = 1},     -- Epic Pawn
			{unitName = "armwar", count = 15},     -- Centurion
		},
		[5] = {
			{unitName = "corthud", count = 50},    -- Thugs
			{unitName = "cormando", count = 5},    -- Commando
			{unitName = "corhrk", count = 10},     -- Arbiter
			{unitName = "legshot", count = 25},    -- Legion Shield Bot
			{unitName = "corgol", count = 1},      -- Tzar
		},
		[6] = {
			{unitName = "corthud", count = 20},    -- Thugs
			{unitName = "cormando", count = 5},    -- Commando
			{unitName = "corhrk", count = 10},     -- Arbiter
			{unitName = "legshot", count = 25},    -- Legion Shield Bot
			{unitName = "corgol", count = 3},      -- Tzar
			{unitName = "armpw", count = 20},      -- Pawns
			{unitName = "armpwt4", count = 1},     -- Epic Pawn
			{unitName = "armwar", count = 10},     -- Centurion
		},
		[7] = {
			{unitName = "corthud", count = 50},    -- Thugs
			{unitName = "cormando", count = 5},    -- Commando
			{unitName = "corhrk", count = 10},     -- Arbiter
			{unitName = "legshot", count = 25},    -- Legion Shield Bot
			{unitName = "corgol", count = 3},      -- Tzar
			{unitName = "armpw", count = 50},      -- Pawns
			{unitName = "armpwt4", count = 1},     -- Epic Pawn
			{unitName = "armwar", count = 10},     -- Centurion
			{unitName = "armmerl", count = 10},    -- Ambassador
		},
		[8] = {
			{unitName = "corthud", count = 50},    -- Thugs
			{unitName = "cormando", count = 5},    -- Commando
			{unitName = "corhrk", count = 10},     -- Arbiter
			{unitName = "legshot", count = 25},    -- Legion Shield Bot
			{unitName = "corgol", count = 3},      -- Tzar
			{unitName = "armpw", count = 50},      -- Pawns
			{unitName = "armpwt4", count = 1},     -- Epic Pawn
			{unitName = "armwar", count = 10},     -- Centurion
			{unitName = "armmerl", count = 10},    -- Ambassador
			{unitName = "corgolt4", count = 1},    -- Epic Tzar
		},
		[9] = {
			{unitName = "corthud", count = 20},    -- Thugs
			{unitName = "cormando", count = 5},    -- Commando
			{unitName = "corhrk", count = 5},      -- Arbiter
			{unitName = "legshot", count = 25},    -- Legion Shield Bot
			{unitName = "corgol", count = 10},     -- Tzar
			{unitName = "armpw", count = 70},      -- Pawns
			{unitName = "armpwt4", count = 3},     -- Epic Pawn
			{unitName = "armwar", count = 10},     -- Centurion
			{unitName = "armmerl", count = 10},    -- Ambassador
			{unitName = "corgolt4", count = 1},    -- Epic Tzar
		},
		[10] = {
			{unitName = "legshot", count = 35},    -- Legion Shield Bot
			{unitName = "corgol", count = 10},     -- Tzar
			{unitName = "armpw", count = 80},      -- Pawns
			{unitName = "armpwt4", count = 10},    -- Epic Pawn
			{unitName = "corgolt4", count = 1},    -- Epic Tzar
		}
    },

	["Inferno"] = {
        [1] = {
			{unitName = "cortorch", count = 15},  -- Torch
			{unitName = "corsala", count = 10},   -- Salamander
			{unitName = "corcan", count = 15}     -- Fiends
		},
		[2] = {
			{unitName = "legkark", count = 10},   -- Karkinos
			{unitName = "leghelios", count = 30}, -- Helios
			{unitName = "corhal", count = 5},     -- Laser Tigers
			{unitName = "legbar", count = 5}      -- Barrage
		},
		[3] = {
			{unitName = "leginf", count = 1},     -- Inferno
			{unitName = "leghelios", count = 20}, -- Helios
			{unitName = "legbar", count = 5},     -- Barrage
			{unitName = "corcan", count = 15},    -- Fiends
			{unitName = "corsala", count = 10},   -- Salamanders
			{unitName = "cortermite", count = 10} -- Thermites
		},
		[4] = {
			{unitName = "corvipe", count = 1},    -- Scorpion Tank
			{unitName = "corftiger", count = 10}, -- Heat Tigers
			{unitName = "corsala", count = 20},   -- Salamanders
			{unitName = "leginf", count = 2}      -- Infernos
		},
		[5] = {
			{unitName = "legbart", count = 10},   -- Belcher
			{unitName = "leginf", count = 5},     -- Inferno
			{unitName = "legbar", count = 20},    -- Barrage
			{unitName = "corcan", count = 30},    -- Fiends
			{unitName = "corsala", count = 20}    -- Salamanders
		},
		[6] = {
			{unitName = "cortermite", count = 50},  -- Termites
			{unitName = "corthert4", count = 1}     -- Epic Termite
		},
		[7] = {
			{unitName = "corvipe", count = 5},     -- Scorpion Tanks
			{unitName = "corsala", count = 20},    -- Salamanders
			{unitName = "corftiger", count = 30},  -- Heat Tigers
			{unitName = "corcan", count = 20},     -- Fiends
			{unitName = "cortorch", count = 20},   -- Torch
			{unitName = "cordemon", count = 1},    -- Demon
			{unitName = "corforge", count = 5}     -- Forge
		},
		[8] = {
			{unitName = "cordemon", count = 3},    -- Demons
			{unitName = "corvipe", count = 10},    -- Scorpion Tanks
			{unitName = "corftiger", count = 30},  -- Heat Tigers
			{unitName = "leginf", count = 10},     -- Infernos
			{unitName = "cortorch", count = 30}    -- Torch
		},
		[9] = {
			{unitName = "corjugg", count = 1},     -- Juggernaut
			{unitName = "cordemon", count = 2},    -- Demons
			{unitName = "leghelios", count = 50},  -- Helios
			{unitName = "corsala", count = 50}     -- Salamanders
		},
		[10] = {
			{unitName = "corjugg", count = 1},     -- Juggernaut
			{unitName = "cordemon", count = 4},    -- Demons
			{unitName = "corthert4", count = 2},   -- Epic Termites
			{unitName = "corvipe", count = 15},    -- Scorpion Tanks
			{unitName = "corftiger", count = 10},  -- Heat Tigers
			{unitName = "corsala", count = 20},    -- Salamanders
			{unitName = "cortermite", count = 10}, -- Termites
			{unitName = "leginf", count = 10},     -- Infernos
			{unitName = "legbart", count = 10},    -- Belchers
			{unitName = "leghelios", count = 30},  -- Helios
			{unitName = "legkark", count = 10},    -- Karkinos
			{unitName = "corcan", count = 30}      -- Fiends
		},
    },

	["World of Tanks"] = {
        [1] = {
			{unitName = "leghades", count = 10},  -- Helios
			{unitName = "corraid", count = 10},   -- Brutes
			{unitName = "armstump", count = 10},  -- Stouts
			{unitName = "leghades", count = 10},  -- Hades
			{unitName = "corlevlr", count = 10},  -- Pounders
			{unitName = "corgarp", count = 10},   -- Garpikes
			{unitName = "armpincer", count = 10}, -- Pincers
			{unitName = "armflash", count = 10},  -- Blitz
			{unitName = "corgator", count = 10}   -- Incisors
		},
		[2] = {
			{unitName = "corgator", count = 20},  -- Incisors
			{unitName = "corsala", count = 20},   -- Salamanders
			{unitName = "armlatnk", count = 20},  -- Jaguars
			{unitName = "armflash", count = 20},  -- Blitz
			{unitName = "armstump", count = 20},  -- Stouts
			{unitName = "corraid", count = 20}    -- Brutes
		},
		[3] = {
			{unitName = "corban", count = 10},    -- Banishers
			{unitName = "corsala", count = 40},   -- Salamanders
			{unitName = "leghades", count = 30},  -- Hades
			{unitName = "legkark", count = 1}     -- Scorpion
		},
		[4] = {
			{unitName = "armcroc", count = 5},    -- Turtles
			{unitName = "corgarp", count = 10},   -- Garpikes
			{unitName = "armpincer", count = 10}, -- Pincers
			{unitName = "corsala", count = 5},    -- Salamanders
			{unitName = "corparrow", count = 1}   -- Poison Arrow
		},
		[5] = {
			{unitName = "legmed", count = 1},     -- Medusa
			{unitName = "corgator", count = 10},  -- Incisors
			{unitName = "corsala", count = 10},   -- Salamanders
			{unitName = "corparrow", count = 3},  -- Poison Arrows
			{unitName = "corgol", count = 2}      -- Tzars
		},
		[6] = {
			{unitName = "corftiger", count = 15}, -- Heat Tigers
			{unitName = "corraid", count = 15},   -- Tigers
			{unitName = "corgatreap", count = 15} -- Laser Tigers
		},
		[7] = {
			{unitName = "legmed", count = 5},     -- Medusa
			{unitName = "legkeres", count = 1},   -- Keres
			{unitName = "corlevlr", count = 30},  -- Pounders
			{unitName = "armstump", count = 20},  -- Stouts
			{unitName = "corraid", count = 20},   -- Brutes
			{unitName = "corban", count = 5}      -- Banishers
		},
		[8] = {
			{unitName = "armbull", count = 5},     -- Bulls
			{unitName = "corraid", count = 5},     -- Tigers
			{unitName = "corban", count = 5},      -- Banishers
			{unitName = "corparrow", count = 5},   -- Poison Arrows
			{unitName = "legmed", count = 5},      -- Medusa
			{unitName = "corgol", count = 5},      -- Tzars
			{unitName = "corgatreap", count = 5},  -- Laser Tigers
			{unitName = "corftiger", count = 5},   -- Heat Tigers
			{unitName = "corsala", count = 5},     -- Salamanders
			{unitName = "corraid", count = 5},     -- Brutes
			{unitName = "armstump", count = 5},    -- Stouts
			{unitName = "armtorch", count = 5},    -- Torch
			{unitName = "armcroc", count = 5},     -- Turtles
			{unitName = "armflash", count = 5},    -- Blitz
			{unitName = "corgator", count = 5},    -- Incisors
			{unitName = "armgremlin", count = 5},  -- Gremlin
			{unitName = "legkark", count = 5},     -- Scorpion
			{unitName = "armpincer", count = 5},   -- Pincers
			{unitName = "corgarp", count = 5},     -- Garpikes
			{unitName = "leghades", count = 5},    -- Hades
			{unitName = "leghades", count = 5}     -- Helios
		},
		[9] = {
			{unitName = "armbull", count = 5},     -- Bulls
			{unitName = "corraid", count = 5},     -- Tigers
			{unitName = "corban", count = 5},      -- Banishers
			{unitName = "corparrow", count = 5},   -- Poison Arrows
			{unitName = "legmed", count = 5},      -- Medusa
			{unitName = "corgol", count = 5},      -- Tzars
			{unitName = "corgatreap", count = 5},  -- Laser Tigers
			{unitName = "corftiger", count = 5},   -- Heat Tigers
			{unitName = "corsala", count = 5},     -- Salamanders
			{unitName = "corraid", count = 5},     -- Brutes
			{unitName = "armstump", count = 5},    -- Stouts
			{unitName = "armtorch", count = 5},    -- Torch
			{unitName = "armcroc", count = 5},     -- Turtles
			{unitName = "armflash", count = 5},    -- Blitz
			{unitName = "corgator", count = 5},    -- Incisors
			{unitName = "armgremlin", count = 5},  -- Gremlin
			{unitName = "legkark", count = 5},     -- Scorpion
			{unitName = "armpincer", count = 5},   -- Pincers
			{unitName = "corgarp", count = 5},     -- Garpikes
			{unitName = "leghades", count = 5},    -- Hades
			{unitName = "leghades", count = 5},    -- Helios
			{unitName = "armthor", count = 1},     -- Thor
			{unitName = "corgolt4", count = 1},    -- Epic Tzar
			{unitName = "legkeres", count = 1}     -- Keres
		},
		[10] = {
			{unitName = "armgremlin", count = 75},  -- Gremlins
			{unitName = "armlatnk", count = 25},    -- Jaguars
			{unitName = "armthor", count = 1}       -- Thor
		},
    },

	["Arachnophobia"] = {
        [1] = {
			{unitName = "armsptk", count = 20},    -- Recluse
			{unitName = "armspid", count = 10},    -- Webber
			{unitName = "leginfestor", count = 30} -- Infestors
		},
		[2] = {
			{unitName = "armsptk", count = 20},    -- Recluse
			{unitName = "armspid", count = 10},    -- Webber
			{unitName = "leginfestor", count = 30},-- Infestors
			{unitName = "cortermite", count = 20}, -- Termites
			{unitName = "legsrail", count = 20}    -- Railgun Spiders
		},
		[3] = {
			{unitName = "armspid", count = 20},    -- Webbers
			{unitName = "armvang", count = 10},    -- Vanguards
			{unitName = "armsptk", count = 20}     -- Recluse
		},
		[4] = {
			{unitName = "corthermite", count = 1}, -- Epic Termite
			{unitName = "cortermite", count = 60}  -- Termites
		},
		[5] = {
			{unitName = "corkarg", count = 1},     -- Karganeth
			{unitName = "leginfestor", count = 15} -- Infestors
		},
		[6] = {
			{unitName = "legpede", count = 2},     -- Mukade
			{unitName = "legsrail", count = 50},   -- Railgun Spiders
			{unitName = "armspid", count = 10},    -- Webbers
			{unitName = "armsptk", count = 10}     -- Recluse
		},
		[7] = {
			{unitName = "armsptk", count = 40},    -- Recluse
			{unitName = "cortermite", count = 40}, -- Termites
			{unitName = "armspid", count = 20},    -- Webbers
			{unitName = "legsrail", count = 40},   -- Railgun Spiders
			{unitName = "legpede", count = 1},     -- Mukade
			{unitName = "armsptkt4", count = 1},   -- Epic Recluse
			{unitName = "corthermite", count = 1}  -- Epic Termite
		},
		[8] = {
			{unitName = "armvang", count = 15},    -- Vanguards
			{unitName = "legsrail", count = 20},   -- Railgun Spiders
			{unitName = "armsptkt4", count = 1},   -- Epic Recluse
			{unitName = "corkarg", count = 10},    -- Karganeth
			{unitName = "armsptk", count = 30}     -- Recluse
		},
		[9] = {
			{unitName = "cortermite", count = 30},     -- Termites
			{unitName = "armsptk", count = 30},        -- Recluse
			{unitName = "armsptkt4", count = 5},       -- Epic Recluse
			{unitName = "corthermite", count = 5},     -- Epic Termite
			{unitName = "corkarganetht4", count = 5},  -- Epic Karganeth
			{unitName = "armvang", count = 10},        -- Vanguards
			{unitName = "corkarg", count = 10},        -- Karganeth
			{unitName = "leginfestor", count = 30},    -- Infestors
			{unitName = "legsrail", count = 30},       -- Railgun Spiders
			{unitName = "legkark", count = 30},        -- Karkinos
			{unitName = "armspid", count = 30}         -- Webber
		},
		[10] = {
			{unitName = "armsptkt4", count = 1},      -- Epic Recluse
			{unitName = "corthermite", count = 1},    -- Epic Termite
			{unitName = "corkarganetht4", count = 1}  -- Epic Karganeth
		},
    },

	["Can't Touch This"] = {
        [1] = {
			{unitName = "armfav", count = 30},    -- Rovers
			{unitName = "corfav", count = 30},    -- Rascals
			{unitName = "legcen", count = 1},     -- Centaur
			{unitName = "legstr", count = 1},     -- Strider
			{unitName = "armflea", count = 30},   -- Ticks
			{unitName = "armpw", count = 30},     -- Pawns
			{unitName = "corak", count = 20},     -- Grunts
			{unitName = "armflash", count = 10}   -- Blitz
		},
		[2] = {
			{unitName = "armflea", count = 100},  -- Ticks
			{unitName = "corak", count = 1},      -- Grunt
			{unitName = "armfast", count = 1},    -- Sprinter
			{unitName = "armamph", count = 1},    -- Platypus
			{unitName = "corpyro", count = 1},    -- Fiend
			{unitName = "armpw", count = 1},      -- Pawn
			{unitName = "legcen", count = 1},     -- Centaur
			{unitName = "legstr", count = 1},     -- Strider
			{unitName = "armlatnk", count = 1},   -- Jaguar
			{unitName = "armfav", count = 1},     -- Rover
			{unitName = "leghades", count = 1},   -- Hades
			{unitName = "armflash", count = 1},   -- Blitz
			{unitName = "corgator", count = 1},   -- Incisor
			{unitName = "cortorch", count = 1},   -- Torch
			{unitName = "legmrv", count = 1}      -- Quickshot
		},
		[3] = {
			{unitName = "legcen", count = 5},     -- Centaurs
			{unitName = "armpw", count = 20},     -- Pawns
			{unitName = "corak", count = 20},     -- Grunts
			{unitName = "armflea", count = 30}    -- Ticks
		},
		[4] = {
			{unitName = "corpyro", count = 5},    -- Fiends
			{unitName = "corfav", count = 50},    -- Rascals
			{unitName = "armfast", count = 20},   -- Sprinters
			{unitName = "armlatnk", count = 10}   -- Jaguars
		},
		[5] = {
			{unitName = "legstr", count = 10},    -- Striders
			{unitName = "armfast", count = 10},   -- Sprinters
			{unitName = "corpyro", count = 10},   -- Fiends
			{unitName = "corak", count = 10},     -- Grunts
			{unitName = "armpw", count = 10},     -- Pawns
			{unitName = "armmar", count = 1}      -- Marauder
		},
		[6] = {
			{unitName = "armamph", count = 20},   -- Platypus
			{unitName = "armfast", count = 20},   -- Sprinters
			{unitName = "legcen", count = 20},    -- Centaurs
			{unitName = "corakt4", count = 1}     -- Epic Grunt
		},
		[7] = {
			{unitName = "corakt4", count = 1},    -- Epic Grunt
			{unitName = "armpwt4", count = 1},    -- Epic Pawn
			{unitName = "armflea", count = 100}   -- Ticks
		},
		[8] = {
			{unitName = "armmar", count = 5},     -- Marauders
			{unitName = "legmrv", count = 5},     -- Quickshots
			{unitName = "armpwt4", count = 5},    -- Epic Pawns
			{unitName = "corpyro", count = 50},   -- Fiends
			{unitName = "cortorch", count = 5}    -- Torches
		},
		[9] = {
			{unitName = "armpwt4", count = 1},    -- Epic Pawn
			{unitName = "corakt4", count = 1},    -- Epic Grunt
			{unitName = "armmar", count = 10},    -- Marauders
			{unitName = "corfav", count = 50},    -- Rascals
			{unitName = "armflea", count = 50}    -- Ticks
		},
		[10] = {
			{unitName = "armfav", count = 7},     -- Rovers
			{unitName = "corfav", count = 7},     -- Rascals
			{unitName = "legcen", count = 7},     -- Centaurs
			{unitName = "legstr", count = 7},     -- Striders
			{unitName = "armflea", count = 7},    -- Ticks
			{unitName = "armpw", count = 7},      -- Pawns
			{unitName = "corak", count = 7},      -- Grunts
			{unitName = "armflash", count = 7},   -- Blitz
			{unitName = "armfast", count = 7},    -- Sprinters
			{unitName = "armamph", count = 7},    -- Platypus
			{unitName = "corpyro", count = 7},    -- Fiends
			{unitName = "armlatnk", count = 7},   -- Jaguars
			{unitName = "leghades", count = 7},   -- Hades
			{unitName = "corgator", count = 7},   -- Incisors
			{unitName = "cortorch", count = 7},   -- Torches
			{unitName = "legmrv", count = 7},     -- Quickshots
			{unitName = "armmar", count = 7},     -- Marauders
			{unitName = "corakt4", count = 7},    -- Epic Grunts
			{unitName = "armpwt4", count = 7}     -- Epic Pawns
		}
    },

	["T1 Variety"] = {
        [1] = {
            {unitName = "armpw", count = 30},
            -- More units
        },
        -- Other rounds
    },

    ["Death from Above"] = {
        [1] = {
            {unitName = "corshad", count = 15}, --Bombers
			{unitName = "armrock", count = 30}, --Rocketeers
			{unitName = "armsam", count = 5},     -- Missile Trucks (Arm Sam)
            -- More units
        },
        -- Other rounds
    },

	["Glass the Runners"] = {
        [1] = {
			{unitName = "legphoenix", count = 5},  -- Phoenixes
			{unitName = "armpw", count = 30},      -- Pawns
			{unitName = "armfast", count = 10},    -- Sprinters
			{unitName = "corcrash", count = 5},    -- Trashers
		},
		[2] = {
			{unitName = "legphoenix", count = 10}, -- Phoenixes
			{unitName = "armpwt4", count = 1},     -- Epic Pawn
			{unitName = "armpw", count = 30},      -- Pawns
			{unitName = "armwar", count = 10},     -- Centurions
			{unitName = "corcrash", count = 5},    -- Trashers
			{unitName = "armaak", count = 1},      -- Archangel
			{unitName = "armfast", count = 10},    -- Sprinters
		},
		[3] = {
			{unitName = "legphoenix", count = 20}, -- Phoenixes
			{unitName = "armpwt4", count = 5},     -- Epic Pawns
			{unitName = "corsumo", count = 10},    -- Mammoths
		},
		[4] = {
			{unitName = "legphoenix", count = 20}, -- Phoenixes
			{unitName = "armaak", count = 2},      -- Archangels
			{unitName = "armwar", count = 20},     -- Centurions
		},
		[5] = {
			{unitName = "armfast", count = 100},   -- Sprinters
			{unitName = "armaak", count = 5},      -- Archangels
			{unitName = "legphoenix", count = 20}, -- Phoenixes
		},
		[6] = {
			{unitName = "legphoenix", count = 25}, -- Phoenixes
			{unitName = "armpwt4", count = 10},    -- Epic Pawns
			{unitName = "corban", count = 20},     -- Banishers
			{unitName = "armfast", count = 30},    -- Sprinters
		}
    },

	["Long Range Standoff"] = {
        [1] = {
			{unitName = "armrock", count = 20},    -- Rocket Bots
			{unitName = "cormist", count = 10},    -- Lashers
			{unitName = "armsnipe", count = 1},    -- Sniper
		},
		[2] = {
			{unitName = "armsnipe", count = 5},    -- Snipers
			{unitName = "cormort", count = 10},    -- Sheldons
			{unitName = "corvoyr", count = 1},     -- Radar Bot (Augur)
			{unitName = "armfido", count = 10},    -- Hounds
		},
		[3] = {
			{unitName = "armvang", count = 1},     -- Vanguard
			{unitName = "armsnipe", count = 10},   -- Snipers
			{unitName = "cormort", count = 10},    -- Sheldons
			{unitName = "corvoyr", count = 2},     -- Radar Bots (Augur)
			{unitName = "corspec", count = 1},     -- Deceiver
			{unitName = "corban", count = 2},      -- Banishers
		},
		[4] = {
			{unitName = "armvang", count = 1},     -- Vanguard
			{unitName = "legsrail", count = 20},   -- Railgun Spiders
		},
		[5] = {
			{unitName = "corcat", count = 2},      -- Catapults
			{unitName = "corban", count = 10},     -- Banishers
			{unitName = "armsnipe", count = 20},   -- Snipers
			{unitName = "legsrail", count = 30},   -- Railgun Spiders
			{unitName = "corawac", count = 3},     -- Radar/Sonar Planes (Condor)
		}
    },
    
	["Cortex Bots"] = {
		[1] = { {unitName="corthud",count=5}, {unitName="cornecro",count=1}, {unitName="corak",count=3} },
		[2] = { {unitName="cormando",count=1}, {unitName="cornecro",count=2}, {unitName="corthud",count=10} },
		[3] = { {unitName="corthud",count=20}, {unitName="corroach",count=3} },
		[4] = { {unitName="cormort",count=5}, {unitName="corhrk",count=3}, {unitName="corvoyr",count=1}, {unitName="corspec",count=1}, {unitName="corak",count=10} },
		[5] = { {unitName="corvoyr",count=1}, {unitName="cormort",count=15}, {unitName="corspec",count=2}, {unitName="corsktl",count=1}, {unitName="corak",count=4} },
		[6] = { {unitName="corsumo",count=2}, {unitName="cornecro",count=4}, {unitName="corvoyr",count=1}, {unitName="corhrk",count=7} },
		[7] = { {unitName="corshiva",count=3}, {unitName="corvoyr",count=1}, {unitName="corspec",count=1}, {unitName="cormort",count=15}, {unitName="corpyro",count=10}, {unitName="corspy",count=1} },
		[8] = { {unitName="cordemon",count=3}, {unitName="corpyro",count=30}, {unitName="corkarg",count=3}, {unitName="corshiva",count=5}, {unitName="corcat",count=1}, {unitName="corvoyr",count=1} },
		[9] = { {unitName="corspec",count=10}, {unitName="corkorg",count=3}, {unitName="cordecom",count=2}, {unitName="corcom",count=1} },
	},

	["Armada & Cortex Vehicles"] = {
		[1] = { {unitName="armstump",count=5}, {unitName="armflash",count=3}, {unitName="armsam",count=1} },
		[2] = { {unitName="armstump",count=1}, {unitName="armjanus",count=3}, {unitName="armsam",count=8} },
		[3] = { {unitName="armstump",count=7}, {unitName="armfav",count=5}, {unitName="armjanus",count=4} },
		[4] = { {unitName="corwolv",count=10}, {unitName="corgator",count=5}, {unitName="armsam",count=3}, {unitName="armstump",count=5} },
		[5] = { {unitName="armmart",count=4}, {unitName="armmark",count=1}, {unitName="armaser",count=1}, {unitName="armfav",count=3}, {unitName="armstump",count=5}, {unitName="armjanus",count=1} },
		[6] = { {unitName="armlatnk",count=4}, {unitName="correap",count=1}, {unitName="cormart",count=4}, {unitName="armmark",count=1}, {unitName="armgremlin",count=4}, {unitName="armfav",count=10}, {unitName="armmart",count=8} },
		[7] = { {unitName="armbull",count=3}, {unitName="armmanni",count=1}, {unitName="armmark",count=1}, {unitName="armaser",count=1} },
		[8] = { {unitName="armbull",count=5}, {unitName="armmanni",count=3}, {unitName="armmerl",count=4}, {unitName="armmark",count=3} },
		[9] = { {unitName="cortrem",count=2}, {unitName="armmanni",count=4}, {unitName="corban",count=1}, {unitName="armfav",count=20}, {unitName="armlatnk",count=1}, {unitName="armpeep",count=3} },
		[10] = { {unitName="armmanni",count=10}, {unitName="armmark",count=4}, {unitName="armthor",count=1} },
	},

	["Armada Bots"] = {
		[1] = { {unitName="armrock",count=5}, {unitName="armwar",count=1}, {unitName="armrectr",count=1}, {unitName="armflea",count=3}, {unitName="armpw",count=4} },
		[2] = { {unitName="armwar",count=3}, {unitName="armrectr",count=3} },
		[3] = { {unitName="armrock",count=10}, {unitName="armham",count=4}, {unitName="armrectr",count=1}, {unitName="armflea",count=5} },
		[4] = { {unitName="armmav",count=1}, {unitName="armham",count=10}, {unitName="armrock",count=15}, {unitName="armflea",count=5} },
		[5] = { {unitName="armfido",count=4}, {unitName="armmark",count=1}, {unitName="armaser",count=1}, {unitName="armfast",count=12} },
		[6] = { {unitName="armzeus",count=3}, {unitName="armfido",count=4}, {unitName="armmark",count=1}, {unitName="armaser",count=1}, {unitName="armsnipe",count=1}, {unitName="armflea",count=15} },
		[7] = { {unitName="armfast",count=25}, {unitName="armsnipe",count=5}, {unitName="armzeus",count=7}, {unitName="armmark",count=2} },
		[8] = { {unitName="armfboy",count=1}, {unitName="armzeus",count=4}, {unitName="armflea",count=25} },
		[9] = { {unitName="armmar",count=4}, {unitName="armzeus",count=8}, {unitName="armsnipe",count=2} },
		[10] = { {unitName="armraz",count=2}, {unitName="armmar",count=8}, {unitName="armvang",count=2}, {unitName="armpw",count=20} },
		[11] = { {unitName="armsnipe",count=15}, {unitName="armraz",count=3}, {unitName="armvang",count=1}, {unitName="armrectr",count=4}, {unitName="armmark",count=3}, {unitName="armaser",count=1} },
	},
}
-- ===========================================================================
-- Micro Wars round / scoring engine
-- ===========================================================================

local unitSpawnConfig = unitSpawnConfigs[selectedComposition] or unitSpawnConfigs["Basic T1 - T3"]

local maxRound = 0
for r in pairs(unitSpawnConfig) do
    if type(r) == "number" and r > maxRound then maxRound = r end
end
if maxRound == 0 then maxRound = 1 end

local activeTeams = {}
for _, teamID in ipairs(teams) do
    if teamID ~= gaiaTeamID then activeTeams[#activeTeams + 1] = teamID end
end

local currentRound = 0
local currentRoundFrameStart = 0
local firstSpawnDone = false
local matchOver = false
local unitSpawns = {}              -- teamID -> { unitID }
local roundWins = {}               -- teamID -> wins
local initialCommanderPositions = {}
local commanders = {}              -- unitID -> teamID (invincible / neutral / energy-generating commanders)
local lastReinforceFrame = 0       -- touchdown: frame of the last reinforcement wave
local touchdownPoints = {}         -- touchdown: teamID -> accumulated points

local FIRST_SPAWN_FRAME = 90       -- ~3s: let commanders land before the first wave
local GRACE = 150                  -- ~5s before a round can be resolved

-- "Maros (Team 0)" style label
local function teamLabel(teamID)
    local name
    local players = Spring.GetPlayerList(teamID)
    if players and players[1] then
        name = (Spring.GetPlayerInfo(players[1]))
    end
    if not name or name == "" then
        local _, _, _, isAI = Spring.GetTeamInfo(teamID)
        name = isAI and "AI" or ("Team " .. teamID)
    end
    return name .. " (Team " .. teamID .. ")"
end

local function allyOf(teamID)
    local _, _, _, _, _, ally = Spring.GetTeamInfo(teamID)
    return ally or teamID
end

local function hpStr(hp)
    if hp >= 1000 then return string.format("%.0fk HP", hp / 1000) end
    return string.format("%d HP", math.floor(hp))
end

local function ResetUnitSpawns()
    if despawnUnits then
        for _, units in pairs(unitSpawns) do
            for _, unitID in ipairs(units) do
                if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
                    Spring.DestroyUnit(unitID, false, true)
                end
            end
        end
    end
    for _, teamID in ipairs(activeTeams) do
        unitSpawns[teamID] = {}
    end
end

local function GetCommanderPosition(teamID)
    for _, unitID in ipairs(Spring.GetTeamUnits(teamID)) do
        local udid = Spring.GetUnitDefID(unitID)
        if udid and UnitDefs[udid].customParams.iscommander then
            return Spring.GetUnitPosition(unitID)
        end
    end
    if initialCommanderPositions[teamID] then
        local p = initialCommanderPositions[teamID]
        return p[1], p[2], p[3]
    end
    local x, y, z = Spring.GetTeamStartPosition(teamID)
    return x, Spring.GetGroundHeight(x, z), z
end

local function SpawnUnitsForTeam(teamID, unitName, count)
    local x, y, z = GetCommanderPosition(teamID)
    count = math.floor(count * unitsPerRoundMultiplier)
    local list = unitSpawns[teamID] or {}
    for _ = 1, count do
        local ux = x + math.random(-100, 100)
        local uz = z + math.random(-100, 100)
        local uy = Spring.GetGroundHeight(ux, uz)
        local unitID = Spring.CreateUnit(unitName, ux, uy, uz, 0, teamID)
        if unitID then
            list[#list + 1] = unitID
            Spring.SpawnCEG("botrailspawn", ux, uy, uz, 0, 0, 0)
        end
    end
    unitSpawns[teamID] = list
end

-- surviving spawned army; the commander is never in unitSpawns, so it is excluded
local function armyCount(teamID)
    local n = 0
    for _, unitID in ipairs(unitSpawns[teamID] or {}) do
        if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then n = n + 1 end
    end
    return n
end

local function armyHealth(teamID)
    local hp = 0
    for _, unitID in ipairs(unitSpawns[teamID] or {}) do
        if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
            hp = hp + (Spring.GetUnitHealth(unitID) or 0)
        end
    end
    return hp
end

local function leadingTeam()
    local best, bestN, bestHP
    for _, teamID in ipairs(activeTeams) do
        local n, hp = armyCount(teamID), armyHealth(teamID)
        if not best or n > bestN or (n == bestN and hp > bestHP) then
            best, bestN, bestHP = teamID, n, hp
        end
    end
    return best
end

local function aliveTeams()
    local t = {}
    for _, teamID in ipairs(activeTeams) do
        if armyCount(teamID) > 0 then t[#t + 1] = teamID end
    end
    return t
end

local function winsLine()
    local p = {}
    for _, teamID in ipairs(activeTeams) do
        p[#p + 1] = string.format("%s %d", teamLabel(teamID), roundWins[teamID] or 0)
    end
    return table.concat(p, " | ")
end

-- publish state for the unsynced timer HUD
local function publishTimer()
    if roundTime > 0 and not matchOver then
        Spring.SetGameRulesParam("microwars_round_end_frame", currentRoundFrameStart + roundTime)
    else
        Spring.SetGameRulesParam("microwars_round_end_frame", 0)
    end
    Spring.SetGameRulesParam("microwars_round", currentRound)
end

local function beginRound()
    currentRound = currentRound + 1
    currentRoundFrameStart = Spring.GetGameFrame()
    ResetUnitSpawns()
    local cfg = unitSpawnConfig[currentRound] or {}
    for _, teamID in ipairs(activeTeams) do
        for _, c in ipairs(cfg) do
            SpawnUnitsForTeam(teamID, c.unitName, c.count)
        end
    end
    publishTimer()
    Spring.Echo(string.format("Micro Wars: Round %d begins.", currentRound))
end

local function endMatch()
    matchOver = true
    Spring.SetGameRulesParam("microwars_round_end_frame", 0)
    local winner, bestWins
    for _, teamID in ipairs(activeTeams) do
        local w = roundWins[teamID] or 0
        if not winner or w > bestWins then winner, bestWins = teamID, w end
    end
    Spring.Echo("Micro Wars: MATCH OVER. Round wins -- " .. winsLine())
    if winner then
        Spring.Echo("Micro Wars: " .. teamLabel(winner) .. " wins the match!")
        Spring.GameOver({ allyOf(winner) })
    end
end

local function resolveRound(winner, reason)
    local parts = {}
    for _, teamID in ipairs(activeTeams) do
        parts[#parts + 1] = string.format("%s: %d units / %s",
            teamLabel(teamID), armyCount(teamID), hpStr(armyHealth(teamID)))
    end
    local scoreboard = table.concat(parts, "   vs   ")
    if winner then
        roundWins[winner] = (roundWins[winner] or 0) + 1
        Spring.Echo(string.format("Micro Wars: Round %d -- %s wins by %s.   %s",
            currentRound, teamLabel(winner), reason, scoreboard))
        Spring.Echo("Micro Wars: round wins -- " .. winsLine())
    else
        Spring.Echo(string.format("Micro Wars: Round %d -- draw.   %s", currentRound, scoreboard))
    end
    if currentRound >= maxRound then
        endMatch()
    else
        beginRound()
    end
end

-- ---------------------------------------------------------------------------
-- Touchdown mode: occupy the enemy starter zone for points (tug-of-war)
-- ---------------------------------------------------------------------------

local function touchdownScoreLine()
    local parts = {}
    for _, teamID in ipairs(activeTeams) do
        parts[#parts + 1] = string.format("%s %d", teamLabel(teamID), math.floor(touchdownPoints[teamID] or 0))
    end
    return table.concat(parts, " | ")
end

local function spawnList(teamID, list)
    for _, c in ipairs(list) do
        SpawnUnitsForTeam(teamID, c.unitName, c.count)
    end
end

-- count a team's (non-commander) units standing inside a zone
local function countTeamUnitsInZone(teamID, zonePos)
    local units = Spring.GetUnitsInCylinder(zonePos[1], zonePos[3], touchdownZoneRadius)
    local n = 0
    for _, uid in ipairs(units) do
        if Spring.GetUnitTeam(uid) == teamID and not commanders[uid] then
            n = n + 1
        end
    end
    return n
end

local function touchdownWin(winner, reason)
    matchOver = true
    Spring.SetGameRulesParam("microwars_round_end_frame", 0)
    if winner then
        Spring.Echo(string.format("Micro Wars: TOUCHDOWN. %s wins by %s. Final score -- %s",
            teamLabel(winner), reason, touchdownScoreLine()))
        Spring.GameOver({ allyOf(winner) })
    else
        Spring.Echo("Micro Wars: Touchdown match over. " .. touchdownScoreLine())
    end
end

local function runTouchdown(n)
    -- starting force
    if not firstSpawnDone then
        if n >= FIRST_SPAWN_FRAME then
            firstSpawnDone = true
            currentRound = 1
            currentRoundFrameStart = n
            lastReinforceFrame = n
            for _, teamID in ipairs(activeTeams) do
                spawnList(teamID, reinforcementInitial)
            end
            publishTimer()
            Spring.Echo("Micro Wars: Touchdown match begins.")
        end
        return
    end

    -- periodic reinforcement waves
    if reinforcementInterval > 0 and #reinforcementWave > 0
       and (n - lastReinforceFrame) >= reinforcementInterval * 30 then
        lastReinforceFrame = n
        for _, teamID in ipairs(activeTeams) do
            spawnList(teamID, reinforcementWave)
        end
        Spring.Echo("Micro Wars: reinforcements deployed.")
    end

    -- score once per second: +1 per unit standing in an enemy zone
    if n % 30 == 0 then
        for _, teamID in ipairs(activeTeams) do
            local gained = 0
            for _, enemyID in ipairs(activeTeams) do
                if enemyID ~= teamID and initialCommanderPositions[enemyID] then
                    gained = gained + countTeamUnitsInZone(teamID, initialCommanderPositions[enemyID])
                end
            end
            touchdownPoints[teamID] = (touchdownPoints[teamID] or 0) + gained
            Spring.SetGameRulesParam("microwars_td_score_" .. teamID, math.floor(touchdownPoints[teamID]))
        end

        -- tug-of-war win: one team leads by the score limit (2-team match)
        if #activeTeams == 2 then
            local a, b = activeTeams[1], activeTeams[2]
            local diff = (touchdownPoints[a] or 0) - (touchdownPoints[b] or 0)
            if diff >= touchdownWinScore then
                touchdownWin(a, "reaching the score limit"); return
            elseif -diff >= touchdownWinScore then
                touchdownWin(b, "reaching the score limit"); return
            end
        end
    end

    -- time limit: whoever leads on points takes the match
    if roundTime > 0 and (n - currentRoundFrameStart) >= roundTime then
        local best, bestScore
        for _, teamID in ipairs(activeTeams) do
            local s = touchdownPoints[teamID] or 0
            if not best or s > bestScore then best, bestScore = teamID, s end
        end
        touchdownWin(best, "time")
    end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
    local ud = UnitDefs[unitDefID]
    if ud and ud.customParams and ud.customParams.iscommander then
        commanders[unitID] = unitTeam
        Spring.SetUnitNeutral(unitID, true)               -- enemies ignore the commander
        Spring.SetTeamResource(unitTeam, "es", 100000)    -- raise energy storage so income accumulates
        Spring.SetTeamResource(unitTeam, "e", 100000)     -- start full so weapons can fire immediately
        if commanderRadar then
            local base = Spring.GetUnitSensorRadius(unitID, "radar") or 0
            if base <= 0 then base = 2000 end
            Spring.SetUnitSensorRadius(unitID, "radar", base * 50)   -- 50x radar
        end
    end
end

function gadget:UnitDestroyed(unitID)
    commanders[unitID] = nil
end

-- commanders take no damage
function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage)
    if commanders[unitID] then return 0, 0 end
    return damage
end

function gadget:Initialize()
    for _, teamID in ipairs(activeTeams) do
        unitSpawns[teamID] = {}
        roundWins[teamID] = 0
        touchdownPoints[teamID] = 0
    end
    Spring.SetGameRulesParam("microwars_round_end_frame", 0)
    Spring.SetGameRulesParam("microwars_round", 0)
end

function gadget:GameStart()
    if touchdownMode then
        local timer = roundTime > 0 and string.format("%d min limit", roundTimeMin) or "no time limit"
        local wave = reinforcementInterval > 0 and string.format("reinforcements every %ds", reinforcementInterval) or "no reinforcements"
        Spring.Echo(string.format("Micro Wars TOUCHDOWN started. First to %d points wins. Zone radius %d. %s. %s.",
            touchdownWinScore, touchdownZoneRadius, timer, wave))
        return
    end
    local victory = wipeoutOnly and "destroy the enemy army"
        or string.format("+%d%% domination or time", earlyPct)
    local timer = roundTime > 0 and string.format("%d min/round", roundTimeMin) or "no timer"
    Spring.Echo(string.format("Micro Wars started. Composition: %s | Victory: %s | %s | building disabled.",
        selectedComposition, victory, timer))
end

function gadget:GameFrame(n)
    if matchOver then return end

    -- commanders generate 10k energy/second for their team
    if n % 30 == 0 then
        for _, ct in pairs(commanders) do
            Spring.AddTeamResource(ct, "e", 10000)
        end
    end

    -- publish live troop counts for the on-screen scoreboard
    if n % 6 == 0 then
        for _, teamID in ipairs(activeTeams) do
            Spring.SetGameRulesParam("microwars_army_" .. teamID, armyCount(teamID))
        end
    end

    if n == 60 then
        for _, teamID in ipairs(activeTeams) do
            for _, unitID in ipairs(Spring.GetTeamUnits(teamID)) do
                local udid = Spring.GetUnitDefID(unitID)
                if udid and UnitDefs[udid].customParams.iscommander then
                    local x, y, z = Spring.GetUnitPosition(unitID)
                    initialCommanderPositions[teamID] = { x, y, z }
                    Spring.SetGameRulesParam("microwars_zone_" .. teamID .. "_x", x)
                    Spring.SetGameRulesParam("microwars_zone_" .. teamID .. "_z", z)
                    break
                end
            end
        end
        return
    end

    if touchdownMode then
        runTouchdown(n)
        return
    end

    if not firstSpawnDone then
        if n >= FIRST_SPAWN_FRAME then
            firstSpawnDone = true
            beginRound()
        end
        return
    end

    local elapsed = n - currentRoundFrameStart
    if elapsed <= GRACE then return end

    -- 1) wipeout: only one team still has an army
    local alive = aliveTeams()
    if #alive <= 1 then
        resolveRound(alive[1] or leadingTeam(), "enemy army destroyed")
        return
    end

    -- 2) domination ratio (skipped when wipeout-only)
    if not wipeoutOnly then
        local lead = leadingTeam()
        if lead then
            local leadN, leadHP = armyCount(lead), armyHealth(lead)
            local dominates = true
            for _, teamID in ipairs(activeTeams) do
                if teamID ~= lead then
                    local n2, hp2 = armyCount(teamID), armyHealth(teamID)
                    if not (leadN >= n2 * (1 + earlyPct / 100) and leadHP >= hp2 * (1 + earlyPct / 100)) then
                        dominates = false
                        break
                    end
                end
            end
            if dominates then
                resolveRound(lead, string.format("+%d%% domination", earlyPct))
                return
            end
        end
    end

    -- 3) round timer
    if roundTime > 0 and elapsed >= roundTime then
        resolveRound(leadingTeam(), "time")
        return
    end
end

-- no building in Micro Wars
function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID)
    if cmdID < 0 then return false end
    return true
end

function gadget:Shutdown()
    ResetUnitSpawns()
end

else
--------------------------------------------------------------------------------
-- UNSYNCED: round timer, tug-of-war bar, troop scoreboard; touchdown zones
--------------------------------------------------------------------------------

local function activeTeamList()
    local t = {}
    local gaia = Spring.GetGaiaTeamID()
    for _, teamID in ipairs(Spring.GetTeamList()) do
        if teamID ~= gaia then t[#t + 1] = teamID end
    end
    return t
end

local function playerName(teamID)
    local players = Spring.GetPlayerList(teamID)
    local name
    if players and players[1] then name = (Spring.GetPlayerInfo(players[1])) end
    if not name or name == "" then name = "Team " .. teamID end
    return name
end

-- commanders are invisible (rendering only; they still anchor spawns)
function gadget:UnitCreated(unitID, unitDefID, unitTeam)
    local ud = UnitDefs[unitDefID]
    if ud and ud.customParams and ud.customParams.iscommander then
        Spring.SetUnitNoDraw(unitID, true)
    end
end

-- tug-of-war bar: the rope marker slides toward whoever is winning
local function drawTugOfWar(cx, topY, vsx)
    local list = activeTeamList()
    if #list < 2 then return topY end
    local a, b = list[1], list[2]
    local sA = Spring.GetGameRulesParam("microwars_td_score_" .. a) or 0
    local sB = Spring.GetGameRulesParam("microwars_td_score_" .. b) or 0

    local W = math.min(640, vsx * 0.42)
    local H = 30
    local bx = cx - W / 2
    local top = topY - 4
    local bot = top - H

    local denom = (touchdownWinScore > 0) and (2 * touchdownWinScore) or 1
    local f = 0.5 + (sA - sB) / denom
    if f < 0 then f = 0 elseif f > 1 then f = 1 end

    local ar, ag, ab = Spring.GetTeamColor(a)
    local br, bg, bb = Spring.GetTeamColor(b)

    gl.Color(0, 0, 0, 0.85)
    gl.Rect(bx - 3, bot - 3, bx + W + 3, top + 3)
    gl.Color(ar or 1, ag or 0, ab or 0, 0.95)
    gl.Rect(bx, bot, bx + f * W, top)
    gl.Color(br or 0, bg or 0, bb or 1, 0.95)
    gl.Rect(bx + f * W, bot, bx + W, top)
    gl.Color(1, 1, 1, 0.9)
    gl.Rect(cx - 1.5, bot - 5, cx + 1.5, top + 5)

    gl.Color(1, 1, 1, 1)
    gl.Text(tostring(math.floor(sA)), bx + 8, bot + H / 2 - 7, 16, "o")
    gl.Text(tostring(math.floor(sB)), bx + W - 8, bot + H / 2 - 7, 16, "or")

    return bot - 26
end

function gadget:DrawScreen()
    local round = Spring.GetGameRulesParam("microwars_round") or 0
    if round < 1 then return end
    local vsx, vsy = Spring.GetViewGeometry()
    local cx = vsx * 0.5
    local y = vsy - 110

    if showTimer then
        local endFrame = Spring.GetGameRulesParam("microwars_round_end_frame") or 0
        local prefix = touchdownMode and "Touchdown" or ("Round " .. round)
        local label
        if endFrame > 0 then
            local remain = (endFrame - Spring.GetGameFrame()) / 30
            if remain < 0 then remain = 0 end
            label = string.format("%s    %d:%02d", prefix, math.floor(remain / 60), math.floor(remain % 60))
        else
            label = prefix
        end
        gl.Color(1, 1, 1, 1)
        gl.Text(label, cx, y, 22, "oc")
        y = y - 28
    end

    if touchdownMode then
        y = drawTugOfWar(cx, y, vsx)
    end

    -- live troop scoreboard, one line per player
    for _, teamID in ipairs(activeTeamList()) do
        local troops = Spring.GetGameRulesParam("microwars_army_" .. teamID) or 0
        local r, g, b = Spring.GetTeamColor(teamID)
        gl.Color(r or 1, g or 1, b or 1, 1)
        gl.Text(string.format("%s: %d units", playerName(teamID), troops), cx, y, 18, "oc")
        y = y - 22
    end
    gl.Color(1, 1, 1, 1)
end

-- mark the touchdown zones on the ground in each team's color
function gadget:DrawWorld()
    if not touchdownMode then return end
    if (Spring.GetGameRulesParam("microwars_round") or 0) < 1 then return end
    gl.LineWidth(3)
    for _, teamID in ipairs(activeTeamList()) do
        local x = Spring.GetGameRulesParam("microwars_zone_" .. teamID .. "_x")
        local z = Spring.GetGameRulesParam("microwars_zone_" .. teamID .. "_z")
        if x and z then
            local yy = Spring.GetGroundHeight(x, z)
            local r, g, b = Spring.GetTeamColor(teamID)
            gl.Color(r or 1, g or 1, b or 1, 0.75)
            gl.DrawGroundCircle(x, yy, z, touchdownZoneRadius, 64)
        end
    end
    gl.LineWidth(1)
    gl.Color(1, 1, 1, 1)
end

end
