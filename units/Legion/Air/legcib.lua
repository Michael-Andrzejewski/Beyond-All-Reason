return {
	legcib = {
		acceleration = 0.2,
		blocking = false,
		maxdec = 0.055,
		energycost = 3500,
		metalcost = 100,
		buildpic = "LEGCIB.DDS",
		buildtime = 4200,
		canfly = true,
		canmove = true,
		category = "ALL MOBILE WEAPON NOTLAND VTOL NOTSUB NOTSHIP NOTHOVER",
		collide = true,
		cruisealtitude = 130,
		explodeas = "mediumexplosiongeneric",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 1800,
		maxacc = 0.1825,
		maxaileron = 0.0144,
		maxbank = 0.8,
		health = 890,
		maxelevator = 0.01065,
		maxpitch = 0.625,
		maxrudder = 0.00615,
		maxslope = 10,
		speed = 300.0,
		maxwaterdepth = 0,
		noautofire = true,
		nochasecategory = "VTOL",
		objectname = "Units/LEGCIB.s3o",
		script = "Units/LEGCIB.cob",
		seismicsignature = 0,
		selfdestructas = "mediumExplosionGenericSelfd",
		sightdistance = 835,
		speedtofront = 0.06183,
		turnradius = 64,
		turnrate = 800,
		usesmoothmesh = true,
		wingangle = 0.06296,
		wingdrag = 0.08,
		customparams = {
			unitgroup = 'weapon',
			model_author = "ZephyrSkies",
			normaltex = "unittextures/leg_normal.dds",
			subfolder = "coraircraft",
		},
		sfxtypes = {
			crashexplosiongenerators = {
				[1] = "crashing-small",
				[2] = "crashing-small",
				[3] = "crashing-small2",
				[4] = "crashing-small3",
				[5] = "crashing-small3",
			},
			pieceexplosiongenerators = {
				[1] = "airdeathceg2",
				[2] = "airdeathceg3",
				[3] = "airdeathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
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
				[1] = "vtolcrmv",
			},
			select = {
				[1] = "vtolcrac",
			},
		},
		weapondefs = {
			juno_pulse_mini = {
				accuracy = 500,
				areaofeffect = 700,
				avoidfeature = false,
				cegtag = "missiletrail-juno",
				collidefriendly = false,
				commandfire = false,
				craterareaofeffect = 600,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 1,
				explosiongenerator = "custom:juno-explo-mini",
				impulseboost = 0,
				impulsefactor = 0,
				model = "legmediumrocket.s3o",
				name = "Anti radar/minefield/jammer magnetic impulse bomb",
				range = 1280,
				reloadtime = 10,
				smoketrail = true,
				smokePeriod = 8,
				smoketime = 45,
				smokesize = 14.0,
				smokecolor = 0.7,
				smokeTrailCastShadow = false,
				castshadow = true, --projectile
				soundhit = "junohit2",
				soundstart = "bombrel",
				sprayangle = 300,
				weapontype = "AircraftBomb",
				customparams = {
					lups_noshockwave = 1,
					nofire = true,
				},
				damage = {
					default = 1,
					mines = 1000,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "MOBILE",
				def = "JUNO_PULSE_MINI",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
