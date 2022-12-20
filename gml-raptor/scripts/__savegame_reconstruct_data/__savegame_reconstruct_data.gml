/*
    This function will restore the 'data' member in a loaded object instance 
	by scanning the structure recursively and invoking constructors if needed.
*/
function __savegame_reconstruct_data(into, from) {
	var names = variable_struct_get_names(from);
	
	with (into) {
		for (var i = 0; i < array_length(names); i++) {
			var name = names[i];
			var member = from[$ name];
			if (is_struct(member)) {
				var classinst = undefined;
				if (variable_struct_exists(member, __SAVEGAME_CONSTRUCT_NAME)) {
					var class = asset_get_index(member[$ __SAVEGAME_CONSTRUCT_NAME]);
					classinst = new class();
				} else {
					classinst = {};
				}
				self[$ name] = classinst;
				__savegame_reconstruct_data(classinst, member);
			} else
				self[$ name] = from[$ name];
		}
	}
}

