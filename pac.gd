extends Node2D

var Util = preload('res://util.gd')

var position_tile = Vector2()
var last_direction = Vector2()

signal reached_destination(pac)

var animations = {
	Vector2(0, 0): 'idle',
	Vector2(1, 0): 'right',
	Vector2(-1, 0): 'left',
	Vector2(0, -1): 'up',
	Vector2(0, 1): 'down'
}

func go_in_direction(direction):

	if not $animation_player.is_playing() or (last_direction == Vector2() and direction != Vector2()):
		$animation_player.stop()
		last_direction = direction
		$animation_player.play(animations[direction])

	elif $animation_player.is_playing() and direction + last_direction == Vector2() :
		var current_animation_position = $animation_player.current_animation_position
		var current_animation_length = $animation_player.current_animation_length

		position_tile += last_direction
		position += last_direction * 32.0

		last_direction = direction
		$animation_player.play(animations[direction])
		$animation_player.seek(current_animation_length - current_animation_position, true)

func _on_animation_player_animation_finished(anim_name):
	position_tile += last_direction
	position += last_direction * 32.0
	$animation_player.seek(0, true)
	emit_signal('reached_destination', self)
