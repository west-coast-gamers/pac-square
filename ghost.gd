extends Node2D

var position_tile = Vector2(0, 0)
var destination_tile = Vector2(0, 0)
var speed = 110
var animation = 'idle'

func _ready():
	chase()

func _process(delta):

	var direction = destination_tile - position_tile
	var new_animation = ''

	if direction.x > 0:
		new_animation = 'right'
	elif direction.x < 0:
		new_animation = 'left'
	elif direction.y > 0:
		new_animation = 'down'
	elif direction.y < 0:
		new_animation = 'up'

	if animation != new_animation:
		animation = new_animation
		$animation_player.play(animation)

func run():
	speed = 50
	$sprite_chasing.hide()
	$sprite_running_away.show()

func chase():
	speed = 60
	$sprite_chasing.show()
	$sprite_running_away.hide()
