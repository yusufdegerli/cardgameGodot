extends Node2D

const ANIMATION_SPEED = 275
const LIFETIME = 4
const START_POS_X = 400

var active = false

func animation():
	self.position = Vector2(START_POS_X, self.position.y)
	$".".visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", START_POS_X + (ANIMATION_SPEED * LIFETIME), LIFETIME)
	
	await get_tree().create_timer(LIFETIME).timeout
	$".".visible = false
