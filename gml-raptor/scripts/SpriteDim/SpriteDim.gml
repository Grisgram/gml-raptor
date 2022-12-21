/// @function					SpriteDim(sprite)
/// @description				Scan a sprite's width and height (asset dimensions)
/// @param {asset} sprite
function SpriteDim(sprite = -1) constructor {
	savegame_construct("SpriteDim");
	
	if (sprite != -1) {
		width = sprite_get_width(sprite);
		height = sprite_get_height(sprite);
		center_x = width / 2;
		center_y = height / 2;
		origin_x = sprite_get_xoffset(sprite);
		origin_y = sprite_get_yoffset(sprite);
	} else {
		width = 1;
		height = 1;
		center_x = 0.5;
		center_y = 0.5;
		origin_x = 0;
		origin_y = 0;
	}
	
	static toString = function() {
		return sprintf("{{0}x{1}}", width, height);
	}
}

