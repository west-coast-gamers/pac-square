extends Node

func load(filename, game_area):
	var file = File.new()
	file.open(filename, File.READ)

	var loaded_map = {}
	loaded_map['loaded_ok'] = false
	loaded_map['dot_positions'] = []
	loaded_map['wall_positions'] = []
	loaded_map['pac_position'] = Vector2(0, 0)

	for y in range(game_area.height_in_tiles):
		if file.eof_reached():
			return loaded_map

		var line = file.get_line()
		var x = 0
		for c in line:

			if c == 'P':
				loaded_map.pac_position = Vector2(x, y)
			elif c == '.':
				loaded_map.dot_positions.append(Vector2(x, y))
			else:
				loaded_map.wall_positions.append(Vector2(x, y))

			x += 1
			if x == game_area.width_in_tiles:
				break

	loaded_map.loaded_ok = true

	return loaded_map
