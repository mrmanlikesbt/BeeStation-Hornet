/datum/antagonist/changeling
	name = "Changeling"
	roundend_category  = "changelings"
	antagpanel_category = "Changeling"
	banning_key = ROLE_CHANGELING
	required_living_playtime = 4
	ui_name = "AntagInfoChangeling"
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	var/you_are_greet = TRUE
	var/team_mode = FALSE //Should assign team objectives ?
	var/competitive_objectives = FALSE //Should we assign objectives in competition with other lings?

	//Changeling Stuff

	var/list/stored_profiles = list() //list of datum/changelingprofile
	var/datum/changelingprofile/first_prof = null
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_storage = 75
	var/chem_recharge_rate = 0.5
	var/chem_recharge_slowdown = 0
	var/sting_range = 2
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/was_absorbed = FALSE //if they were absorbed by another ling already.
	var/isabsorbing = 0
	var/islinking = 0
	var/geneticpoints = 10
	var/purchasedpowers = list()

	var/mimicing = ""
	var/canrespec = FALSE//set to TRUE in absorb.dm
	var/changeling_speak = 0
	var/datum/dna/chosen_dna
	var/datum/action/changeling/sting/chosen_sting
	var/datum/cellular_emporium/cellular_emporium
	var/datum/action/innate/cellular_emporium/emporium_action

	var/static/list/all_powers = typecacheof(/datum/action/changeling,TRUE)

	var/static/list/slot2type = list(
		"head" = /obj/item/clothing/head/changeling,
		"wear_mask" = /obj/item/clothing/mask/changeling,
		"back" = /obj/item/changeling,
		"wear_suit" = /obj/item/clothing/suit/changeling,
		"w_uniform" = /obj/item/clothing/under/changeling,
		"shoes" = /obj/item/clothing/shoes/changeling,
		"belt" = /obj/item/changeling,
		"gloves" = /obj/item/clothing/gloves/changeling,
		"glasses" = /obj/item/clothing/glasses/changeling,
		"ears" = /obj/item/changeling,
		"wear_id" = /obj/item/card/id/changeling,
		"s_store" = /obj/item/changeling,
	)

/datum/antagonist/changeling/New()
	. = ..()
	for(var/datum/antagonist/changeling/C in GLOB.antagonists)
		if(!C.owner || C.owner == owner)
			continue
		if(C.was_absorbed) //make sure the other ling wasn't already killed by another one. only matters if the changeling that absorbed them was gibbed after.
			continue
		competitive_objectives = TRUE
		break

/datum/antagonist/changeling/Destroy()
	QDEL_NULL(cellular_emporium)
	QDEL_NULL(emporium_action)
	. = ..()

/datum/antagonist/changeling/proc/generate_name()
	var/static/list/left_changling_names = GLOB.greek_letters.Copy()

	var/honorific
	if(owner.current.gender == FEMALE)
		honorific = "Ms."
	else
		honorific = "Mr."
	if(length(left_changling_names))
		changelingID = pick_n_take(left_changling_names)
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [pick(GLOB.greek_letters)] No.[rand(1,9)]"

/datum/antagonist/changeling/proc/create_actions()
	cellular_emporium = new(src)
	emporium_action = new(cellular_emporium)
	emporium_action.Grant(owner.current)

/datum/antagonist/changeling/on_gain()
	generate_name()
	create_actions()
	reset_powers()
	create_initial_profile()
	if(give_objectives)
		forge_objectives()
	handle_clown_mutation(owner.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
	owner.current.get_language_holder().omnitongue = TRUE
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	. = ..()

/datum/antagonist/changeling/on_removal()
	//We'll be using this from now on
	var/mob/living/carbon/C = owner.current
	if(istype(C))
		var/obj/item/organ/brain/B = C.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(B && (B.decoy_override != initial(B.decoy_override)))
			B.organ_flags |= ORGAN_VITAL
			B.decoy_override = FALSE
	remove_changeling_powers()
	handle_clown_mutation(owner.current, removing=FALSE)
	. = ..()

/datum/antagonist/changeling/proc/reset_properties()
	changeling_speak = 0
	chosen_sting = null
	mimicing = ""
	sting_range = initial(sting_range)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_charges = min(chem_charges, chem_storage)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)

/datum/antagonist/changeling/proc/remove_changeling_powers()
	if(ishuman(owner.current) || ismonkey(owner.current))
		reset_properties()
		for(var/datum/action/changeling/p in purchasedpowers)
			purchasedpowers -= p
			p.Remove(owner.current)
			geneticpoints += p.dna_cost

	//MOVE THIS
	if(owner.current.hud_used?.lingstingdisplay)
		owner.current.hud_used.lingstingdisplay.icon_state = null
		owner.current.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/datum/antagonist/changeling/proc/reset_powers()
	if(purchasedpowers)
		remove_changeling_powers()
	//Repurchase free powers.
	for(var/path in all_powers)
		var/datum/action/changeling/S = new path
		if(!S.dna_cost)
			if(!has_sting(S))
				purchasedpowers += S
				S.on_purchase(owner.current,TRUE)

/datum/antagonist/changeling/proc/regain_powers()//for when action buttons are lost and need to be regained, such as when the mind enters a new mob
	emporium_action.Grant(owner.current)
	for(var/power in purchasedpowers)
		var/datum/action/changeling/S = power
		if(istype(S) && S.needs_button)
			S.Grant(owner.current)

/datum/antagonist/changeling/ui_data(mob/user)
	var/list/data = list()

	data["true_name"] = changelingID
	data["objectives"] = get_objectives()
	return data

///Handles stinging without verbs.
/datum/antagonist/changeling/proc/stingAtom(mob/living/carbon/ling, atom/A)
	if(!chosen_sting || A == ling || !istype(ling) || ling.stat)
		return
	chosen_sting.try_to_sting(ling, A)
	ling.changeNext_move(CLICK_CD_MELEE)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/antagonist/changeling/proc/has_sting(datum/action/changeling/power)
	for(var/P in purchasedpowers)
		var/datum/action/changeling/otherpower = P
		if(initial(power.name) == otherpower.name)
			return TRUE
	return FALSE


/datum/antagonist/changeling/proc/purchase_power(sting_name)
	var/datum/action/changeling/thepower

	for(var/path in all_powers)
		var/datum/action/changeling/S = path
		if(initial(S.name) == sting_name)
			thepower = new path
			break

	if(!thepower)
		to_chat(owner.current, "This is awkward. Changeling power purchase failed, please report this bug to a coder!")
		return

	if(absorbedcount < thepower.req_dna)
		to_chat(owner.current, "We lack the energy to evolve this ability!")
		return

	if(has_sting(thepower))
		to_chat(owner.current, "We have already evolved this ability!")
		return

	if(thepower.dna_cost < 0)
		to_chat(owner.current, "We cannot evolve this ability.")
		return

	if(geneticpoints < thepower.dna_cost)
		to_chat(owner.current, "We have reached our capacity for abilities.")
		return

	if(HAS_TRAIT(owner.current, TRAIT_DEATHCOMA))//To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		to_chat(owner.current, "We lack the energy to evolve new abilities right now.")
		return

	log_game("[sting_name] purchased by [owner.current.ckey]/[owner.current.name] the [owner.current.job] for [thepower.dna_cost] GP, [geneticpoints] GP remaining.")
	geneticpoints -= thepower.dna_cost
	purchasedpowers += thepower
	thepower.on_purchase(owner.current)//Grant() is ran in this proc, see changeling_powers.dm

/datum/antagonist/changeling/proc/readapt()
	if(!ishuman(owner.current))
		to_chat(owner.current, span_danger("We can't remove our evolutions in this form!"))
		return
	if(isabsorbing)
		to_chat(owner.current, span_danger("We cannot readapt right now!"))
		return
	if(canrespec)
		to_chat(owner.current, span_notice("We have removed our evolutions from this form, and are now ready to readapt."))
		reset_powers()
		canrespec = 0
		SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, "Readapt")
		log_game("Genetic powers refunded by [owner.current.ckey]/[owner.current.name] the [owner.current.job], [geneticpoints] GP remaining.")
		return 1
	else
		to_chat(owner.current, span_danger("You lack the power to readapt your evolutions!"))
		return 0

//Called in life()
/datum/antagonist/changeling/proc/regenerate(delta_time, times_fired)//grants the HuD in life.dm
	var/mob/living/carbon/the_ling = owner.current
	if(istype(the_ling))
		if(the_ling.stat == DEAD)
			chem_charges = min(max(0, chem_charges + ((chem_recharge_rate - chem_recharge_slowdown) * delta_time)), (chem_storage * 0.5))
			geneticdamage = max(geneticdamage - (0.5 * delta_time), LING_DEAD_GENETICDAMAGE_HEAL_CAP)
		else //not dead? no chem/geneticdamage caps.
			chem_charges = min(max(0, chem_charges + ((chem_recharge_rate - chem_recharge_slowdown) * delta_time)), chem_storage)
			geneticdamage = max(geneticdamage - (0.5 * delta_time), 0)


/datum/antagonist/changeling/proc/get_dna(dna_owner)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(dna_owner == prof.name)
			return prof

/datum/antagonist/changeling/proc/has_dna(datum/dna/tDNA)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(tDNA.is_same_as(prof.dna))
			return TRUE
	return FALSE

/datum/antagonist/changeling/proc/can_absorb_dna(mob/living/carbon/human/target, verbose=TRUE)
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return
	if(!target)
		return
	if(isipc(target))
		if(verbose)
			to_chat(user, span_warning("We cannot absorb mechanical entities!"))
		return
	if(NO_DNA_COPY in target.dna.species.species_traits)
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return
	if(HAS_TRAIT(target, TRAIT_BADDNA))
		if(verbose)
			to_chat(user, span_warning("DNA of [target] is ruined beyond usability!"))
		return
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(verbose)
			to_chat(user, span_warning("[target]'s body is ruined beyond usability!"))
		return
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		if(verbose)
			to_chat(user, span_warning("We could gain no benefit from absorbing a lesser creature."))
		return
	if(has_dna(target.dna))
		if(verbose)
			to_chat(user, span_warning("We already have this DNA in storage!"))
		return
	if(!target.has_dna())
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return
	return 1


/datum/antagonist/changeling/proc/create_profile(mob/living/carbon/human/H, protect = 0)
	var/datum/changelingprofile/prof = new

	H.dna.real_name = H.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = new H.dna.type
	H.dna.copy_dna(new_dna)
	prof.dna = new_dna
	prof.name = H.real_name
	prof.protected = protect

	prof.underwear = H.underwear
	prof.undershirt = H.undershirt
	prof.socks = H.socks

	if(H.wear_id?.GetID())
		var/obj/item/card/id/I = H.wear_id.GetID()
		if(istype(I))
			prof.id_job_name = I.assignment
			prof.id_hud_state = I.hud_state

	var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		if(slot in H.vars)
			var/obj/item/clothing/I = H.vars[slot]
			if(!I)
				continue
			prof.name_list[slot] = I.name
			prof.appearance_list[slot] = I.appearance
			prof.flags_cover_list[slot] = I.flags_cover
			prof.item_state_list[slot] = I.item_state
			prof.lefthand_file_list[slot] = I.lefthand_file
			prof.righthand_file_list[slot] = I.righthand_file
			prof.worn_icon_list[slot] = I.worn_icon
			prof.worn_icon_state_list[slot] = I.worn_icon_state
			prof.exists_list[slot] = 1
		else
			continue

	return prof

/datum/antagonist/changeling/proc/add_profile(datum/changelingprofile/prof)
	if(!first_prof)
		first_prof = prof

	stored_profiles += prof
	absorbedcount++

/datum/antagonist/changeling/proc/add_new_profile(mob/living/carbon/human/H, protect = 0)
	var/datum/changelingprofile/prof = create_profile(H, protect)
	add_profile(prof)
	return prof

/datum/antagonist/changeling/proc/remove_profile(mob/living/carbon/human/H, force = 0)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(H.real_name == prof.name)
			if(prof.protected && !force)
				continue
			stored_profiles -= prof
			qdel(prof)

/datum/antagonist/changeling/proc/get_profile_to_remove()
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(!prof.protected)
			return prof

/datum/antagonist/changeling/proc/push_out_profile()
	var/datum/changelingprofile/removeprofile = get_profile_to_remove()
	if(removeprofile)
		stored_profiles -= removeprofile
		return 1
	return 0


/datum/antagonist/changeling/proc/create_initial_profile()
	var/mob/living/carbon/C = owner.current	//only carbons have dna now, so we have to typecaste
	//If you can't be turned into that creature, you shouldnt start as that creature
	if(NOTRANSSTING in C.dna.species.species_traits)
		C.set_species(/datum/species/human)
		C.fully_replace_character_name(C.real_name, C.client.prefs.read_character_preference(/datum/preference/name/backup_human))
		for(var/datum/record/crew/E in GLOB.manifest.general)
			if(E.name == C.real_name)
				E.species = "\improper Human"
				var/static/list/show_directions = list(SOUTH, WEST)
				var/image = get_flat_existing_human_icon(C, show_directions)
				var/datum/picture/pf = new
				var/datum/picture/ps = new
				pf.picture_name = "[C]"
				ps.picture_name = "[C]"
				pf.picture_desc = "This is [C]."
				ps.picture_desc = "This is [C]."
				pf.picture_image = icon(image, dir = SOUTH)
				ps.picture_image = icon(image, dir = WEST)
				E.gender = C.gender
	if(ishuman(C))
		add_new_profile(C)

/datum/antagonist/changeling/apply_innate_effects()
	//Brains optional.
	var/mob/living/carbon/C = owner.current
	if(istype(C))
		var/obj/item/organ/brain/B = C.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(B)
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE
		RegisterSignals(C, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON), PROC_REF(stingAtom))
	update_changeling_icons_added()

/datum/antagonist/changeling/remove_innate_effects()
	update_changeling_icons_removed()
	UnregisterSignal(owner.current, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON))


/datum/antagonist/changeling/greet()
	if (you_are_greet)
		to_chat(owner.current, span_boldannounce("You are [changelingID], a changeling! You have absorbed and taken the form of a human."))
	to_chat(owner.current, "<b>You must complete the following tasks:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

	owner.announce_objectives()

	owner.current.client?.tgui_panel?.give_antagonist_popup("Changeling",
		"You have absorbed the form of [owner.current] and have infiltrated the station. Use your changeling powers to complete your objectives.")

/datum/antagonist/changeling/farewell()
	to_chat(owner.current, span_userdanger("You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!"))

/datum/antagonist/changeling/proc/forge_objectives()
	//OBJECTIVES - random traitor objectives. Unique objectives "steal brain" and "identity theft".
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/escape_objective_possible = TRUE
	switch(competitive_objectives ? rand(1,2) : 1)
		if(1)
			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = owner
			absorb_objective.gen_amount_goal(6, 8)
			objectives += absorb_objective
			log_objective(owner, absorb_objective.explanation_text)
		if(2)
			var/datum/objective/absorb_most/ac = new
			ac.owner = owner
			objectives += ac
			log_objective(owner, ac.explanation_text)

	if(prob(60))
		if(prob(85))
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
			log_objective(owner, steal_objective.explanation_text)
		else
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			objectives += download_objective
			log_objective(owner, download_objective.explanation_text)

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/GLOB.joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = owner
		destroy_objective.find_target()
		objectives += destroy_objective
		log_objective(owner, destroy_objective.explanation_text)
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			if(team_mode) //No backstabbing while in a team
				kill_objective.find_target_by_role(role = ROLE_CHANGELING, role_type = TRUE, invert = TRUE)
			else
				kill_objective.find_target()
			objectives += kill_objective
			log_objective(owner, kill_objective.explanation_text)
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			if(team_mode)
				maroon_objective.find_target_by_role(role = ROLE_CHANGELING, role_type = TRUE, invert = TRUE)
			else
				maroon_objective.find_target()
			objectives += maroon_objective
			log_objective(owner, maroon_objective.explanation_text)

			if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = owner
				if(identity_theft.is_valid_target(maroon_objective.target))
					identity_theft.set_target(maroon_objective.target)
					identity_theft.update_explanation_text()
					objectives += identity_theft
					log_objective(owner, identity_theft.explanation_text)
					escape_objective_possible = FALSE
				else
					qdel(identity_theft)

	if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
			log_objective(owner, escape_objective.explanation_text)
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = owner
			if(team_mode)
				identity_theft.find_target_by_role(role = ROLE_CHANGELING, role_type = TRUE, invert = TRUE)
			else
				identity_theft.find_target()
			objectives += identity_theft
			log_objective(owner, identity_theft.explanation_text)
		escape_objective_possible = FALSE

/datum/antagonist/changeling/proc/update_changeling_icons_added()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_CHANGELING]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "changeling")

/datum/antagonist/changeling/proc/update_changeling_icons_removed()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_CHANGELING]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/changeling/admin_add(datum/mind/new_owner,mob/admin)
	. = ..()
	to_chat(new_owner.current, span_boldannounce("Our powers have awoken. A flash of memory returns to us...we are [changelingID], a changeling!"))

/datum/antagonist/changeling/get_admin_commands()
	. = ..()
	if(stored_profiles.len && (owner.current.real_name != first_prof.name))
		.["Transform to initial appearance."] = CALLBACK(src,PROC_REF(admin_restore_appearance))

/datum/antagonist/changeling/proc/admin_restore_appearance(mob/admin)
	if(!stored_profiles.len || !iscarbon(owner.current))
		to_chat(admin, span_danger("Resetting DNA failed!"))
	else
		var/mob/living/carbon/C = owner.current
		first_prof.dna.transfer_identity(C, transfer_SE=1)
		C.real_name = first_prof.name
		C.updateappearance(mutcolor_update=1)
		C.domutcheck()

// Profile

/datum/changelingprofile
	var/name = "a bug"

	var/protected = 0

	var/datum/dna/dna = null
	var/list/name_list = list() //associative list of slotname = itemname
	var/list/appearance_list = list()
	var/list/flags_cover_list = list()
	var/list/exists_list = list()
	var/list/item_state_list = list()
	var/list/lefthand_file_list = list()
	var/list/righthand_file_list = list()
	var/list/worn_icon_list = list()
	var/list/worn_icon_state_list = list()

	var/underwear
	var/undershirt
	var/socks

	/// ID HUD icon associated with the profile
	var/id_job_name
	var/id_hud_state

/datum/changelingprofile/Destroy()
	qdel(dna)
	. = ..()

/datum/changelingprofile/proc/copy_profile(datum/changelingprofile/newprofile)
	newprofile.name = name
	newprofile.protected = protected
	newprofile.dna = new dna.type
	dna.copy_dna(newprofile.dna)
	newprofile.name_list = name_list.Copy()
	newprofile.appearance_list = appearance_list.Copy()
	newprofile.flags_cover_list = flags_cover_list.Copy()
	newprofile.exists_list = exists_list.Copy()
	newprofile.item_state_list = item_state_list.Copy()
	newprofile.lefthand_file_list = lefthand_file_list.Copy()
	newprofile.righthand_file_list = righthand_file_list.Copy()
	newprofile.worn_icon_list = worn_icon_list.Copy()
	newprofile.worn_icon_state_list = worn_icon_state_list.Copy()
	newprofile.underwear = underwear
	newprofile.undershirt = undershirt
	newprofile.socks = socks
	newprofile.id_job_name = id_job_name
	newprofile.id_hud_state = id_hud_state

/datum/antagonist/changeling/proc/transform(mob/living/carbon/human/user, datum/changelingprofile/chosen_prof)
	var/static/list/slot2slot = list(
		"head" = ITEM_SLOT_HEAD,
		"wear_mask" = ITEM_SLOT_MASK,
		"neck" = ITEM_SLOT_NECK,
		"back" = ITEM_SLOT_BACK,
		"wear_suit" = ITEM_SLOT_OCLOTHING,
		"w_uniform" = ITEM_SLOT_ICLOTHING,
		"shoes" = ITEM_SLOT_FEET,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"glasses" = ITEM_SLOT_EYES,
		"ears" = ITEM_SLOT_EARS,
		"wear_id" = ITEM_SLOT_ID,
		"s_store" = ITEM_SLOT_SUITSTORE,
	)

	var/datum/dna/chosen_dna = chosen_prof.dna
	user.real_name = chosen_prof.name
	user.underwear = chosen_prof.underwear
	user.undershirt = chosen_prof.undershirt
	user.socks = chosen_prof.socks

	chosen_dna.transfer_identity(user, 1)

	///Bodypart data hack. Will rewrite when I rewrite changelings soon-ish
	for(var/obj/item/bodypart/BP as() in user.bodyparts)
		if(IS_ORGANIC_LIMB(BP))
			BP.update_limb(is_creating = TRUE)

	user.updateappearance(mutcolor_update=1)
	user.domutcheck()

	//vars hackery. not pretty, but better than the alternative.
	for(var/slot in slot2type)
		if(istype(user.vars[slot], slot2type[slot]) && !(chosen_prof.exists_list[slot])) //remove unnecessary flesh items
			qdel(user.vars[slot])
			continue

		if((user.vars[slot] && !istype(user.vars[slot], slot2type[slot])) || !(chosen_prof.exists_list[slot]))
			continue

		if(istype(user.vars[slot], slot2type[slot]) && slot == "wear_id") //always remove old flesh IDs, so they get properly updated
			qdel(user.vars[slot])

		var/obj/item/C
		var/equip = 0
		if(!user.vars[slot])
			var/thetype = slot2type[slot]
			equip = 1
			C = new thetype(user)

		else if(istype(user.vars[slot], slot2type[slot]))
			C = user.vars[slot]

		C.appearance = chosen_prof.appearance_list[slot]
		C.name = chosen_prof.name_list[slot]
		C.flags_cover = chosen_prof.flags_cover_list[slot]
		C.lefthand_file = chosen_prof.lefthand_file_list[slot]
		C.righthand_file = chosen_prof.righthand_file_list[slot]
		C.item_state = chosen_prof.item_state_list[slot]
		C.worn_icon = chosen_prof.worn_icon_list[slot]
		C.worn_icon_state = chosen_prof.worn_icon_state_list[slot]

		if(istype(C, /obj/item/card/id/changeling) && chosen_prof.id_job_name)
			var/obj/item/card/id/changeling/flesh_id = C
			flesh_id.assignment = chosen_prof.id_job_name
			flesh_id.hud_state = chosen_prof.id_hud_state

		if(equip)
			user.equip_to_slot_or_del(C, slot2slot[slot])
			if(!QDELETED(C))
				ADD_TRAIT(C, TRAIT_NODROP, CHANGELING_TRAIT)

	user.regenerate_icons()

/datum/antagonist/changeling/xenobio
	name = "Xenobio Changeling"
	give_objectives = FALSE
	show_in_roundend = FALSE //These are here for admin tracking purposes only
	you_are_greet = FALSE

/datum/antagonist/changeling/roundend_report()
	var/list/parts = list()

	var/changelingwin = 1
	if(!owner.current)
		changelingwin = 0

	parts += printplayer(owner)

	//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
	parts += "<b>Changeling ID:</b> [changelingID]."
	parts += "<b>Genomes Extracted:</b> [absorbedcount]"
	parts += " "
	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!</b>")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				changelingwin = 0
			count++

	if(changelingwin)
		parts += span_greentext("The changeling was successful!")
	else
		parts += span_redtext("The changeling has failed.")

	return parts.Join("<br>")

/datum/antagonist/changeling/antag_listing_name()
	return ..() + "([changelingID])"

/datum/antagonist/changeling/xenobio/antag_listing_name()
	return ..() + "(Xenobio)"

