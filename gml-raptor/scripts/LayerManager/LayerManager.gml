/// @function					layer_set_all_visible(wildcard, vis)
/// @description				Sets the visible state of all layers where the name matches
///								the specified wildcard.
///								Wildcard character is '*'. It can be at the beginning, the end or both.
/// @param {string}	wildcard			The layer name or wildcard (name* or *name) to set visibility for
/// @param {bool}	vis					Visible yes/no
/// @param {bool}	object_activation	if true, all objects on this layer will be 
///										activated/deactivated according to vis
function layer_set_all_visible(wildcard, vis, object_activation = true) {
	var layers = layer_get_all();
	for (var i = 0; i < array_length(layers); i++) {
		var lid = layers[i];
		var lname = layer_get_name(lid);
		
		if (string_match(lname, wildcard)) {
			layer_set_visible(lid, vis);
			if (object_activation) {
				if (vis) instance_activate_layer(lid); else instance_deactivate_layer(lid);
			}
			log(sprintf("Setting layer visibility: layer='{0}'; visible={1};", lname, vis));
		}
	}
}

function __set_tile_data(data, tile_idx = undefined, flip = undefined, rotate = undefined, mirror = undefined) {
	if (tile_idx != undefined) data = tile_set_index(data, tile_idx);
	if (flip     != undefined) data = tile_set_flip(data, flip);
	if (rotate   != undefined) data = tile_set_rotate(data, rotate);
	if (mirror   != undefined) data = tile_set_mirror(data, mirror);
	return data;
}

/// @function		layer_tile_modify(layername_or_id, xcell, ycell, tile_idx = undefined, flip = undefined, rotate = undefined, mirror = undefined)
/// @description	Change the tile index of a tile set layer to another tile 
///					and optionally rotates, flips or mirrors the tile
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xcell		The x position (in cells, not pixels!)
/// @param {int}	ycell		The y position (in cells, not pixels!)
/// @param {int}	tile_idx	The new tile index to set
/// @param {bool}	flip		Flip the tile. If you omit this parameter, the current state is not changed.
/// @param {bool}	rotate		Rotate the tile. If you omit this parameter, the current state is not changed.
/// @param {bool}	mirror		Mirror the tile. If you omit this parameter, the current state is not changed.
function layer_tile_modify(layername_or_id, xcell, ycell, tile_idx = undefined, flip = undefined, rotate = undefined, mirror = undefined) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get(map_id, xcell, ycell);
	data = __set_tile_data(data, tile_idx, flip, rotate, mirror);
	tilemap_set(map_id, data, xcell, ycell);
}

/// @function		layer_tile_modify_px(layername_or_id, xpixel, ypixel, tile_idx = undefined, flip = undefined, rotate = undefined, mirror = undefined)
/// @description	Change the tile index of a tile set layer to another tile 
///					and optionally rotates, flips or mirrors the tile
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xpixel		The x position (in pixels, not cells!)
/// @param {int}	ypixel		The y position (in pixels, not cells!)
/// @param {int}	tile_idx	The new tile index to set
/// @param {bool}	flip		Flip the tile. If you omit this parameter, the current state is not changed.
/// @param {bool}	rotate		Rotate the tile. If you omit this parameter, the current state is not changed.
/// @param {bool}	mirror		Mirror the tile. If you omit this parameter, the current state is not changed.
function layer_tile_modify_px(layername_or_id, xpixel, ypixel, tile_idx = undefined, flip = undefined, rotate = undefined, mirror = undefined) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get_at_pixel(map_id, xpixel, ypixel);
	data = __set_tile_data(data, tile_idx, flip, rotate, mirror);
	tilemap_set_at_pixel(map_id, data, xpixel, ypixel);
}

/// @function		layer_tile_set_empty(layername_or_id, xcell, ycell)
/// @description	Clear the tile index at the specified cell position in the tile set layer.
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xcell		The x position (in cells, not pixels!)
/// @param {int}	ycell		The y position (in cells, not pixels!)
function layer_tile_set_empty(layername_or_id, xcell, ycell) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get(map_id, xcell, ycell);
	data = tile_set_empty(data);
	tilemap_set(map_id, data, xcell, ycell);
}

/// @function		layer_tile_set_empty_px(layername_or_id, xpixel, ypixel)
/// @description	Clear the tile index at the specified pixel position in the tile set layer.
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xpixel		The x position (in pixels, not cells!)
/// @param {int}	ypixel		The y position (in pixels, not cells!)
function layer_tile_set_empty_px(layername_or_id, xpixel, ypixel) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get_at_pixel(map_id, xpixel, ypixel);
	data = tile_set_empty(data);
	tilemap_set_at_pixel(map_id, data, xpixel, ypixel);
}

/// @function		layer_tile_set_empty(layername_or_id, xcell, ycell)
/// @description	Returns whether ther is a tile set 
///					at the specified pixel position in the tile set layer.
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xcell		The x position (in cells, not pixels!)
/// @param {int}	ycell		The y position (in cells, not pixels!)
/// @returns {bool}	True, if the cell is empty
function layer_tile_is_empty(layername_or_id, xcell, ycell) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get(map_id, xcell, ycell);
	return tile_get_empty(data);
}

/// @function		layer_tile_set_empty_px(layername_or_id, xpixel, ypixel)
/// @description	Returns whether ther is a tile set 
///					at the specified pixel position in the tile set layer.
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xpixel		The x position (in pixels, not cells!)
/// @param {int}	ypixel		The y position (in pixels, not cells!)
/// @returns {bool}	True, if the cell is empty
function layer_tile_is_empty_px(layername_or_id, xpixel, ypixel) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get_at_pixel(map_id, xpixel, ypixel);
	return tile_get_empty(data);
}

/// @function		layer_tile_get_index(layername_or_id, xcell, ycell)
/// @description	Returns the index of the tile
///					at the specified pixel position in the tile set layer.
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xcell		The x position (in cells, not pixels!)
/// @param {int}	ycell		The y position (in cells, not pixels!)
/// @returns {int}	The index of the tile
function layer_tile_get_index(layername_or_id, xcell, ycell) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get(map_id, xcell, ycell);
	return tile_get_index(data);
}

/// @function		layer_tile_get_index_px(layername_or_id, xpixel, ypixel)
/// @description	Returns the index of the tile
///					at the specified pixel position in the tile set layer.
/// @param {id|string}	layername_or_id	The name or the id of the tile set layer
/// @param {int}	xpixel		The x position (in pixels, not cells!)
/// @param {int}	ypixel		The y position (in pixels, not cells!)
/// @returns {int}	The index of the tile
function layer_tile_get_index_px(layername_or_id, xpixel, ypixel) {
	var lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
	var map_id = layer_tilemap_get_id(lay_id);
	var data = tilemap_get_at_pixel(map_id, xpixel, ypixel);
	return tile_get_index(data);
}
