/* 		WITHOUT THIS POWER:
 *	- Mid-Blood: SHOW AS PALE
 *	- Low-Blood: SHOW AS DEAD
 *	- No Heartbeat
 *  - Examine shows actual blood
 *	- Thermal homeostasis (ColdBlooded)
 * 		WITH THIS POWER:
 *	- Normal body temp -- remove Cold Blooded (return on deactivate)
 */

/datum/action/bloodsucker/masquerade
	name = "Masquerade"
	desc = "Feign the vital signs of a mortal, and escape both casual and medical notice as the monster you truly are."
	button_icon_state = "power_human"
	bloodcost = 10
	cooldown = 50
	amToggle = TRUE
	bloodsucker_can_buy = FALSE
	warn_constant_cost = TRUE
	can_use_in_torpor = TRUE // Masquerade is maybe the only one that can do this. It stops your healing.
	cooldown_static = TRUE
	must_be_concious = FALSE

/*
/// NOTE: Firing off vulgar powers disables your Masquerade!
/datum/action/bloodsucker/masquerade/CheckCanUse(display_error)
	if(!..(display_error)) // DEFAULT CHECKS
		return FALSE
	// DONE!
	return TRUE
*/

/datum/action/bloodsucker/masquerade/ActivatePower()

	var/mob/living/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)

	to_chat(user, "<span class='notice'>Your heart beats falsely within your lifeless chest. You may yet pass for a mortal.</span>")
	to_chat(user, "<span class='warning'>Your vampiric healing is halted while imitating life.</span>")

	// Remove Bloodsucker traits
	REMOVE_TRAIT(user, TRAIT_NOHARDCRIT, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_VIRUSIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RADIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_TOXIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_COLDBLOODED, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RESISTCOLD, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOPULSE, BLOODSUCKER_TRAIT)
	// Falsifies Health Analyzers
	ADD_TRAIT(user, TRAIT_MASQUERADE, BLOODSUCKER_TRAIT)
	// Falsifies Genetic Analyzers
	REMOVE_TRAIT(user, TRAIT_GENELESS, SPECIES_TRAIT)
	var/obj/item/organ/heart/vampheart/H = user.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/eyes/bloodsucker/E = user.getorganslot(ORGAN_SLOT_EYES)
	E.flash_protect = 0

	// WE ARE ALIVE! //
	bloodsuckerdatum.poweron_masquerade = TRUE
	while(bloodsuckerdatum && ContinueActive(user))

		// HEART
		if(istype(H))
			H.FakeStart()

		// 		PASSIVE (done from LIFE)
		// Don't Show Pale/Dead on low blood
		// Don't vomit food
		// Don't Heal

		// Pay Blood Toll if awake. This is rather high, as we're removing all Bloodsucker abilities, meaning they will regenerate blood like a normal human.
		if(user.stat == CONSCIOUS)
			bloodsuckerdatum.AddBloodVolume(-0.3)

		sleep(20) // Check every few ticks that we haven't disabled this power

/datum/action/bloodsucker/masquerade/ContinueActive(mob/living/user)
	// Disable if unable to use power anymore.
	//if (user.stat == DEAD || user.blood_volume <= 0) // not conscious or soft critor uncon, just dead
	//	return FALSE
	return ..() // Active, and still Antag

/datum/action/bloodsucker/masquerade/DeactivatePower(mob/living/user = owner, mob/living/target)
	..() // activate = FALSE

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum.poweron_masquerade = FALSE

	ADD_TRAIT(user, TRAIT_NOHARDCRIT, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_VIRUSIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_RADIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_TOXIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_COLDBLOODED, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_RESISTCOLD, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_NOPULSE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_MASQUERADE, BLOODSUCKER_TRAIT)
	var/mob/living/carbon/human/bloodsucker = user
	bloodsucker.dna.remove_all_mutations()
	ADD_TRAIT(user, TRAIT_GENELESS, SPECIES_TRAIT)

	// HEART
	var/obj/item/organ/heart/H = user.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/eyes/bloodsucker/E = user.getorganslot(ORGAN_SLOT_EYES)
	H.Stop()

	E.flash_protect = -1

	to_chat(user, "<span class='notice'>Your heart beats one final time, while your skin dries out and your icy pallor returns.</span>")
