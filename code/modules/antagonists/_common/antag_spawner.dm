/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	/// Whether or not this contract has been used
	var/used = FALSE
	/// Whether or not we're currently polling ghosts, to prevent spam
	var/currently_polling_ghosts = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return


///////////WIZARD

/obj/item/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"

/obj/item/antag_spawner/contract/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_DESTRUCTION]'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_BLUESPACE]'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_HEALING]'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_ROBELESS]'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_WILDMAGIC]'>Wild Magic</A><BR>"
		dat += "<I>Your apprentice is training wild magic. You don't know which spells they got from the wild magic, but it's how the school of wild magic is.</I><BR><BR>"
	user << browse(HTML_SKELETON(dat), "window=radio")
	onclose(user, "radio")
	return

/obj/item/antag_spawner/contract/Topic(href, href_list)
	. = ..()

	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(!ishuman(usr))
		return TRUE
	var/mob/living/carbon/human/H = usr

	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["school"])
			if(currently_polling_ghosts)
				to_chat(H, "Already requesting support!")
				return
			if(used)
				to_chat(H, "You already used this contract!")
				return

			currently_polling_ghosts = TRUE
			var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
				question = "Do you want to play as a wizard's [href_list["school"]] apprentice?",
				check_jobban = ROLE_WIZARD,
				poll_time = 15 SECONDS,
				ignore_category = POLL_IGNORE_WIZARD_HELPER,
				jump_target = H,
				role_name_text = "[href_list["school"]] apprentice",
				alert_pic = H,
			)
			currently_polling_ghosts = FALSE

			if(candidate)
				if(QDELETED(src))
					return
				used = TRUE
				spawn_antag(candidate.client, get_turf(src), href_list["school"], H.mind)
			else
				to_chat(H, "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.")

/obj/item/antag_spawner/contract/spawn_antag(client/C, turf/T, kind ,datum/mind/user)
	new /obj/effect/particle_effect/smoke(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key
	var/datum/mind/app_mind = M.mind

	var/datum/antagonist/wizard/apprentice/app = new()
	app.master = user
	app.school = kind

	var/datum/antagonist/wizard/master_wizard = user.has_antag_datum(/datum/antagonist/wizard)
	if(master_wizard)
		if(!master_wizard.wiz_team)
			master_wizard.create_wiz_team()
		app.wiz_team = master_wizard.wiz_team
		master_wizard.wiz_team.add_member(app_mind)
	app_mind.add_antag_datum(app)
	//TODO Kill these if possible
	app_mind.assigned_role = "Apprentice"
	app_mind.special_role = "apprentice"
	//
	SEND_SOUND(M, sound('sound/effects/magic.ogg'))

///////////BORGS AND OPERATIVES


/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, span_warning("[src] is out of power!"))
		return FALSE
	if(!user.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE))
		to_chat(user, span_danger("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	return TRUE

/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, span_notice("You activate [src] and wait for confirmation."))
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		check_jobban = ROLE_OPERATIVE,
		poll_time = 15 SECONDS,
		jump_target = user,
		role_name_text = "syndicate [borg_to_spawn ? "[LOWER_TEXT(borg_to_spawn)] cyborg":"operative"]",
		alert_pic = /mob/living/silicon/robot/model/syndicate,
	)
	if(candidate)
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE

		spawn_antag(candidate.client, get_turf(src), "syndieborg", user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		to_chat(user, span_warning("Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded."))

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/new_op = new()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = /datum/outfit/syndicate/no_crystals

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(creator_op)
		M.mind.add_antag_datum(new_op,creator_op.nuke_team)
		M.mind.special_role = "Nuclear Operative"

//////CLOWN OP
/obj/item/antag_spawner/nuke_ops/clown
	name = "clown operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce clown operatives in the field."

/obj/item/antag_spawner/nuke_ops/clown/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/clownop/new_op = new /datum/antagonist/nukeop/clownop()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = /datum/outfit/syndicate/clownop/no_crystals

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop/clownop,TRUE)
	if(creator_op)
		M.mind.add_antag_datum(new_op, creator_op.nuke_team)
		M.mind.special_role = "Clown Operative"


//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur teleporter"
	borg_to_spawn = "Saboteur"

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop, TRUE)
	if(!creator_op)
		return

	var/mob/living/silicon/robot/robot
	switch(borg_to_spawn)
		if("Medical")
			robot = new /mob/living/silicon/robot/model/syndicate/medical(T)
		if("Saboteur")
			robot = new /mob/living/silicon/robot/model/syndicate/saboteur(T)
		else
			robot = new /mob/living/silicon/robot/model/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = pick(GLOB.last_names)
	if(creator_op.nuke_team.syndicate_name)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = creator_op.nuke_team.syndicate_name
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	robot.mmi.name = "[initial(robot.mmi.name)]: [brainopsname]"
	robot.mmi.brain.name = "[brainopsname]'s brain"
	robot.mmi.brainmob.real_name = brainopsname
	robot.mmi.brainmob.name = brainopsname
	robot.real_name = robot.name

	robot.key = C.key

	var/datum/antagonist/nukeop/new_borg = new()
	new_borg.send_to_spawnpoint = FALSE
	robot.mind.add_antag_datum(new_borg,creator_op.nuke_team)
	robot.mind.special_role = "Syndicate Cyborg"

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

	var/shatter_msg = span_notice("You shatter the bottle, no turning back now!")
	var/veil_msg = span_warning("You sense a dark presence lurking just beyond the veil...")
	var/mob/living/demon_type = /mob/living/simple_animal/hostile/imp/slaughter
	var/antag_type = /datum/antagonist/slaughter


/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(!is_station_level(user.z))
		to_chat(user, span_notice("You should probably wait until you reach the station."))
		return
	if(used)
		return

	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		check_jobban = ROLE_SLAUGHTER_DEMON,
		poll_time = 10 SECONDS,
		jump_target = user,
		role_name_text = initial(demon_type.name),
		alert_pic = /mob/living/simple_animal/hostile/imp/slaughter,
	)
	if(candidate)
		if(used || QDELETED(src))
			return
		used = TRUE

		spawn_antag(candidate.client, get_turf(src), initial(demon_type.name),user.mind)
		to_chat(user, shatter_msg)
		to_chat(user, veil_msg)
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		to_chat(user, span_notice("You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later."))


/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	var/mob/living/simple_animal/hostile/imp/slaughter/S = new demon_type(T)
	new /obj/effect/dummy/phased_mob(T, S)
	S.key = C.key
	S.mind.assigned_role = S.name
	S.mind.special_role = S.name
	S.mind.add_antag_datum(antag_type)
	to_chat(S, ("<span class='bold'>You are currently not currently in the same plane of existence as the station. \
		Use your Blood Crawl ability near a pool of blood to manifest and wreak havoc.</span>"))

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from countless hugging attacks. Used in funny rituals to attract adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	color = "#FF69B4" // HOT PINK

	veil_msg = span_warning("You sense an adorable presence lurking just beyond the veil...")
	demon_type = /mob/living/simple_animal/hostile/imp/slaughter/laughter
	antag_type = /datum/antagonist/slaughter/laughter
