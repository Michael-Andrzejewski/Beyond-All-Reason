-- watersplash_large

return {
  ["watersplash_large"] = {
    waterball = {
      air                = false,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = false,
      underwater         = 1,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[0 0 0 0  0.8 0.8 1 .1     0.9 .9 0.95 .8  	0 0 0 0.01]],
        directional        = true,
        emitrot            = 30,
        emitrotspread      = [[0 r-360 r360]],
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 45,
        particlelife       = 4,
        particlelifespread = 28,
        particlesize       = 0.70,
        particlesizespread = 4,
        particlespeed      = [[0 r3 i-0.05]],
        particlespeedspread = 2,
        pos                = [[0 r-10 r10, 2 r5, 0 r-10 r10]],
        sizegrowth         = [[-0.30 r1.6 r-1.6]],
        sizemod            = 1.0,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    waterball2 = {
      air                = false,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = false,
      underwater         = 1,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[0 0 0 0  0.8 0.8 1 .1     0.9 .9 0.95 .8  	0 0 0 0.01]],
        directional        = true,
        emitrot            = 90,
        emitrotspread      = 0,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 50,
        particlelife       = 4,
        particlelifespread = 24,
        particlesize       = [[2 r4]],
        particlesizespread = 0,
        particlespeed      = [[4 i0.25]],
        particlespeedspread = 0,
        pos                = [[0 r-10 r10,4, 0 r-10 r10]],
        sizegrowth         = [[0.10]],
        sizemod            = 1.0,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
    waterexplosion = {
      air                = false,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = false,
      underwater         = 1,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[1 1 1 1   0.8 0.8 1 1 	0 0 0 0.01]],
        directional        = false,
        emitrot            = 0,
        emitrotspread      = [[20 r-20 r20]],
        emitvector         = [[0,1,0]],
        gravity            = [[0, -.25, 0]],
        numparticles       = 40,
        particlelife       = 20,
        particlelifespread = 18,
        particlesize       = 5,
        particlesizespread = 10,
        particlespeed      = [[3 i0.25]],
        particlespeedspread = 2,
        pos                = [[0, 18, 0]],
        sizegrowth         = -0.25,
        sizemod            = 1.0,
        texture            = [[dirt]],
        useairlos          = true,
      },
    },
  },
}

