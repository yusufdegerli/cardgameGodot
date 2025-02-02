extends Node2D

const CARD_WIDTH = 160
const HAND_Y_POSITION = 955
const DEFAULT_CARD_MOVE_SPEED = 0.1

var center_screen_x
var player_hand = []

func _ready() -> void:
	"""
	Ekranın ortasını kullanmak için.
	"""
	center_screen_x = get_viewport().size.x / 2


func add_card_to_hand(card, speed):
	"""
	Bu Deck.gd dosyasının içindeki draw_card fonksiyonunun içinde çalışan
	fonksiyon.
	
	Eğer oyuncunun elinde hiç kart yoksa, ilk başta kartı ekler ve
	update_hand_positions fonksiyonuyla beraber
	"""
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.starting_position, DEFAULT_CARD_MOVE_SPEED)


func update_hand_positions(speed):
	"""
	Kartların ekran üzerindeki pozisyonları dinamik olarak günceller ve
	her kartı yeni pozisyonlarına animasyonlu bir şekilde taşır.
	
	Bu fonksiyon, kartların sayısı değişse bile düzenli bir şekilde
	hizalanmasını ve animasyonlu bir şekilde taşınnmasını sağlar.
	"""
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)


func calculate_card_position(index):
	"""
	Bu hesaplama, tüm kartların ortalanmış bir düzende sıralanmasını sağlar.
	Her bir kartın konumu, toplam genişliğe ve indeksine bağlı olarak
	hesaplanır. Amaç, elin(hand) görsel olarak düzgün ve simetrik görünmesini
	sağlamaktadır.
	"""
	var total_width = (player_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset


func animate_card_to_position(card, new_position, speed):
	"""
	Bir kartın pozisyonunu belirtilen bir süre boyunca bir Tween(ara-nesne gibi)
	kullanarak yeni bir konuma animasyonla taşır.
	
	Parametreler:
		card (Node2D): Animasyon yapılacak kart nesnesi.
		new_position (Vector2): Kartın taşınacağı hedef pozisyon.
		speed: Animasyon süresi.
	
	Bu fonksiyon, bir kartın "position" özelliğini mevcut konumunda 'new_position'
	parametresinde belirtilen konuma, Tween kullanılarak animasyonla taşır.
	Tween  nesnesi 'get_tree().create_tween()' ile oluşturulur ve SceneTree
	tarafından otomatik olarak yönetilir, yani sahne hiyerarşisine manule
	olarak eklenmesi gerekmez. Animasyonun süresi 'speed' parametresi ile
	belirlenir.
	"""
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)


func remove_card_from_hand(card):
	"""
	Eğer kart kullanıldıysa, kartın desteden ayrılması gerekiyor.
	Bunun için kartın destede olup olmadığını kontrol ettikten sonra
	kart desteden çıkartılır ve aynı zamanda deste güncellernir.
	"""
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
