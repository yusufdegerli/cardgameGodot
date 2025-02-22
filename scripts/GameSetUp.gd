extends Node2D

const STARTING_HEALTH = 10


func host_set_up():
# Set player and opponent healt
# Set deck text count and draw initial hand
# Make end turn button visible as the host will play first
# Enable inputs
	$PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("OpponentField/OpponentHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.opponent_health = STARTING_HEALTH
	
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = 8
	get_parent().get_node("OpponentField/OpponentDeck/RichTextLabel").text = "8"
	
	await $Deck.draw_initial_hand()
	
	$EndTurnButton.visible = true
	$EndTurnButton.disabled = false
	
	$InputManager.inputs_disabled = false






func client_set_up():
	get_parent().get_node("OpponentField/OpponentHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.opponent_health = STARTING_HEALTH
	
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = 8
	get_parent().get_node("OpponentField/OpponentDeck/RichTextLabel").text = "8"
	
	$Deck.draw_initial_hand()
