return {
	cortex_herring = {
		maxacc = 0.05,
		activatewhenbuilt = true,
		airsightdistance = 800,
		autoheal = 1.5,
		maxdec = 0.06473,
		energycost = 1400,
		metalcost = 210,
		buildpic = "cortex_herring.DDS",
		buildtime = 2500,
		canmove = true,
		category = "ALL MOBILE WEAPON NOTLAND SHIP NOTSUB NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0 -3 -1",
		collisionvolumescales = "20 20 60",
		collisionvolumetype = "box",
		corpse = "DEAD",
		explodeas = "smallExplosionGeneric",
		floater = true,
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 900,
		health = 890,
		speed = 69.0,
		minwaterdepth = 6,
		movementclass = "BOAT3",
		nochasecategory = "VTOL UNDERWATER",
		objectname = "Units/cortex_herring.s3o",
		radardistance = 1000,
		radaremitheight = 25,
		script = "Units/cortex_herring.cob",
		seismicsignature = 0,
		selfdestructas = "smallExplosionGenericSelfd",
		sightdistance = 670,
		sonardistance = 400,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 520.5,
		waterline = 0,
		customparams = {
			unitgroup = 'weaponaa',
			model_author = "Mr Bob",
			normaltex = "unittextures/cor_normal.dds",
			paralyzemultiplier = 0.3,
			subfolder = "cortex_ships",
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "-3.69921112061 1.72119140629e-06 -0.0",
				collisionvolumescales = "32.8984222412 14.8354034424 64.0",
				collisionvolumetype = "Box",
				damage = 500,
				energy = 0,
				featuredead = "HEAP",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 97.5,
				object = "Units/cortex_herring_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "55.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 1432,
				energy = 0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 48.75,
				object = "Units/cortex_3x3A.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:waterwake-tiny",
				[2] = "custom:radarpulse_t1",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
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
				[1] = "shcormov",
			},
			select = {
				[1] = "shcorsel",
			},
		},
		weapondefs = {
			cortruck_missile = {
				areaofeffect = 48,
				avoidfeature = false,
				cegtag = "missiletrailtiny",
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:genericshellexplosion-tiny",
				firestarter = 70,
				flighttime = 2,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				metalpershot = 0,
				model = "cortex_tinymissile.s3o",
				name = "Missiles",
				noselfdamage = true,
				range = 650,
				reloadtime = 2.0,
				smoketrail = true,
				smokePeriod = 8,
				smoketime = 15,
				smokesize = 6.0,
				smokecolor = 0.7,
				smokeTrailCastShadow = false,
				castshadow = true, --projectile
				soundhit = "rockhit2",
				soundhitwet = "splssml",
				soundstart = "rockhvy2",
				soundstartvolume = 8.5,
				startvelocity = 420,
				texture1 = "null",
				texture2 = "smoketrailbar",
				tolerance = 8000,
				tracks = true,
				turnrate = 63000,
				turret = true,
				weaponacceleration = 110,
				weapontimer = 5,
				weapontype = "MissileLauncher",
				weaponvelocity = 680,
				damage = {
					default = 47,
					vtol = 120,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "NOTAIR",
				def = "CORTRUCK_MISSILE",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
