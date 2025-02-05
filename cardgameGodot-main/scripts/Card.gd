extends Node2D

signal hovered
signal hovered_off

var starting_position
var card_slot_card_is_in
var card_type
var health
var attack

func _ready() -> void:
	"""
	Bu fonksiyon, kartın ebeveny node'una kartla ilgili sinyalleri bağlamak
	için kullanılır. Kart sinyalleri tetiklendiğinde, bu sinyaller
	ebeveyn node tarafından dinlenip işlenir.
	
	Kartın ebeveyn node'una kartla ilgili sinyalleri bağlar.
	Bu, kartın üzerine gelindiğinde veya tıklanıldığında gerekli işlemleri
	yapmak için kullanılır.
	
	Örnek kullanım:
		Kart üzerinde gelindiğinde, vurgulama işlemi yapılabilir.
		Karta tıklandığında, kart taşıma işlemi başlatılabilir.
	"""
	get_parent().connect_card_signals(self) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()



func _on_area_2d_mouse_entered() -> void:
	"""
	Godot'un yerleşik sinyal fonksiyonlarından biri.
	Area2D nesnesi üzerine fare girdiğinde tetiklenir. Tetiklendiği an,
	hovered sinyali çalışır.
	"""
	emit_signal("hovered", self)# Nesnenin sinyalini yaymak için kullanılır.


func _on_area_2d_mouse_exited() -> void:
	"""
	Godot'ın yerleşik sinyal fonksiyonlarından biri.
	Area2D nesnesi üzerine fare çıktığında tetiklenir. Tetiklendiği an,
	hovered_off sinyali çalışır.
	"""
	emit_signal("hovered_off", self)
