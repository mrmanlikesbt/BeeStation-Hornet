SUBSYSTEM_DEF(traumas)
	name = "Traumas"
	flags = SS_NO_FIRE
	var/list/phobia_types
	var/list/phobia_words
	var/list/phobia_mobs
	var/list/phobia_objs
	var/list/phobia_turfs
	var/list/phobia_species

/datum/controller/subsystem/traumas/Initialize()
	//phobia types is to pull from randomly for brain traumas, e.g. conspiracies is for special assignment only
	//defined in __DEFINES/mobs.dm
	//5 is the default weight, lower it for more punishing phobias
	phobia_types = sort_list(GLOB.available_random_trauma_list)

	phobia_words = list(
		"spiders"   = strings(PHOBIA_FILE, "spiders"),
		"space"     = strings(PHOBIA_FILE, "space"),
		"security"  = strings(PHOBIA_FILE, "security"),
		"clowns"    = strings(PHOBIA_FILE, "clowns"),
		"greytide"  = strings(PHOBIA_FILE, "greytide"),
		"lizards"   = strings(PHOBIA_FILE, "lizards"),
		"skeletons" = strings(PHOBIA_FILE, "skeletons"),
		"snakes"	= strings(PHOBIA_FILE, "snakes"),
		"robots"	= strings(PHOBIA_FILE, "robots"),
		"doctors"	= strings(PHOBIA_FILE, "doctors"),
		"authority"	= strings(PHOBIA_FILE, "authority"),
		"the supernatural"	= strings(PHOBIA_FILE, "the supernatural"),
		"aliens"	= strings(PHOBIA_FILE, "aliens"),
		"strangers"	= strings(PHOBIA_FILE, "strangers"),
		"conspiracies" = strings(PHOBIA_FILE, "conspiracies"),
		"birds" = strings(PHOBIA_FILE, "birds"),
		"falling" = strings(PHOBIA_FILE, "falling"),
		"anime" = strings(PHOBIA_FILE, "anime")
	)

	phobia_mobs = list(
		"spiders"  = typecacheof(list(
			/mob/living/simple_animal/hostile/poison/giant_spider
			)),
		"security" = typecacheof(list(
			/mob/living/simple_animal/bot/secbot,
			/mob/living/simple_animal/bot/ed209
			)),
		"lizards"  = typecacheof(list(
			/mob/living/simple_animal/hostile/lizard
			)),
		"skeletons" = typecacheof(list(
			/mob/living/simple_animal/hostile/skeleton
			)),
		"snakes"   = typecacheof(list(
			/mob/living/simple_animal/hostile/retaliate/poison/snake
			)),
		"robots"   = typecacheof(list(
			/mob/living/silicon/robot,
			/mob/living/silicon/ai,
			/mob/living/simple_animal/drone,
			/mob/living/simple_animal/bot,
			/mob/living/simple_animal/hostile/swarmer
			)),
		"doctors"   = typecacheof(list(
			/mob/living/simple_animal/bot/medbot
			)),
		"the supernatural"   = typecacheof(list(
			/mob/living/simple_animal/hostile/construct,
			/mob/living/simple_animal/revenant,
			/mob/living/simple_animal/shade
		)),
		"aliens"   = typecacheof(list(
			/mob/living/carbon/alien,
			/mob/living/simple_animal/slime
			)),
		"conspiracies" = typecacheof(list(
			/mob/living/simple_animal/bot/secbot,
			/mob/living/simple_animal/bot/ed209,
			/mob/living/simple_animal/drone,
			/mob/living/simple_animal/pet/penguin
			)),
		"birds" = typecacheof(list(
			/mob/living/simple_animal/parrot,
			/mob/living/simple_animal/chick,
			/mob/living/simple_animal/chicken,
			/mob/living/simple_animal/pet/penguin)),
		"anime" = typecacheof(list(
			/mob/living/simple_animal/hostile/holoparasite
		))
	)

	phobia_objs = list(
		"snakes" = typecacheof(list(
			/obj/item/rod_of_asclepius
			)),

		"spiders"   = typecacheof(list(
			/obj/structure/spider
			)),

		"security"  = typecacheof(list(
			/obj/item/clothing/under/rank/security/officer,
			/obj/item/clothing/under/rank/security/warden,
			/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/security/detective,
			/obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs,
			/obj/item/melee/tonfa,
			/obj/machinery/door/airlock/security, /obj/effect/hallucination/simple/securitron)),

		"clowns"    = typecacheof(list(
			/obj/item/clothing/under/rank/civilian/clown, /obj/item/clothing/shoes/clown_shoes,
			/obj/item/clothing/mask/gas/clown_hat, /obj/item/instrument/bikehorn,
			/obj/item/modular_computer/tablet/pda/preset/clown, /obj/item/grown/bananapeel)),

		"greytide"  = typecacheof(list(
			/obj/item/clothing/under/color/grey, /obj/item/melee/baton/cattleprod,
			/obj/item/spear, /obj/item/clothing/mask/gas/old)),

		"lizards"   = typecacheof(list(
			/obj/item/toy/plush/lizard_plushie, /obj/item/food/kebab/tail,
			/obj/item/organ/tail/lizard, /obj/item/reagent_containers/cup/glass/bottle/lizardwine)),

		"skeletons" = typecacheof(list(
			/obj/item/organ/tongue/bone, /obj/item/clothing/suit/armor/bone, /obj/item/stack/sheet/bone,
			/obj/item/food/meat/slab/human/mutant/skeleton,
			/obj/effect/decal/remains/human)),

		"conspiracies" = typecacheof(list(
			/obj/item/clothing/under/rank/captain, /obj/item/clothing/under/rank/security/head_of_security,
			/obj/item/clothing/under/rank/engineering/chief_engineer, /obj/item/clothing/under/rank/medical/chief_medical_officer,
			/obj/item/clothing/under/rank/civilian/head_of_personnel, /obj/item/clothing/under/rank/rnd/research_director,
			/obj/item/clothing/under/rank/security/head_of_security/white, /obj/item/clothing/under/rank/security/head_of_security/alt,
			/obj/item/clothing/under/rank/rnd/research_director/alt, /obj/item/clothing/under/rank/rnd/research_director/turtleneck,
			/obj/item/clothing/under/rank/captain/parade, /obj/item/clothing/under/rank/security/head_of_security/parade, /obj/item/clothing/under/rank/security/head_of_security/parade/female,
			/obj/item/clothing/head/helmet/abductor, /obj/item/clothing/suit/armor/abductor/vest, /obj/item/melee/baton/abductor,
			/obj/item/storage/belt/military/abductor, /obj/item/gun/energy/alien, /obj/item/abductor/silencer,
			/obj/item/abductor/gizmo, /obj/item/clothing/under/rank/centcom/official,
			/obj/item/clothing/suit/space/hardsuit/ert, /obj/item/clothing/suit/space/hardsuit/ert/sec,
			/obj/item/clothing/suit/space/hardsuit/ert/engi, /obj/item/clothing/suit/space/hardsuit/ert/med,
			/obj/item/clothing/suit/space/hardsuit/deathsquad, /obj/item/clothing/head/helmet/space/hardsuit/deathsquad,
			/obj/machinery/door/airlock/centcom)),

		"robots"   = typecacheof(list(
			/obj/machinery/computer/upload, /obj/item/ai_module/, /obj/machinery/recharge_station,
			/obj/item/aicard, /obj/item/deactivated_swarmer, /obj/effect/mob_spawn/swarmer)),

		"doctors"   = typecacheof(list(
			/obj/item/clothing/under/rank/medical, /obj/item/clothing/under/rank/medical/chemist,
			/obj/item/clothing/under/rank/medical/doctor/nurse, /obj/item/clothing/under/rank/medical/chief_medical_officer,
			/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/pill/, /obj/item/reagent_containers/hypospray,
			/obj/item/storage/firstaid, /obj/item/storage/pill_bottle, /obj/item/healthanalyzer,
			/obj/structure/sign/departments/medbay, /obj/machinery/door/airlock/medical, /obj/machinery/sleeper, /obj/machinery/stasis,
			/obj/machinery/dna_scannernew, /obj/machinery/cryo_cell, /obj/item/surgical_drapes,
			/obj/item/retractor, /obj/item/hemostat, /obj/item/cautery, /obj/item/surgicaldrill, /obj/item/scalpel, /obj/item/circular_saw,
			/obj/item/clothing/suit/bio_suit/plaguedoctorsuit, /obj/item/clothing/head/costume/plague, /obj/item/clothing/mask/gas/plaguedoctor)),

		"authority"   = typecacheof(list(
			/obj/item/clothing/under/rank/captain,  /obj/item/clothing/under/rank/civilian/head_of_personnel,
			/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/rnd/research_director,
			/obj/item/clothing/under/rank/medical/chief_medical_officer, /obj/item/clothing/under/rank/engineering/chief_engineer,
			/obj/item/clothing/under/rank/centcom/official, /obj/item/clothing/under/rank/centcom/commander,
			/obj/item/melee/classic_baton/police/telescopic, /obj/item/card/id/silver, /obj/item/card/id/gold,
			/obj/item/card/id/captains_spare, /obj/item/card/id/centcom, /obj/machinery/door/airlock/command)),

		"the supernatural"  = typecacheof(list(
			/obj/structure/destructible/cult, /obj/item/tome,
			/obj/item/melee/cultblade, /obj/item/restraints/legcuffs/bola/cult,
			/obj/item/clothing/suit/hooded/cultrobes,
			/obj/item/clothing/suit/hooded/cultrobes, /obj/item/clothing/head/hooded/cult_hoodie, /obj/effect/rune,
			/obj/item/stack/sheet/runed_metal, /obj/machinery/door/airlock/cult, /obj/eldritch/narsie,
			/obj/item/soulstone, /obj/item/clockwork,
			/obj/item/stack/sheet/brass,
			/obj/machinery/door/airlock/clockwork,
			/obj/item/clothing/suit/wizrobe, /obj/item/clothing/head/wizard, /obj/item/spellbook, /obj/item/staff,
			/obj/item/clothing/suit/space/hardsuit/shielded/wizard, /obj/item/clothing/suit/space/hardsuit/wizard,
			/obj/item/gun/magic/staff, /obj/item/gun/magic/wand,
			/obj/item/nullrod, /obj/item/clothing/under/rank/civilian/chaplain)),

		"aliens" = typecacheof(list(
			/obj/item/clothing/mask/facehugger, /obj/item/organ/body_egg/alien_embryo,
			/obj/structure/alien, /obj/item/toy/toy_xeno,
			/obj/item/clothing/suit/armor/abductor, /obj/item/abductor, /obj/item/gun/energy/alien,
			/obj/item/melee/baton/abductor, /obj/item/radio/headset/abductor, /obj/item/scalpel/alien, /obj/item/hemostat/alien,
			/obj/item/retractor/alien, /obj/item/circular_saw/alien, /obj/item/surgicaldrill/alien, /obj/item/cautery/alien,
			/obj/item/clothing/head/helmet/abductor, /obj/structure/bed/abductor, /obj/structure/table_frame/abductor,
			/obj/structure/table/abductor, /obj/structure/table/optable/abductor, /obj/structure/closet/abductor, /obj/item/organ/heart/gland,
			/obj/machinery/abductor, /obj/item/crowbar/abductor, /obj/item/screwdriver/abductor, /obj/item/weldingtool/abductor,
			/obj/item/wirecutters/abductor, /obj/item/wrench/abductor, /obj/item/stack/sheet/mineral/abductor,
			/obj/item/toy/plush/slimeplushie)),

		"birds" = typecacheof(list(
			/obj/item/clothing/mask/gas/plaguedoctor,
			/obj/item/food/cracker,
			/obj/item/clothing/suit/costume/chickensuit,
			/obj/item/clothing/head/costume/chicken,
			/obj/item/clothing/suit/toggle/owlwings,
			/obj/item/clothing/under/costume/owl,
			/obj/item/clothing/mask/gas/owl_mask,
			/obj/item/clothing/under/costume/griffin,
			/obj/item/clothing/shoes/griffin,
			/obj/item/clothing/head/costume/griffin,
			/obj/item/clothing/head/helmet/space/freedom,
			/obj/item/clothing/suit/space/freedom
			)),

		"anime" = typecacheof(list(
			/obj/item/clothing/under/costume/schoolgirl,
			/obj/item/katana,
			/obj/item/food/sashimi,
			/obj/item/food/chawanmushi,
			/obj/item/reagent_containers/cup/glass/bottle/sake,
			/obj/item/throwing_star,
			/obj/item/clothing/head/costume/kitty/genuine,
			/obj/item/clothing/suit/space/space_ninja,
			/obj/item/clothing/mask/gas/space_ninja,
			/obj/item/clothing/shoes/space_ninja,
			/obj/item/clothing/gloves/space_ninja,
			/obj/item/vibro_weapon,
			/obj/item/nullrod/scythe/vibro,
			/obj/item/energy_katana,
			/obj/item/toy/katana,
			/obj/item/nullrod/claymore/katana,
			/obj/item/katana/weak/curator,
			/obj/structure/window/paperframe,
			/obj/structure/mineral_door/paperframe
			))
						)

	phobia_turfs = list("space" = typecacheof(list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)),
						"the supernatural" = typecacheof(list(/turf/open/floor/clockwork, /turf/closed/wall/clockwork,
						/turf/open/floor/cult, /turf/closed/wall/mineral/cult)),
						"aliens" = typecacheof(list(/turf/open/floor/plating/abductor, /turf/open/floor/plating/abductor2,
						/turf/open/floor/mineral/abductor, /turf/closed/wall/mineral/abductor)),
						"falling" = typecacheof(list(/turf/open/chasm, /turf/open/floor/fakepit))
						)

	phobia_species = list("lizards" = typecacheof(list(/datum/species/lizard)),
							"skeletons" = typecacheof(list(/datum/species/skeleton, /datum/species/plasmaman)),
							"conspiracies" = typecacheof(list(/datum/species/abductor, /datum/species/lizard)),
							"robots" = typecacheof(list(/datum/species/android)),
							"the supernatural" = typecacheof(list(/datum/species/golem/clockwork, /datum/species/golem/runic)),
							"aliens" = typecacheof(list(/datum/species/abductor, /datum/species/diona, /datum/species/shadow)),
							"anime" = typecacheof(list(/datum/species/human/felinid))
						)

	return SS_INIT_SUCCESS
