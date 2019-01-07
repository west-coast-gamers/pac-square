extends Node2D

var position_tile = Vector2(0, 0)
var last_direction = Vector2()

signal reached_destination(ghost)

func _ready():
	chase()

func run():
	$sprite_chasing.hide()
	$sprite_running_away.show()

func chase():
	$sprite_chasing.show()
	$sprite_running_away.hide()

func go_in_direction(direction):
	last_direction = direction
	if direction.x > 0:
		$animation_player.play('right')
	elif direction.x < 0:
		$animation_player.play('left')
	elif direction.y > 0:
		$animation_player.play('down')
	elif direction.y < 0:
		$animation_player.play('up')

func _on_animation_player_animation_finished(anim_name):
	position_tile += last_direction
	position += last_direction * 32.0
	$animation_player.seek(0, true)
	emit_signal('reached_destination', self)
