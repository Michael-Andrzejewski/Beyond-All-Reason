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

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
    local ud = UnitDefs[unitDefID]
    if ud and ud.customParams and ud.customParams.iscommander then
        commanders[unitID] = unitTeam
        Spring.SetUnitNeutral(unitID, true)               -- enemies ignore the commander
        Spring.SetTeamResource(unitTeam, "es", 100000)    -- raise energy storage so income accumulates
        Spring.SetTeamResource(unitTeam, "e", 100000)     -- start full so weapons can fire immediately
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
    end
    Spring.SetGameRulesParam("microwars_round_end_frame", 0)
    Spring.SetGameRulesParam("microwars_round", 0)
end

function gadget:GameStart()
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

    if n == 60 then
        for _, teamID in ipairs(activeTeams) do
            for _, unitID in ipairs(Spring.GetTeamUnits(teamID)) do
                local udid = Spring.GetUnitDefID(unitID)
                if udid and UnitDefs[udid].customParams.iscommander then
                    local x, y, z = Spring.GetUnitPosition(unitID)
                    initialCommanderPositions[teamID] = { x, y, z }
                    break
                end
            end
        end
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
-- UNSYNCED: on-screen round-timer HUD
--------------------------------------------------------------------------------

-- commanders are invisible (rendering only; they still anchor spawns)
function gadget:UnitCreated(unitID, unitDefID, unitTeam)
    local ud = UnitDefs[unitDefID]
    if ud and ud.customParams and ud.customParams.iscommander then
        Spring.SetUnitNoDraw(unitID, true)
    end
end

if showTimer then
    local GetGameRulesParam = Spring.GetGameRulesParam
    local GetGameFrame = Spring.GetGameFrame
    local GetViewGeometry = Spring.GetViewGeometry

    function gadget:DrawScreen()
        local round = GetGameRulesParam("microwars_round") or 0
        if round < 1 then return end
        local endFrame = GetGameRulesParam("microwars_round_end_frame") or 0
        local vsx, vsy = GetViewGeometry()
        local label
        if endFrame > 0 then
            local remain = (endFrame - GetGameFrame()) / 30
            if remain < 0 then remain = 0 end
            label = string.format("Round %d    %d:%02d", round, math.floor(remain / 60), math.floor(remain % 60))
        else
            label = "Round " .. round
        end
        gl.Color(1, 1, 1, 1)
        gl.Text(label, vsx * 0.5, vsy - 110, 22, "oc")
        gl.Color(1, 1, 1, 1)
    end
end

end
