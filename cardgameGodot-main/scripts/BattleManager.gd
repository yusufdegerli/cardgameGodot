extends Node

const CARD_SMALLER_SCALE = 0.8
const CARD_MOVE_SPEED = 0.2
const STARTING_HEALTH = 10
const BATTLE_POS_OFFSET = 25

var battle_timer
var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []
var player_health
var opponent_health
var player_cards_that_attacked_this_turn = []

func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0

	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")

	player_health = STARTING_HEALTH
	$"../PlayerHealth".text = str(player_health)
	opponent_health = STARTING_HEALTH
	$"../OpponentHealth".text = str(opponent_health)

func _on_end_turn_button_pressed() -> void:
	player_cards_that_attacked_this_turn = []
	opponent_turn()



func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	# Wait 1 second
	battle_timer.start()
	await battle_timer.timeout

#	If can draw a card, draw then wait 1 second
	if $"../OpponentDeck".opponent_deck.size() != 0:	
		$"../OpponentDeck".draw_card() 
		# Wait 1 second
		battle_timer.start()
		await battle_timer.timeout
	
	# Check if any free slot, and play monster with highest attack if so
	if empty_monster_card_slots.size() != 0:
		await try_play_card_with_highest_attack()
	
	# Try attack
	if opponent_cards_on_battlefield.size() != 0:
		# Create a new array with all the opponent cards to loop through
		var enemy_cards_to_attack = opponent_cards_on_battlefield.duplicate()
		# Each opponent attacks
		for card in enemy_cards_to_attack:
			# If at least 1 card on player field
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "Opponent")
			else:
				await direct_attack(card, "Opponent")
				# Perform direct attack
	
	end_opponent_turn()
	

func direct_attack(attacking_card, attacker):
	print("direct_attack")
	var new_pos_y
	if attacker == "Opponent":
		new_pos_y = 1080
	else:
		new_pos_y = 0
		player_cards_that_attacked_this_turn.append(attacking_card)
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	
	attacking_card.z_index = 5
	
	#Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)

	if attacker == "Opponent":
		player_health = max(0, player_health - attacking_card.attack)
		$"../PlayerHealth".text = str(player_health)
	else:
		opponent_health = max(0, opponent_health - attacking_card.attack)
		$"../OpponentHealth".text = str(opponent_health)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	attacking_card.z_index = 0
	await wait(1.0)


func attack(attacking_card, defending_card, attacker):
	if attacker == "Player":
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	attacking_card.z_index = 5
	
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	# Card deal damage to each other
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("Health").text = str(defending_card.health)
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait(1.0)
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	# Destroy cards if health is 0
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
		card_was_destroyed = true
	if defending_card.health == 0:
		if attacker == "Player":
			destroy_card(defending_card, "Opponent")
		else:
			destroy_card(defending_card, "Player")
		card_was_destroyed = true
	if card_was_destroyed:
		await wait(1.0)

func destroy_card(card, card_owner):
	# Move card to discard pile
	# Remove card from any relevant array e.g. player_cards_on_battlefield
	var new_pos
	if card_owner == "Player":
		new_pos = $"../PlayerDiscard".position
		if card in player_cards_on_battlefield:
			player_cards_on_battlefield.erase(card)
	else:
		new_pos = $"../OpponentDiscard".position
		
	card.card_slot_card_is_in.card_in_slot = false
	card.card_slot_card_is_in = null
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)

func try_play_card_with_highest_attack():
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
	# Get random empty slot to play the card in
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	# Play the card in hard with highest attack
	# Start by assuming the first card in hand has highest attack
	var card_with_highest_atk = opponent_hand[0]
	# Loop through cards in hand looking for higher attack
	for card in opponent_hand:
		if card.attack > card_with_highest_atk.attack:
			card_with_highest_atk = card
	
	# Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(card_with_highest_atk, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_highest_atk, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	# Remove the card from opponents_hand
	$"../OpponentHand".remove_card_from_hand(card_with_highest_atk)
	card_with_highest_atk.card_slot_card_is_in = random_empty_monster_card_slot
	opponent_cards_on_battlefield.append(card_with_highest_atk)
	
	# Wait 1 second
	await wait(1.0)


func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout

func end_opponent_turn():
	# Reset the player deck draw
	$"../Deck".reset_draw()
	$"../CardManager".reset_played_monster()
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	
	
