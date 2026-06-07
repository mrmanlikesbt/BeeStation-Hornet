/obj/emitter/fire_smoke
	alpha = 150
	particles = new/particles/fire_smoke

/obj/emitter/fire_smoke/Initialize(mapload)
	. = ..()
	add_filter("blur", 1, list(type="blur", size=3))


/obj/emitter/flare_smoke
	particles = new/particles/smoke
	layer = OBJ_LAYER

CREATION_TEST_IGNORE_SUBTYPES(/obj/emitter/flare_smoke)

/obj/emitter/flare_smoke/Initialize(mapload, time, _color)
	. = ..()
	add_filter("blur", 1, list(type="blur", size=1.5))

/particles/smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = list(6, 0, 0)
	drift = generator("sphere", 0, 2, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.95)
	grow = 0.05

// Fog
/obj/emitter/fog
	alpha = 150
	particles = new/particles/fog

/particles/fog
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	color = "#DEF4EB"
	count = 200
	spawning = 6
	lifespan = 32
	fade = 27
	#ifndef SPACEMAN_DMM
	fadein = 5
	#endif
	position = generator("box", list(-12, 5, -12), list(12, 10, 12), UNIFORM_RAND)
	gravity = null
	velocity = list(0, -0.9, 0)
	friction = list(0, 0.01, 0)
	drift = generator("box", list(-0.04, 0, 0), list(0.04, 0, 0), UNIFORM_RAND)
