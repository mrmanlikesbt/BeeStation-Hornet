//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs) //complete list of all blobs made.
GLOBAL_LIST_EMPTY(blob_cores)
GLOBAL_LIST_EMPTY(overminds)
GLOBAL_LIST_EMPTY(blob_nodes)


/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	desc = "The overmind. It controls the blob."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = 1
	see_in_dark = NIGHTVISION_FOV_RANGE
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER

	pass_flags = PASSBLOB
	faction = list(FACTION_BLOB)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	hud_type = /datum/hud/blob_overmind
	var/obj/structure/blob/special/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = OVERMIND_MAX_POINTS_DEFAULT
	var/last_attack = 0
	var/datum/blobstrain/reagent/blobstrain
	var/list/blob_mobs = list()
	/// A list of all blob structures
	var/list/all_blobs = list()
	var/list/resource_blobs = list()
	var/list/factory_blobs = list()
	var/list/node_blobs = list()
	var/free_strain_rerolls = OVERMIND_STARTING_REROLLS
	var/last_reroll_time = 0 //time since we last rerolled, used to give free rerolls
	var/nodes_required = TRUE //if the blob needs nodes to place resource and factory blobs
	var/placed = FALSE
	var/manualplace_min_time = OVERMIND_STARTING_MIN_PLACE_TIME	// Some time to get your bearings
	var/autoplace_max_time = OVERMIND_STARTING_AUTO_PLACE_TIME	// Automatically place the core in a random spot
	var/list/blobs_legit = list()
	var/max_count = 0 //The biggest it got before death
	var/blobwincount = OVERMIND_WIN_CONDITION_AMOUNT
	var/victory_in_progress = FALSE
	var/rerolling = FALSE
	var/announcement_size = OVERMIND_ANNOUNCEMENT_MIN_SIZE // Announce the biohazard when this size is reached
	var/announcement_time
	var/has_announced = FALSE

	/// The list of strains the blob can reroll for.
	var/list/strain_choices
	var/need_reroll_strain = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/mob/camera/blob)

/mob/camera/blob/Initialize(mapload, starting_points = OVERMIND_STARTING_POINTS)
	validate_location()
	blob_points = starting_points
	manualplace_min_time += world.time
	autoplace_max_time += world.time
	GLOB.overminds += src
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	var/datum/blobstrain/BS = pick(GLOB.valid_blobstrains)
	set_strain(BS)
	color = blobstrain.complementary_color
	if(blob_core)
		blob_core.update_icon()
	SSshuttle.registerHostileEnvironment(src)
	announcement_time = world.time + OVERMIND_ANNOUNCEMENT_MAX_TIME
	. = ..()
	START_PROCESSING(SSobj, src)

/mob/camera/blob/proc/validate_location()
	var/turf/T = get_turf(src)
	if(!is_valid_turf(T) && LAZYLEN(GLOB.blobstart))
		var/list/blobstarts = shuffle(GLOB.blobstart)
		for(var/_T in blobstarts)
			if(is_valid_turf(_T))
				T = _T
				break
	if(!T)
		CRASH("No blobspawnpoints and blob spawned in nullspace.")
	forceMove(T)

/mob/camera/blob/proc/set_strain(datum/blobstrain/new_strain)
	if (ispath(new_strain))
		var/hadstrain = FALSE
		if (istype(blobstrain))
			blobstrain.on_lose()
			qdel(blobstrain)
			hadstrain = TRUE
		blobstrain = new new_strain(src)
		blobstrain.on_gain()
		if (hadstrain)
			to_chat(src, "Your strain is now: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!")
			to_chat(src, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> strain [blobstrain.description]")
			if(blobstrain.effectdesc)
				to_chat(src, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> strain [blobstrain.effectdesc]")


/mob/camera/blob/proc/is_valid_turf(turf/T)
	var/area/A = get_area(T)
	if((A && !(A.area_flags & BLOBS_ALLOWED)) || !T || !is_station_level(T.z) || isspaceturf(T) || istype(T, /turf/open/openspace))
		return FALSE
	return TRUE

/mob/camera/blob/process()
	if(!blob_core)
		if(!placed)
			if(manualplace_min_time && world.time >= manualplace_min_time)
				to_chat(src, "<b>[span_big("<font color=\"#EE4000\">You may now place your blob core.</font>")]</b>")
				to_chat(src, span_big("<font color=\"#EE4000\">You will automatically place your blob core in [DisplayTimeText(autoplace_max_time - world.time)].</font>"))
				manualplace_min_time = 0
			if(autoplace_max_time && world.time >= autoplace_max_time)
				place_blob_core(1)
		else
			qdel(src)
	else if(!victory_in_progress && (blobs_legit.len >= blobwincount))
		victory_in_progress = TRUE
		priority_announce("Biohazard has reached critical mass. Station loss is imminent.", "Biohazard Alert", SSstation.announcer.get_rand_alert_sound())
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		max_blob_points = INFINITY
		blob_points = INFINITY
		addtimer(CALLBACK(src, PROC_REF(victory)), 450)
	else if(!free_strain_rerolls && (last_reroll_time + BLOB_POWER_REROLL_FREE_TIME<world.time))
		to_chat(src, "<b>[span_big("<font color=\"#EE4000\">You have gained another free strain re-roll.</font>")]</b>")
		free_strain_rerolls = 1

	if(!victory_in_progress && max_count < blobs_legit.len)
		max_count = blobs_legit.len

	if(!has_announced && (world.time >= announcement_time || blobs_legit.len >= announcement_size))
		priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)
		has_announced = TRUE
/mob/camera/blob/proc/victory()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue

		if((L in GLOB.overminds) || (L.pass_flags & PASSBLOB))
			continue

		var/area/Ablob = get_area(T)

		if(!(Ablob.area_flags & BLOBS_ALLOWED))
			continue

		if(!(FACTION_BLOB in L.faction))
			playsound(L, 'sound/effects/splat.ogg', 50, 1)
			if(L.stat != DEAD)
				L.investigate_log("has died from blob takeover.", INVESTIGATE_DEATHS)
			L.death()
			new/mob/living/simple_animal/hostile/blob/blobspore(T)
		else
			L.fully_heal()

		for(var/area/A in GLOB.areas)
			if(!(A.type in GLOB.the_station_areas))
				continue
			if(!(A.area_flags & BLOBS_ALLOWED))
				continue
			A.color = blobstrain.color
			A.name = "blob"
			A.icon = 'icons/mob/blob.dmi'
			A.icon_state = "blob_shield"
			A.layer = BELOW_MOB_LAYER
			A.invisibility = 0
			A.blend_mode = 0
	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(B)
		var/datum/objective/blob_takeover/main_objective = locate() in B.objectives
		if(main_objective)
			main_objective.completed = TRUE
	to_chat(world, "<B>[real_name] consumed the station in an unstoppable tide!</B>")
	SSticker.news_report = BLOB_WIN
	SSticker.force_ending = 1

/mob/camera/blob/Destroy()
	QDEL_NULL(blobstrain)
	for(var/BL in GLOB.blobs)
		var/obj/structure/blob/B = BL
		if(B && B.overmind == src)
			B.overmind = null
			B.update_icon() //reset anything that was ours
	for(var/BLO in blob_mobs)
		var/mob/living/simple_animal/hostile/blob/BM = BLO
		if(BM)
			BM.overmind = null
			BM.update_icons()
	for(var/obj/structure/blob/blob_structure as anything in all_blobs)
		blob_structure.overmind = null
	all_blobs = null
	resource_blobs = null
	factory_blobs = null
	node_blobs = null
	blob_mobs = null
	GLOB.overminds -= src
	QDEL_LIST_ASSOC_VAL(strain_choices)

	SSshuttle.clearHostileEnvironment(src)
	STOP_PROCESSING(SSobj, src)

	return ..()

/mob/camera/blob/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_notice("You are the overmind!"))
	blob_help()
	update_health_hud()
	add_points(0)

/mob/camera/blob/examine(mob/user)
	. = ..()
	if(blobstrain)
		. += "Its strain is <font color=\"[blobstrain.color]\">[blobstrain.name]</font>."
	. += "It currently consists of [blobs_legit.len] nodes, out of the [blobwincount] nodes needed to achieve critical mass."

/mob/camera/blob/update_health_hud()
	if(blob_core)
		var/current_health = round((blob_core.get_integrity() / blob_core.max_integrity) * 100)
		hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[current_health]</font></div>")
		for(var/mob/living/simple_animal/hostile/blob/blobbernaut/B in blob_mobs)
			if(B.hud_used?.blobpwrdisplay)
				B.hud_used.blobpwrdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[current_health]</font></div>")

/mob/camera/blob/proc/add_points(points)
	blob_points = clamp(blob_points + points, 0, max_blob_points)
	hud_used.blobpwrdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(blob_points)]</font></div>")

/mob/camera/blob/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	message = treat_message_min(message)
	src.log_talk(message, LOG_SAY, tag="blob")

	var/message_a = say_quote(message)
	var/rendered = span_big("<font color=\"#EE4000\"><b>\[Blob Telepathy\] [name](<font color=\"[blobstrain.color]\">[blobstrain.name]</font>)</b> [message_a]</font>")

	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/mob/camera/blob/get_stat_tab_status()
	var/list/tab_data = ..()
	if(blob_core)
		tab_data["Core Health"] = GENERATE_STAT_TEXT("[blob_core.get_integrity()]")
	tab_data["Power Stored"] = GENERATE_STAT_TEXT("[blob_points]/[max_blob_points]")
	tab_data["Blobs to Win"] = GENERATE_STAT_TEXT("[blobs_legit.len]/[blobwincount]")
	if(free_strain_rerolls)
		tab_data["Strain Reroll"] = GENERATE_STAT_TEXT("You have [free_strain_rerolls] Free Strain Reroll\s Remaining")
	if(!placed)
		if(manualplace_min_time)
			tab_data["Time Before Manual Placement"] = GENERATE_STAT_TEXT("[max(round((manualplace_min_time - world.time)*0.1, 0.1), 0)]")
		tab_data["Time Before Automatic Placement"] = GENERATE_STAT_TEXT("[max(round((autoplace_max_time - world.time)*0.1, 0.1), 0)]")
	return tab_data

/mob/camera/blob/canZMove(direction, turf/source, turf/target, pre_move = TRUE)
	return !placed

/mob/camera/blob/Move(NewLoc, Dir = 0)
	if(placed)
		var/obj/structure/blob/B = locate() in range(OVERMIND_MAX_CAMERA_STRAY, NewLoc)
		if(B)
			forceMove(NewLoc)
		else
			return FALSE
	else
		var/turf/T = get_turf(NewLoc)
		if(!is_valid_turf(T)) //if unplaced, can't go out of placeable area
			return FALSE
		forceMove(NewLoc)
		return TRUE

/mob/camera/blob/mind_initialize()
	. = ..()
	var/datum/antagonist/blob/B = mind.has_antag_datum(/datum/antagonist/blob)
	if(!B)
		mind.add_antag_datum(/datum/antagonist/blob)
