GLOBAL_DATUM_INIT(admin_secrets, /datum/admin_secrets, new)

/datum/admin_secrets


/datum/admin_secrets/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_secrets/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights(0))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the Secrets panel.")
		ui = new(user, src, "AdminSecretsPanel", "Secrets Panel")
		ui.open()

/datum/admin_secrets/ui_static_data(mob/user)
	/*
	Each command is a list that will be read like [Name, Action(see ui_act)]
	"omg but you could have done it like X"
	But I didn't. This is how I did it. And it works (THIS STOPPED WORKING WITH TGUI 4 PORT!). And it's simple.
	And lets us keep each command entry to one line. Gotta stay compact, yo.
	*/
	var/list/data = list()
	data["Categories"] = list()

	data["Categories"]["General Secrets"] = list(
		list("Admin Log", "admin_log"),
		list("Mentor Log", "mentor_log"),
		list("Show Admin List", "show_admins")
		)

	if(check_rights(R_ADMIN,0))
		data["Categories"]["Admin Secrets"] = list(
			list("Cure all diseases currently in existence", "clear_virus"),
			list("Vaccinate all diseases currently in existence", "delete_virus"),
			list("Bombing List", "list_bombers"),
			list("Show last [length(GLOB.lastsignalers)] signalers", "list_signalers"),
			list("Show last [length(GLOB.lawchanges)] law changes", "list_lawchanges"),
			list("Show AI Laws", "showailaws"),
			list("Show Crew Manifest", "manifest"),
			list("List DNA (Blood)", "DNA"),
			list("List Fingerprints", "fingerprints"),
			list("Enable/Disable CTF", "ctfbutton"),
			list("Reset Thunderdome to default state", "tdomereset"),
			list("Rename Station Name", "set_name"),
			list("Reset Station Name", "reset_name"),
			list("Set Night Shift Mode", "night_shift_set"),
			list("Toggle All Lights", "all_light_toggle")
			)

		data["Categories"]["Shuttles"] += list(
			list("Move Ferry", "moveferry"),
			list("Toggle Arrivals Ferry", "togglearrivals"),
			list("Move Mining Shuttle", "moveminingshuttle"),
			list("Move Labor Shuttle", "movelaborshuttle")
			)

	if(check_rights(R_FUN,0))
		data["Categories"]["Fun Secrets"] += list(
			list("Trigger a Virus Outbreak", "virus"),
			list("Turn all humans into monkeys", "monkey"),
			list("Chinese Cartoons", "anime"),
			list("Change the species of all humans", "allspecies"),
			list("Make all areas powered", "power"),
			list("Make all areas unpowered", "unpower"),
			list("Power all SMES", "quickpower"),
			list("Triple AI mode (needs to be used in the lobby)", "tripleAI"),
			list("Mass Antag (Everyone is the traitor)", "traitor_all"),
			list("Summon Guns", "guns"),
			list("Summon Magic", "magic"),
			list("Summon Events (Toggle)", "events"),
			list("There can only be one!", "onlyone"),
			list("There can only be one! (40-second delay)", "delayed_onlyone"),
			list("Make all players intellectually disabled", "dumbify"),
			list("Make all players Australian", "aussify"),
			list("Egalitarian Station Mode", "eagles"),
			list("Anarcho-Capitalist Station Mode", "ancap"),
			list("Break all lights", "blackout"),
			list("Fix all lights", "whiteout"),
			list("The floor is lava! (DANGEROUS: extremely lame)", "floorlava"),
			list("Spawn a custom portal storm", "customportal"),
			list("Flip client movement directions", "flipmovement"),
			list("Randomize client movement directions", "randommovement"),
			list("Set each movement direction manually", "custommovement"),
			list("Reset movement directions to default", "resetmovement"),
			list("Change bomb cap", "changebombcap"),
			list("Mass Purrbation", "masspurrbation"),
			list("Mass Remove Purrbation", "massremovepurrbation"),
			list("Fully Immerse Everyone", "massimmerse"),
			list("Un-Fully Immerse Everyone", "unmassimmerse"),
			list("Make All Animals Playable", "animalsentience")
			)

	if(check_rights(R_DEBUG,0))
		data["Categories"]["Security Level Elevated"] = list(
			list("Change all maintenance doors to engie/brig access only", "maint_access_engiebrig"),
			list("Change all maintenance doors to brig access only", "maint_access_brig"),
			list("Remove cap on security officers", "infinite_sec")
			)

	return data

/datum/admin_secrets/ui_act(action, params)
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]
	if(!admin_datum) // Should have already been blocked by ui_state, but juuust in case
		message_admins("[usr] sent a request to interact with the secrets panel without sufficient rights.")
		log_admin_private("[usr] sent a request to interact with the secrets panel without sufficient rights.")
		return
	var/datum/round_event/E
	var/ok = 0
	switch(action)
		if("admin_log")
			var/dat
			for(var/l in GLOB.admin_log)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_log.len)
				dat += "No one has done anything this round!"
			var/datum/browser/browser = new(usr, "admin_log", "Admin Logs", 600, 500)
			browser.set_content(dat)
			browser.open()

		if("mentor_log") // hippie start -- access mentor log
			admin_datum.MentorLogSecret() // hippie end

		if("show_admins")
			var/dat
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank.name]<br>"
				var/datum/browser/browser = new(usr, "showadmins", "Current admins", 600, 500)
				browser.set_content(dat)
				browser.open()

		if("tdomereset")
			if(!check_rights(R_ADMIN))
				return
			var/delete_mobs = tgui_alert(usr, "Clear all mobs?","Confirm",list("Yes","No","Cancel"))
			if(delete_mobs == "Cancel" || !delete_mobs)
				return

			log_admin("[key_name(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
			message_admins(span_adminnotice("[key_name_admin(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs]."))

			var/area/thunderdome = GLOB.areas_by_type[/area/tdome/arena]
			if(delete_mobs == "Yes")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera) && !istype(obj, /obj/effect/landmark/arena))
					qdel(obj) //Clear objects

			var/area/template = GLOB.areas_by_type[/area/tdome/arena_source]
			template.copy_contents_to(thunderdome)

		if("clear_virus")
			if(tgui_alert(usr, "Are you sure you want to remove all disease?", "", list("Yes", "Cancel")) == "Yes")
				message_admins("[key_name_admin(usr)] has removed all diseases.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure(0)
		if("delete_virus")
			if(tgui_alert(usr, "Are you sure you want to vaccinate all disease?", "", list("Yes", "Cancel")) == "Yes")
				message_admins("[key_name_admin(usr)] has cured all diseases.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure()
		if("set_name")
			if(!check_rights(R_ADMIN))
				return
			var/new_name = tgui_input_text(usr, "Please input a new name for the station.")
			if(!new_name)
				to_chat(usr, span_warning("No name given."))
				return
			set_station_name(new_name)
			log_admin("[key_name(usr)] renamed the station to \"[new_name]\".")
			message_admins(span_adminnotice("[key_name_admin(usr)] renamed the station to: [new_name]."))
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".", sound = SSstation.announcer.get_rand_alert_sound())
		if("night_shift_set")
			if(!check_rights(R_ADMIN))
				return
			var/val = tgui_alert(usr, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", list("On", "Off", "Automatic"))
			switch(val)
				if("Automatic")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(FALSE, TRUE)
				if("On")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(TRUE, TRUE)
				if("Off")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(FALSE, TRUE)
		if("all_light_toggle")
			if(!check_rights(R_ADMIN))
				return
			var/val = tgui_alert(usr, "Do you want to turn all lights on or off?", "Light Manipulation", list("On", "Off", "Cancel"))
			var/set_to = null
			if(val == "Cancel" || !val)
				return
			switch(val)
				if("On")
					set_to = TRUE
				if("Off")
					set_to = FALSE
				else
					return
			if(!isnull(set_to))
				for(var/area/found_area in GLOB.areas)
					found_area.lightswitch = set_to
					found_area.update_appearance()
					for(var/obj/machinery/light_switch/lswitch in found_area)
						lswitch.update_appearance()
					found_area.power_change()
		if("reset_name")
			if(!check_rights(R_ADMIN))
				return
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(usr)] reset the station name.")
			message_admins(span_adminnotice("[key_name_admin(usr)] reset the station name."))
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".", sound = SSstation.announcer.get_rand_alert_sound())

		if("list_bombers")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Bombing List</B><HR>"
			for(var/l in GLOB.bombers)
				dat += "[l]<BR>"
			usr << browse(HTML_SKELETON(dat), "window=bombers")

		if("list_signalers")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing last [length(GLOB.lastsignalers)] signalers.</B><HR>"
			for(var/sig in GLOB.lastsignalers)
				dat += "[sig]<BR>"
			usr << browse(HTML_SKELETON(dat), "window=lastsignalers;size=800x500")

		if("list_lawchanges")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing last [length(GLOB.lawchanges)] law changes.</B><HR>"
			for(var/sig in GLOB.lawchanges)
				dat += "[sig]<BR>"
			usr << browse(HTML_SKELETON(dat), "window=lawchanges;size=800x500")

		if("moveminingshuttle")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Mining Shuttle"))
			if(!SSshuttle.toggleShuttle("mining","mining_home","mining_away"))
				message_admins("[key_name_admin(usr)] moved mining shuttle")
				log_admin("[key_name(usr)] moved the mining shuttle")

		if("movelaborshuttle")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Labor Shuttle"))
			if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
				message_admins("[key_name_admin(usr)] moved labor shuttle")
				log_admin("[key_name(usr)] moved the labor shuttle")

		if("moveferry")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send CentCom Ferry"))
			if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
				message_admins("[key_name_admin(usr)] moved the CentCom ferry")
				log_admin("[key_name(usr)] moved the CentCom ferry")

		if("togglearrivals")
			if(!check_rights(R_ADMIN))
				return
			var/obj/docking_port/mobile/arrivals/A = SSshuttle.arrivals
			if(A)
				var/new_perma = !A.perma_docked
				A.perma_docked = new_perma
				SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Permadock Arrivals Shuttle", "[new_perma ? "Enabled" : "Disabled"]"))
				message_admins("[key_name_admin(usr)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
				log_admin("[key_name(usr)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
			else
				to_chat(usr, span_admin("There is no arrivals shuttle"))
		if("showailaws")
			if(!check_rights(R_ADMIN))
				return
			admin_datum.output_ai_laws()
		if("manifest")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing Crew Manifest.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
			for(var/datum/record/crew/t in GLOB.manifest.general)
				dat += "<tr><td>[t.name]</td><td>[t.rank]</td></tr>"
			dat += "</table>"
			usr << browse(HTML_SKELETON(dat), "window=manifest;size=440x410")
		if("DNA")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing DNA from blood.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td></tr>"
			dat += "</table>"
			usr << browse(HTML_SKELETON(dat), "window=DNA;size=440x410")
		if("fingerprints")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Showing Fingerprints.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[rustg_hash_string(RUSTG_HASH_MD5, H.dna.unique_identity)]</td></tr>"
			dat += "</table>"
			usr << browse(HTML_SKELETON(dat), "window=fingerprints;size=440x410")

		if("monkey")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Monkeyize All Humans"))
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				spawn(0)
					H.monkeyize()
			ok = 1

		if("allspecies")
			if(!check_rights(R_FUN))
				return
			var/result = tgui_input_list(usr, "Please choose a new species", "Species", GLOB.species_list)
			if(isnull(result))
				return
			if(isnull(GLOB.species_list[result]))
				return

			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Species Change", "[result]"))
			log_admin("[key_name(usr)] turned all humans into [result]", 1)
			message_admins("\blue [key_name_admin(usr)] turned all humans into [result]")
			var/newtype = GLOB.species_list[result]
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				H.set_species(newtype)

		if("tripleAI")
			if(!check_rights(R_FUN))
				return
			usr.client.triple_ai()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Triple AI"))

		if("power")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All APCs"))
			log_admin("[key_name(usr)] made all areas powered", 1)
			message_admins(span_adminnotice("[key_name_admin(usr)] made all areas powered"))
			power_restore()

		if("unpower")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Depower All APCs"))
			log_admin("[key_name(usr)] made all areas unpowered", 1)
			message_admins(span_adminnotice("[key_name_admin(usr)] made all areas unpowered"))
			power_failure()

		if("quickpower")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All SMESs"))
			log_admin("[key_name(usr)] made all SMESs powered", 1)
			message_admins(span_adminnotice("[key_name_admin(usr)] made all SMESs powered"))
			power_restore_quick()

		if("traitor_all")
			if(!check_rights(R_FUN))
				return
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr, "The game hasn't started yet!")
				return
			if(!GLOB.admin_objective_list)
				generate_admin_objective_list()
			if(!GLOB.admin_antag_list)
				generate_admin_antag_list()
			//Get Antag Type
			var/selected_antag = tgui_input_list(usr, "Select antag type:", "Antag type", GLOB.admin_antag_list)
			selected_antag = GLOB.admin_antag_list[selected_antag]
			if(!selected_antag)
				return
			//Get Objective
			var/selected_type = tgui_input_list(usr, "Select objective type (make sure it's compatible with the selected antag type):", "Objective type", GLOB.admin_objective_list)
			selected_type = GLOB.admin_objective_list[selected_type]
			if(!selected_type)
				return
			var/objective_explanation = new selected_type
			var/datum/objective/new_objective = objective_explanation
			new_objective.admin_edit(usr)
			//Get Percentage
			var/selected_percentage = tgui_input_number(usr, "Percentage of crew to convert (percentage):", "Antag Percentage", 0, 100)
			if(!selected_percentage)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Antag", "[objective_explanation]"))
			//Pick antags
			var/list/choices = list()
			var/list/chosenPlayers = list()
			for(var/player in GLOB.player_list)
				choices.Add(player)
			var/antagCount = round(GLOB.player_list.len * (selected_percentage / 100) + 0.999)
			for(var/i in 0 to antagCount)
				if(choices.len == 0)
					break
				var/chosenPlayer = pick(choices)
				choices.Remove(chosenPlayer)
				chosenPlayers.Add(chosenPlayer)
			//Make the antags
			for(var/mob/living/H in chosenPlayers)
				if(!(ishuman(H)||istype(H, /mob/living/silicon/)))
					continue
				if(H.stat == DEAD || !H.client || !H.mind || ispAI(H))
					continue
				if(is_special_character(H))
					continue
				var/datum/antagonist/T = new selected_antag()
				T.give_objectives = FALSE
				var/datum/antagonist/A = H.mind.add_antag_datum(T)
				A.objectives = list()
				new_objective.owner = H
				A.objectives += new_objective
				log_objective(A, new_objective.explanation_text, usr)
				var/obj_count = 1
				to_chat(T.owner, span_alertsyndie("Your contractors have updated your objectives."))
				for(var/objective in A.objectives)
					var/datum/objective/O = objective
					to_chat(T.owner, "<B>Objective #[obj_count]</B>: [O.explanation_text]")
					obj_count++
			message_admins(span_adminnotice("[key_name_admin(usr)] used mass antag secret. Objective is: [objective_explanation]"))
			log_admin("[key_name(usr)] used mass antag secret. Objective is: [objective_explanation]")

		if("changebombcap")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Bomb Cap"))

			var/newBombCap = tgui_input_number(usr, "What would you like the new bomb cap to be? (Entered as the light damage range (the 3rd number in common (1,2,3) notation))", "New Bomb Cap", GLOB.MAX_EX_LIGHT_RANGE, 10000, 4)
			if (newBombCap > 256)
				if(tgui_alert(usr, "The value you picked is over 256 (Z-levels are 256 tiles wide). Are you sure about this?", "Bomb Cap", list("Yes", "Cancel")) == "Cancel") // Do you want cuban petes? This is how you get cuban petes.
					return
			if (!CONFIG_SET(number/bombcap, newBombCap))
				to_chat(usr, span_warning("New bomb cap not set."))
				return

			message_admins(span_boldannounce("[key_name_admin(usr)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]"))
			log_admin("[key_name(usr)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]")

		if("blackout")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Break All Lights"))
			message_admins("[key_name_admin(usr)] broke all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.break_light_tube()

		if("anime")
			if(!check_rights(R_FUN))
				return
			var/animetype = tgui_alert(usr, "Would you like to have the clothes be changed?", "", list("Yes","No","Cancel"))

			var/droptype
			if(animetype =="Yes")
				droptype = tgui_alert(usr, "Make the uniforms undroppable?","",list("Yes","No","Cancel"))

			if(animetype == "Cancel" || droptype == "Cancel" || !animetype || (!droptype && animetype == "Yes"))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Chinese Cartoons"))
			message_admins("[key_name_admin(usr)] made everything kawaii.")
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				SEND_SOUND(H, sound(SSstation.announcer.event_sounds[ANNOUNCER_ANIMES]))

				if(H.dna.species.id == SPECIES_HUMAN)
					if(H.dna.features["tail_human"] == "None" || H.dna.features["ears"] == "None")
						var/obj/item/organ/ears/cat/ears = new
						var/obj/item/organ/tail/cat/tail = new
						ears.Insert(H, drop_if_replaced=FALSE)
						tail.Insert(H, drop_if_replaced=FALSE)
					var/list/honorifics = list("[MALE]" = list("kun"), "[FEMALE]" = list("chan","tan"), "[NEUTER]" = list("san"), "[PLURAL]" = list("san")) //John Robust -> Robust-kun
					var/list/names = splittext(H.real_name," ")
					var/forename = names.len > 1 ? names[2] : names[1]
					var/newname = "[forename]-[pick(honorifics["[H.gender]"])]"
					H.fully_replace_character_name(H.real_name,newname)
					H.update_mutant_bodyparts()
					if(animetype == "Yes")
						var/seifuku = pick(typesof(/obj/item/clothing/under/costume/schoolgirl))
						var/obj/item/clothing/under/costume/schoolgirl/I = new seifuku
						var/olduniform = H.w_uniform
						H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
						H.equip_to_slot_or_del(I, ITEM_SLOT_ICLOTHING)
						qdel(olduniform)
						if(droptype == "Yes")
							ADD_TRAIT(I, TRAIT_NODROP, ADMIN_TRAIT)
				else
					to_chat(H, "You're not kawaii enough for this.")

		if("whiteout")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Fix All Lights"))
			message_admins("[key_name_admin(usr)] fixed all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.fix()

		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)

		if("virus")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Virus Outbreak"))
			switch(tgui_alert(usr, "Do you want this to be a random disease or do you have something in mind?", "",list("Make Your Own","Random","Choose")))
				if("Make Your Own")
					AdminCreateVirus(usr.client)
				if("Random")
					E = new /datum/round_event/disease_outbreak()
				if("Choose")
					var/virus = tgui_input_list(usr, "Choose the virus to spread", "BIOHAZARD", sort_list(typesof(/datum/disease, GLOBAL_PROC_REF(cmp_typepaths_asc))))
					if (!virus)
						to_chat(usr, span_warning("No virus selected."))
						return
					E = new /datum/round_event/disease_outbreak{}()
					var/datum/round_event/disease_outbreak/DO = E
					DO.virus_type = virus

		if("dumbify")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Braindamage"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, span_boldannounce("You suddenly feel stupid."))
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60, 80)
			message_admins("[key_name_admin(usr)] gave everybody intellectual disability")

		if("aussify") //for rimjobtide
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Australian"))
			var/s = sound('sound/misc/downunder.ogg')
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, span_boldannounce("You suddenly feel crikey."))
				var/matrix/M = H.transform
				H.transform = M.Scale(1,-1) //flip em upside down
				SEND_SOUND(H, s)
			message_admins("[key_name_admin(usr)] made everybody australian")

		if("eagles")//SCRAW
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Egalitarian Station"))
			for(var/obj/machinery/door/airlock/W in GLOB.machines)
				if(is_station_level(W.z) && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
					W.req_access = list()
			message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
			priority_announce("CentCom airlock control override activated. Please take this time to get acquainted with your coworkers.", null, SSstation.announcer.get_rand_report_sound())

		if("ancap")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Anarcho-capitalist Station"))
			SSeconomy.full_ancap = !SSeconomy.full_ancap
			message_admins("[key_name_admin(usr)] toggled Anarcho-capitalist mode")
			if(SSeconomy.full_ancap)
				priority_announce("The NAP is now in full effect.", null, SSstation.announcer.get_rand_report_sound())
			else
				priority_announce("The NAP has been revoked.", null, SSstation.announcer.get_rand_report_sound())




		if("guns")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Guns"))
			var/survivor_probability = 0
			switch(tgui_alert(usr, "Do you want this to create survivors antagonists?", "", list("No Antags","Some Antags (25%)","All Antags!")))
				if("Some Antags (25%)")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			rightandwrong(SUMMON_GUNS, usr, survivor_probability)

		if("magic")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Magic"))
			var/survivor_probability = 0
			switch(tgui_alert(usr, "Do you want this to create survivors antagonists?", "", list("No Antags","Some Antags (25%)","All Antags!")))
				if("Some Antags (25%)")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			rightandwrong(SUMMON_MAGIC, usr, survivor_probability)

		if("events")
			if(!check_rights(R_FUN))
				return
			if(!SSevents.wizardmode)
				if(tgui_alert(usr, "Do you want to toggle summon events on?", "", list("Yes","No")) == "Yes")
					summonevents()
					SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Activate"))

			else
				switch(tgui_alert(usr, "What would you like to do?", "", list("Intensify Summon Events","Turn Off Summon Events","Nothing")))
					if("Intensify Summon Events")
						summonevents()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Intensify"))
					if("Turn Off Summon Events")
						SSevents.toggleWizardmode()
						SSevents.resetFrequency()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Disable"))

		if("dorf")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Dwarf Beards"))
			for(var/mob/living/carbon/human/B in GLOB.carbon_list)
				B.facial_hair_style = "Dward Beard"
				B.update_hair()
			message_admins("[key_name_admin(usr)] activated dorf mode")

		if("onlyone")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			usr.client.only_one()
			sound_to_playing_players('sound/misc/highlander.ogg')

		if("delayed_onlyone")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			usr.client.only_one_delayed()
			sound_to_playing_players('sound/misc/highlander_delayed.ogg')

		if("maint_access_brig")
			if(!check_rights(R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list(ACCESS_BRIG)
			message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
		if("maint_access_engiebrig")
			if(!check_rights(R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list()
					M.req_one_access = list(ACCESS_BRIG,ACCESS_ENGINE)
			message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
		if("infinite_sec")
			if(!check_rights(R_DEBUG))
				return
			var/datum/job/J = SSjob.GetJob(JOB_NAME_SECURITYOFFICER)
			if(!J)
				return
			J.total_positions = -1
			message_admins("[key_name_admin(usr)] has removed the cap on security officers.")

		if("ctfbutton")
			if(!check_rights(R_ADMIN))
				return
			toggle_id_ctf(usr, "centcom")
		if("masspurrbation")
			if(!check_rights(R_FUN))
				return
			mass_purrbation()
			message_admins("[key_name_admin(usr)] has put everyone on \
				purrbation!")
			log_admin("[key_name(usr)] has put everyone on purrbation.")
		if("massremovepurrbation")
			if(!check_rights(R_FUN))
				return
			mass_remove_purrbation()
			message_admins("[key_name_admin(usr)] has removed everyone from \
				purrbation.")
			log_admin("[key_name(usr)] has removed everyone from purrbation.")

		if("massimmerse")
			if(!check_rights(R_FUN))
				return
			mass_immerse()
			message_admins("[key_name_admin(usr)] has Fully Immersed \
				everyone!")
			log_admin("[key_name(usr)] has Fully Immersed everyone.")
		if("unmassimmerse")
			if(!check_rights(R_FUN))
				return
			mass_immerse(remove=TRUE)
			message_admins("[key_name_admin(usr)] has Un-Fully Immersed \
				everyone!")
			log_admin("[key_name(usr)] has Un-Fully Immersed everyone.")
		if("animalsentience")
			for(var/mob/living/simple_animal/L in GLOB.alive_mob_list)
				var/turf/T = get_turf(L)
				if(!T || !is_station_level(T.z))
					continue
				if((L in GLOB.player_list) || L.mind || (L.flags_1 & HOLOGRAM_1))
					continue
				L.set_playable(ROLE_SENTIENT_ANIMAL)

		if("flipmovement")
			if(!check_rights(R_FUN))
				return
			if(tgui_alert(usr, "Flip all movement controls?","Confirm", list("Yes","Cancel")) != "Yes")
				return
			var/list/movement_keys = SSinput.movement_keys
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				movement_keys[key] = turn(movement_keys[key], 180)
			message_admins("[key_name_admin(usr)] has flipped all movement directions.")
			log_admin("[key_name(usr)] has flipped all movement directions.")

		if("randommovement")
			if(!check_rights(R_FUN))
				return
			if(tgui_alert(usr, "Randomize all movement controls?","Confirm", list("Yes","Cancel")) != "Yes")
				return
			var/list/movement_keys = SSinput.movement_keys
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				movement_keys[key] = turn(movement_keys[key], 45 * rand(1, 8))
			message_admins("[key_name_admin(usr)] has randomized all movement directions.")
			log_admin("[key_name(usr)] has randomized all movement directions.")

		if("custommovement")
			if(!check_rights(R_FUN))
				return
			if(tgui_alert(usr, "Are you sure you want to change every movement key?", "Confirm", list("Yes","Cancel")) != "Yes")
				return
			var/list/movement_keys = SSinput.movement_keys
			var/list/new_movement = list()
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				var/new_direction = tgui_input_list(usr, "Please input the new movement direction when the user presses [key].", "New direction for [key]", list("North", "West", "South", "East", "Northwest", "Southwest", "Southeast", "Northeast"))
				if(!new_direction)
					new_direction = movement_keys[key]
				else
					new_movement[key] = text2dir(new_direction)
			SSinput.movement_keys = new_movement
			message_admins("[key_name_admin(usr)] has configured all movement directions.")
			log_admin("[key_name(usr)] has configured all movement directions.")

		if("resetmovement")
			if(!check_rights(R_FUN))
				return
			if(tgui_alert(usr, "Are you sure you want to reset movement keys to default?","Confirm", list("Yes","Cancel")) != "Yes")
				return
			SSinput.setup_default_movement_keys()
			message_admins("[key_name_admin(usr)] has reset all movement keys.")
			log_admin("[key_name(usr)] has reset all movement keys.")

		if("customportal")
			if(!check_rights(R_FUN))
				return

			var/list/settings = list(
				"mainsettings" = list(
					"typepath" = list("desc" = "Path to spawn", "type" = "datum", "path" = "/mob/living", "subtypesonly" = TRUE, "value" = /mob/living/simple_animal/hostile/poison/bees),
					"humanoutfit" = list("desc" = "Outfit if human", "type" = "datum", "path" = "/datum/outfit", "subtypesonly" = TRUE, "value" = /datum/outfit),
					"amount" = list("desc" = "Number per portal", "type" = "number", "value" = 1),
					"portalnum" = list("desc" = "Number of total portals", "type" = "number", "value" = 10),
					"offerghosts" = list("desc" = "Get ghosts to play mobs", "type" = "boolean", "value" = "No"),
					"minplayers" = list("desc" = "Minimum number of ghosts", "type" = "number", "value" = 1),
					"playersonly" = list("desc" = "Only spawn ghost-controlled mobs", "type" = "boolean", "value" = "No"),
					"ghostpoll" = list("desc" = "Ghost poll question", "type" = "string", "value" = "Do you want to play as %TYPE% portal invader?"),
					"delay" = list("desc" = "Time between portals, in deciseconds", "type" = "number", "value" = 50),
					"color" = list("desc" = "Portal color", "type" = "color", "value" = "#00FF00"),
					"playlightning" = list("desc" = "Play lightning sounds on announcement", "type" = "boolean", "value" = "Yes"),
					"announce_players" = list("desc" = "Make an announcement", "type" = "boolean", "value" = "Yes"),
					"announcement" = list("desc" = "Announcement", "type" = "string", "value" = "Massive bluespace anomaly detected en route to %STATION%. Brace for impact."),
				)
			)

			message_admins("[key_name(usr)] is creating a custom portal storm...")
			var/list/prefreturn = presentpreflikepicker(usr,"Customize Portal Storm", "Customize Portal Storm", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

			if (prefreturn["button"] == 1)
				var/list/prefs = settings["mainsettings"]

				if (prefs["amount"]["value"] < 1 || prefs["portalnum"]["value"] < 1)
					to_chat(usr, "Number of portals and mobs to spawn must be at least 1")
					return

				var/mob/pathToSpawn = prefs["typepath"]["value"]
				if (!ispath(pathToSpawn))
					pathToSpawn = text2path(pathToSpawn)

				if (!ispath(pathToSpawn))
					to_chat(usr, "Invalid path [pathToSpawn]")
					return

				var/list/candidates = list()

				if (prefs["offerghosts"]["value"] == "Yes")
					SSpolling.poll_ghost_candidates(
						question = replacetext(prefs["ghostpoll"]["value"], "%TYPE%", initial(pathToSpawn.name)),
						check_jobban = BAN_ROLE_ALL_ANTAGONISTS,
						poll_time = 30 SECONDS,
						role_name_text = "portal storm",
						alert_pic = /obj/structure/carp_rift,
					)
				if (prefs["playersonly"]["value"] == "Yes" && length(candidates) < prefs["minplayers"]["value"])
					message_admins("Not enough players signed up to create a portal storm, the minimum was [prefs["minplayers"]["value"]] and the number of signups [length(candidates)]")
					return

				if (prefs["announce_players"]["value"] == "Yes")
					portalAnnounce(prefs["announcement"]["value"], (prefs["playlightning"]["value"] == "Yes" ? TRUE : FALSE))

				var/mutable_appearance/storm = mutable_appearance('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
				storm.color = prefs["color"]["value"]

				message_admins("[key_name_admin(usr)] has created a customized portal storm that will spawn [prefs["portalnum"]["value"]] portals, each of them spawning [prefs["amount"]["value"]] of [pathToSpawn]")
				log_admin("[key_name(usr)] has created a customized portal storm that will spawn [prefs["portalnum"]["value"]] portals, each of them spawning [prefs["amount"]["value"]] of [pathToSpawn]")

				var/outfit = prefs["humanoutfit"]["value"]
				if (!ispath(outfit))
					outfit = text2path(outfit)

				for (var/i in 1 to prefs["portalnum"]["value"])
					if (length(candidates)) // if we're spawning players, gotta be a little tricky and also not spawn players on top of NPCs
						var/ghostcandidates = list()
						for (var/j in 1 to min(prefs["amount"]["value"], length(candidates)))
							ghostcandidates += pick_n_take(candidates)
							addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), get_random_station_turf(), pathToSpawn, length(ghostcandidates), storm, ghostcandidates, outfit), i*prefs["delay"]["value"])
					else if (prefs["playersonly"]["value"] != "Yes")
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), get_random_station_turf(), pathToSpawn, prefs["amount"]["value"], storm, null, outfit), i*prefs["delay"]["value"])

	if(E)
		E.processing = FALSE
		if(E.announceWhen>0)
			if(tgui_alert(usr, "Would you like to alert the crew?", "Alert", list("Yes", "No")) != "Yes")
				E.announceChance = 0
		E.processing = TRUE
	if (usr)
		log_admin("[key_name(usr)] used secret [action]")
		if (ok)
			to_chat(world, "<B>A secret has been activated by [usr.key]!</B>")

/proc/portalAnnounce(announcement, playlightning)
	set waitfor = 0
	if (playlightning)
		sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
		sleep(80)
	priority_announce(replacetext(announcement, "%STATION%", station_name()), sound = SSstation.announcer.get_rand_alert_sound())
	if (playlightning)
		sleep(20)
		sound_to_playing_players('sound/magic/lightningbolt.ogg')

/proc/doPortalSpawn(turf/loc, mobtype, numtospawn, portal_appearance, players, humanoutfit)
	for (var/i in 1 to numtospawn)
		var/mob/spawnedMob = new mobtype(loc)
		if (length(players))
			var/mob/chosen = players[1]
			if (chosen.client)
				if(ishuman(spawnedMob))
					chosen.client.prefs.apply_prefs_to(spawnedMob)
				spawnedMob.key = chosen.key
			players -= chosen
		if (ishuman(spawnedMob) && ispath(humanoutfit, /datum/outfit))
			var/mob/living/carbon/human/H = spawnedMob
			H.equipOutfit(humanoutfit)
	var/turf/T = get_step(loc, SOUTHWEST)
	flick_overlay_static(portal_appearance, T, 15)
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), 1)
