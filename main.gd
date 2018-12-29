extends Node2D

# :Tips - a scene doesn't look like a class but it is one. There is an
# invisible Class declaration around the .tscn file...

var Util = preload('res://util.gd')
var Map = preload('res://map.gd')

var dot_scene = load('res://dot.tscn')
var wall_scene = load('res://wall.tscn')
var ghost_scene = load('res://ghost.tscn')

# :Tips - dictionaries works like a struct in some sense since it can be
# access using a . syntax, e.g. game_area.offset.
var game_area = {'height_in_tiles': 20, 'width_in_tiles': 20, 'offset': 16.0, 'tile_size': 32.0}

# Dictionary with Vector2(x, y) as key for all valid paths. Value
# is not important at the moment.
var map_paths = {}

# Dictionary with Vector2(x, y) as key for valid paths. Value is
# shortest distance to Pac.
# @Cleanup - same as map_paths?
var map_path_dist_to_pac = {}

func _ready():

	var map = Map.load('res://map/map1.txt', game_area)
	if map.loaded_ok:

		# Map loaded ok... Create dots, walls etc and insert them
		# into the scene tree. Stuff inserted into the scene tree
		# is rendered by the engine (and has it's magic functions
		# like _process and _ready called).

		# :Tips - the $ syntax is a shortcut (for get_node(node_name))
		# for accessing a node in the scene tree.

		$pac.position_tile = map.pac_position
		$pac.destination_tile = map.pac_position
		place_pac(map.pac_position)
		map_paths[map.pac_position] = true

		for pos in map.dot_positions:
			var dot = dot_scene.instance()
			dot.position_tile = pos
			dot.position = Vector2(game_area.offset + pos.x*game_area.tile_size,
				game_area.offset + pos.y*game_area.tile_size)

			# :Tips - to organize stuff in the scene tree, simple create an
			# arbitrary node in the editor (in this case it is of the type Node2D)
			# and add stuff as childs. Makes it easy to find and iterate stuff.

			$dots.add_child(dot)
			map_paths[pos] = true # A traversable path...

		for pos in map.wall_positions:
			var wall = wall_scene.instance()
			wall.position = Vector2(game_area.offset + pos.x*game_area.tile_size,
				game_area.offset + pos.y*game_area.tile_size)
			$walls.add_child(wall)

	else:
		print('Failed to load map')

	build_distance_to_pac()

	# @Temporary : Ghosts must spawn...
	create_ghost(Vector2(9, 6))
	create_ghost(Vector2(9, 9))


func _process(delay):
	if $pac.position_tile == $pac.destination_tile:
		if Input.is_action_pressed('pac_up'):
			$pac.destination_tile += Vector2(0, -1)
		elif Input.is_action_pressed('pac_down'):
			$pac.destination_tile += Vector2(0, 1)
		elif Input.is_action_pressed('pac_left'):
			$pac.destination_tile += Vector2(-1, 0)
		elif Input.is_action_pressed('pac_right'):
			$pac.destination_tile += Vector2(1, 0)

	# Reject move if it isn't valid...
	if $pac.destination_tile != $pac.position_tile and not $pac.destination_tile in map_paths:
		$pac.destination_tile = $pac.position_tile

	move_pac(delay)
	move_ghosts(delay)


func move_character(character, delay):

	# The character is moving...
	if character.position_tile != character.destination_tile:

		var movement = (character.destination_tile - character.position_tile) * character.speed * delay
		var distance_to_destination = character.position.distance_to(
			(character.destination_tile * game_area.tile_size) + Vector2(game_area.offset, game_area.offset))

		character.position += movement

		if movement.length() > distance_to_destination:
			character.position_tile = character.destination_tile
			character.position = (character.position_tile * game_area.tile_size) + Vector2(game_area.offset, game_area.offset)

			return {'did_move': true, 'reached_destination': true, 'distance_remaining': distance_to_destination}

		return {'did_move': true, 'reached_destination': false, 'distance_remaining': Vector2(0, 0)}

	# :Tips - GDScript has no way to unpack multiple return values. So the
	# cleanest way I think is to return a dictionary (which then can be accessed
	# using the . syntax).
	return {'did_move': false, 'reached_destination': false, 'distance_remaining': Vector2(0, 0)}


func build_distance_to_pac():
	map_path_dist_to_pac = {}
	map_path_dist_to_pac[$pac.position_tile] = 0

	var distance = 1

	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]

	while true:
		var updated = false
		for pos in map_path_dist_to_pac.keys():
			for direction in directions:

				var goto = Vector2(0, 0)
				goto = pos + direction
				if goto in map_path_dist_to_pac:
					if map_path_dist_to_pac[goto] > distance:
						map_path_dist_to_pac[goto] = distance
						updated = true
				elif goto in map_paths:
					map_path_dist_to_pac[goto] = distance
					updated = true

		distance += 1

		if not updated:
			break

func eat_dot(position):
	for dot in $dots.get_children():
		if dot.position_tile == position:
			dot.queue_free()
			return true
	return false


func create_ghost(pos):
	var ghost = ghost_scene.instance()
	$ghosts.add_child(ghost)
	ghost.position_tile = pos
	ghost.destination_tile = pos
	place_ghost(ghost)


func place_pac(tile_vector):
	$pac.position = (tile_vector * game_area.tile_size) + Vector2(game_area.offset, game_area.offset)


func place_ghost(ghost):
	ghost.position = (ghost.position_tile * game_area.tile_size) + Vector2(game_area.offset, game_area.offset)


func move_pac(delay):

	var movement = move_character($pac, delay)

	if movement.reached_destination:
		eat_dot($pac.position_tile)


func move_ghosts(delay):

	for ghost in $ghosts.get_children():

		var movement = move_character(ghost, delay)

		if not movement.did_move or movement.reached_destination:
			build_distance_to_pac()
			var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]
			var goto = Vector2(0, 0)
			var min_distance = 100 # Something big

			for direction in directions:
				var next_position = ghost.position_tile + direction
				if next_position in map_path_dist_to_pac:
					if map_path_dist_to_pac[next_position] < min_distance:
						min_distance = map_path_dist_to_pac[next_position]
						goto = next_position

			ghost.destination_tile = goto
