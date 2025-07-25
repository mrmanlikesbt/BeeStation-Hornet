/*
Because mapping is already tedious enough this spawner let you spawn generic
"sets" of objects rather than having to make the same object stack again and
again.
*/

/obj/effect/spawner/structure
	name = "map structure spawner"
	density = TRUE
	var/list/spawn_list

/obj/effect/spawner/structure/Initialize(mapload)
	. = ..()
	// When spawner is created at a holodeck template
	var/area/holodeck/holodeck_area = get_area(src)
	if(istype(holodeck_area, /area/holodeck))
		var/obj/machinery/computer/holodeck/holocomputer = holodeck_area.linked
		for(var/spawn_type as anything in spawn_list)
			holocomputer.from_spawner += new spawn_type(loc)
		return
	// standard init
	for(var/spawn_type in spawn_list)
		new spawn_type(loc)

//normal windows

/obj/effect/spawner/structure/window
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "window_spawner"
	name = "window spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/fulltile)
	dir = SOUTH
	FASTDMM_PROP(\
		pipe_astar_cost = 1\
	)

/obj/effect/spawner/structure/window/Initialize(mapload)
	. = ..()

	if (is_station_level(z))
		var/turf/current_turf = get_turf(src)
		current_turf.rcd_memory = RCD_MEMORY_WINDOWGRILLE

/obj/effect/spawner/structure/window/hollow
	name = "hollow window spawner"
	icon_state = "hwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)

/obj/effect/spawner/structure/window/hollow/end
	icon_state = "hwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north, /obj/structure/window/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/middle
	icon_state = "hwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/east, /obj/structure/window/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/directional
	icon_state = "hwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window, /obj/structure/window/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/spawner/north, /obj/structure/window/spawner/west)
	. = ..()

//reinforced

/obj/effect/spawner/structure/window/reinforced //brig windows here
	name = "reinforced window spawner"
	icon_state = "rwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile)
	FASTDMM_PROP(\
		pipe_astar_cost = 2\
	)

//Alarm grilles for prison wing
/obj/effect/spawner/structure/window/reinforced/prison
	name = "prison window spawner"
	spawn_list = list(/obj/structure/grille/prison, /obj/structure/window/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/reinforced
	name = "hollow reinforced window spawner"
	icon_state = "hrwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/reinforced/end
	icon_state = "hrwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/reinforced/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/reinforced/middle
	icon_state = "hrwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/reinforced/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/east, /obj/structure/window/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/reinforced/directional
	icon_state = "hrwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/reinforced/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced, /obj/structure/window/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/spawner/north, /obj/structure/window/reinforced/spawner/west)
	. = ..()

//tinted

/obj/effect/spawner/structure/window/reinforced/tinted
	name = "tinted reinforced window spawner"
	icon_state = "twindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile)

//tinted nightclub

/obj/effect/spawner/structure/window/reinforced/tinted/nightclub
	name = "tinted nightclub reinforced window spawner"
	icon_state = "twindow_spawner"
	color ="#9b1d70"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/tinted/fulltile/nightclub)

//shuttle window

/obj/effect/spawner/structure/window/shuttle
	name = "shuttle window spawner"
	icon_state = "swindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle)


//plastitanium window

/obj/effect/spawner/structure/window/plastitanium
	name = "plastitanium window spawner"
	icon_state = "plastitaniumwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plastitanium)


//ice window

/obj/effect/spawner/structure/window/ice
	name = "ice window spawner"
	icon_state = "icewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile/ice)


//survival pod window

/obj/effect/spawner/structure/window/survival_pod
	name = "pod window spawner"
	icon_state = "podwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/survival_pod)

/obj/effect/spawner/structure/window/hollow/survival_pod
	name = "hollow pod window spawner"
	icon_state = "podwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)

/obj/effect/spawner/structure/window/hollow/survival_pod/end
	icon_state = "podwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/survival_pod/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/survival_pod/middle
	icon_state = "podwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/survival_pod/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/east, /obj/structure/window/shuttle/survival_pod/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/survival_pod/directional
	icon_state = "podwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/survival_pod/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/shuttle/survival_pod/spawner/north, /obj/structure/window/shuttle/survival_pod/spawner/west)
	. = ..()


//plasma windows

/obj/effect/spawner/structure/window/plasma
	name = "plasma window spawner"
	icon_state = "pwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/fulltile)

/obj/effect/spawner/structure/window/hollow/plasma
	name = "hollow plasma window spawner"
	icon_state = "phwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/end
	icon_state = "phwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/plasma/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/plasma/middle
	icon_state = "phwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/plasma/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/east, /obj/structure/window/plasma/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/plasma/directional
	icon_state = "phwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/plasma/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma, /obj/structure/window/plasma/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/spawner/north, /obj/structure/window/plasma/spawner/west)
	. = ..()

//plasma reinforced

/obj/effect/spawner/structure/window/plasma/reinforced
	name = "reinforced plasma window spawner"
	icon_state = "prwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/fulltile)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced
	name = "hollow reinforced plasma window spawner"
	icon_state = "phrwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/end
	icon_state = "phrwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/middle
	icon_state = "phrwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/east, /obj/structure/window/plasma/reinforced/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/directional
	icon_state = "phrwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/plasma/reinforced/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced, /obj/structure/window/plasma/reinforced/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/plasma/reinforced/spawner/north, /obj/structure/window/plasma/reinforced/spawner/west)
	. = ..()

//Depleted Uranium Windows

/obj/effect/spawner/structure/window/depleteduranium
	name = "reinforced depleted uranium window spawner"
	icon_state = "duwindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/fulltile)

/obj/effect/spawner/structure/window/hollow/depleteduranium
	name = "hollow depleted uranium window spawner"
	icon_state = "duhwindow_spawner_full"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/north, /obj/structure/window/depleteduranium/spawner/east, /obj/structure/window/depleteduranium/spawner/west)

/obj/effect/spawner/structure/window/hollow/depleteduranium/end
	icon_state = "duhwindow_spawner_end"

/obj/effect/spawner/structure/window/hollow/depleteduranium/end/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/north, /obj/structure/window/depleteduranium/spawner/east, /obj/structure/window/depleteduranium/spawner/west)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/north, /obj/structure/window/depleteduranium/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/east, /obj/structure/window/depleteduranium/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/north, /obj/structure/window/depleteduranium/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/depleteduranium/middle
	icon_state = "duhwindow_spawner_middle"

/obj/effect/spawner/structure/window/hollow/depleteduranium/middle/Initialize(mapload)
	switch(dir)
		if(NORTH,SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/north)
		if(EAST,WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/east, /obj/structure/window/depleteduranium/spawner/west)
	. = ..()

/obj/effect/spawner/structure/window/hollow/depleteduranium/directional
	icon_state = "duhwindow_spawner_directional"

/obj/effect/spawner/structure/window/hollow/depleteduranium/directional/Initialize(mapload)
	switch(dir)
		if(NORTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/north)
		if(NORTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/north, /obj/structure/window/depleteduranium/spawner/east)
		if(EAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/east)
		if(SOUTHEAST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/east)
		if(SOUTH)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium)
		if(SOUTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium, /obj/structure/window/depleteduranium/spawner/west)
		if(WEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/west)
		if(NORTHWEST)
			spawn_list = list(/obj/structure/grille, /obj/structure/window/depleteduranium/spawner/north, /obj/structure/window/depleteduranium/spawner/west)
	. = ..()

/obj/effect/spawner/structure/shipping_container
	name = "shipping container spawner"
	icon = 'icons/obj/containers.dmi'
	icon_state = "random_container"
	spawn_list = list(/obj/structure/shipping_container/conarex = 3,/obj/structure/shipping_container/deforest = 3,/obj/structure/shipping_container/kahraman = 3,/obj/structure/shipping_container/kahraman/alt = 3,/obj/structure/shipping_container/kosmologistika = 3,/obj/structure/shipping_container/interdyne = 3,/obj/structure/shipping_container/nakamura = 3,/obj/structure/shipping_container/nanotrasen = 3,/obj/structure/shipping_container/nthi = 3,/obj/structure/shipping_container/vitezstvi = 3,/obj/structure/shipping_container/cybersun = 2,/obj/structure/shipping_container/donk_co = 2,/obj/structure/shipping_container/gorlex = 1,/obj/structure/shipping_container/gorlex/red = 1)
