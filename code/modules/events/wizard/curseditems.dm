/datum/round_event_control/wizard/cursed_items //fashion disasters
	name = "Cursed Items"
	weight = 3
	typepath = /datum/round_event/wizard/cursed_items
	max_occurrences = 3
	earliest_start = 0 MINUTES

//Note about adding items to this: Because of how NODROP_1 works if an item spawned to the hands can also be equiped to a slot
//it will be able to be put into that slot from the hand, but then get stuck there. To avoid this make a new subtype of any
//item you want to equip to the hand, and set its slots_flags = null. Only items equiped to hands need do this.

/datum/round_event/wizard/cursed_items/start()
	var/item_set = pick("wizardmimic", "swords", "bigfatdoobie", "boxing", "voicemodulators", "catgirls2015")
	var/list/loadout[SLOTS_AMT]
	var/ruins_spaceworthiness
	var/ruins_wizard_loadout

	switch(item_set)
		if("wizardmimic")
			loadout[TOBITSHIFT(ITEM_SLOT_OCLOTHING) + 1] = /obj/item/clothing/suit/wizrobe
			loadout[TOBITSHIFT(ITEM_SLOT_FEET) + 1] = /obj/item/clothing/shoes/sandal/magic
			loadout[TOBITSHIFT(ITEM_SLOT_HEAD) + 1] = /obj/item/clothing/head/wizard
			ruins_spaceworthiness = 1
		if("swords")
			loadout[TOBITSHIFT(ITEM_SLOT_HANDS) + 1] = /obj/item/katana/cursed
		if("bigfatdoobie")
			loadout[TOBITSHIFT(ITEM_SLOT_MASK) + 1] = /obj/item/clothing/mask/cigarette/rollie/trippy
			ruins_spaceworthiness = 1
		if("boxing")
			loadout[TOBITSHIFT(ITEM_SLOT_MASK) + 1] = /obj/item/clothing/mask/luchador
			loadout[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1] = /obj/item/clothing/gloves/boxing
			ruins_spaceworthiness = 1
		if("voicemodulators")
			loadout[TOBITSHIFT(ITEM_SLOT_MASK) + 1] = /obj/item/clothing/mask/chameleon
		if("catgirls2015")
			loadout[TOBITSHIFT(ITEM_SLOT_HEAD) + 1] = /obj/item/clothing/head/costume/kitty
			ruins_spaceworthiness = 1
			ruins_wizard_loadout = 1

	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(ruins_spaceworthiness && !is_station_level(H.z) || isspaceturf(H.loc) || isplasmaman(H))
			continue	//#savetheminers
		if(ruins_wizard_loadout && IS_WIZARD(H))
			continue
		if(item_set == "catgirls2015") //Wizard code means never having to say you're sorry
			H.gender = FEMALE
		for(var/i in 1 to loadout.len)
			if(loadout[i])
				var/obj/item/J = loadout[i]
				var/obj/item/I = new J //dumb but required because of byond throwing a fit anytime new gets too close to a list
				H.dropItemToGround(H.get_item_by_slot(i), TRUE)
				H.equip_to_slot_or_del(I, i)
				ADD_TRAIT(I, TRAIT_NODROP, CURSED_ITEM_TRAIT)
				I.item_flags |= DROPDEL
				I.name = "cursed " + I.name

	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(0, H.loc)
		smoke.start()
