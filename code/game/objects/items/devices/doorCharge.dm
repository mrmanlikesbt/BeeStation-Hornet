/obj/item/doorCharge
	name = "airlock charge"
	desc = null //Different examine for traitors
	icon = 'icons/obj/device.dmi'
	item_state = "electronic"
	icon_state = "doorCharge"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	throw_range = 4
	throw_speed = 1
	item_flags = NOBLUDGEON
	force = 3
	attack_verb_continuous = list("explodes", "detonates")
	attack_verb_simple = list("explode", "detonate")
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=30)

/obj/item/doorCharge/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			visible_message(span_warning("[src] detonates!"))
			explosion(src.loc,0,2,1,flame_range = 4)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				ex_act(EXPLODE_DEVASTATE)
		if(EXPLODE_LIGHT)
			if(prob(25))
				ex_act(EXPLODE_DEVASTATE)

/obj/item/doorCharge/Destroy()
	if(istype(loc, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = loc
		if(A.charge == src)
			A.charge = null
	return ..()

/obj/item/doorCharge/examine(mob/user)
	. = ..()
	if(IS_TRAITOR(user) || IS_NUCLEAR_OPERATIVE(user))
		. += "A small explosive device that can be used to sabotage airlocks to cause an explosion upon opening. To apply, remove the airlock's maintenance panel and place it within."
	else
		. += "A small, suspicious object that feels lukewarm when held."
