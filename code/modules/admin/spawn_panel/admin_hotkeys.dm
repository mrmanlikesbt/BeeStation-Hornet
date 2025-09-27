// Open "View Variables" menu for target
/mob/dead/observer/CtrlShiftClickOn(atom/target)
	if(check_rights(R_DEBUG))
		usr.client.debug_variables(target)

// Open "Show Player Panel" menu for target mob
/mob/dead/observer/CtrlClickOn(atom/target)
	if(check_rights(R_ADMIN) && ismob(target))
		usr.client.holder.show_player_panel(target)
