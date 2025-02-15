extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGGER_SCALE = 0.85
const CARD_SMALLER_SCALE = 0.8
const ANIMATION_TORNADO = preload("res://scenes/AnimationTornado.tscn")

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var played_monster_card_this_turn = false
var played_human_card_this_turn = false
var selected_monster

func _ready() -> void:
	"""
	Başlangıç fonksiyonu.
	
	Ekranın üzerindeki görüntülenme alanı. Size kullanığ global variable'e
	bu değerleri vererek ekranın genişliğinin önemi olmadan işlem yapılabilir.
	"""
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)


func _process(delta: float) -> void:
	"""
	Fareyle sürüklenen bir kartın pozisyonunun günceller ve ekran
	sınırları içerisinde kalmasını sağlar. Fare pozisyonu 'clamp'
	kullanılarak ekran boyutlarıyla sınırlandırılır.
	
	Parametreler:
		delta: float iki kare arasındaki süre. (Zaman tabanlı işlemler
		için kullanılabilir.)
	"""
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y))

func card_clicked(card):
	# Card if card on battlefield or in hand
	if card.card_slot_card_is_in:
		if $"../BattleManager".is_opponents_turn:
			return
			
		#if $"../BattleManager".player_is_attacking:
			#return
		if card in $"../BattleManager".player_cards_that_attacked_this_turn:
			return
		#if card.card_type != "Monster":
			#return
		if $"../BattleManager".opponent_cards_on_battlefield.size() == 0:
			$"../BattleManager".direct_attack(card, "Player")
		else:
			select_card_for_battle(card)
	else:
		# Card in hand
		start_drag(card)


func select_card_for_battle(card):
	# Check if monster already selected
	if selected_monster:
		# If this card already selected
		if selected_monster == card:
			card.position.y += 20
			selected_monster = null
		# If differenet card seleceted
		else:
			selected_monster.position.y += 20
			selected_monster = card
			card.position.y -= 20
	else:
		selected_monster = card
		card.position.y -= 20
	

func start_drag(card):
	"""
	Bir kartın sürüklenme işlemini başlatır.
	
	Parametreler:
		card : Node
		Sürüklenmeye başlanan kart nesnesi.
	"""
	card_being_dragged = card
	card_being_dragged.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)


func finish_drag():
	"""
	Sürükleme işlemini tamamlar ve kartı bırakır.
	
	Bu fonksiyon, kartın sürüklenme işlemini sonlandırır. Kartı
	uygun bir kart yuvasına bırakır veya kart oyuncunun eline geri döner.
	Eğer kart bir yuva üzerine bırakılırsa, yuvanın durumunu günceller ve
	kartın fiziksel çarpışmasını devre dışı bırakır.
	"""
	card_being_dragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot: # oc sorgu
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			if card_being_dragged.card_type == "Monster" && played_monster_card_this_turn:
				player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
				card_being_dragged = null
				return
			#if !played_human_card_this_turn:
				#played_human_card_this_turn = true
			#else:
				#
			card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
			card_being_dragged.z_index = -1
			is_hovering_on_card = false
			card_being_dragged.card_slot_card_is_in = card_slot_found
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			card_being_dragged.position = card_slot_found.position
			card_slot_found.card_in_slot = true
			card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
			
			if card_being_dragged.card_type == "Monster":
				$"../BattleManager".player_cards_on_battlefield.append(card_being_dragged)
				played_monster_card_this_turn = true
			else:
				if card_being_dragged.ability_script:
			#elif card_being_dragged.ability_script:
					if card_being_dragged.card_type == "Ability":
						var animationScene = get_node("../AnimationTornado")
						if animationScene:
							animationScene.animation()
							animationScene.visible = true

			#if $"../AnimationTornado":
				#$"../AnimationTornado".visible = true
		
			if card_being_dragged.ability_script:
				card_being_dragged.ability_script.trigger_ability($"../BattleManager", card_being_dragged, $"../InputManager", "card_placed")
		
			card_being_dragged = null
			return
	player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null

func unselect_selected_monster():
	if selected_monster:
		selected_monster.position.y += 20
		selected_monster = null

func connect_card_signals(card):
	"""
	Card nesnesine sinyalleri bağlar.
	
	Parametreler:
		card : Node
			Sintalleri bağlanacak kart nesnesi.
	"""
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_left_click_released():
	"""
	Sol fare tıklamasının bırakıldığı olayı işler.
	Kart sürükleme işlemi sırasında, sol fare düğmesi bırakıldığında,
	sürükleme işlemini tamamlar.
	"""
	if card_being_dragged:
		finish_drag()


func on_hovered_over_card(card):
	"""
	Fare bir kartın üzerine geldiğinde tetiklenen olay.
	
	Fare bir kartın üzerine geldiğinde görsel vurgulamayı etkinleştirir ve
	kartın 'is_hovering_on_card' durumunu günceller.
	
	Parametreler:
		card : Node
			Fareyle üzerine gelinen kart nesnesi.
	"""
	if card.card_slot_card_is_in:
		return
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


func on_hovered_off_card(card):
	"""
	Fare bir karttan ayrıldığında tetiklenen olay.
	
	Bu fonksiyon, karrten ayrıldığında görsel vurgulamayı kaldırır. Ayrıca,
	fare başka bir kartın üzerine gelmişse o kartı vurgular. Kart sürüklendiğinde
	vurgulamayı kaldırmaz.
	
	Parametreler:
		card : Node
			Fareyle üzerinden ayrılan kart nesnesi
	"""
	if !card.defeated:
		# Check if card is in a card slot
		if !card.card_slot_card_is_in && !card_being_dragged:
				#is_hovering_on_card = false
				highlight_card(card, false)
				var new_card_hovered = raycast_check_for_card()
				if new_card_hovered:
					highlight_card(new_card_hovered, true)
				else:
					is_hovering_on_card = false


func highlight_card(card, hovered):
	"""
	Bir kartın fareyle etkileşimde olup olmadığını kontrol ederek, ölçeklendirmesinde
	değişiklik yapılıyor.
	
	Bu fonksiyon, kartın üzerinde fare gezdirildiğinde (`hovered` durumu), ölçeğini ve
	z-index'ini artırarak daha belirgin görünmesini sağlar. 
	Fare karttan uzaklaştığında, görsel özellikleri orijinal durumuna geri döndürülür.

	Parametreler:
		card : Node2D
		Etkileşimde bulunulan kart düğümü.
	hovered : bool
		Kartın fareyle etkileşimde olup olmadığını belirten durum. 
	- `true` olduğunda, kart vurgulanır.
	- `false` olduğunda, kart eski durumuna döner.
	"""
	# BURAYA HİÇ GİRMİYOR? BU YÜZDEN TETİKLENMİYO AMA GERİ KALAN ŞEYLER HALLOLDU GİBİ.
	
	if card.card_slot_card_is_in: # Çalışmasa da olur galiba
		print("AAAAA")
		return
	if hovered:
		#var get_asd = get_node("res://scenes/Card.tscn")
		#$AbilityBallon.visible = false
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1


func raycast_check_for_card_slot():
	"""
	Fare konumunda bir kart yuvası (slot) ile çarpışma olup olmadığını kontrol eder
	ve çarpışan ilk yuvanın ebeveyn düğümünü döndürür.
	
	Return:
		Node2D veya null Eğer fare konumunda bir kart yuvası ile çarpışma varsa,
		çarpışan yuvanın ebeveyn düğümü döndürülür. Eğer çarpışma yoksa null döner.
	
	Kullanım:
		Fonksiyon, genellikle kartların doğru yuvalara yerleştirilip yerleştirilmediğini
		kontrol etmek için kullanılır.
	"""
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func raycast_check_for_card():
	"""
	Fare tıklaması veya hareketeiyle bir kartın alanında bir çarpışma olup
	olmadığını kontrol eder.
	
	**get_world_2d()**: oyundaki fizik işlemlerin kabasını alır.
	**PhysicsPointQueryParameters2D**: Nesnenin fiziksel sorgusunu yapmak için.
	**get_global_mouse_position()**: Mouse koordinatı.
	**collide_with_areas** = `true` olarak ayarlandığında, sorgunun sadece `Area2D`
	türündeki nesnelerle çarpışmayı kontrol etmesini sağlar.
	collision_mask = Kaçıncı katmanda(layer) olduğunu kontrol etmek için yapılır
	intersect_point(çarpışan_obje): iki boyutlu bir uzayda çarpışmayı kontrol etmek için kullanılır.
	
	Bir `PhysicsPointQueryParameters2D` nesnesi oluşturulur ve fare pozisyonu
	(`get_global_mouse_position`) sorgu parametresi olarak ayarlanır.
	Çarpışma sadece belirli bir katman (`COLLISION_MASK_CARD`) üzerinde ve
	`Area2D` nesneleriyle kontrol edilir. Eğer çarpışma varsa
	(`result.size() > 0`), çarpışan nesneler arasında Z indeksi
	en yüksek olan kart bulunur ve döndürülür.
	Çarpışma yoksa `null` döner.
	"""
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null


func get_card_with_highest_z_index(cards):
	"""
	Belirtilen kartlar arasından en yüksek z_index değerine sahip kartı döndürür.
	
	Fonksiyon, çarpışma kontrolü ile tespit edilen kartların ebeveyn düğümlerini
	(örneğin Area2D'nin üstündeki kart düğümleri) kontrol eder
	ve en yüksek 'z_index' değerine sahip kart düğümünü bulur. Bu oyun
	sahnesinde en üstte görünen kartı belirlemek için kullanılır.
	
	Parametreler:
		card: Array
		Çarpışma sonuçlarından gelen, collider nesnelerini içeren bir dizi.
		Her bir elemanın 'colider' özelliği, bir Area2D veya benzeri bir fiziksel
		düğümü temsil eder.
	Return:
		Node2D
		En yüksek 'z_index' değerine sahip kart düğümünün kendisi.
		Eğer iki kartın z_index değerleri eşitse, dizide önce gelen kart döner.
	"""
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func reset_played_monster():
	played_monster_card_this_turn = false
	
