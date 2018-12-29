extends Node2D

var position_tile = Vector2(0, 0)
var destination_tile = Vector2(0, 0)
var speed = 110

func _ready():
	chase()

func run():
	speed = 90
	$sprite_chasing.hide()
	$sprite_running_away.show()

func chase():
	speed = 110
	$sprite_chasing.show()
	$sprite_running_away.hide()
