GLOBAL_LIST_EMPTY(conveyors_by_id)
#define MAX_CONVEYOR_ITEMS_MOVE 30

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_map"
	base_icon_state = "conveyor"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = GAS_PUMP_LAYER
	processing_flags = NONE
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/id = ""			// the control ID	- must match controller ID
	var/verted = 1		// Inverts the direction the conveyor belt moves.
	var/conveying = FALSE
	//Direction -> if we have a conveyor belt in that direction
	var/list/neighbors

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"


/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner pieces.
	icon_state = "conveyor_map_inverted"
	verted = -1

/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !(dir in GLOB.diagonals))
		log_mapping("[src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")

// Auto conveyour is always on unless unpowered

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/conveyor/auto)

/obj/machinery/conveyor/auto/Initialize(mapload, newdir)
	. = ..()
	set_operating(TRUE)
	update_move_direction()
	begin_processing()

/obj/machinery/conveyor/auto/update()
	. = ..()
	if(.)
		set_operating(TRUE)

// create a conveyor
CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/conveyor)

/obj/machinery/conveyor/Initialize(mapload, newdir, newid)
	. = ..()
	if(newdir)
		setDir(newdir)
	if(newid)
		id = newid
	neighbors = list()
	///Leaving onto conveyor detection won't work at this point, but that's alright since it's an optimization anyway
	///Should be fine without it
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(conveyable_exit),
		COMSIG_ATOM_ENTERED = PROC_REF(conveyable_enter),
		COMSIG_ATOM_CREATED = PROC_REF(conveyable_enter)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/conveyor/LateInitialize()
	. = ..()
	build_neighbors()

/obj/machinery/conveyor/Destroy()
	set_operating(FALSE)
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

/obj/machinery/conveyor/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!.)
		return
	//Now that we've moved, rebuild our neighbors list
	neighbors = list()
	build_neighbors()

/obj/machinery/conveyor/proc/build_neighbors()
	//This is acceptable because conveyor belts only move sometimes. Otherwise would be n^2 insanity
	var/turf/our_turf = get_turf(src)
	for(var/direction in GLOB.cardinals)
		var/turf/new_turf = get_step(our_turf, direction)
		var/obj/machinery/conveyor/valid = locate(/obj/machinery/conveyor) in new_turf
		if(QDELETED(valid))
			continue
		neighbors["[direction]"] = TRUE
		valid.neighbors["[turn(direction, 180)]"] = TRUE
		RegisterSignal(valid, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		RegisterSignal(valid, COMSIG_PARENT_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)

/obj/machinery/conveyor/proc/nearby_belt_changed(datum/source)
	SIGNAL_HANDLER
	neighbors = list()
	build_neighbors()

/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH

	if(verted == -1)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/update_icon_state()
	icon_state = "[base_icon_state][(machine_stat & BROKEN) ? "-broken" : (operating * verted)]"
	return ..()

/obj/machinery/conveyor/proc/set_operating(new_value)
	if(operating == new_value)
		return
	operating = new_value
	update_appearance()
	update_move_direction()
	//If we ever turn off, disable moveloops
	if(!operating)
		for(var/atom/movable/movable in get_turf(src))
			stop_conveying(movable)

/obj/machinery/conveyor/proc/update()
	. = TRUE
	if(machine_stat & NOPOWER)
		set_operating(FALSE)
		return FALSE

	if(!operating) //If we're on, start conveying so moveloops on our tile can be refreshed if they stopped for some reason
		return
	for(var/atom/movable/movable in get_turf(src))
		start_conveying(movable)

/obj/machinery/conveyor/proc/conveyable_enter(datum/source, atom/convayable)
	SIGNAL_HANDLER
	if(!operating)
		SSmove_manager.stop_looping(convayable, SSconveyors)
		return
	start_conveying(convayable)

/obj/machinery/conveyor/proc/conveyable_exit(datum/source, atom/convayable, direction)
	SIGNAL_HANDLER
	var/has_conveyor = neighbors["[direction]"]
	if(!has_conveyor || !isturf(convayable.loc)) //If you've entered something on us, stop moving
		SSmove_manager.stop_looping(convayable, SSconveyors)

/obj/machinery/conveyor/proc/start_conveying(atom/movable/moving)
	if(QDELETED(moving))
		return
	var/datum/move_loop/move/moving_loop = SSmove_manager.processing_on(moving, SSconveyors)
	if(moving_loop)
		moving_loop.direction = movedir
		moving_loop.delay = 0.2 SECONDS
		return

	var/static/list/unconveyables = typecacheof(list(/obj/effect, /mob/dead))
	if(!istype(moving) || is_type_in_typecache(moving, unconveyables) || moving == src)
		return
	moving.AddComponent(/datum/component/convey, movedir, 0.2 SECONDS)

/obj/machinery/conveyor/proc/stop_conveying(atom/movable/thing)
	if(!ismovable(thing))
		return
	SSmove_manager.stop_looping(thing, SSconveyors)

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		user.visible_message(span_notice("[user] struggles to pry up \the [src] with \the [I]."), \
		span_notice("You struggle to pry up \the [src] with \the [I]."))
		if(I.use_tool(src, user, 40, volume=40))
			set_operating(FALSE)
			if(!(machine_stat & BROKEN))
				var/obj/item/stack/conveyor/C = new /obj/item/stack/conveyor(loc, 1, TRUE, null, id)
				if(QDELETED(C))
					C = locate(/obj/item/stack/conveyor) in loc
				if(C)
					transfer_fingerprints_to(C)

			to_chat(user, span_notice("You remove the conveyor belt."))
			qdel(src)

	else if(I.tool_behaviour == TOOL_WRENCH)
		if(!(machine_stat & BROKEN))
			I.play_tool_sound(src)
			setDir(turn(dir,-45))
			update_move_direction()
			to_chat(user, span_notice("You rotate [src]."))

	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!(machine_stat & BROKEN))
			verted = verted * -1
			update_move_direction()
			to_chat(user, span_notice("You reverse [src]'s direction."))

	else if(!user.combat_mode)
		user.transferItemToLoc(I, drop_location())
	else
		return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/conveyor)

DEFINE_BUFFER_HANDLER(/obj/machinery/conveyor)
	var/obj/machinery/conveyor_switch/cswitch = buffer
	if(!cswitch || !istype(cswitch))
		return NONE

	// Set up the conveyor with our new ID
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	id = cswitch.id
	LAZYADD(GLOB.conveyors_by_id[id], src)
	to_chat(user, span_notice("You link [src] to [cswitch]."))
	return COMPONENT_BUFFER_RECEIVED

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	atom_break()
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	. = ..()
	update()

// the conveyor control switch
//
//

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	processing_flags = START_PROCESSING_MANUALLY

	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/oneway = FALSE			// if the switch only operates the conveyor belts in a single direction.
	var/invert_icon = FALSE		// If the level points the opposite direction when it's turned on.

	var/id = "" 				// must match conveyor IDs to control them

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/conveyor_switch)

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid
	update_icon()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/conveyor_switch,
	))

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	. = ..()

/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

// update the icon depending on the position

/obj/machinery/conveyor_switch/update_icon()
	if(position<0)
		if(invert_icon)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-rev"
	else if(position>0)
		if(invert_icon)
			icon_state = "switch-rev"
		else
			icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

/// Updates all conveyor belts that are linked to this switch, and tells them to start processing.
/obj/machinery/conveyor_switch/proc/update_linked_conveyors()
	for(var/obj/machinery/conveyor/C in GLOB.conveyors_by_id[id])
		C.set_operating(position)
		CHECK_TICK

/// Finds any switches with same `id` as this one, and set their position and icon to match us.
/obj/machinery/conveyor_switch/proc/update_linked_switches()
	for(var/obj/machinery/conveyor_switch/S in GLOB.conveyors_by_id[id])
		S.invert_icon = invert_icon
		S.position = position
		S.update_icon()
		CHECK_TICK

/// Updates the switch's `position` and `last_pos` variable. Useful so that the switch can properly cycle between the forwards, backwards and neutral positions.
/// If set direction == false, this behaves like the normal switch. If it is set to true
/// attempt to set the switch to the indicated direction.
/obj/machinery/conveyor_switch/proc/update_position(set_direction = FALSE, direction = 0)
	if(set_direction)
		last_pos = position
		position = 0 //Default to stopped.
		if(direction > 0)
			position = 1 //Positive values moves the switch to forward
		if(direction < 0)
			position = -1 //Negative values moves the switch to reverse.

		//Run sanity check on the switch for one way direction.
		if(oneway)
			if(SIGN(position) != SIGN(oneway)) //If our signs don't match...
				position = 0 // Set position to zero to stop the conveyor since we can't go that way.
	else
		if(position == 0)
			if(oneway)   //is it a oneway switch
				position = oneway
			else
				if(last_pos < 0)
					position = 1
					last_pos = 0
				else
					position = -1
					last_pos = 0
		else
			last_pos = position
			position = 0

/// Called when a user clicks on this switch with an open hand.
/obj/machinery/conveyor_switch/interact(mob/user)
	add_fingerprint(user)
	play_click_sound("switch")
	update_position()
	update_icon()
	update_linked_conveyors()
	update_linked_switches()


/obj/machinery/conveyor_switch/crowbar_act(mob/living/user, obj/item/I)
	var/obj/item/conveyor_switch_construct/C = new/obj/item/conveyor_switch_construct(src.loc)
	C.id = id
	transfer_fingerprints_to(C)
	to_chat(user, span_notice("You detach the conveyor switch."))
	qdel(src)
	return TRUE

REGISTER_BUFFER_HANDLER(/obj/machinery/conveyor_switch)

DEFINE_BUFFER_HANDLER(/obj/machinery/conveyor_switch)
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You store [src] in [buffer_parent]'s buffer."))
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/conveyor_switch/screwdriver_act(mob/living/user, obj/item/I)
	var/newdirtext = ""
	switch(oneway)
		if(-1)
			oneway = 0
			newdirtext = "two-way"
		if(0)
			oneway = 1
			newdirtext = "one-way"
		if(1)
			oneway = -1
			newdirtext = "reverse one-way"
	to_chat(user, span_notice("You set the conveyor switch to [newdirtext] mode."))
	return TRUE

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	oneway = TRUE

/obj/machinery/conveyor_switch/oneway/Initialize(mapload)
	. = ..()
	if((dir == NORTH) || (dir == WEST))
		invert_icon = TRUE

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	var/id = "" //inherited by the switch

/obj/item/conveyor_switch_construct/Initialize(mapload)
	. = ..()
	id = "[rand()]" //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/attack_self(mob/user)
	for(var/obj/item/stack/conveyor/C in view())
		C.id = id
	to_chat(user, span_notice("You have linked all nearby conveyor belt assemblies to this switch."))

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id == src.id)
			found = 1
			break
	if(!found)
		to_chat(user, "[icon2html(src, user)][span_notice("The conveyor switch did not detect any linked conveyor belts in range.")]")
		return
	var/obj/machinery/conveyor_switch/NC = new/obj/machinery/conveyor_switch(A, id)
	transfer_fingerprints_to(NC)
	qdel(src)

/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	merge_type = /obj/item/stack/conveyor
	///id for linking
	var/id = ""


CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/conveyor)

/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, mob/user = null, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/cdir = get_dir(A, user)
	if(A == user.loc)
		to_chat(user, span_warning("You cannot place a conveyor belt under yourself!"))
		return
	var/obj/machinery/conveyor/C = new/obj/machinery/conveyor(A, cdir, id)
	transfer_fingerprints_to(C)
	use(1)

/obj/item/stack/conveyor/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/conveyor_switch_construct))
		to_chat(user, span_notice("You link the switch to the conveyor belt assembly."))
		var/obj/item/conveyor_switch_construct/C = I
		id = C.id

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/thirty
	amount = 30

/obj/item/paper/guides/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	default_raw_text = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined assembly procedure that puts all other mail-order products to shame!</p><p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"

/obj/item/circuit_component/conveyor_switch
	display_name = "Conveyor Switch"
	desc = "Allows to control connected conveyor belts."

	//This input works the same way as clicking on a switch.
	var/datum/port/input/toggle_trigger
	//Direction of the belt to set.
	var/datum/port/input/set_direction
	//This input sets the direction of the belt
	var/datum/port/input/set_direction_trigger

	var/datum/port/output/direction
	var/datum/port/output/triggered

	var/obj/machinery/conveyor_switch/attached_switch


/obj/item/circuit_component/conveyor_switch/populate_ports()
	toggle_trigger = add_input_port("Toggle Switch", PORT_TYPE_SIGNAL)
	set_direction = add_input_port("Conveyor Direction", PORT_TYPE_NUMBER)
	set_direction_trigger = add_input_port("Set Direction", PORT_TYPE_SIGNAL)

	direction = add_output_port("Conveyor Direction", PORT_TYPE_NUMBER)
	triggered = add_output_port("Triggered", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/conveyor_switch/get_ui_notices()
	. = ..()
	. += create_ui_notice("Conveyor direction 0 means that it is stopped, 1 means that it is active and -1 means that it is working in reverse mode", "orange", "info")

/obj/item/circuit_component/conveyor_switch/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/conveyor_switch))
		attached_switch = parent

/obj/item/circuit_component/conveyor_switch/unregister_usb_parent(atom/movable/parent)
	attached_switch = null
	return ..()

/obj/item/circuit_component/conveyor_switch/input_received(datum/port/input/port)
	if(!attached_switch)
		return

	if(COMPONENT_TRIGGERED_BY(port, toggle_trigger))
		INVOKE_ASYNC(src, PROC_REF(update_conveyors))
		return

	if(COMPONENT_TRIGGERED_BY(port, set_direction_trigger))
		INVOKE_ASYNC(src, PROC_REF(update_conveyors), TRUE, set_direction.value)
		return

/// If set direction == false, this behaves like the normal switch. If it is set to true
/// attempt to set the switch to the indicated direction.
/obj/item/circuit_component/conveyor_switch/proc/update_conveyors(set_direction = FALSE, direction_in = 0)
	if(!attached_switch)
		return
	attached_switch.update_position(set_direction, direction_in)
	attached_switch.update_icon()
	attached_switch.update_icon_state()
	attached_switch.update_linked_conveyors()
	attached_switch.update_linked_switches()
	direction.set_output(attached_switch.position)
	triggered.set_output(COMPONENT_SIGNAL)

#undef MAX_CONVEYOR_ITEMS_MOVE
