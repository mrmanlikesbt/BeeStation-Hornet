/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha = .
		mecha.chassis = src


/datum/action/vehicle/sealed/mecha
	icon_icon = 'icons/hud/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/on_activate(mob/user, atom/target)
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.container_resist(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_internals/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.balloon_alert(owner, "Now taking air from the [chassis.use_internal_tank ? "internal airtank" : "environment"].")
	chassis.log_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].", LOG_MECHA)
	update_buttons()

/datum/action/vehicle/sealed/mecha/mech_cycle_equip
	name = "Cycle Equipment"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/vehicle/sealed/mecha/mech_cycle_equip/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	var/list/available_equipment = list()
	for(var/e in chassis.equipment)
		var/obj/item/mecha_parts/mecha_equipment/equipment = e
		if(equipment.selectable)
			available_equipment += equipment

	if(available_equipment.len == 0)
		chassis.balloon_alert(owner, "No equipment available.")
		return
	if(!chassis.selected)
		chassis.selected = available_equipment[1]
		chassis.balloon_alert(owner, "[chassis.selected] selected.")
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		button_icon_state = "mech_cycle_equip_on"
		update_buttons()
		return
	var/number = 0
	for(var/equipment in available_equipment)
		number++
		if(equipment != chassis.selected)
			continue
		if(available_equipment.len == number)
			chassis.selected = null
			chassis.balloon_alert(owner, "Switched to no equipment.")
			button_icon_state = "mech_cycle_equip_off"
		else
			chassis.selected = available_equipment[number+1]
			chassis.balloon_alert(owner, "Switched to [chassis.selected].")
			button_icon_state = "mech_cycle_equip_on"
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		update_buttons()
		return


/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!(chassis.mecha_flags & HAS_LIGHTS))
		to_chat(owner, span_warning("This mechs lights are destroyed!"))
		return
	chassis.mecha_flags ^= LIGHTS_ON
	if(chassis.mecha_flags & LIGHTS_ON)
		button_icon_state = "mech_lights_on"
	else
		button_icon_state = "mech_lights_off"
	chassis.set_light_on(chassis.mecha_flags & LIGHTS_ON)
	chassis.balloon_alert(owner, "Toggled lights [(chassis.mecha_flags & LIGHTS_ON) ? "on" : "off"].")
	chassis.log_message("Toggled lights [(chassis.mecha_flags & LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	update_buttons()

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/mecha/mech_view_stats/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/datum/browser/popup = new(owner , "exosuit")
	popup.set_content(chassis.get_stats_html(owner))
	popup.open()


/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/vehicle/sealed/mecha/strafe/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()

/obj/vehicle/sealed/mecha/AltClick(mob/living/user)
	if((user in occupants) && user.canUseTopic(src))
		toggle_strafe()

/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CANSTRAFE))
		to_chat(occupants, "[icon2html(src, occupants)][span_notice("This mecha does not support strafing.")]")
		return
	strafe = !strafe

	to_chat(occupants, "[icon2html(src, occupants)][span_notice("Toggled strafing mode [strafe?"on":"off"].")]")
	log_message("Toggled strafing mode [strafe?"on":"off"].", LOG_MECHA)

	for(var/occupant in occupants)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.update_buttons()

//////////////////////////////////////// Specific Ability Actions  ///////////////////////////////////////////////
//Need to be granted by the mech type, Not default abilities.

/datum/action/vehicle/sealed/mecha/mech_defense_mode
	name = "Toggle an energy shield that blocks all attacks from the faced direction at a heavy power cost."
	button_icon_state = "mech_defense_mode_off"

/datum/action/vehicle/sealed/mecha/mech_defense_mode/on_activate(mob/user, atom/target)
	SEND_SIGNAL(chassis, COMSIG_MECHA_ACTION_TRIGGER, owner, args) //Signal sent to the mech, to be handed to the shield. See durand.dm for more details

/datum/action/vehicle/sealed/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overload_mode/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	/*if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else Don't know what to do about this part*/
	chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.", LOG_MECHA)
	if(chassis.leg_overload_mode)
		chassis.movedelay = min(1, round(chassis.movedelay * 0.5))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.balloon_alert(owner,"Toggled leg actuators overload.")
	else
		chassis.movedelay = initial(chassis.movedelay)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.balloon_alert(owner, "Disabled leg actuators overload.")
	update_buttons()

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/vehicle/sealed/mecha/mech_smoke/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_SMOKE) && chassis.smoke_charges>0)
		chassis.smoke_system.start()
		chassis.smoke_charges--
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_SMOKE, chassis.smoke_cooldown)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/on_activate(mob/user, atom/target)

	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Toggled zoom mode.", LOG_MECHA)
		chassis.balloon_alert(owner, "Zoom mode has been [chassis.zoom_mode ? "enabled" : "disabled"].")
		if(chassis.zoom_mode)
			owner.client.view_size.setTo(4.5)
			SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg',volume=50))
		else
			owner.client.view_size.resetToDefault() //Let's not let this stack shall we?
		update_buttons()

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if("tox")
			new_damtype = "brute"
			to_chat(owner, "[icon2html(chassis, owner)][span_notice("Your exosuit's hands form into fists.")]")
		if("brute")
			new_damtype = "fire"
			to_chat(owner, "[icon2html(chassis, owner)][span_notice("A torch tip extends from your exosuit's hand, glowing red.")]")
		if("fire")
			new_damtype = "tox"
			to_chat(owner, "[icon2html(chassis, owner)][span_notice("A bone-chillingly thick plasteel needle protracts from the exosuit's palm.")]")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(chassis, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	update_buttons()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = !chassis.phasing
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "Enabled" : "Disabled"] phasing")
	update_buttons()
