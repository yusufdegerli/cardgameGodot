extends Sprite2D
#var tmp = load("res://scenes/Card.tscn").instantiate()
	#var rich_label = tmp.get_node("AbilityBallon/RichTextLabel")
	#print("asdasds: ", rich_label.text)
	#rich_label.visible = false
var card_database_reference
const CARD_SCENE = "res://scenes/Card.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
