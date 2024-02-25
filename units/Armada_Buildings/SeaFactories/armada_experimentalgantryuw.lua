return {
	armada_experimentalgantryuw = {
		maxacc = 0,
		maxdec = 0,
		energycost = 58000,
		metalcost = 7900,
		builder = true,
		buildpic = "armada_experimentalgantryUW.DDS",
		buildtime = 61400,
		canmove = true,
		category = "ALL NOTSUB NOWEAPON NOTAIR NOTHOVER SURFACE UNDERWATER EMPABLE",
		collisionvolumeoffsets = "0 0 8",
		collisionvolumescales = "137 75 145",
		collisionvolumetype = "Box",
		corpse = "armada_seekerLT_DEAD",
		energystorage = 1400,
		explodeas = "hugeBuildingexplosiongeneric-uw",
		footprintx = 9,
		footprintz = 9,
		idleautoheal = 5,
		idletime = 1800,
		health = 16000,
		maxslope = 10,
		metalstorage = 800,
		minwaterdepth = 30,
		objectname = "Units/armada_experimentalgantry.s3o",
		script = "Units/armada_experimentalgantry.cob",
		seismicsignature = 0,
		selfdestructas = "hugeBuildingExplosionGenericSelfd-uw",
		sightdistance = 273,
		terraformspeed = 3000,
		workertime = 600,
		yardmap = "ooooooooooooooooooooooooooooooooooooooooooooocccccccccccccccccccccccccccccccccccc",
		buildoptions = {
			[1] = "armada_titan",
			[2] = "armmar",
			[3] = "armcroc",
			[4] = "armada_lunkhead",
		},
		customparams = {
			usebuildinggrounddecal = true,
			buildinggrounddecaltype = "decals/armada_experimentalgantry_aoplane.dds",
			buildinggrounddecalsizey = 10,
			buildinggrounddecalsizex = 10,
			buildinggrounddecaldecayspeed = 30,
			unitgroup = 'buildert3',
			model_author = "Cremuss",
			normaltex = "unittextures/Arm_normal.dds",
			subfolder = "armada_buildings/seafactories",
			techlevel = 3,
		},
		featuredefs = {
			armada_seekerlt_dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "0 0 0",
				collisionvolumescales = "125 75 145",
				collisionvolumetype = "Box",
				damage = 8640,
				energy = 0,
				featuredead = "armada_seekerLT_HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 9,
				footprintz = 9,
				height = 20,
				hitdensity = 100,
				metal = 4807,
				object = "Units/armada_experimentalgantry_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			armada_seekerlt_heap = {
				blocking = false,
				category = "heaps",
				damage = 4320,
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 9,
				footprintz = 9,
				height = 4,
				hitdensity = 100,
				metal = 1923,
				object = "Units/arm7X7D.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:YellowLight",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg3",
				[2] = "deathceg4",
			},
		},
		sounds = {
			activate = "gantok2",
			build = "gantok2",
			canceldestruct = "cancel2",
			deactivate = "gantok2",
			repair = "lathelrg",
			underattack = "warning1",
			unitcomplete = "gantok1",
			working = "build",
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			select = {
				[1] = "gantsel1",
			},
		},
	},
}
