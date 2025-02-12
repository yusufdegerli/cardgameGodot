extends Node
const TORNADO_DAMAGE = 1
const ANIMATION_SCENE = "res://scenes/AnimationTornado.tscn"
const ANIMATION_X = 400
const ANIMATION_Y = 300

func trigger(battle_manager_reference, card_with_ability, input_manager_reference):
	input_manager_reference.inputs_disabled = true
	battle_manager_reference.enable_end_turn_button(false)
	battle_manager_reference.enable_end_turn_button(false)

	await battle_manager_reference.wait(1.0)
	var cards_to_destroy = []

	for card in battle_manager_reference.opponent_cards_on_battlefield:
		card.health = max(0, card.health - TORNADO_DAMAGE)
		card.get_node("Health").text = str(card.health)
		if card.health == 0:
			cards_to_destroy.append(card)
			
	await battle_manager_reference.wait(1.0)
	
	
	if cards_to_destroy.size() > 0: # rakip kart, tornadoyla öldüğünde siktir olup gitmiyor.
		for card in cards_to_destroy:
			battle_manager_reference.destroy_card(card, "Opponent")
			
	battle_manager_reference.destroy_card(card_with_ability, "Player")
	await battle_manager_reference.wait(1.0)
	battle_manager_reference.enable_end_turn_button(true)
	input_manager_reference.inputs_disabled = false

	
	
