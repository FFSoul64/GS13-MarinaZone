// Normal strength

#define SINGULO_BEACON_DISTURBANCE 0.2 //singularity beacon also improve the odds of meteor waves and speed them up a little.
#define SINGULO_BEACON_MAX_DISTURBANCE 0.6 //maximum cap due to how meteor waves can be potentially round ending.

/datum/round_event_control/meteor_wave
	name = "Meteor Wave: Normal"
	typepath = /datum/round_event/meteor_wave
	weight = 4
	min_players = 20 //GS13 - tweaked all meteor waves to nerf them a bit
	max_occurrences = 2
	earliest_start = 40 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "A regular meteor wave."

/datum/round_event/meteor_wave
	start_when		= 6
	end_when			= 66
	announce_when	= 1
	threat = 15
	var/list/wave_type
	var/wave_name = "normal"
	var/direction

/datum/round_event/meteor_wave/setup()
	announce_when = 1
	start_when = 150		// 5 minutes
	if(GLOB.singularity_counter)
		start_when *= 1 - min(GLOB.singularity_counter * SINGULO_BEACON_DISTURBANCE, SINGULO_BEACON_MAX_DISTURBANCE)
	end_when = start_when + 60

/datum/round_event/meteor_wave/New()
	..()
	if(!wave_type)
		determine_wave_type()

/datum/round_event/meteor_wave/proc/determine_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"normal" = 50,
			"threatening" = 40,
			"catastrophic" = 10))
	if(!direction)
		direction = pick(GLOB.cardinals)
	switch(wave_name)
		if("normal")
			wave_type = GLOB.meteors_normal
		if("threatening")
			wave_type = GLOB.meteors_threatening
		if("catastrophic")
			if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
				wave_type = GLOB.meteorsSPOOKY
			else
				wave_type = GLOB.meteors_catastrophic
		if("meaty")
			wave_type = GLOB.meteorsB
		if("space dust")
			wave_type = GLOB.meteorsC
		if("halloween")
			wave_type = GLOB.meteorsSPOOKY
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()

/datum/round_event/meteor_wave/announce(fake)
	priority_announce(generateMeteorString(start_when,TRUE,direction), "Meteor Alert", "meteors", has_important_message = TRUE)

/proc/generateMeteorString(start_when,syndiealert,direction)
	var/directionstring
	switch(direction)
		if(NORTH)
			directionstring = " towards the fore"
		if(SOUTH)
			directionstring = " towards the aft"
		if(EAST)
			directionstring = " towards starboard"
		if(WEST)
			directionstring = " towards port"
	return "Meteors have been detected on a collision course with the station[directionstring]. Estimated time until impact: [round((start_when * SSevents.wait) / 10, 0.1)] seconds.[GLOB.singularity_counter && syndiealert ? " Warning: Anomalous gravity pulse detected, Syndicate technology interference likely." : ""]"

/datum/round_event/meteor_wave/tick()
	if(ISMULTIPLE(activeFor, 3))
		spawn_meteors(5, wave_type, direction) //meteor list types defined in gamemode/meteor/meteors.dm

/datum/round_event_control/meteor_wave/threatening
	name = "Meteor Wave: Threatening"
	typepath = /datum/round_event/meteor_wave/threatening
	weight = 5
	min_players = 20
	max_occurrences = 0 //GS13 - too chaotic
	earliest_start = 45 MINUTES
	description = "A meteor wave with higher chance of big meteors."

/datum/round_event/meteor_wave/threatening
	wave_name = "threatening"
	threat = 25

/datum/round_event_control/meteor_wave/catastrophic
	name = "Meteor Wave: Catastrophic"
	typepath = /datum/round_event/meteor_wave/catastrophic
	weight = 7
	min_players = 25
	max_occurrences = 0 //GS13 - too chaotic
	earliest_start = 55 MINUTES
	description = "A meteor wave that might summon a tunguska class meteor."

/datum/round_event/meteor_wave/catastrophic
	wave_name = "catastrophic"
	threat = 35

#undef SINGULO_BEACON_DISTURBANCE
#undef SINGULO_BEACON_MAX_DISTURBANCE
