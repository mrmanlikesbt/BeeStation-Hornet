/obj/item/book/granter/action/origami
	granted_action = /datum/action/innate/origami
	name = "The Art of Origami"
	desc = "A meticulously in-depth manual explaining the art of paper folding."
	icon_state = "origamibook"
	action_name = "origami"
	remarks = list(
		"Dead-stick stability...",
		"Symmetry seems to play a rather large factor...",
		"Accounting for crosswinds... really?",
		"Drag coefficients of various paper types...",
		"Thrust to weight ratios?",
		"Positive dihedral angle?",
		"Center of gravity forward of the center of lift...",
	)

/datum/action/innate/origami
	name = "Origami Folding"
	desc = "Toggles your ability to fold and catch robust paper airplanes."
	button_icon_state = "origami_off"
	check_flags = NONE

/datum/action/innate/origami/on_activate()
	to_chat(owner, "<span class='notice'>You will now fold origami planes.</span>")
	button_icon_state = "origami_on"
	active = TRUE
	update_buttons()

/datum/action/innate/origami/on_deactivate(mob/user, atom/target)
	to_chat(owner, "<span class='notice'>You will no longer fold origami planes.</span>")
	button_icon_state = "origami_off"
	active = FALSE
	update_buttons()
