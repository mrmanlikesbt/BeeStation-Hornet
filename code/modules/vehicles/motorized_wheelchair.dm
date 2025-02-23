/obj/vehicle/ridden/wheelchair/motorized
	name = "motorized wheelchair"
	desc = "A chair with big wheels. It seems to have a motor in it."
	max_integrity = 150
	move_resist = MOVE_FORCE_DEFAULT
	var/speed = 2
	var/power_efficiency = 1
	var/power_usage = 25
	var/panel_open = FALSE
	var/list/required_parts = list(/obj/item/stock_parts/manipulator,
							/obj/item/stock_parts/manipulator,
							/obj/item/stock_parts/capacitor)
	var/obj/item/stock_parts/cell/power_cell
	var/low_power_alerted = FALSE

/obj/vehicle/ridden/wheelchair/motorized/CheckParts(list/parts_list)
	..()
	refresh_parts()

/obj/vehicle/ridden/wheelchair/motorized/proc/refresh_parts()
	speed = 1 // Should never be under 1
	for(var/obj/item/stock_parts/manipulator/M in contents)
		speed += M.rating
	for(var/obj/item/stock_parts/capacitor/C in contents)
		power_efficiency = C.rating
	var/datum/component/riding/D = GetComponent(/datum/component/riding)
	D.vehicle_move_delay = round(1.5 * delay_multiplier) / speed
	D.empable = TRUE


/obj/vehicle/ridden/wheelchair/motorized/get_cell()
	return power_cell

/obj/vehicle/ridden/wheelchair/motorized/atom_destruction(damage_flag)
	var/turf/T = get_turf(src)
	for(var/c in contents)
		var/atom/movable/thing = c
		thing.forceMove(T)
	return ..()

/obj/vehicle/ridden/wheelchair/motorized/driver_move(mob/living/user, direction)
	if(istype(user))
		if(!canmove)
			return FALSE
		if(!power_cell)
			to_chat(user, span_warning("There seems to be no cell installed in [src]."))
			canmove = FALSE
			addtimer(VARSET_CALLBACK(src, canmove, TRUE), 20)
			return FALSE
		if(power_cell.charge < power_usage / max(power_efficiency, 1))
			to_chat(user, span_warning("The display on [src] blinks 'Out of Power'."))
			canmove = FALSE
			addtimer(VARSET_CALLBACK(src, canmove, TRUE), 20)
			return FALSE
		if(user.usable_hands < arms_required)
			to_chat(user, span_warning("You don't have enough arms to operate the motor controller!"))
			canmove = FALSE
			addtimer(VARSET_CALLBACK(src, canmove, TRUE), 20)
			return FALSE
	return ..()

/obj/vehicle/ridden/wheelchair/motorized/Moved()
	. = ..()
	power_cell.use(power_usage / max(power_efficiency, 1))
	if(!low_power_alerted && power_cell.charge <= (power_cell.maxcharge / 4))
		playsound(src, 'sound/machines/twobeep.ogg', 30, 1)
		say("Warning: Power low!")
		low_power_alerted = TRUE

/obj/vehicle/ridden/wheelchair/motorized/set_move_delay(mob/living/user)
	return

/obj/vehicle/ridden/wheelchair/motorized/post_buckle_mob(mob/living/user)
	. = ..()
	set_density(TRUE)

/obj/vehicle/ridden/wheelchair/motorized/post_unbuckle_mob()
	. = ..()
	set_density(FALSE)

/obj/vehicle/ridden/wheelchair/motorized/attack_hand(mob/living/user)
	if(power_cell && panel_open)
		power_cell.update_icon()
		user.put_in_hands(power_cell)
		power_cell = null
		to_chat(user, span_notice("You remove the power cell from [src]."))
		low_power_alerted = FALSE
		return
	return ..()

/obj/vehicle/ridden/wheelchair/motorized/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src)
		panel_open = !panel_open
		user.visible_message(span_notice("[user] [panel_open ? "opens" : "closes"] the maintenance panel on [src]."), span_notice("You [panel_open ? "open" : "close"] the maintenance panel."))
		return
	if(panel_open)
		if(istype(I, /obj/item/stock_parts/cell))
			if(power_cell)
				to_chat(user, span_warning("There is a power cell already installed."))
			else
				I.forceMove(src)
				power_cell = I
				to_chat(user, span_notice("You install the [I]."))
			refresh_parts()
			return
		if(istype(I, /obj/item/stock_parts))
			var/obj/item/stock_parts/B = I
			var/P
			for(var/obj/item/stock_parts/A in contents)
				for(var/D in required_parts)
					if(ispath(A.type, D))
						P = D
						break
				if(istype(B, P) && istype(A, P))
					if(B.get_part_rating() > A.get_part_rating())
						B.forceMove(src)
						user.put_in_hands(A)
						user.visible_message(span_notice("[user] replaces [A] with [B] in [src]."), span_notice("You replace [A] with [B]."))
						break
			refresh_parts()
			return
	return ..()

/obj/vehicle/ridden/wheelchair/motorized/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You begin to detach the wheels..."))
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You detach the wheels and deconstruct the chair."))
		new /obj/item/stack/rods(drop_location(), 8)
		new /obj/item/stack/sheet/iron(drop_location(), 10)
		var/turf/T = get_turf(src)
		for(var/c in contents)
			var/atom/movable/thing = c
			thing.forceMove(T)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/wheelchair/motorized/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "There is a small screen on it, [(in_range(user, src) || isobserver(user)) ? "[power_cell ? "it reads:" : "but it is dark."]" : "but you can't see it from here."]"
	if(!power_cell || (!in_range(user, src) && !isobserver(user)))
		return
	. += "Speed: [speed]"
	. += "Energy efficiency: [power_efficiency]"
	. += "Power: [power_cell.charge] out of [power_cell.maxcharge]"

/obj/vehicle/ridden/wheelchair/motorized/Bump(atom/movable/M)
	. = ..()
	// If the speed is higher than delay_multiplier throw the person on the wheelchair away
	if(M.density && speed > delay_multiplier && has_buckled_mobs())
		var/mob/living/H = buckled_mobs[1]
		var/atom/throw_target = get_edge_target_turf(H, pick(GLOB.cardinals))
		unbuckle_mob(H)
		H.throw_at(throw_target, 2, 3)
		var/multiplier = 1
		if(HAS_TRAIT(H, TRAIT_PROSKATER))
			multiplier = 0.7 //30% reduction
		H.Knockdown(100 * multiplier)
		H.adjustStaminaLoss(40 * multiplier)
		if(isliving(M))
			var/mob/living/D = M
			throw_target = get_edge_target_turf(D, pick(GLOB.cardinals))
			D.throw_at(throw_target, 2, 3)
			D.Knockdown(80)
			D.adjustStaminaLoss(35)
			visible_message(span_danger("[src] crashes into [M], sending [H] and [D] flying!"))
		else
			visible_message(span_danger("[src] crashes into [M], sending [H] flying!"))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
