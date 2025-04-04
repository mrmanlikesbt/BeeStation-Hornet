//============The internal camera console used for designating the area=============
/obj/machinery/computer/camera_advanced/shuttle_creator
	name = "internal shuttle creator console"
	desc = "You should not have access to this, please report this as a bug"
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	networks = list()
	use_power = NO_POWER_USE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	var/obj/item/shuttle_creator/owner_rsd
	var/datum/action/innate/shuttle_creator/designate_area/area_action
	var/datum/action/innate/shuttle_creator/designate_turf/turf_action
	var/datum/action/innate/shuttle_creator/clear_turf/clear_turf_action
	var/datum/action/innate/shuttle_creator/reset/reset_action
	var/datum/action/innate/shuttle_creator/airlock/airlock_action
	var/datum/action/innate/shuttle_creator/modify/modify_action

/obj/machinery/computer/camera_advanced/shuttle_creator/Initialize(mapload)
	. = ..()
	area_action = new(src)
	turf_action = new(src)
	clear_turf_action = new(src)
	reset_action = new(src)
	airlock_action = new(src)
	modify_action = new(src)

/obj/machinery/computer/camera_advanced/shuttle_creator/check_eye(mob/user)
	if(user.incapacitated())
		user.unset_machine()

/obj/machinery/computer/camera_advanced/shuttle_creator/CreateEye()
	eyeobj = new /mob/camera/ai_eye/remote/shuttle_creation(get_turf(owner_rsd))
	eyeobj.origin = src
	eyeobj.use_static = FALSE

/obj/machinery/computer/camera_advanced/shuttle_creator/can_interact(mob/user)
	if(!isliving(user))
		return FALSE
	var/mob/living/L = user
	if(L.incapacitated())
		return FALSE
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_creator/GrantActions(mob/living/user)
	..(user)
	eyeobj.invisibility = SEE_INVISIBLE_LIVING
	if(area_action)
		area_action.Grant(user)
		actions += area_action
	if(turf_action)
		turf_action.Grant(user)
		actions += turf_action
	if(clear_turf_action)
		clear_turf_action.Grant(user)
		actions += clear_turf_action
	if(reset_action)
		reset_action.Grant(user)
		actions += reset_action
	if(!owner_rsd.linkedShuttleId && airlock_action)
		airlock_action.Grant(user)
		actions += airlock_action
	if(owner_rsd.linkedShuttleId && modify_action)
		modify_action.Grant(user)
		actions += modify_action

/obj/machinery/computer/camera_advanced/shuttle_creator/remove_eye_control(mob/living/user)
	. = ..()
	owner_rsd.overlay_holder.remove_client()
	eyeobj.invisibility = INVISIBILITY_MAXIMUM
	if(user.client)
		user.client.images -= eyeobj.user_image

/obj/machinery/computer/camera_advanced/shuttle_creator/attack_hand(mob/user, list/modifiers)
	if(!is_operational) //you cant use broken machine you chumbis
		return
	if(current_user)
		to_chat(user, "The console is already in use!")
		return
	var/mob/living/L = user
	if(!can_use(user))
		return
	if(!eyeobj)
		CreateEye()
	if(!eyeobj.eye_initialized)
		var/camera_location = get_turf(owner_rsd)
		if(camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(camera_location)
			var/mob/camera/ai_eye/remote/shuttle_creation/shuttle_eye = eyeobj
			shuttle_eye.source_turf = get_turf(user)
		else
			user.unset_machine()
	else
		var/camera_location = get_turf(owner_rsd)
		var/mob/camera/ai_eye/remote/shuttle_creation/eye = eyeobj
		give_eye_control(L)
		if(camera_location)
			eye.source_turf = camera_location
			eyeobj.setLoc(camera_location)
		else
			eyeobj.setLoc(eyeobj.loc)
