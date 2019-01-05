extends Node

static func convert_base_type(var_item):
	match typeof(var_item):
		TYPE_NIL:
			return 'null'
		TYPE_BOOL:
			return str(var_item)
		TYPE_INT:
			return str(var_item)
		TYPE_REAL:
			return '%.3f' % [var_item]
		TYPE_STRING:
			return '"%s"' % [var_item]
		TYPE_VECTOR2:
			return 'v2(%.3f, %.3f)' % [var_item.x, var_item.y]
		TYPE_OBJECT:
			var res = '%s { ' % [var_item.name]
			for i in var_item.get_property_list():
				if i.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
					var value = var_item.get(i.name)
					res += '%s: %s ' % [i.name, convert_base_type(value)]
			res += '}'
			return res

	return '[Unsupported type %d]' % [typeof(var_item)]

static func oprint(format, var_item_or_array):

	var resolved_items = []

	match typeof(var_item_or_array):
		TYPE_ARRAY:
			for var_item in var_item_or_array:
				resolved_items.append(convert_base_type(var_item))
		_:
			resolved_items.append(convert_base_type(var_item_or_array))

	var resolved_item_index = 0
	var res = ''

	# @Incomplete - no error checking, simply skipping items if '%' are missing...
	for c in format:
		if c == '%':
			if resolved_item_index < len(resolved_items):
				res += resolved_items[resolved_item_index]
				resolved_item_index += 1
		else:
			res += c

	print(res)
