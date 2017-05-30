
return {
	["COMMANDER_EXPLOSION"] = {

		GROUNDFLASH = {
			flashsize=1000,
			flashalpha=0.4,
			circlegrowth=25,
			circlealpha=0,
			ttl=35,
			color={1,0.75,0.6},
		},

		pop1 = {
			class=[[heatcloud]],
			air=1,
			water=1,
			ground=1,
			count=2,
			properties ={
				alwaysVisible=1,
				texture=[[fireball]],
				heat = 10,
				maxheat = 10,
				heatFalloff = 0.7,
				size = 2,
				sizeGrowth = 22,
				pos = [[r-10 r10, 0, r-10 r10]],
				speed=[[0, 0, 0]],
			},
		},

		innersmoke = {
			class = [[CSimpleParticleSystem]],
			water=0,
			air=1,
			ground=1,
			count=1,
			properties = {
				alwaysVisible = 1,
				sizeGrowth = 1.08,
				sizeMod = 1.0,
				pos = [[r-1 r1, 0, r-1 r1]],
				emitRot=35,
				emitRotSpread=70,
				emitVector = [[0, 1, 0]],
				gravity = [[0, 0.015, 0]],
				colorMap=[[1 0.55 0.4 0.45    0.45 0.18 0.09 0.77   0.3 0.17 0.12 0.7    0.2 0.16 0.14 0.55   0.1 0.095 0.088 0.25   0.07 0.065 0.058 0.15    0 0 0 0.01]],
				Texture=[[graysmoke]],
				airdrag=0.66,
				particleLife=20,
				particleLifeSpread=250,
				numParticles=60,
				particleSpeed=2,
				particleSpeedSpread=63,
				particleSize=30,
				particleSizeSpread=6,
				directional=1,
			},
		},

		outersmoke = {
			class = [[CSimpleParticleSystem]],
			water=0,
			air=1,
			ground=1,
			count=1,
			properties = {
				alwaysVisible = 1,
				sizeGrowth = 1.08,
				sizeMod = 1.0,
				pos = [[r-1 r1, 0, r-1 r1]],
				emitRot=35,
				emitRotSpread=70,
				emitVector = [[0, 1, 0]],
				gravity = [[0, 0.015, 0]],
				colorMap=[[1 0.55 0.4 0.45    0.42 0.16 0.07 0.77   0.2 0.16 0.14 0.55   0.1 0.095 0.088 0.25    0 0 0 0.01]],
				Texture=[[graysmoke]],
				airdrag=0.77,
				particleLife=10,
				particleLifeSpread=140,
				numParticles=220,
				particleSpeed=15,
				particleSpeedSpread=40,
				particleSize=25,
				particleSizeSpread=6,
				directional=1,
			},
		},

		dirt = {
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water        			 = true,
			air        			   = true,
			properties = {
				airdrag            = 0.96,
				colormap           = [[ 0.1 0.07 0.033 0.66    0.02 0.02 0.2 0.4   0.08 0.065 0.035 0.55   0.075 0.07 0.06 0.4   0 0 0 0  ]],
				directional        = true,
				emitrot            = 25,
				emitrotspread      = 35,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, -0.55, 0]],
				numparticles       = 45,
				particlelife       = 200,
				particlelifespread = 50,
				particlesize       = 3.2,
				particlesizespread = -2.7,
				particlespeed      = 10,
				particlespeedspread = 17,
				pos                = [[0, 10, 0]],
				sizegrowth         = 0,
				sizemod            = 1,
				texture            = [[bigexplosmoke]],
				useairlos          = true,
			},
		},

		dirtbig = {
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water        	   = true,
			underwater         = true,
			properties = {
				airdrag            = 0.96,
				colormap           = [[0.04 0.03 0.01 0.05   0.1 0.07 0.033 0.66    0.02 0.02 0.2 0.4   0.08 0.065 0.035 0.55   0.075 0.07 0.06 0.4   0 0 0 0  ]],
				directional        = true,
				emitrot            = 25,
				emitrotspread      = 25,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, -0.85, 0]],
				numparticles       = 35,
				particlelife       = 150,
				particlelifespread = 50,
				particlesize       = 4,
				particlesizespread = -3.3,
				particlespeed      = 9,
				particlespeedspread = 16,
				pos                = [[0, 10, 0]],
				sizegrowth         = 0,
				sizemod            = 1,
				texture            = [[bigexplosmoke]],
				useairlos          = true,
			},
		},

		sparks = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			properties = {
				airdrag            = 0.98,
				colormap           = [[0.9 0.5 0.2 0.022   0.5 0.3 0.1 0.013   0.04 0.03 0.01 0.07   0.01 0.01 0 0.015]],
				directional        = true,
				emitrot            = 22,
				emitrotspread      = 66,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, -0.11, 0]],
				numparticles       = 20,
				particlelife       = 25,
				particlelifespread = 70,
				particlesize       = 5,
				particlesizespread = 7,
				particlespeed      = 7.5,
				particlespeedspread = 11,
				pos                = [[0, 4, 0]],
				sizegrowth         = -0.007,
				sizemod            = 1,
				texture            = [[gunshotglow]],
				useairlos          = false,
			},
		},

		electricstorm = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 25,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[10 r180]],
				explosiongenerator = [[custom:lightning_stormbolt]],
				pos                = [[-190 r380, 2 r60, -190 r380]],
			},
		},

	}
}
