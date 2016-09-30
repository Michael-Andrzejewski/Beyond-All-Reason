-- missiletrailblue
-- missiletrail
-- missiletrailsmall
-- missiletrailgunshiplesssmokey
-- missiletrailbomber
-- missiletrailflashy
-- missiletrailnuke
-- missiletrailaa
-- missiletrailgunship
-- missiletrailgreen

return {
  ["missiletrailblue"] = {
    groundflash = {
      circlealpha        = 0.1,
      circlegrowth       = 3,
      flashalpha         = 1,
      flashsize          = 12,
      ttl                = 8,
      color = {
        [1]  = 0.80000001192093,
        [2]  = 0.10000000149012,
        [3]  = 0,
      },
    },
    searingflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.8,
        alwaysvisible      = true,
        colormap           = [[0.9 0.5 0.4 0.04   0.9 0.4 0.1 0.01  0.5 0.1 0.1 0.01]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.01, 0]],
        numparticles       = 2,
        particlelife       = 10,
        particlelifespread = 5,
        particlesize       = 20,
        particlesizespread = 0,
        particlespeed      = 5,
        particlespeedspread = 5,
        pos                = [[0, 2, 0]],
        sizegrowth         = 1,
        sizemod            = 0.5,
        texture            = [[gunshot]],
        useairlos          = false,
      },
    },
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.70,
        alwaysvisible      = true,
        colormap           = [[0.1 0.1 0.1 0.01    0.0 0.3 0.5 0.05    0.1 0.1 0.5 1.0    0.1 0.1 0.1 1.0    0.5 0.5 0.5 1.0   0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.0, 0.0]],
        numparticles       = 3,
        particlelife       = 50,
        particlelifespread = 4,
        particlesize       = 2,
        particlesizespread = 40,
        particlespeed      = 0,
        particlespeedspread = 2,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = -0.2,
        sizemod            = 1,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
  },

  ["missiletrail"] = {
    core = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.70,
        alwaysvisible      = true,
        colormap           = [[0.1 0.1 0.1 0.01    0.4 0.25 0.0 0.04    0.1 0.1 0.1 0.005	0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.0, 0.0]],
        numparticles       = 2,
        particlelife       = 5,
        particlelifespread = 4,
        particlesize       = 1,
        particlesizespread = 20,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = -0.1,
        sizemod            = 1,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.70,
        alwaysvisible      = true,
        colormap           = [[0.4 0.25 0.0 0.04    0.22 0.22 0.22 0.04	0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.0, 0.0]],
        numparticles       = 2,
        particlelife       = 10,
        particlelifespread = 4,
        particlesize       = 1,
        particlesizespread = 20,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = -0.1,
        sizemod            = 1,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
  },

  ["missiletrailsmall"] = {
    groundflash = {
      circlealpha        = 0,
      circlegrowth       = 0,
      flashalpha         = 0.03,
      flashsize          = 45,
      ttl                = 10,
      color = {
        [1]  = 1,
        [2]  = 0.75,
        [3]  = 0.25,
      },
    },
    searingflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.8,
        alwaysvisible      = true,
        colormap           = [[0.9 0.5 0.4 0.04   0.9 0.4 0.1 0.01  0.5 0.1 0.1 0.01]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.01, 0]],
        numparticles       = 5,
        particlelife       = 3,
        particlelifespread = 1,
        particlesize       = 8,
        particlesizespread = 0,
        particlespeed      = 1,
        particlespeedspread = 1,
        pos                = [[0, 2, 0]],
        sizegrowth         = 1,
        sizemod            = 0.5,
        texture            = [[gunshot]],
        useairlos          = false,
      },
    },
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.60,
        alwaysvisible      = true,
        colormap           = [[0.4 0.27 0.25 0.2   0.44 0.3 0 0.24    0.35 0.22 0 0.16    0.08 0.06 0.02 0.05	   0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 5,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.15, 0.0]],
        numparticles       = 8,
        particlelife       = 6,
        particlelifespread = 10,
        particlesize       = 4,
        particlesizespread = 8,
        particlespeed      = 1,
        particlespeedspread = 1,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = -0.3,
        sizemod            = 0.9,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    exhale = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.60,
        alwaysvisible      = true,
        colormap           = [[0.03 0.03 0.03 0.08   0.07 0.07 0.07 0.13   0.05 0.05 0.05 0.07    0.02 0.02 0.02 0.03    0 0 0 0]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 5,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, -0.07, 0.0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 30,
        particlesize       = 1.5,
        particlesizespread = 12,
        particlespeed      = 3,
        particlespeedspread = 0,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = 0.6,
        sizemod            = 0.95,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    exhale2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.6,
        alwaysvisible      = true,
        colormap           = [[0.03 0.03 0.03 0  0.06 0.06 0.06 0.08   0.05 0.05 0.05 0.06   0 0 0 0]],
        directional        = true,
        emitrot            = 4,
        emitrotspread      = 4,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.06, 0]],
        numparticles       = 2,
        particlelife       = 10,
        particlelifespread = 15,
        particlesize       = 3,
        particlesizespread = 12,
        particlespeed      = 3,
        particlespeedspread = 3,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.6,
        sizemod            = 1.0,
        texture            = [[bigexplosmoke]],
      },
    },
  },

  ["missiletrailgunshiplesssmokey"] = {
    groundflash = {
      circlealpha        = 0,
      circlegrowth       = 0,
      flashalpha         = 0.13,
      flashsize          = 90,
      ttl                = 10,
      color = {
        [1]  = 0.80000001192093,
        [2]  = 0.50000000149012,
        [3]  = 0.15,
      },
    },
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.60,
        alwaysvisible      = true,
        colormap           = [[0.42 0.27 0.25 0.26   0.46 0.3 0 0.3    0.38 0.22 0 0.24    0.09 0.065 0.05 0.1	   0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 5,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.15, 0.0]],
        numparticles       = 8,
        particlelife       = 0,
        particlelifespread = 25,
        particlesize       = 8,
        particlesizespread = 12,
        particlespeed      = 2,
        particlespeedspread = 1,
        pos                = [[0.0, 2, 0.0]],
        sizegrowth         = -0.22,
        sizemod            = 0.9,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    searingflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.8,
        alwaysvisible      = true,
        colormap           = [[0.9 0.5 0.4 0.04   0.9 0.4 0.1 0.01  0.5 0.1 0.1 0.01]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.01, 0]],
        numparticles       = 6,
        particlelife       = 1,
        particlelifespread = 10,
        particlesize       = 14,
        particlesizespread = 0,
        particlespeed      = 1,
        particlespeedspread = 1,
        pos                = [[0, 2, 0]],
        sizegrowth         = 1,
        sizemod            = 0.5,
        texture            = [[gunshot]],
        useairlos          = false,
      },
    },
    exhale4 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.60,
        alwaysvisible      = true,
        colormap           = [[0.03 0.03 0.03 0.25	   0.11 0.11 0.11 0.22   0.11 0.11 0.11 0.13    0.03 0.03 0.03 0.06    0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 5,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, -0.07, 0.0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 30,
        particlesize       = 1.5,
        particlesizespread = 12,
        particlespeed      = 3,
        particlespeedspread = 0,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = 0.6,
        sizemod            = 0.99,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    exhale5 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.6,
        alwaysvisible      = true,
        colormap           = [[0.03 0.03 0.03 0  0.07 0.07 0.07 0.11   0.075 0.075 0.075 0.05   0 0 0 0]],
        directional        = true,
        emitrot            = 4,
        emitrotspread      = 4,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.04, 0]],
        numparticles       = 2,
        particlelife       = 10,
        particlelifespread = 15,
        particlesize       = 3,
        particlesizespread = 12,
        particlespeed      = 3,
        particlespeedspread = 3,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.6,
        sizemod            = 1.02,
        texture            = [[bigexplosmoke]],
      },
    },
    exhale = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.1 0.1 0.1 0.2		0.3 0.3 0.3 0.2		0.2 0.2 0.2 0.1		0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 2,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 3,
        particlelife       = 8,
        particlelifespread = 40,
        particlesize       = 8,
        particlesizespread = 1,
        particlespeed      = 2,
        particlespeedspread = 1,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.2,
        sizemod            = 0.8,
        texture            = [[smoke]],
      },
    },
	coreflame2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = false,
      underwater         = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.3 0.3 0.3 0.01    0.3 0.3 0.3 0.05    0.1 0.1 0.1 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 5,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.1, 0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 0,
        particlesize       = 6,
        particlesizespread = 1,
        particlespeed      = 1,
        particlespeedspread = 1,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.20,
        sizemod            = 1.0,
        texture            = [[randomdots]],
      },
    },
  },

  ["missiletrailbomber"] = {
    coreflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.1 0.1 0.1 0.01    0.5 0.3 0.0 0.05    0.5 0.1 0.1 1.0    0.1 0.1 0.1 1.0    0.5 0.5 0.5 1.0   0 0 0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 0,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 4,
        particlelife       = 50,
        particlelifespread = 0,
        particlesize       = 5,
        particlesizespread = 1,
        particlespeed      = 0,
        particlespeedspread = 5,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[smoke]],
      },
    },
    exhale = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.7 0.5 0.2 0.1 0.15 0.15 0.15 0.2 0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 5,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 4,
        particlelife       = 100,
        particlelifespread = 15,
        particlesize       = 13,
        particlesizespread = 1,
        particlespeed      = 2,
        particlespeedspread = 5,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[smoke]],
      },
    },
  },

  ["missiletrailflashy"] = {
    groundflash = {
      circlealpha        = 0,
      circlegrowth       = 0,
      flashalpha         = 0.07,
      flashsize          = 38,
      ttl                = 10,
      color = {
        [1]  = 0.80000001192093,
        [2]  = 0.50000000149012,
        [3]  = 0.15,
      },
    },
    searingflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.8,
        alwaysvisible      = true,
        colormap           = [[0.9 0.5 0.4 0.04   0.9 0.4 0.1 0.01  0.5 0.1 0.1 0.01]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.01, 0]],
        numparticles       = 6,
        particlelife       = 4,
        particlelifespread = 1,
        particlesize       = 6,
        particlesizespread = 0,
        particlespeed      = 1,
        particlespeedspread = 2,
        pos                = [[0, 2, 0]],
        sizegrowth         = 1,
        sizemod            = 0.5,
        texture            = [[gunshot]],
        useairlos          = false,
      },
    },
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.60,
        alwaysvisible      = true,
        colormap           = [[0.4 0.35 0.3 0.12    0.42 0.3 0.03 0.33    0.4 0.2 0.07 0.5    0.2 0.13 0.1 0.7    0.1 0.1 0.1 0.8    0.5 0.5 0.5 0.85   0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, -0.15, 0.0]],
        numparticles       = 2,
        particlelife       = 40,
        particlelifespread = 20,
        particlesize       = 3,
        particlesizespread = 15,
        particlespeed      = 0,
        particlespeedspread = 1,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = 0,
        sizemod            = 0.9,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
  },

  ["missiletrailnuke"] = {
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.70,
        alwaysvisible      = true,
        colormap           = [[0.1 0.1 0.1 0.01    0.5 0.3 0.0 0.05    0.5 0.1 0.1 1.0    0.1 0.1 0.1 1.0    0.5 0.5 0.5 1.0   0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.0, 0.0]],
        numparticles       = 20,
        particlelife       = 50,
        particlelifespread = 4,
        particlesize       = 2,
        particlesizespread = 40,
        particlespeed      = 0,
        particlespeedspread = 2,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = -0.2,
        sizemod            = 0.8,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
  },

  ["missiletrailaa"] = {
    coreflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.1 0.1 0.1 0.01    0.5 0.3 0.0 0.05    0.5 0.1 0.1 1.0    0.1 0.1 0.1 1.0    0.5 0.5 0.5 1.0   0 0 0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 0,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 0,
        particlesize       = 5,
        particlesizespread = 1,
        particlespeed      = 0,
        particlespeedspread = 5,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[smoke]],
      },
    },
    exhale = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.7 0.5 0.2 0.1 0.15 0.15 0.15 0.2 0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 5,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 4,
        particlelife       = 30,
        particlelifespread = 15,
        particlesize       = 15,
        particlesizespread = 1,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[smoke]],
      },
    },
  },

  ["missiletrailgunship"] = {
    coreflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.1 0.1 0.1 0.01    0.5 0.3 0.0 0.05    0.5 0.1 0.1 1.0    0.1 0.1 0.1 1.0    0.5 0.5 0.5 1.0   0 0 0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 0,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 4,
        particlelife       = 50,
        particlelifespread = 0,
        particlesize       = 5,
        particlesizespread = 1,
        particlespeed      = 0,
        particlespeedspread = 5,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[smoke]],
      },
    },
    exhale = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.7 0.5 0.2 0.1 0.15 0.15 0.15 0.2 0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 5,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 4,
        particlelife       = 100,
        particlelifespread = 15,
        particlesize       = 13,
        particlesizespread = 1,
        particlespeed      = 2,
        particlespeedspread = 5,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[smoke]],
      },
    },
    coreflame2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      underwater         = 1,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.8 0.8 0.8 0.01    0.8 0.8 0.5 0.05    0.1 0.1 0.5 1.0]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 5,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.1, 0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 0,
        particlesize       = 1,
        particlesizespread = 1,
        particlespeed      = 1,
        particlespeedspread = 1,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0.50,
        sizemod            = 1.0,
        texture            = [[randomdots]],
      },
    },
    exhale2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      underwater         = 1,
      water              = true,
      properties = {
        airdrag            = 0.87,
        colormap           = [[0.2 0.2 0.5 0.1 0.15 0.15 0.15 0.05 0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 80,
        emitrotspread      = 5,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.1, 0]],
        numparticles       = 4,
        particlelife       = 30,
        particlelifespread = 15,
        particlesize       = 2,
        particlesizespread = 1,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[0, 1, 0]],
        sizegrowth         = 1,
        sizemod            = 1.0,
        texture            = [[randomdots]],
      },
    },
  },

  ["missiletrailgreen"] = {
    groundflash = {
      circlealpha        = 0.1,
      circlegrowth       = 3,
      flashalpha         = 1,
      flashsize          = 12,
      ttl                = 8,
      color = {
        [1]  = 0.80000001192093,
        [2]  = 0.10000000149012,
        [3]  = 0,
      },
    },
    searingflame = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.8,
        alwaysvisible      = true,
        colormap           = [[0.9 0.5 0.4 0.04   0.9 0.4 0.1 0.01  0.5 0.1 0.1 0.01]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.01, 0]],
        numparticles       = 2,
        particlelife       = 10,
        particlelifespread = 5,
        particlesize       = 10,
        particlesizespread = 0,
        particlespeed      = 5,
        particlespeedspread = 5,
        pos                = [[0, 2, 0]],
        sizegrowth         = 1,
        sizemod            = 0.5,
        texture            = [[gunshot]],
        useairlos          = false,
      },
    },
    smokeandfire = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.70,
        alwaysvisible      = true,
        colormap           = [[0.1 0.1 0.1 0.01    0.0 0.5 0.3 0.05    0.1 0.5 0.1 1.0    0.1 0.2 0.1 1.0    0.3 0.5 0.3 1.0   0 0.2 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0.0, 1, 0.0]],
        gravity            = [[0.0, 0.0, 0.0]],
        numparticles       = 10,
        particlelife       = 5,
        particlelifespread = 4,
        particlesize       = 15,
        particlesizespread = 40,
        particlespeed      = 0,
        particlespeedspread = 2,
        pos                = [[0.0, 1, 0.0]],
        sizegrowth         = -1,
        sizemod            = 0.9,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
  },

}

