/datum/computer_file/program/aidiag
	filename = "aidiag"
	filedesc = "AI Integrity Restorer"
	category = PROGRAM_CATEGORY_ROBO
	program_icon_state = "ai_restorer_off"
	extended_desc = "This program is capable of reconstructing damaged AI systems. Requires direct AI connection via intellicard slot."
	size = 12
	transfer_access = list(ACCESS_HEADS, ACCESS_ROBOTICS, ACCESS_RESEARCH)
	tgui_id = "NtosAiRestorer"
	program_icon = "laptop-code"
	hardware_requirement = MC_AI
	/// Variable dictating if we are in the process of restoring the AI in the inserted intellicard
	var/restoring = FALSE

/datum/computer_file/program/aidiag/proc/get_ai(cardcheck)

	var/obj/item/computer_hardware/ai_slot/ai_slot

	if(computer)
		ai_slot = computer.all_components[MC_AI]

	if(computer && ai_slot && ai_slot.check_functionality())
		if(cardcheck == 1)
			return ai_slot
		if(ai_slot.enabled && ai_slot.stored_card)
			if(cardcheck == 2)
				return ai_slot.stored_card
			if(ai_slot.stored_card.AI)
				return ai_slot.stored_card.AI

	return

/datum/computer_file/program/aidiag/ui_act(action, params)
	if(..())
		return

	var/mob/living/silicon/ai/A = get_ai()
	if(!A)
		restoring = FALSE

	switch(action)
		if("PRG_beginReconstruction")
			if(A && A.health < 100)
				restoring = TRUE
				A.notify_ghost_cloning("Your core files are being restored!", source = computer)
			return TRUE
		if("PRG_eject")
			if(computer.all_components[MC_AI])
				var/obj/item/computer_hardware/ai_slot/ai_slot = computer.all_components[MC_AI]
				if(ai_slot?.stored_card)
					ai_slot.try_eject(usr)
					return TRUE

/datum/computer_file/program/aidiag/process_tick()
	. = ..()
	if(!restoring)	//Put the check here so we don't check for an ai all the time
		return
	var/obj/item/aicard/cardhold = get_ai(2)

	var/obj/item/computer_hardware/ai_slot/ai_slot = get_ai(1)


	var/mob/living/silicon/ai/A = get_ai()
	if(!A || !cardhold)
		restoring = FALSE	// If the AI was removed, stop the restoration sequence.
		if(ai_slot)
			ai_slot.locked = FALSE
		return

	if(cardhold.flush)
		ai_slot.locked = FALSE
		restoring = FALSE
		return
	ai_slot.locked =TRUE
	A.adjustOxyLoss(-1, 0)
	A.adjustFireLoss(-1, 0)
	A.adjustToxLoss(-1, 0)
	A.adjustBruteLoss(-1, 0)
	A.updatehealth()
	if(A.health >= 0 && A.stat == DEAD)
		A.revive()
	// Finished restoring
	if(A.health >= 100)
		ai_slot.locked = FALSE
		restoring = FALSE

	return TRUE


/datum/computer_file/program/aidiag/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/silicon/ai/AI = get_ai()

	var/obj/item/aicard/aicard = get_ai(2)

	data["ejectable"] = TRUE
	data["AI_present"] = FALSE
	data["error"] = null
	program_icon_state = "ai_restorer_off"
	update_computer_icon()

	if(!aicard)
		data["error"] = "Please insert an intelliCard."
	else
		if(!AI)
			data["error"] = "No AI located"
		else
			var/obj/item/aicard/cardhold = AI.loc
			if(cardhold.flush)
				data["error"] = "Flush in progress"
			else
				data["AI_present"] = TRUE
				data["name"] = AI.name
				data["restoring"] = restoring
				data["health"] = (AI.health + 100) / 2
				data["isDead"] = AI.stat == DEAD
				data["laws"] = AI.laws.get_law_list(include_zeroth = 1)
				program_icon_state = "ai_restorer"
				update_computer_icon()


	return data

/datum/computer_file/program/aidiag/kill_program(forced)
	restoring = FALSE
	return ..(forced)
