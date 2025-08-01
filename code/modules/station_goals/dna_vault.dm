//Crew has to create dna vault
// Cargo can order DNA samplers + DNA vault boards
// DNA vault requires x animals ,y plants, z human dna
// DNA vaults require high tier stock parts and cold
// After completion each crewmember can receive single upgrade chosen out of 2 for the mob.
#define VAULT_TOXIN "Toxin Adaptation"
#define VAULT_NOBREATH "Lung Enhancement"
#define VAULT_FIREPROOF "Thermal Regulation"
#define VAULT_STUNTIME "Neural Repathing"
#define VAULT_ARMOUR "Bone Reinforcement"
#define VAULT_SPEED "Leg Muscle Stimulus"
#define VAULT_QUICK "Arm Muscle Stimulus"

/datum/station_goal/dna_vault
	name = "DNA Vault"
	var/animal_count
	var/human_count
	var/plant_count

/datum/station_goal/dna_vault/New()
	..()
	animal_count = rand(15,20) //might be too few given ~15 roundstart stationside ones
	human_count = rand(round(0.75 * SSticker.totalPlayersReady) , SSticker.totalPlayersReady) // 75%+ roundstart population.
	var/non_standard_plants = non_standard_plants_count()
	plant_count = rand(round(0.5 * non_standard_plants),round(0.7 * non_standard_plants))

/datum/station_goal/dna_vault/proc/non_standard_plants_count()
	. = 0
	for(var/T in subtypesof(/obj/item/seeds)) //put a cache if it's used anywhere else
		var/obj/item/seeds/S = T
		if(initial(S.rarity) > 0)
			.++

/datum/station_goal/dna_vault/get_report()
	return list(
		"<blockquote>Our long term prediction systems indicate a 99% chance of system-wide cataclysm in the near future.",
		"We need you to construct a DNA Vault aboard your station.",
		"",
		"The DNA Vault needs to contain samples of:",
		"* [animal_count] unique animal data",
		"* [plant_count] unique non-standard plant data",
		"* [human_count] unique sapient humanoid DNA data",
		"",
		"Base vault parts are available for shipping via cargo.</blockquote>",
	).Join("\n")


/datum/station_goal/dna_vault/on_report()
	var/datum/supply_pack/P = SSsupply.supply_packs[/datum/supply_pack/engineering/dna_vault]
	P.special_enabled = TRUE

	P = SSsupply.supply_packs[/datum/supply_pack/engineering/dna_probes]
	P.special_enabled = TRUE

/datum/station_goal/dna_vault/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/dna_vault/V in GLOB.machines)
		if(V.animals.len >= animal_count && V.plants.len >= plant_count && V.dna.len >= human_count)
			return TRUE
	return FALSE


/obj/item/dna_probe
	name = "DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of pretty much anything."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "hypo"
	item_flags = NOBLUDGEON
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()
	///weak ref to the dna vault
	var/datum/weakref/dna_vault_ref

/obj/item/dna_probe/proc/clear_data()
	animals = list()
	plants = list()
	dna = list()

/obj/item/dna_probe/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !target)
		return

	//tray plants
	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/H = target
		if(!H.myseed)
			return
		if(!H.harvest)// So it's bit harder.
			to_chat(user, span_warning("Plant needs to be ready to harvest to perform full data scan.")) //Because space dna is actually magic
			return
		if(plants[H.myseed.type])
			to_chat(user, span_notice("Plant data already present in local storage."))
			return
		plants[H.myseed.type] = 1
		to_chat(user, span_notice("Plant data added to local storage."))

	//animals
	var/obj/machinery/dna_vault/our_vault = dna_vault_ref?.resolve()
	var/static/list/non_simple_animals = typecacheof(list(/mob/living/carbon/alien))
	if(isanimal_or_basicmob(target) || is_type_in_typecache(target, non_simple_animals) || ismonkey(target))
		var/mob/living/living_target = target
		if(our_vault.animals[living_target.type])
			to_chat(user, span_notice("Animal data already present in vault storage."))
			return
		if(animals[living_target.type])
			to_chat(user, span_notice("Animal data already present in local storage."))
			return
		if(!(MOB_ORGANIC in living_target.mob_biotypes))
			to_chat(user, span_alert("No compatible DNA detected."))
			return .
		animals[living_target.type] = 1
		balloon_alert(user, "data added")

	//humans
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(dna[H.dna.unique_identity])
			to_chat(user, span_notice("Humanoid data already present in local storage."))
			return
		dna[H.dna.unique_identity] = 1
		to_chat(user, span_notice("Humanoid data added to local storage."))

/obj/machinery/dna_vault
	name = "DNA Vault"
	desc = "Break glass in case of apocalypse."
	icon = 'icons/obj/machines/dna_vault.dmi'
	icon_state = "vault"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5000
	pixel_x = -32
	pixel_y = -64
	light_range = 3
	light_power = 1.5
	light_color = LIGHT_COLOR_CYAN




	//High defaults so it's not completed automatically if there's no station goal
	var/animals_max = 100
	var/plants_max = 100
	var/dna_max = 100
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()

	var/completed = FALSE
	var/list/power_lottery = list()

	var/list/obj/structure/fillers = list()

/obj/machinery/dna_vault/Initialize(mapload)
	//TODO: Replace this,bsa and gravgen with some big machinery datum
	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,SOUTHEAST,SOUTHWEST))
		occupied += get_step(src,direct)
	occupied += locate(x+1,y-2,z)
	occupied += locate(x-1,y-2,z)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

	var/datum/station_goal/dna_vault/dna_vault_goal = SSstation.get_station_goal(/datum/station_goal/dna_vault)
	if(dna_vault_goal)
		animals_max = dna_vault_goal.animal_count
		plants_max = dna_vault_goal.plant_count
		dna_max = dna_vault_goal.human_count
	. = ..()

/obj/machinery/dna_vault/Destroy()
	for(var/V in fillers)
		var/obj/structure/filler/filler = V
		filler.parent = null
		qdel(filler)
	. = ..()



/obj/machinery/dna_vault/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/dna_vault/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		roll_powers(user)
		ui = new(user, src, "DnaVault")
		ui.open()


/obj/machinery/dna_vault/proc/roll_powers(mob/user)
	if(user in power_lottery)
		return
	var/list/L = list()
	var/list/possible_powers = list(VAULT_TOXIN,VAULT_NOBREATH,VAULT_FIREPROOF,VAULT_STUNTIME,VAULT_ARMOUR,VAULT_SPEED,VAULT_QUICK)
	L += pick_n_take(possible_powers)
	L += pick_n_take(possible_powers)
	power_lottery[user] = L

/obj/machinery/dna_vault/ui_data(mob/user) //TODO Make it % bars maybe
	var/list/data = list()
	data["plants"] = plants.len
	data["plants_max"] = plants_max
	data["animals"] = animals.len
	data["animals_max"] = animals_max
	data["dna"] = dna.len
	data["dna_max"] = dna_max
	data["completed"] = completed
	data["used"] = TRUE
	data["choiceA"] = ""
	data["choiceB"] = ""
	if(user && completed)
		var/list/L = power_lottery[user]
		if(L?.len)
			data["used"] = FALSE
			data["choiceA"] = L[1]
			data["choiceB"] = L[2]
	return data

/obj/machinery/dna_vault/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("gene")
			. = upgrade(usr,params["choice"])

/obj/machinery/dna_vault/proc/check_goal()
	if(plants.len >= plants_max && animals.len >= animals_max && dna.len >= dna_max)
		completed = TRUE
	ui_update()

/obj/machinery/dna_vault/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/dna_probe))
		var/obj/item/dna_probe/P = I
		var/uploaded = 0
		for(var/plant in P.plants)
			if(!plants[plant])
				uploaded++
				plants[plant] = 1
		for(var/animal in P.animals)
			if(!animals[animal])
				uploaded++
				animals[animal] = 1
		for(var/ui in P.dna)
			if(!dna[ui])
				uploaded++
				dna[ui] = 1
		check_goal()
		to_chat(user, span_notice("[uploaded] new datapoints uploaded."))
	else
		return ..()

/obj/machinery/dna_vault/proc/upgrade(mob/living/carbon/human/H,upgrade_type)
	if(!(upgrade_type in power_lottery[H]))
		return
	. = TRUE
	var/datum/species/S = H.dna.species
	switch(upgrade_type)
		if(VAULT_TOXIN)
			to_chat(H, span_notice("You feel resistant to airborne toxins."))
			if(locate(/obj/item/organ/lungs) in H.internal_organs)
				var/obj/item/organ/lungs/L = H.internal_organs_slot[ORGAN_SLOT_LUNGS]
				L.gas_max -= /datum/gas/plasma
			ADD_TRAIT(H, TRAIT_VIRUSIMMUNE, "dna_vault")
		if(VAULT_NOBREATH)
			to_chat(H, span_notice("Your lungs feel great."))
			ADD_TRAIT(H, TRAIT_NOBREATH, "dna_vault")
		if(VAULT_FIREPROOF)
			to_chat(H, span_notice("You feel fireproof."))
			S.burnmod = 0.5
			ADD_TRAIT(H, TRAIT_RESISTHEAT, "dna_vault")
			ADD_TRAIT(H, TRAIT_NOFIRE, "dna_vault")
		if(VAULT_STUNTIME)
			to_chat(H, span_notice("Nothing can keep you down for long."))
			S.stunmod = 0.5
		if(VAULT_ARMOUR)
			to_chat(H, span_notice("You feel tough."))
			S.armor = 30
			ADD_TRAIT(H, TRAIT_PIERCEIMMUNE, "dna_vault")
		if(VAULT_SPEED)
			to_chat(H, span_notice("Your legs feel faster."))
			H.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
		if(VAULT_QUICK)
			to_chat(H, span_notice("Your arms move as fast as lightning."))
			H.next_move_modifier = 0.5
	power_lottery[H] = list()

#undef VAULT_TOXIN
#undef VAULT_NOBREATH
#undef VAULT_FIREPROOF
#undef VAULT_STUNTIME
#undef VAULT_ARMOUR
#undef VAULT_SPEED
#undef VAULT_QUICK
