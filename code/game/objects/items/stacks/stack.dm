/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

//stack recipe placement check types config
/// checks if there is an object of the result type in any of the cardinal directions
#define STACK_CHECK_CARDINALS "cardinals"
/// checks if there is an object of the result type within one tile
#define STACK_CHECK_ADJACENT "adjacent"

/*
 * Stacks
 */

/obj/item/stack
	icon = 'icons/obj/stacks/minerals.dmi'
	gender = PLURAL
	material_modifier = 0.05 //5%, so that a 50 sheet stack has the effect of 5k materials instead of 100k.
	///The name of the thing when it's singular
	var/singular_name
	///The amount of thing in the stack
	var/amount = 1
	///also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/max_amount = 50
	///It's TRUE if module is used by a cyborg, and uses its storage
	var/is_cyborg = FALSE
	///Holder var for the cyborg energy source
	var/datum/robot_energy_storage/source
	///How much energy from storage it costs
	var/cost = 1
	///This path and its children should merge with this stack, defaults to src.type
	var/merge_type
	///The weight class the stack should have at amount > 2/3rds max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	//Determines whether the item should update it's sprites based on amount.
	var/novariants = TRUE
	//list that tells you how much is in a single unit.
	var/list/mats_per_unit
	///Datum material type that this stack is made of
	var/material_type
	///Stores table variant to be built from this stack
	var/obj/structure/table/tableVariant
	/// Amount of matter for RCD
	var/matter_amount = 0

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack)

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	if(new_amount != null)
		amount = new_amount
	if(user)
		add_fingerprint(user)
	check_max_amount()
	if(!merge_type)
		merge_type = type

	if(LAZYLEN(mats_per_unit))
		set_mats_per_unit(mats_per_unit, 1)
	else if(LAZYLEN(custom_materials))
		set_mats_per_unit(custom_materials, amount ? 1/amount : 1)

	. = ..()
	if(merge)
		for(var/obj/item/stack/item_stack in loc)
			if(item_stack == src)
				continue
			if(can_merge(item_stack))
				INVOKE_ASYNC(src, PROC_REF(merge_without_del), item_stack)
				if(is_zero_amount(delete_if_zero = FALSE))
					return INITIALIZE_HINT_QDEL
	update_weight()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_movable_entered_occupied_turf),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/stack/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_left_click_action("Open stack crafting")
	context.add_right_click_action("Split Stack")


/** Sets the amount of materials per unit for this stack.
  *
  * Arguments:
  * - [mats][/list]: The value to set the mats per unit to.
  * - multiplier: The amount to multiply the mats per unit by. Defaults to 1.
  */
/obj/item/stack/proc/set_mats_per_unit(list/mats, multiplier=1)
	mats_per_unit = SSmaterials.FindOrCreateMaterialCombo(mats, multiplier)
	update_custom_materials()

/** Updates the custom materials list of this stack.
  */
/obj/item/stack/proc/update_custom_materials()
	set_custom_materials(mats_per_unit, amount, is_update=TRUE)

/**
 * Override to make things like metalgen accurately set custom materials
 */
/obj/item/stack/set_custom_materials(list/materials, multiplier=1, is_update=FALSE)
	return is_update ? ..() : set_mats_per_unit(materials, multiplier/(amount || 1))

/obj/item/stack/grind_requirements()
	if(is_cyborg)
		to_chat(usr, span_warning("[src] is electronically synthesized in your chassis and can't be ground up!"))
		return
	return TRUE

/obj/item/stack/grind(datum/reagents/target_holder, mob/user)
	var/current_amount = get_amount()
	if(current_amount <= 0 || QDELETED(src)) //just to get rid of this 0 amount/deleted stack we return success
		return TRUE
	if(on_grind() == -1)
		return FALSE
	if(isnull(target_holder))
		return TRUE

	if(reagents)
		reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
	var/available_volume = target_holder.maximum_volume - target_holder.total_volume

	//compute total volume of reagents that will be occupied by grind_results
	var/total_volume = 0
	for(var/reagent in grind_results)
		total_volume += grind_results[reagent]

	//compute number of pieces(or sheets) from available_volume
	var/available_amount = min(current_amount, round(available_volume / total_volume))
	if(available_amount <= 0)
		return FALSE

	//Now transfer the grind results scaled by available_amount
	var/list/grind_reagents = grind_results.Copy()
	for(var/reagent in grind_reagents)
		grind_reagents[reagent] *= available_amount
	target_holder.add_reagent_list(grind_reagents)

	/**
	 * use available_amount of sheets/pieces, return TRUE only if all sheets/pieces of this stack were used
	 * we don't delete this stack when it reaches 0 because we expect the all in one grinder, etc to delete
	 * this stack if grinding was successfull
	 */
	use(available_amount, check = FALSE)
	return available_amount == current_amount

/obj/item/stack/proc/check_max_amount()
	while(amount > max_amount)
		amount -= max_amount
		ui_update()
		new type(loc, max_amount, FALSE)

/// DO NOT CALL PARENT EVER. Each material should call individual material recipe
/obj/item/stack/proc/get_recipes()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if(amount <= (max_amount * (2/3)))
		w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/update_icon_state()
	if(novariants)
		return
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
		return ..()
	if(amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
		return ..()
	icon_state = "[initial(icon_state)]_3"
	return ..()

/obj/item/stack/examine(mob/user)
	. = ..()
	if(is_cyborg)
		if(singular_name)
			. += "There is enough energy for [get_amount()] [singular_name]\s."
		else
			. += "There is enough energy for [get_amount()]."
		return
	if(singular_name)
		if(get_amount() > 1)
			. += "There are [get_amount()] [singular_name]\s in the stack."
		else
			. += "There is [get_amount()] [singular_name] in the stack."
	else if(get_amount() > 1)
		. += "There are [get_amount()] in the stack."
	else
		. += "There is [get_amount()] in the stack."
	. += "<span class='notice'><b>Right-click</b> with an empty hand to take a custom amount.</span>"

/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source?.energy / cost)
	else
		. = (amount)

/**
  * Builds all recipes in a given recipe list and returns an association list containing them
  *
  * Arguments:
  * * recipe_to_iterate - The list of recipes we are using to build recipes
  */
/obj/item/stack/proc/recursively_build_recipes(list/recipe_to_iterate)
	var/list/L = list()
	for(var/recipe in recipe_to_iterate)
		if(isnull(recipe))
			L += list(list(
				"spacer" = TRUE
			))
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L += list(list(
				"title" = R.title,
				"sub_recipes" = recursively_build_recipes(R.recipes),
			))
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L += list(build_recipe(R))
	return L

/**
  * Returns a list of properties of a given recipe
  *
  * Arguments:
  * * R - The stack recipe we are using to get a list of properties
  */
/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"title" = R.title,
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = "[REF(R)]",
	)

/**
  * Checks if the recipe is valid to be used
  *
  * Arguments:
  * * R - The stack recipe we are checking if it is valid
  * * recipe_list - The list of recipes we are using to check the given recipe
  */
/obj/item/stack/proc/is_valid_recipe(datum/stack_recipe/R, list/recipe_list)
	for(var/S in recipe_list)
		if(S == R)
			return TRUE
		if(istype(S, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/L = S
			if(is_valid_recipe(R, L.recipes))
				return TRUE
	return FALSE

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Stack", name)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(get_recipes())
	return data

/obj/item/stack/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			if(get_amount() < 1 && !is_cyborg)
				qdel(src)
				return
			var/datum/stack_recipe/R = locate(params["ref"])
			if(!is_valid_recipe(R, get_recipes())) //href exploit protection
				return
			var/multiplier = text2num(params["multiplier"])
			if(!isnum_safe(multiplier) || (multiplier <= 0)) //href exploit protection
				return
			if(!building_checks(R, multiplier))
				return
			if(R.time)
				usr.visible_message(span_notice("[usr] starts building \a [R.title]."), span_notice("You start building \a [R.title]..."))
				if(!do_after(usr, R.time, target = usr))
					return
				if(!building_checks(R, multiplier))
					return

			var/obj/O
			if(R.max_res_amount > 1) //Is it a stack?
				O = new R.result_type(usr.drop_location(), R.res_amount * multiplier)
			else if(ispath(R.result_type, /turf))
				var/turf/T = usr.drop_location()
				if(!isturf(T))
					return
				T.PlaceOnTop(R.result_type, flags = CHANGETURF_INHERIT_AIR)
			else
				O = new R.result_type(usr.drop_location())
			if(O)
				O.setDir(usr.dir)
			use(R.req_amount * multiplier)

			if(R.applies_mats && LAZYLEN(mats_per_unit))
				if(isstack(O))
					var/obj/item/stack/crafted_stack = O
					crafted_stack.set_mats_per_unit(mats_per_unit, R.req_amount / R.res_amount)
				else
					O.set_custom_materials(mats_per_unit, R.req_amount / R.res_amount)

			if(QDELETED(O))
				return //It's a stack and has already been merged

			if(isitem(O))
				usr.put_in_hands(O)
			O.add_fingerprint(usr)

			if(istype(O, /obj/item/storage))
				for(var/obj/item/I in O)
					qdel(I)
			return TRUE

/obj/item/stack/proc/building_checks(datum/stack_recipe/recipe, multiplier)
	if(get_amount() < recipe.req_amount*multiplier)
		if(recipe.req_amount*multiplier>1)
			to_chat(usr, span_warning("You haven't got enough [src] to build \the [recipe.req_amount*multiplier] [recipe.title]\s!"))
		else
			to_chat(usr, span_warning("You haven't got enough [src] to build \the [recipe.title]!"))
		return FALSE

	var/turf/dest_turf = get_turf(usr)

	// If we're making a window, we have some special snowflake window checks to do.
	if(ispath(recipe.result_type, /obj/structure/window))
		var/obj/structure/window/result_path = recipe.result_type
		if(!valid_window_location(dest_turf, usr.dir, is_fulltile = initial(result_path.fulltile)))
			to_chat(usr, span_warning("The [recipe.title] won't fit here!"))
			return FALSE

	if(recipe.one_per_turf && (locate(recipe.result_type) in dest_turf))
		to_chat(usr, span_warning("There is another [recipe.title] here!"))
		return FALSE

	if(recipe.on_floor)
		if(!isanyfloor(dest_turf))
			to_chat(usr, span_warning("\The [recipe.title] must be constructed on the floor!"))
			return FALSE

		for(var/obj/object in dest_turf)
			if(istype(object, /obj/structure/grille))
				continue
			if(istype(object, /obj/structure/table))
				continue
			if(istype(object, /obj/structure/window))
				var/obj/structure/window/window_structure = object
				if(!window_structure.fulltile)
					continue
			if(object.density)
				to_chat(usr, span_warning("There is \a [object.name] here. You cant make \a [recipe.title] here!"))
				return FALSE
	if(recipe.placement_checks)
		switch(recipe.placement_checks)
			if(STACK_CHECK_CARDINALS)
				var/turf/step
				for(var/direction in GLOB.cardinals)
					step = get_step(dest_turf, direction)
					if(locate(recipe.result_type) in step)
						to_chat(usr, span_warning("\The [recipe.title] must not be built directly adjacent to another!"))
						return FALSE
			if(STACK_CHECK_ADJACENT)
				if(locate(recipe.result_type) in range(1, dest_turf))
					to_chat(usr, span_warning("\The [recipe.title] must be constructed at least one tile away from others of its type!"))
					return FALSE
	return TRUE

/obj/item/stack/use(used, transfer = FALSE, check = TRUE) // return FALSE = borked; return TRUE = had enough
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return FALSE
	if(is_cyborg)
		return source.use_charge(used * cost)
	if(amount < used)
		return FALSE
	amount -= used
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return TRUE
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	ui_update()
	update_weight()
	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, span_warning("You need at least [amount] [singular_name]\s to do this!"))
			else
				to_chat(user, span_warning("You need at least [amount] [singular_name] to do this!"))
		else
			to_chat(user, span_warning("You need at least [amount] to do this!"))
		return FALSE
	return TRUE

/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/obj/item/stack/proc/is_zero_amount(delete_if_zero = TRUE)
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		if(delete_if_zero)
			qdel(src)
		return TRUE
	return FALSE

/** Adds some number of units to this stack.
  *
  * Arguments:
  * - _amount: The number of units to add to this stack.
  */
/obj/item/stack/proc/add(_amount)
	if (is_cyborg)
		source.add_charge(_amount * cost)
	else
		amount += _amount
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	update_weight()
	ui_update()

/** Checks whether this stack can merge itself into another stack.
  *
  * Arguments:
  * - [check][/obj/item/stack]: The stack to check for mergeability.
  */
/obj/item/stack/proc/can_merge(obj/item/stack/check)
	if(!istype(check, merge_type))
		return FALSE
	if(mats_per_unit != check.mats_per_unit)
		return FALSE
	if(is_cyborg)	// No merging cyborg stacks into other stacks
		return FALSE
	return TRUE

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This calls use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/obj/item/stack/proc/merge_without_del(obj/item/stack/target_stack, limit)
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(QDELETED(target_stack))
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(QDELETED(src))
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(target_stack == src)
		CRASH("Stack attempted to merge into itself.")

	var/transfer = get_amount()
	if(target_stack.is_cyborg)
		transfer = min(transfer, round((target_stack.source.max_energy - target_stack.source.energy) / target_stack.cost))
	else
		transfer = min(transfer, (limit ? limit : target_stack.max_amount) - target_stack.amount)
	if(pulledby)
		pulledby.start_pulling(target_stack)
	target_stack.copy_evidences(src)
	use(transfer, transfer = TRUE, check = FALSE)
	target_stack.add(transfer)
	return transfer

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/obj/item/stack/proc/merge(obj/item/stack/target_stack, limit)
	. = merge_without_del(target_stack, limit)
	is_zero_amount(delete_if_zero = TRUE)
	ui_update() //merging into stack wont update stackcrafting menu otherwise

/// Signal handler for connect_loc element. Called when a movable enters the turf we're currently occupying. Merges if possible.
/obj/item/stack/proc/on_movable_entered_occupied_turf(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	// Edge case. This signal will also be sent when src has entered the turf. Don't want to merge with ourselves.
	if(arrived == src)
		return

	if(!arrived.throwing && can_merge(arrived))
		INVOKE_ASYNC(src, PROC_REF(merge), arrived)

/obj/item/stack/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(can_merge(AM))
		merge(AM)
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		return split_stack(user, 1)
	else
		. = ..()

//If we attack ourselves with the same hand
/obj/item/stack/attack_self_secondary(mob/user, modifiers)
	. = ..()
	src.attack_hand_secondary(user, modifiers)

//If we attack ourselves with a different hand
/obj/item/stack/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(is_cyborg || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	if(is_zero_amount(delete_if_zero = TRUE))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/max = get_amount()
	var/stackmaterial = tgui_input_number(user, "How many sheets do you wish to take out of this stack?", "Stack Split", max_value = max)
	if(!stackmaterial || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK, !iscyborg(user)))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	split_stack(user, stackmaterial)
	to_chat(user, span_notice("You take [stackmaterial] sheets out of the stack."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/** Splits the stack into two stacks.
  *
  * Arguments:
  * - [user][/mob]: The mob splitting the stack.
  * - amount: The number of units to split from this stack.
  */
/obj/item/stack/proc/split_stack(mob/user, amount)
	if(!use(amount, TRUE, FALSE))
		return null
	var/obj/item/stack/F = new type(user ? user : drop_location(), amount, FALSE)
	. = F
	F.set_mats_per_unit(mats_per_unit, 1) // Required for greyscale sheets and tiles.
	F.copy_evidences(src)
	loc.atom_storage?.refresh_views()
	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)

	is_zero_amount(delete_if_zero = TRUE)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(can_merge(W))
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, span_notice("Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s."))
	else
		return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	add_blood_DNA(from.return_blood_DNA())
	add_fingerprint_list(from.return_fingerprints())
	add_hiddenprint_list(from.return_hiddenprints())
	fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty += amount

/*
 * Recipe datum
 */
/datum/stack_recipe
	///The name of the recipe
	var/title = "ERROR"
	///The thing we get from doing the recipe
	var/result_type
	///The amount of type of material we need
	var/req_amount = 1
	///The amount of thing we make
	var/res_amount = 1
	///The maximum amount of thing we can get from crafting
	var/max_res_amount = 1
	///The time it takes to make
	var/time = 0
	///Can we have only one instance of recipe result per turf?
	var/one_per_turf = FALSE
	///Can we make the result on non-solid turfs (space)
	var/on_floor = FALSE
	///Do we do placement checks while placing the recipe?
	var/placement_checks = FALSE
	var/applies_mats = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1,time = 0, one_per_turf = FALSE, on_floor = FALSE, window_checks = FALSE, placement_checks = FALSE, applies_mats = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.placement_checks = placement_checks
	src.applies_mats = applies_mats

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes

#undef STACK_CHECK_CARDINALS
#undef STACK_CHECK_ADJACENT
