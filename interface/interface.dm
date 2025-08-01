//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
AUTH_CLIENT_VERB(wiki, query as text)
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser. Type nothing to go to the main page."
	set hidden = 1
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		if(query)
			var/output = wikiurl + "/Special:Search/" + query
			src << link(output)
		else if (query != null)
			src << link(wikiurl)
	else
		to_chat(src, span_danger("The wiki URL is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(forum)
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(forumurl)
	else
		to_chat(src, span_danger("The forum URL is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(rules)
	set name = "rules"
	set desc = "Show Server Rules."
	set hidden = 1
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(alert("This will open the rules in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(rulesurl)
	else
		to_chat(src, span_danger("The rules URL is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(github)
	set name = "github"
	set desc = "Visit Github"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		if(alert("This will open the Github repository in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(githuburl)
	else
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(reportissue)
	set name = "report-issue"
	set desc = "Report an issue"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		var/message = "This will open the Github issue reporter in your browser. Are you sure?"
		if(GLOB.revdata.testmerge.len)
			message += "<br>The following experimental changes are active and are probably the cause of any new or sudden issues you may experience. If possible, please try to find a specific thread for your issue instead of posting to the general issue tracker:<br>"
			message += GLOB.revdata.GetTestMergeInfo(FALSE)
		// We still use tgalert here because some people were concerned that if someone wanted to report that tgui wasn't working
		// then the report issue button being tgui-based would be problematic.
		if(tgalert(src, message, "Report Issue","Yes","No")!="Yes")
			return
		var/static/issue_template = rustg_file_read(".github/ISSUE_TEMPLATE.md")
		var/servername = CONFIG_GET(string/servername)
		var/url_params = "Reporting client version: [byond_version].[byond_build]\n\n[issue_template]"
		if(GLOB.round_id || servername)
			url_params = "Issue reported from [GLOB.round_id ? " Round ID: [GLOB.round_id][servername ? " ([servername])" : ""]" : servername]\n\n[url_params]"
		var/issue_label = CONFIG_GET(string/issue_label)
		DIRECT_OUTPUT(src, link("[githuburl]/issues/new?body=[rustg_url_encode(url_params)][issue_label ? "&labels=[rustg_url_encode(issue_label)]" : ""]"))
	else
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(hotkeys_help)
	set name = "hotkeys-help"
	set category = "OOC"

	var/adminhotkeys = {"<font color='purple'>
Admin:
\tF3 = asay
\tF4 = msay
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel
\tF7 = Buildmode
\tF8 = Invisimin
\tCtrl+F8 = Stealthmin
</font>"}

	mob.hotkey_help()

	if(holder)
		to_chat(src, adminhotkeys)

AUTH_CLIENT_VERB(changelog)
	set name = "Changelog"
	set category = "OOC"
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs && prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.mark_undatumized_dirty_player()
		winset(src, "infowindow.changelog", "font-style=;")


/mob/proc/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tm = me
\tt = say
\to = OOC
\tb = resist
\t<B></B>h = stop pulling
\tx = swap-hand
\tz = activate held object (or y)
\tShift+e = Put held item into belt(or belt slot) or take out most recent item added.
\tShift+b = Put held item into backpack(or back slot) or take out most recent item added.
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
\tNumpad = Body target selection (Press 8 repeatedly for Head->Eyes->Mouth)
\tAlt(HOLD) = Alter movement intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+b = resist
\tCtrl+h = stop pulling
\tCtrl+o = OOC
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tCtrl+'+/-' OR
\tShift+Mousewheel = Ghost zoom in/out
\tDEL = stop pulling
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
\tCtrl+Numpad = Body target selection (Press 8 repeatedly for Head->Eyes->Mouth)
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)

/mob/living/silicon/robot/hotkey_help()
	//h = talk-wheel has a nonsense tag in it because \th is an escape sequence in BYOND.
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = unequip active module
\t<B></B>h = stop pulling
\tm = me
\tt = say
\to = OOC
\tx = cycle active modules
\tb = resist
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = activate module 1
\t2 = activate module 2
\t3 = activate module 3
\t4 = toggle intents
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = unequip active module
\tCtrl+x = cycle active modules
\tCtrl+b = resist
\tCtrl+h = stop pulling
\tCtrl+o = OOC
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = activate module 1
\tCtrl+2 = activate module 2
\tCtrl+3 = activate module 3
\tCtrl+4 = toggle intents
\tDEL = stop pulling
\tINS = toggle intents
\tPGUP = cycle active modules
\tPGDN = activate held object
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)




AUTH_CLIENT_VERB(donate)
	set name = "donate"
	set desc = "Donate to the server"
	set hidden = 1
	var/donateurl = CONFIG_GET(string/donateurl)
	if(donateurl)
		if(alert("This will open the Donation page in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(donateurl)
	else
		to_chat(src, span_danger("The Donation URL is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(discord)
	set name = "discord"
	set desc = "Join the Discord"
	set hidden = 1
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(alert("This will open the Discord invite in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(discordurl)
	else
		to_chat(src, span_danger("The Discord invite is not set in the server configuration."))
	return

AUTH_CLIENT_VERB(map)
	set name = "View Webmap"
	set desc = "View the current map in the webviewer"
	set category = "OOC"
	if(SSmapping.config.map_link == "None")
		to_chat(src,span_danger("The current map does not have a webmap. "))
	else if(SSmapping.config.map_link)
		if(tgui_alert(src, "This will open the current map in your browser. Are you sure?", "", list("Yes","No"))!="Yes")
			return
		src << link("https://webmap.affectedarc07.co.uk/maps/bee/[SSmapping.config.map_link]")
	else
		to_chat(src, span_danger("The current map is either invalid or unavailable. Open an issue on the github. "))
