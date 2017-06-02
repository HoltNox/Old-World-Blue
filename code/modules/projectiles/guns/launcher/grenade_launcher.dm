/obj/item/weapon/gun/launcher/grenade
	name = "grenade launcher"
	desc = "A bulky pump-action grenade launcher. Holds up to 6 grenades in a revolving magazine."
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = ITEM_SIZE_HUGE
	force = 10

	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"
	recoil = 0
	throw_distance = 7
	release_force = 5

	var/obj/item/weapon/grenade/chambered
	var/list/grenades = new/list()
	var/max_grenades = 5 //holds this + one in the chamber
	matter = list(DEFAULT_WALL_MATERIAL = 2000)

//revolves the magazine, allowing players to choose between multiple grenade types
/obj/item/weapon/gun/launcher/grenade/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)

	var/obj/item/weapon/grenade/next
	if(grenades.len)
		//get this first, so that the chambered grenade can still be removed if the grenades list is empty
		next = grenades[1]
	if(chambered)
		grenades += chambered //rotate the revolving magazine
		chambered = null
	if(next)
		grenades -= next //Remove grenade from loaded list.
		chambered = next
		M << SPAN_WARN("You pump [src], loading \a [next] into the chamber.")
	else
		M << SPAN_WARN("You pump [src], but the magazine is empty.")
	update_icon()

/obj/item/weapon/gun/launcher/grenade/examine(mob/user, return_dist=1)
	.=..()
	if(.<=2)
		var/grenade_count = grenades.len + (chambered? 1 : 0)
		user << "Has [grenade_count] grenade\s remaining."
		if(chambered)
			user << "\A [chambered] is chambered."

/obj/item/weapon/gun/launcher/grenade/proc/load(obj/item/weapon/grenade/G, mob/user)
	if(grenades.len >= max_grenades)
		user << SPAN_WARN("[src] is full.")
		return
	user.remove_from_mob(G)
	G.loc = src
	grenades.Insert(1, G) //add to the head of the list, so that it is loaded on the next pump
	user.visible_message(
		"[user] inserts \a [G] into [src].",
		"<span class='notice'>You insert \a [G] into [src].</span>"
	)

/obj/item/weapon/gun/launcher/grenade/proc/unload(mob/user)
	if(grenades.len)
		var/obj/item/weapon/grenade/G = grenades[grenades.len]
		grenades.len--
		user.put_in_hands(G)
		user.visible_message(
			"[user] removes \a [G] from [src].",
			"<span class='notice'>You remove \a [G] from [src].</span>"
		)
	else
		user << SPAN_WARN("[src] is empty.")

/obj/item/weapon/gun/launcher/grenade/attack_self(mob/user)
	pump(user)

/obj/item/weapon/gun/launcher/grenade/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/weapon/grenade)))
		load(I, user)
	else
		..()

/obj/item/weapon/gun/launcher/grenade/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		unload(user)
	else
		..()

/obj/item/weapon/gun/launcher/grenade/consume_next_projectile()
	if(chambered)
		chambered.det_time = 10
		chambered.activate(null)
	return chambered

/obj/item/weapon/gun/launcher/grenade/handle_post_fire(mob/user)
	log_game("[key_name_admin(user)] used a grenade ([chambered.name]).", chambered, 0)
	chambered = null

//Underslung grenade launcher to be used with the Z8
/obj/item/weapon/gun/launcher/grenade/underslung
	name = "underslung grenade launcher"
	desc = "Not much more than a tube and a firing mechanism, this grenade launcher is designed to be fitted to a rifle."
	w_class = ITEM_SIZE_NORMAL
	force = 5
	max_grenades = 0

/obj/item/weapon/gun/launcher/grenade/underslung/attack_self()
	return

//load and unload directly into chambered
/obj/item/weapon/gun/launcher/grenade/underslung/load(obj/item/weapon/grenade/G, mob/user)
	if(chambered)
		user << SPAN_WARN("[src] is already loaded.")
		return
	user.remove_from_mob(G)
	G.loc = src
	chambered = G
	user.visible_message(
		"[user] load \a [G] into [src].",
		"<span class='notice'>You load \a [G] into [src].</span>"
	)

/obj/item/weapon/gun/launcher/grenade/underslung/unload(mob/user)
	if(chambered)
		user.put_in_hands(chambered)
		user.visible_message(
			"[user] removes \a [chambered] from [src].",
			"<span class='notice'>You remove \a [chambered] from [src].</span>"
		)
		chambered = null
	else
		user << SPAN_WARN("[src] is empty.")