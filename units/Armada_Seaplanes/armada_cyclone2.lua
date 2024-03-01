return {
	armada_cyclone2 = {
		acceleration = 0.35,
		airsightdistance = 950,
		blocking = false,
		maxdec = 0.1,
		energycost = 4500,
		metalcost = 90,
		buildpic = "armada_cyclone2.DDS",
		buildtime = 5500,
		canfly = true,
		canmove = true,
		cansubmerge = true,
		category = "ALL NOTLAND MOBILE WEAPON NOTSUB VTOL NOTSHIP NOTHOVER",
		collide = false,
		cruisealtitude = 140,
		explodeas = "smallExplosionGenericAir",
		footprintx = 2,
		footprintz = 2,
		maxacc = 0.2075,
		maxaileron = 0.01403,
		maxbank = 0.8,
		health = 220,
		maxelevator = 0.01028,
		maxpitch = 0.625,
		maxrudder = 0.00578,
		maxslope = 10,
		speed = 310.8,
		maxwaterdepth = 255,
		nochasecategory = "NOTAIR",
		objectname = "Units/armada_cyclone2.s3o",
		script = "Units/armada_cyclone2.cob",
		seismicsignature = 0,
		selfdestructas = "smallExplosionGenericAir",
		sightdistance = 230,
		speedtofront = 0.07,
		turnradius = 64,
		turnrate = 750,
		usesmoothmesh = true,
		wingangle = 0.06278,
		wingdrag = 0.235,
		customparams = {
			unitgroup = 'aa',
			model_author = "FireStorm",
			normaltex = "unittextures/Arm_normal.dds",
			subfolder = "armada_seaplanes",
			fighter = 1,
		},
		sfxtypes = {
			crashexplosiongenerators = {
				[1] = "crashing-tiny",
				[2] = "crashing-tiny2",
			},
			pieceexplosiongenerators = {
				[1] = "airdeathceg2",
				[2] = "airdeathceg3",
				[3] = "airdeathceg4",
			},
		},
		sounds = {
			build = "nanlath1",
			canceldestruct = "cancel2",
			repair = "repair1",
			underattack = "warning1",
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
				[1] = "vtolcrmv",
			},
			select = {
				[1] = "seapsel1",
			},
		},
		weapondefs = {
			armada_cyclone_weapon = {
				areaofeffect = 8,
				avoidfeature = false,
				avoidfriendly = false,
				burnblow = true,
				canattackground = false,
				cegtag = "missiletrailfighter",
				collidefriendly = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:genericshellexplosion-tiny-air",
				firestarter = 0,
				flighttime = 1.3,
				impulseboost = 0,
				impulsefactor = 0,
				metalpershot = 0,
				model = "cortex_tinymissile.s3o",
				name = "Guided a2a missile launcher",
				noselfdamage = true,
				range = 710,
				reloadtime = 0.83333,
				smoketrail = false,
				smokePeriod = 4,
				smoketime = 8,
				smokesize = 1.8,
				smokecolor = 0.55,
				smokeTrailCastShadow = false,
				castshadow = false,
				soundhit = "xplosml2",
				soundhitwet = "splshbig",
				soundstart = "Rocklit3",
				startvelocity = 480,
				texture1 = "null",
				texture2 = "smoketrail",
				tolerance = 8000,
				tracks = true,
				turnrate = 22000,
				turret = true,
				weaponacceleration = 425,
				weapontimer = 5,
				weapontype = "MissileLauncher",
				weaponvelocity = 900,
				damage = {
					commanders = 4,
					default = 12,
					vtol = 210,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "NOTAIR",
				def = "armada_cyclone_WEAPON",
				onlytargetcategory = "VTOL",
			},
		},
	},
}
