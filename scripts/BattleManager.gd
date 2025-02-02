extends Node

const CARD_SMALLER_SCALE = 0.8
const CARD_MOVE_SPEED = 0.2

var battle_timer
var empty_monster_card_slots = []

func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.wait_time = 1.0

	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")


func _on_end_turn_button_pressed() -> void:
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
	
	# Check if any free monster card slots, and if no, end turn
	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return
	
	# Try play card and wait 1 sec if played
	await try_play_card_with_highest_attack()
	
	
	end_opponent_turn()
	


func try_play_card_with_highest_attack():
	# Get random empty slot to play the card in
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size())]
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
	tween.tween_property(card_with_highest_atk, "position", random_empty_monster_card_slot, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_highest_atk, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	# Remove the card from opponents_hand
	$"../OpponentHand".remove_card_from_hand(card_with_highest_atk)
	
	# Wait 1 second
	battle_timer.start()
	await battle_timer.timeout


func end_opponent_turn():
	# Reset the player deck draw
	$"../Deck".reset_draw()
	$"../CardManager".reset_played_monster()
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false
