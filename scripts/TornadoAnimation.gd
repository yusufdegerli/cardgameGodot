extends Node2D

const ANIMATION_SPEED = 275
const LIFETIME = 4
const START_POS_X = 400

var active = false

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#START_POS_X = position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if active:
		#position.x += ANIMATON_SPEED * delta

#func animation():
	#$AnimatedSprite2D.visible = true
	#$AnimatedSprite2D.play()
	#active = true
	#await get_tree().create_timer(LIFETIME).timeout
	#queue_free()

func animation():
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play()

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", START_POS_X + (ANIMATION_SPEED * LIFETIME), LIFETIME)
	
	await get_tree().create_timer(LIFETIME).timeout
	queue_free()
