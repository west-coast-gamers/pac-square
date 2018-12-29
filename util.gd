extends Node

func oprint(format, var_array):
	
	var resolved_items = []
	
	for var_item in var_array:		
		match typeof(var_item):
			TYPE_NIL:
				resolved_items.append('null')
			TYPE_BOOL:
				resolved_items.append(str(var_item))
			TYPE_INT:
				resolved_items.append(str(var_item))
			TYPE_REAL:
				resolved_items.append('%.4f' % [var_item])
			TYPE_STRING:
				resolved_items.append('"%s"' % [var_item])
			TYPE_VECTOR2:
				resolved_items.append('v2(%.4f, %.4f)' % [var_item.x, var_item.y])
			_:
				resolved_items.append('[Unsupported type %d]' % [typeof(var_item)])
				
	var resolved_item_index = 0
	var res = ''
	
	# @Incomplete - no error checking...
	for c in format:		
		if c == '%':
			res += resolved_items[resolved_item_index]
			resolved_item_index += 1
		else:
			res += c
			
	print(res)