////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	volume = 5
	center_of_mass = list("x"=17, "y"=17)

/obj/item/weapon/reagent_containers/dropper/do_surgery(mob/living/carbon/M, mob/living/user)
	if(user.a_intent != I_HELP) //in case it is ever used as a surgery tool
		return ..()
	afterattack(M, user, 1)
	return 1

/obj/item/weapon/reagent_containers/dropper/afterattack(var/obj/target, var/mob/user, var/proximity)
	if(!target.reagents || !proximity) return

	if(reagents.total_volume)

		if(!target.reagents.get_free_space())
			user << "<span class='notice'>[target] is full.</span>"
			return

		if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/clothing/mask/smokable/cigarette)) //You can inject humans and food but you cant remove the shit.
			user << "<span class='notice'>You cannot directly fill this object.</span>"
			return

		var/trans = 0

		if(ismob(target))

			var/time = 20 //2/3rds the time of a syringe
			user.visible_message(SPAN_WARN("[user] is trying to squirt something into [target]'s eyes!"))

			if(!do_mob(user, target, time))
				return

			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = null
				if(victim.wear_mask)
					if (victim.wear_mask.body_parts_covered & EYES)
						safe_thing = victim.wear_mask
				if(victim.head)
					if (victim.head.body_parts_covered & EYES)
						safe_thing = victim.head
				if(victim.glasses)
					if (!safe_thing)
						safe_thing = victim.glasses

				if(safe_thing)
					trans = reagents.trans_to_obj(safe_thing, amount_per_transfer_from_this)
					user.visible_message(
						SPAN_WARN("[user] tries to squirt something into [target]'s eyes, but fails!"),
						"<span class='notice'>You transfer [trans] units of the solution.</span>"
					)
					return

			var/mob/living/M = target
			var/contained = reagentlist()
			admin_attack_log(user, M,
				"Used the [name] to squirt [M.name] ([M.key]). Reagents: [contained]",
				"Has been squirted with [name] by [user.name] ([user.ckey]). Reagents: [contained]",
				"used [name] (reagents: [contained]) for  squirted"
			)
			trans = reagents.trans_to_mob(target, reagents.total_volume, CHEM_INGEST)
			user.visible_message(
				SPAN_WARN("[user] squirts something into [target]'s eyes!"),
				"<span class='notice'>You transfer [trans] units of the solution.</span>"
			)
			return

		else
			trans = reagents.splash(target, amount_per_transfer_from_this) //sprinkling reagents on generic non-mobs
			user << "<span class='notice'>You transfer [trans] units of the solution.</span>"

	else // Taking from something

		if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
			user << "<span class='notice'>You cannot directly remove reagents from [target].</span>"
			return

		if(!target.reagents || !target.reagents.total_volume)
			user << "<span class='notice'>[target] is empty.</span>"
			return

		var/trans = target.reagents.trans_to_obj(src, amount_per_transfer_from_this)

		user << "<span class='notice'>You fill the dropper with [trans] units of the solution.</span>"

	return

/obj/item/weapon/reagent_containers/dropper/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/dropper/update_icon()
	if(reagents.total_volume)
		icon_state = "dropper1"
	else
		icon_state = "dropper0"

/obj/item/weapon/reagent_containers/dropper/industrial
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////
