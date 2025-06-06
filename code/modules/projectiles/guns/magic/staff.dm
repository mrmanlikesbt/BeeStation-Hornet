/obj/item/gun/magic/staff
	slot_flags = ITEM_SLOT_BACK
	worn_icon_state = null
	icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	item_flags = NEEDS_PERMIT | NO_MAT_REDEMPTION
	weapon_weight = WEAPON_MEDIUM
	fire_rate = 1.5
	block_power = 20 //staffs can block shit if you're walking
	block_upgrade_walk = TRUE

/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"
	//school = SCHOOL_TRANSMUTATION
	/// If set, all wabbajacks this staff produces will be of this type, instead of random
	var/preset_wabbajack_type
	/// If set, all wabbajacks this staff produces will be of this changeflag, instead of only WABBAJACK
	var/preset_wabbajack_changeflag

/obj/item/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	fire_sound = 'sound/magic/staff_animation.ogg'
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"

/obj/item/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

/obj/item/gun/magic/staff/healing/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	fire_sound = 'sound/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	/// Static list of all projectiles we can fire from our staff.
	/// Doesn't contain all subtypes of magic projectiles, unlike what it looks like
	var/static/list/allowed_projectile_types = list(
		/obj/projectile/magic/animate,
		/obj/projectile/magic/antimagic,
		/obj/projectile/magic/arcane_barrage,
		/obj/projectile/magic/bounty,
		/obj/projectile/magic/change,
		/obj/projectile/magic/death,
		/obj/projectile/magic/door,
		/obj/projectile/magic/fetch,
		/obj/projectile/magic/fireball,
		/obj/projectile/magic/flying,
		/obj/projectile/magic/locker,
		/obj/projectile/magic/necropotence,
		/obj/projectile/magic/resurrection,
		/obj/projectile/magic/sapping,
		/obj/projectile/magic/spellblade,
		/obj/projectile/magic/teleport,
		/obj/projectile/magic/wipe,
		/obj/projectile/temp/chill,
	)

/obj/item/gun/magic/staff/chaos/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	chambered.projectile_type = pick(allowed_projectile_types)
	return ..()

/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	fire_sound = 'sound/magic/staff_door.ogg'
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1

/obj/item/gun/magic/staff/honk
	name = "staff of the honkmother"
	desc = "Honk."
	fire_sound = 'sound/items/airhorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/honk
	icon_state = "honker"
	item_state = "honker"
	max_charges = 4
	recharge_rate = 8

/obj/item/gun/magic/staff/spellblade
	name = "spellblade"
	desc = "A deadly combination of laziness and boodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 20
	armour_penetration = 75
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_DEEP_WOUND
	max_charges = 4

/obj/item/gun/magic/staff/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 15, 125, 0, hitsound)

/obj/item/gun/magic/staff/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/obj/item/gun/magic/staff/locker
	name = "staff of the locker"
	desc = "An artefact that expells encapsulating bolts, for incapacitating thy enemy."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/locker
	icon_state = "locker"
	item_state = "locker"
	worn_icon_state = "lockerstaff"
	max_charges = 6
	recharge_rate = 4

//yes, they don't have sounds. they're admin staves, and their projectiles will play the chaos bolt sound anyway so why bother?

/obj/item/gun/magic/staff/flying
	name = "staff of flying"
	desc = "An artefact that spits bolts of graceful magic that can make something fly."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/flying
	icon_state = "staffofflight"
	item_state = "staffofflight"
	worn_icon_state = "flightstaff"

/obj/item/gun/magic/staff/sapping
	name = "staff of sapping"
	desc = "An artefact that spits bolts of sapping magic that can make something sad."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/sapping
	icon_state = "staffofsapping"
	item_state = "staffofsapping"
	worn_icon_state = "staff"

/obj/item/gun/magic/staff/necropotence
	name = "staff of necropotence"
	desc = "An artefact that spits bolts of death magic that can repurpose the soul."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/necropotence
	icon_state = "staffofnecropotence"
	item_state = "staffofnecropotence"
	worn_icon_state = "necrostaff"

/obj/item/gun/magic/staff/wipe
	name = "staff of possession"
	desc = "An artefact that spits bolts of mind-unlocking magic that can let ghosts invade the victim's mind."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/wipe
	icon_state = "staffofwipe"
	item_state = "staffofwipe"
	worn_icon_state = "wipestaff"
