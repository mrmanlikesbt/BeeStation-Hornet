//Acid rain is part of the natural weather cycle in the humid forests of Planetstation, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 400
	telegraph_message = span_boldwarning("Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.")
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_overlay = "acid_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/ambience/acidrain_mid.ogg'

	end_duration = 100
	end_message = span_boldannounce("The downpour gradually slows to a light shower. It should be safe outside now.")
	end_sound = 'sound/ambience/acidrain_end.ogg'

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_ACIDRAIN

	immunity_type = ACID // temp

	barometer_predictable = TRUE


/datum/weather/acid_rain/weather_act(mob/living/L)
	var/resist = L.getarmor(null, ACID)
	if(prob(max(0,100-resist)))
		L.acid_act(20,20)
