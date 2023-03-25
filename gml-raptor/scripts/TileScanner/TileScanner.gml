/*
    Utility class to scan tile layers in rooms.
	Offers various methods to search for things and list items in tile layers.
	
	It also de-mystifies the "rotate, flip, mirror" flag combinations into 
	an easy-to-understand "orientation" value (see enum below).
*/

enum tile_orientation {
	right	= 0, // rotation   0°
	up		= 1, // rotation  90° ccw
	left	= 2, // rotation 180° ccw
	down	= 3, // rotation 270° ccw
}

/// @function		TileScanner(layername_or_id, scan_on_create = true)
/// @description	Creates a TileScanner for the specified layer.
///					if scan_on_create is true, the constructor will immediately scan the layer
///					and fill the "tiles" array with data. 
///					If you set it to false, tiles is an empty array of undefined's until you invoke "scan_layer()"
function TileScanner(layername_or_id = undefined, scan_on_create = true) constructor {
	construct("TileScanner");
	
	if (layername_or_id != undefined)
		set_layer(layername_or_id, scan_on_create);
	
	/// @function		set_layer(layername_or_id, scan_now = true)
	/// @description	Wrapper init function to have an optional-only construct for savegames
	static set_layer = function(layername_or_id, scan_now = true) {
		lay_id = is_string(layername_or_id) ? layer_get_id(layername_or_id) : layername_or_id;
		map_id = layer_tilemap_get_id(lay_id);
	
		// These hold the width and height IN CELLS of the map!
		map_width	= tilemap_get_width (map_id);
		map_height	= tilemap_get_height(map_id);
	
		cell_width  = tilemap_get_tile_width (map_id);
		cell_height = tilemap_get_tile_height(map_id);
	
		tiles = array_create(map_width * map_height, undefined);
		
		if (scan_now)
			scan_layer();
	}
	
	
	#region orientation management (private)
	
	/// @function		__tiledata_to_orientation(tiledata)
	static __tiledata_to_orientation = function(tiledata) {
		var rotate = tile_get_rotate(tiledata);
		var flip   = tile_get_flip(tiledata);
		var mirror = tile_get_mirror(tiledata);
		
		// Soaked this combinations from the room json after experimenting
		// with tile manipulation - binary it's a bit field in the MSB:
		// 0x0111 = 3x = up   =  rotate &  flip &  mirror
		// 0x0011 = 2x = left = !rotate &  flip &  mirror
		// 0x0100 = 1x = down =  rotate & !flip & !mirror
		// 0x0000 = 0x = right
		if (!rotate && !flip && !mirror) return tile_orientation.right;
		if ( rotate &&  flip &&  mirror) return tile_orientation.up;
		if (!rotate &&  flip &&  mirror) return tile_orientation.left;
		if ( rotate && !flip && !mirror) return tile_orientation.down;
		// This line should never be reached, but still... who knows
		return tile_orientation.right;
	}
	
	/// @function		__orientation_to_tiledata(tiledata, orientation)
	static __orientation_to_tiledata = function(tiledata, orientation) {
		switch (orientation) {
			case tile_orientation.right:
				tiledata = tile_set_rotate(tiledata, false);
				tiledata = tile_set_flip  (tiledata, false);
				tiledata = tile_set_mirror(tiledata, false);
				break;
			case tile_orientation.up:
				tiledata = tile_set_rotate(tiledata, true);
				tiledata = tile_set_flip  (tiledata, true);
				tiledata = tile_set_mirror(tiledata, true);
				break;
			case tile_orientation.left:
				tiledata = tile_set_rotate(tiledata, false);
				tiledata = tile_set_flip  (tiledata, true);
				tiledata = tile_set_mirror(tiledata, true);			
				break;
			case tile_orientation.down:
				tiledata = tile_set_rotate(tiledata, true);
				tiledata = tile_set_flip  (tiledata, false);
				tiledata = tile_set_mirror(tiledata, false);
				break;
		}
	}
	#endregion
	
	/// @function		scan_layer = function()
	/// @description	Returns (and fills) the "tiles" array of this TileScanner
	static scan_layer = function() {
		var xp = 0, yp = 0;
		repeat (map_height) {
			repeat (map_width) {
				tiles[@(yp * map_width + xp)] = new TileInfo().set_data(tilemap_get(map_id, xp, yp), xp, yp, self);
				xp++;
			}
			xp = 0;
			yp++;
		}
		return tiles;
	}
	
	/// @function		find_tiles = function(indices...)
	/// @description	scans the layer for tiles. Specify up to 16 tile indices you want to find.
	///					Returns an array of TileInfo structs.
	static find_tiles = function() {
		return array_filter(tiles, function(element) {
			for (var a = 0; a < argument_count; a++) 
				if (element.index == argument[@ a]) return true;
			return false;
		});
	}
		
}

/// @function		TileInfo()
/// @description	Holds condensed information about a single tile
function TileInfo() constructor {
	construct("TileInfo");
	
	/// @function		set_data(tiledata, map_x, map_y, scanner)
	/// @description	Wrap this in a function to have an empty constructor for the savegame system
	static set_data = function(tiledata, map_x, map_y, scanner) {
		index		= tile_get_index(tiledata);
		orientation = scanner.__tiledata_to_orientation(tiledata);
		empty		= (index <= 0);
		position	= new Coord2(map_x, map_y);
		position_px = new Coord2(map_x * scanner.cell_width, map_y * scanner.cell_height);
		return self;
	}
}