extends Node2D

const CARD_SCENE_PATH = "res://scenes/Card.tscn"
const CARD_DRAW_SPEED = 1
const STARTING_HAND_SIZE = 5

var player_deck = ["Demon", "AbilityTornado", "HumanArcher", "PirateCannon", "HumanArcher", "HumanWizard", "AbilityTornado", "Demon"]
var card_database_reference
var drawn_card_this_turn = false
var AbilityCards = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"""
	Başlangıçta çalışır.
	$RichTextLabel, Deck'e eklenmiş boş bir node. Text yazdırılır.
	Burada da kaç masada kaç tane kart varsa, onu yazdırır.
	Kartların database'ini alıp globa_variable'e eklemek.
	"""
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	$RichTextLabel.bbcode_enabled = true
	card_database_reference = preload("res://scripts/CardDataBase.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	drawn_card_this_turn = true


func draw_card():
	"""
	Masadan her kart çekildiğinde, mevcut kart destesi azaltılır.
	Eğer masada kart kalmadıysa, kartların Sprite'ı görünmez haline getirilir.
	
	instantiate(): bu sahnenin bir kopyası (örneği) oluşturuluyor. Bu kopya,
	dinamik bir kart nesnesi haline geliyor.
	
	Oluşturulan kart, CardManager adlı
	bir düğüm olarak ekleniyor. Bu, kartın sahneden görünür hale gelmesini sağlıyor.
	Kart nesnesine "Card" ismi atanıyor, bu da sahne ağacında bu kartı tanımlamak
	için kullanılabilir.
	
	Yeni oluşturulan kart, add_card_to_hand fonksiyonuna gönderiliyor.
	"""
	if drawn_card_this_turn:
		return
	
	drawn_card_this_turn = true
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://assets/" + card_drawn_name +".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]
	new_card.get_node("Ability").visible = true
	new_card.get_node("AbilityBallon/RichTextLabel").text = new_card.get_node("Ability").text
	new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
	new_card.get_node("Attack").text = str(new_card.attack)
	new_card.health = card_database_reference.CARDS[card_drawn_name][1]
	new_card.get_node("Health").text = str(new_card.health)
	var new_card_ability_script_path = card_database_reference.CARDS[card_drawn_name][3]
	if new_card_ability_script_path:
		new_card.ability_script = load(new_card_ability_script_path).new()
		new_card.get_node("Ability").text = card_database_reference.CARDS[card_drawn_name][4]
	else:
		new_card.get_node("Ability").visible = false
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func reset_draw():
	drawn_card_this_turn = false

func card_is_ability_control(playerDeck):
	for card in player_deck:
		if "Ability" in card:
			AbilityCards.append(card)
	return AbilityCards
	





		#new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
		#new_card.get_node("Attack").text = str(new_card.attack)
		#new_card.health = card_database_reference.CARDS[card_drawn_name][1]
		#new_card.get_node("Health").text = str(new_card.health)

		#new_card.health = card_database_reference.CARDS[card_drawn_name][1]
		#new_card.attack = card_database_reference.CARDS[card_drawn_name][0]





		#if card_database_reference.CARDS[card_drawn_name][3]: ### BUNLAR BENİM YAZDIĞIM
			#new_card.get_node("AbilityBallon/RichTextLabel").text = ""
			#new_card.get_node("AbilityBallon/RichTextLabel").visible = false # ÇALIŞMIYOR
			#new_card.get_node("Ability").text = card_database_reference.CARDS[card_drawn_name][3]
		#else:
			#new_card.get_node("Ability").visible = false
		#new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
		#new_card.get_node("Attack").text = str(new_card.attack)
		#new_card.health = card_database_reference.CARDS[card_drawn_name][1]
		#new_card.get_node("Health").text = str(new_card.health)
		#new_card.get_node("AbilityBallon/RichTextLabel").text = card_database_reference.CARDS[card_drawn_name][3]
		#var new_card_ability_script_path = card_database_reference.CARDS[card_drawn_name][4]

		#if new_card_ability_script_path: # GALİBA BU GEREKSİZ--------------
			#print("new: ", new_card_ability_script_path)
			#new_card.ability_script = load(new_card_ability_script_path).new()
			#new_card.get_node("Health").visible = false
			#new_card.get_node("Attack").visible = false
			#new_card.get_node("Ability").text = str(card_database_reference.CARDS[card_drawn_name][3])#--------------
