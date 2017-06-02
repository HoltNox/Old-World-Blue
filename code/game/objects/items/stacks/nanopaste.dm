/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	amount = 10


/obj/item/stack/nanopaste/attack(mob/living/M as mob, mob/user as mob)
	if (!istype(M) || !istype(user))
		return 0
	if (istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if (R.getBruteLoss() || R.getFireLoss() )
			R.adjustBruteLoss(-15)
			R.adjustFireLoss(-15)
			R.updatehealth()
			use(1)
			user.visible_message(
				SPAN_NOTE("\The [user] applied some [src] on [R]'s damaged areas."),
				SPAN_NOTE("You apply some [src] at [R]'s damaged areas.")
			)
		else
			user << SPAN_NOTE("All [R]'s systems are nominal.")

	if (ishuman(M))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_sel.selecting)
		if(!S)
			user << SPAN_WARN("[M] miss that body part!")
			return

		if(S.open == 1 && S.robotic >= ORGAN_ROBOT)
			if(!S.get_damage())
				user << SPAN_NOTE("Nothing to fix here.")
			else if(can_use(1))
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				S.heal_damage(15, 15, robo_repair = 1)
				H.updatehealth()
				use(1)
				user.visible_message(
					SPAN_NOTE("\The [user] applies some nanite paste on [user != M ? "[M]'s [S.name]" : "[S]"] with [src]."),
					SPAN_NOTE("You apply some nanite paste on [user == M ? "your" : "[M]'s"] [S.name]."
				)
