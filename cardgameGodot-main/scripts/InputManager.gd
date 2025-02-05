extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

var card_manager_reference
var deck_reference

func _ready() -> void:
	"""
	Node'ların referansları alıp, global_variable'lara verilir.
	"""
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"


func _input(event):
	"""
	Sol fare tuşunun tıklanma ve serbest bırakılma olaylarını dinler ve ilgili
	işlemleri yapar. Bu fonksiyon, kullanıcı fareyi kullanarak oyunla etkileşime
	girdiğinde tetiklenir.
	
	İşleyiş:
		Eğer fare sol tuşuna basıldığında:
			left_mouse_button_clicked adlı bir sinyal yayılır.
			raycast_at_cursor() fonksiyonu çağrılır, bu da fare imlecinin
			altında bir nesne olup olmadığın kontrol eder.
		Eğer fare sol tuşu serbest bırakıldığında:
			left_mouse_button_released adlı bir sinyal yayılır.
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")


func raycast_at_cursor():
	"""
	space_state = 2D fizik dünyasının durumunu temsil eder. Fiziksel sorgu için
	parameters = Fiziksel nokta sorgusu için gerekli parametreleri hazırlamak için
	pa...position = fare imlecini alır.
	pa...collide_with_areas = true: Yalnızca, Area2D tipindeki nesnelerin çarpışmalarını
	kontrol edilmesini sağlar.
	result = belirli bir noktada çarpışma olup olmadığını kontrol eder.
	Eğer bir çarpışma varsa if'in içine girer.
	
	result_collisin_mask = çarpışma varsa, değdiği nesnenin collisin_mask(layer) değerini
	alır.
	
	card_found = çarpışan nesnenin ebevynine(yani kartın kendisi) erişilir.
	EĞER KARTA(COLLISIN_MASK_CARD) TIKLANMIŞSA
		CardManager.gd dosyasındaki, start_drag() fonksiyonuyla, kartı hareket ettirir.
	EĞER KART DESTESİNE TIKLANMIŞSA
		Deck.gd dosyasındaki drag_card() fonksionuyla, kart çekilir.
	"""
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = result[0].collider.get_parent()
			# Card clicked
			if card_found:
				card_manager_reference.card_clicked(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			# Deck clicked
			deck_reference.draw_card()
