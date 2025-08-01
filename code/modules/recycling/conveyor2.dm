//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

/obj/structure/machinery/conveyor
	icon = 'icons/obj/structures/machinery/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = CONVEYOR_LAYER // so they appear under stuff
	anchored = TRUE
	var/operating = 0 // 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1 // true if can operate (no broken segments in this belt run)
	var/forwards // this is the default (forward) direction, set by the map dir
	var/backwards // hopefully self-explanatory
	var/movedir // the actual direction to move stuff in

	var/list/affecting // the list of all items that will be moved this ptick
	var/id = "" // the control ID - must match controller ID

/obj/structure/machinery/conveyor/centcom_auto
	id = "round_end_belt"

/obj/structure/machinery/conveyor/Initialize(mapload, newdir, on, ...)
	. = ..()
	if(newdir)
		setDir(newdir)
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHEAST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH
	if(on)
		operating = TRUE
		setmove()

/obj/structure/machinery/conveyor/proc/setmove()
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/structure/machinery/conveyor/proc/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = 0
		stop_processing()
		return

	if(!operable || (stat & NOPOWER))
		operating = 0

	if(operating)
		if(!machine_processing)
			start_processing()
	else
		if(machine_processing)
			stop_processing()

	icon_state = "conveyor[operating]"

	// machine process
	// move items to the target location
/obj/structure/machinery/conveyor/process()
	if(inoperable())
		return
	if(!operating)
		return
	use_power(100)

	affecting = loc.contents - src // moved items will be all in loc
	spawn(1) // slight delay to prevent infinite propagation due to map order //TODO: please no spawn() in process(). It's a very bad idea
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
					step(A,movedir)
					items_moved++
			if(items_moved >= 10)
				break

// attack with item, place item on conveyor
/obj/structure/machinery/conveyor/attackby(obj/item/I, mob/user)
	var/obj/item/grab/G = I
	if(istype(G)) // handle grabbed mob
		if(ismob(G.grabbed_thing))
			var/mob/GM = G.grabbed_thing
			step(GM, get_dir(GM, src))
			return

	if(user.a_intent != INTENT_HARM)
		user.drop_inv_item_to_loc(I, loc)

// attack with hand, move pulled object onto conveyor
/obj/structure/machinery/conveyor/attack_hand(mob/user as mob)
	if (( user.is_mob_incapacitated() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.stop_pulling()
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.stop_pulling()
	return


// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/structure/machinery/conveyor/proc/broken()
	stat |= BROKEN
	update()

	var/obj/structure/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/structure/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op
	if(operable)
		start_processing()

	update()
	var/obj/structure/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/*
/obj/structure/machinery/conveyor/verb/destroy()
	set src in view()
	src.broken()
*/

/obj/structure/machinery/conveyor/power_change()
	..()
	update()

// the conveyor control switch
//
//

/obj/structure/machinery/conveyor_switch

	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/structures/machinery/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0 // 0 off, -1 reverse, 1 forward
	var/last_pos = -1 // last direction setting
	var/operated = 1 // true if just operated

	var/id = "" // must match conveyor IDs to control them

	var/list/conveyors // the list of converyors that are controlled by this switch
	anchored = TRUE



/obj/structure/machinery/conveyor_switch/Initialize(mapload, ...)
	. = ..()
	update()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/machinery/conveyor_switch/LateInitialize()
	. = ..()
	conveyors = list()
	for(var/obj/structure/machinery/conveyor/C in GLOB.machines)
		if(C.id == id)
			conveyors += C
	start_processing()

// update the icon depending on the position

/obj/structure/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"


// timed process
// if the switch changed, update the linked conveyors

/obj/structure/machinery/conveyor_switch/process()
	if(!operated)
		return
	operated = 0

	for(var/obj/structure/machinery/conveyor/C in conveyors)
		C.operating = position
		C.setmove()

// attack with hand, switch position
/obj/structure/machinery/conveyor_switch/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return

	if(position == 0)
		if(last_pos < 0)
			position = 1
			last_pos = 0
		else
			position = -1
			last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/structure/machinery/conveyor_switch/S in GLOB.machines)
		if(S.id == src.id)
			S.position = position
			S.update()

/obj/structure/machinery/conveyor_switch/oneway
	var/convdir = 1 //Set to 1 or -1 depending on which way you want the convayor to go. (In other words keep at 1 and set the proper dir on the belts.)
	desc = "A conveyor control switch. It appears to only go in one direction."

// attack with hand, switch position
/obj/structure/machinery/conveyor_switch/oneway/attack_hand(mob/user)
	if(position == 0)
		position = convdir
	else
		position = 0

	operated = 1
	update()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/structure/machinery/conveyor_switch/S in GLOB.machines)
		if(S.id == src.id)
			S.position = position
			S.update()
