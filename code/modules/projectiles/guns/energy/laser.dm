/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A basic energy-based laser gun that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron=2000)
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = TRUE

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	item_flags = NONE
	dying_key = DYE_REGISTRY_GUN

/obj/item/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3

/obj/item/gun/energy/laser/retro/old
	name ="laser gun"
	icon_state = "retro"
	desc = "First generation lasergun, developed by Nanotrasen. Suffers from ammo issues but its unique ability to recharge its ammo without the need of a magazine helps compensate. You really hope someone has developed a better lasergun while you were in cryo."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)
	ammo_x_offset = 3

/obj/item/gun/energy/laser/repeater
	name = "NT LRR Model 2284"
	icon_state = "repeater"
	item_state = null
	desc = "An experimental laser repeater rifle that uses a built-in bluespace dynamo to recharge its battery, crank it and fire!"
	gun_charge = 200
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/repeater)
	can_charge = FALSE //don't put this in a recharger
	var/cranking = FALSE
	var/fire_interrupted = FALSE

/obj/item/gun/energy/laser/repeater/proc/crank_charge(mob/living/user)
	if(cell.charge >= gun_charge)
		to_chat(user,"<span class='danger'>The gun is at maximum charge already!</span>")
		return
	else if(!cranking)
		balloon_alert(user, "You start cranking")
		while(cell.charge < gun_charge)
			cranking = TRUE
			if(do_after(user, 1 SECONDS) && !fire_interrupted)
				playsound(src, 'sound/weapons/autoguninsert.ogg', 30)
				cell.give(50)
				flick("repeater", src)
				update_icon()
			else
				break
	cranking = FALSE
	fire_interrupted = FALSE

/obj/item/gun/energy/laser/repeater/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	if(cranking)
		fire_interrupted = TRUE //no more cranking when you shoot.
	return ..()

/obj/item/gun/energy/laser/repeater/attack_self(mob/living/user)
	if(!cranking)
		crank_charge(user)

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	w_class = WEIGHT_CLASS_LARGE
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13 with the words NTSSGolden engraved. The station is exploding."
	force = 10
	ammo_x_offset = 3
	selfcharge = 1
	charge_delay = 8
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/captain)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	weapon_weight = WEAPON_LIGHT
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/gun/energy/laser/captain/contents_explosion(severity, target)
	if (!ammo_type || !cell)
		name = "\improper broken antique laser gun"
		desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It was decorated with leather and chrome. Seems too be damaged to the point of not functioning, but still valuable."
		icon_state = "caplaser_broken"
		update_icon()

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lens to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theoretically infinite use."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	shaded_charge = FALSE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

/obj/item/gun/energy/laser/captain/scattershot/contents_explosion(severity, target)
	return

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	use_cyborg_cell = TRUE

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/scatter/shotty
	name = "energy shotgun"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "cshotgun"
	item_state = "shotgun"
	desc = "A combat shotgun gutted and refitted with an internal laser system. Can switch between taser and scattered disabler shots."
	shaded_charge = FALSE
	pin = /obj/item/firing_pin/implant/mindshield
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler, /obj/item/ammo_casing/energy/electrode)
	automatic_charge_overlays = FALSE

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = "laser"
	worn_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	pin = null
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "scatterlaser"
	range = 255
	damage = 6

/obj/projectile/beam/laser/accelerator/Range()
	..()
	damage += 7
	transform *= 1 + ((damage/7) * 0.2)//20% larger per tile

/obj/item/gun/energy/xray
	name = "\improper X-ray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated X-ray blasts that pass through multiple soft targets and heavier materials."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	pin = null
	ammo_x_offset = 3
	w_class = WEIGHT_CLASS_BULKY

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "A retro laser gun modified to fire harmless blue beams of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/blue
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/bluetag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag/hitscan)

/obj/item/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "A retro laser gun modified to fire harmless beams red of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/red
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/redtag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag/hitscan)
