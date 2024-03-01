return {
	legcomt2def = {
		maxacc = 0.18,
		activatewhenbuilt = true,
		autoheal = 10,
		maxdec = 1.125,
		energycost = 26000,
		metalcost = 2700,
		builddistance = 300,
		builder = true,
		buildpic = "LEGCOMT2DEF.DDS",
		buildtime = 75000,
		cancapture = true,
		canmanualfire = true,
		canmove = true,
		capturespeed = 1800,
		category = "ALL WEAPON NOTSUB COMMANDER NOTSHIP NOTAIR NOTHOVER SURFACE CANBEUW EMPABLE",
		collisionvolumeoffsets = "0 3 0",
		collisionvolumescales = "28 52 28",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		energymake = 150,
		energystorage = 2500,
		explodeas = "commanderExplosion",
		footprintx = 2,
		footprintz = 2,
		hidedamage = true,
    	holdsteady = true,
		idleautoheal = 5,
		idletime = 1800,
		sightemitheight = 40,
		mass = 4999,
		health = 4450,
		maxslope = 20,
		speed = 37.5,
		maxwaterdepth = 35,
		metalmake = 5,
		metalstorage = 1500,
		mincloakdistance = 50,
		movementclass = "COMMANDERBOT",
		nochasecategory = "ALL",
		objectname = "Units/LEGCOM.s3o",
		pushresistant = true,
		radardistance = 700,
		radaremitheight = 40,
		reclaimable = false,
   		releaseheld  = true,
		script = "Units/legcom.cob",
		seismicsignature = 0,
		selfdestructas = "commanderexplosion",
		selfdestructcountdown = 5,
		showplayername = true,
		sightdistance = 450,
		sonardistance = 450,
		terraformspeed = 1500,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 0.825,
		turnrate = 1148,
		upright = true,
		workertime = 500,
		buildoptions = {
			[1] = "armada_solarcollector",
			[2] = "armada_windturbine",
			[3] = "armada_metalstorage",
			[4] = "armada_energystorage",
			[5] = "legmex",
			[6] = "armada_energyconverter",
			[7] = "leglab",
			[8] = "legvp",
			[9] = "armada_aircraftplant",
			[10] = "armada_beholder",
			[11] = "armada_radartower",
			[12] = "armada_dragonsteeth",
			[13] = "armada_sentry",
			[14] = "armada_nettle",
			[15] = "armada_anemone",
			[16] = "armada_tidalgenerator",
			[17] = "armada_navalmetalstorage",
			[18] = "armada_navalenergystorage",
			--[19] = "armada_navalmetalextractor",
			[20] = "armada_navalenergyconverter",
			[21] = "armada_shipyard",
			[22] = "armada_sharksteeth",
			[23] = "armada_harpoon",
			[24] = "armada_navalnettle",
			[25] = "armada_navalradarsonar",
			-- Experimental:
			[26] = "armada_hovercraftplatform",
			[27] = "armada_navalhovercraftplatform",
			[28] = "legmg",
			[29] = "armada_dragonsclaw",
			[30] = "armada_ferret",
			[31] = "legmext15",
			[32] = "cortex_castro",
			[33] = "armada_gauntlet",
			[34] = "armada_chainsaw",
		},
		customparams = {
			unitgroup = 'builder',
			area_mex_def = "armada_metalextractor",
			iscommander = true,
			--energyconv_capacity = 70,
			--energyconv_efficiency = 1/70,
			model_author = "FireStorm",
			normaltex = "unittextures/Arm_normal.dds",
			paralyzemultiplier = 0.025,
			subfolder = "",
			shield_color_mult = 0.8,
			shield_power = 1000,
			shield_radius = 150,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "0 0 0",
				collisionvolumescales = "47 10 47",
				collisionvolumetype = "CylY",
				damage = 10000,
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 20,
				hitdensity = 100,
				metal = 2000,
				object = "Units/armada_commander_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 5000,
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 1000,
				object = "Units/armada_2x2F.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:com_sea_laser_bubbles",
				[2] = "custom:barrelshot-medium",
				[3] = "custom:footstep-medium",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg3",
				[2] = "deathceg4",
			},
		},
		sounds = {
			build = "nanlath1",
			canceldestruct = "cancel2",
			capture = "capture1",
			cloak = "kloak1",
			repair = "repair1",
			uncloak = "kloak1un",
			underattack = "warning2",
			unitcomplete = "armada_commandersel",
			working = "reclaim1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "armada_commander1",
				[2] = "armada_commander2",
				[3] = "armada_commander3",
				[4] = "armada_commander4",
			},
			select = {
				[1] = "armada_commandersel",
			},
		},
		weapondefs = {
			cortex_pounder_weapon = {
				areaofeffect = 144,
				avoidfeature = false,
				burnblow = true,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.9,
				explosiongenerator = "custom:genericshellexplosion-medium",
				impulsefactor = 1.8,
				name = "RiotCannon",
				noselfdamage = true,
				range = 315,
				reloadtime = 1.8,
				soundhit = "cortex_pounderhit",
				soundhitwet = "splsmed",
				soundstart = "cortex_pounder",
				soundhitvolume = 11.5,
				soundstartvolume = 13.0,
				separation = 2.0,
				nogap = false,
				sizeDecay = 0.08,
				stages = 12,
				alphaDecay = 0.10,
				turret = true,
				weapontype = "Cannon",
				weaponvelocity = 550,
				damage = {
					default = 190,
					subs = 70,
					vtol = 27,
				},
			},
			torpedo = {
				areaofeffect = 16,
				avoidfeature = false,
				avoidfriendly = true,
				burnblow = true,
				cegtag = "torpedotrail-tiny",
				collidefriendly = true,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.55,
				explosiongenerator = "custom:genericshellexplosion-small-uw",
				flighttime = 1.8,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				model = "cortex_torpedo.s3o",
				name = "Level1TorpedoLauncher",
				noselfdamage = true,
				predictboost = 1,
				range = 400,
				reloadtime = 1.5,
				soundhit = "xplodep2",
				soundstart = "torpedo1",
				startvelocity = 230,
				tracks = false,
				turnrate = 2500,
				turret = true,
				waterweapon = true,
				weaponacceleration = 50,
				weapontimer = 3,
				weapontype = "TorpedoLauncher",
				weaponvelocity = 200,
				damage = {
					-- commanders = 375,
					default = 250, --278.4375,
					subs = 125,
				},
			},
			ferret_missile = {
				areaofeffect = 16,
				avoidfeature = false,
				burnblow = true,
				canattackground = false,
				cegtag = "missiletrailaa",
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				energypershot = 0,
				explosiongenerator = "custom:genericshellexplosion-tiny-aa",
				firestarter = 72,
				flighttime = 2.5,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				metalpershot = 0,
				model = "cortex_tinymissile.s3o",
				name = "Pop-up rapid-fire g2a missile launcher",
				noselfdamage = true,
				range = 450,
				reloadtime = 0.8,
				smoketrail = true,
				smokePeriod = 6,
				smoketime = 12,
				smokesize = 4.6,
				smokecolor = 0.95,
				smokeTrailCastShadow = false,
				castshadow = false,
				soundhit = "packohit",
				soundhitwet = "splshbig",
				soundstart = "packolau",
				soundtrigger = true,
				startvelocity = 1,
				texture1 = "null",
				texture2 = "smoketrailaa3",
				tolerance = 9950,
				tracks = true,
				turnrate = 68000,
				turret = true,
				weaponacceleration = 1200,
				weapontimer = 2,
				weapontype = "MissileLauncher",
				weaponvelocity = 1000,
				damage = {
					vtol = 150,
					commanders = 1,
				},
			},
			empgrenade = {
				areaofeffect = 200,
				avoidfeature = false,
				commandfire = true,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.25,
				explosiongenerator = "custom:genericshellexplosion-large-lightning",
				gravityaffected = "true",
				impulseboost = 0.001,
				impulsefactor = 0.001,
				model = "airbomb.s3o",
				name = "EMP Grenade",
				noselfdamage = true,
				paralyzer = true,
				paralyzetime = 7,
				range = 300,
				reloadtime = 8,
				soundhit = "EMGPULS1",
				soundhitwet = "splslrg",
				soundstart = "bombrel",
				turret = true,
				weapontype = "Cannon",
				weaponvelocity = 240,
				damage = {
					default = 10000,
				},
			},
			repulsor = {
				avoidfeature = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				name = "PlasmaRepulsor",
				range = 150,
				soundhitwet = "sizzle",
				weapontype = "Shield",
				damage = {
					default = 100,
				},
				shield = {
					alpha = 0.17,
					armortype = "shields",
					energyupkeep = 0,
					force = 1.5,
					intercepttype = 1,
					power = 1000,
					powerregen = 20,
					powerregenenergy = 100,
					radius = 150,
					repulser = true,
					smart = true,
					startingpower = 300,
					visiblerepulse = true,
					badcolor = {
						[1] = 1,
						[2] = 0.2,
						[3] = 0.2,
						[4] = 0.2,
					},
					goodcolor = {
						[1] = 0.2,
						[2] = 1,
						[3] = 0.2,
						[4] = 0.17,
					},
				},
			},
		},
		weapons = {
			[1] = {
				def = "cortex_pounder_WEAPON",
				onlytargetcategory = "SURFACE",
			},
			[2] = {
				badtargetcategory = "VTOL",
				def = "TORPEDO",
				onlytargetcategory = "NOTAIR"
			},
			[3] = {
				def = "EMPGRENADE",
				onlytargetcategory = "NOTSUB",
			},
			[4] = {
				badtargetcategory = "NOTAIR GROUNDSCOUT",
				def = "FERRET_MISSILE",
				onlytargetcategory = "VTOL",
			},
			[5] = {
				def = "REPULSOR",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
