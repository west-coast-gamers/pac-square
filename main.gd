extends Node2D

# :Tips - a scene doesn't look like a class but it is one. There is an
# invisible Class declaration around the .tscn file...

var Util = preload('res://util.gd')
var Map = preload('res://map.gd')

var dot_scene = load('res://dot.tscn')
var pill_scene = load('res://pill.tscn')
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

var ghost_running_tick = 0.0

var score = 0

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
		$pac.connect('reached_destination', self, 'on_pac_reached_destination')
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

		for pos in map.pill_positions:
			var pill = pill_scene.instance()
			pill.position_tile = pos
			pill.position = Vector2(game_area.offset + pos.x*game_area.tile_size,
				game_area.offset + pos.y*game_area.tile_size)
			$dots.add_child(pill)
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

	for ghost in $ghosts.get_children():
		move_ghost(ghost)

func _process(delay):

	if ghost_running_tick > 0.0:
		ghost_running_tick -= delay

		if ghost_running_tick <= 0.0:
			ghost_running_tick = 0.0

			for ghost in $ghosts.get_children():
				ghost.chase()

		$ghost_run_timer_label.text = '%.1f' % [ghost_running_tick]

	var goto_direction = Vector2()

	if Input.is_action_pressed('pac_up'):
		goto_direction = Vector2(0, -1)
	elif Input.is_action_pressed('pac_down'):
		goto_direction = Vector2(0, 1)
	elif Input.is_action_pressed('pac_left'):
		goto_direction = Vector2(-1, 0)
	elif Input.is_action_pressed('pac_right'):
		goto_direction = Vector2(1, 0)

	var destination_tile = $pac.position_tile + goto_direction
	if destination_tile in map_paths:
		$pac.go_in_direction(goto_direction)
	else:
		$pac.go_in_direction(Vector2())

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

			if dot.is_pill():
				ghost_running_tick = 9.9
				for ghost in $ghosts.get_children():
					ghost.run()
			else:
				score += 1
				$score_value_label.text = str(score)

			dot.queue_free()
			return true
	return false

func on_pac_reached_destination(pac):
	if eat_dot($pac.position_tile):
		$sound_walk.play()

func on_ghost_reached_destination(ghost):
	move_ghost(ghost)

func create_ghost(pos):
	var ghost = ghost_scene.instance()
	ghost.connect('reached_destination', self, 'on_ghost_reached_destination')
	$ghosts.add_child(ghost)
	ghost.position_tile = pos
	place_ghost(ghost)

func place_pac(tile_vector):
	$pac.position = (tile_vector * game_area.tile_size) + Vector2(game_area.offset, game_area.offset)

func place_ghost(ghost):
	ghost.position = (ghost.position_tile * game_area.tile_size) + Vector2(game_area.offset, game_area.offset)

func move_ghost(ghost):

	build_distance_to_pac()
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]
	var goto_direction = Vector2(0, 0)
	var min_distance = 100 # Something big...
	var max_distance = 0 # Something small...

	for direction in directions:
		var next_position = ghost.position_tile + direction
		if next_position in map_path_dist_to_pac:
			if ghost_running_tick > 0.0:
				if map_path_dist_to_pac[next_position] > max_distance:
					max_distance = map_path_dist_to_pac[next_position]
					goto_direction = direction
			else:
				if map_path_dist_to_pac[next_position] < min_distance:
					min_distance = map_path_dist_to_pac[next_position]
					goto_direction = direction

	ghost.go_in_direction(goto_direction)
