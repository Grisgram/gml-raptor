/// @function					SpriteDim(sprite)
/// @description				Scan a sprite's width and height (asset dimensions)
/// @param {asset} sprite
function SpriteDim(sprite) constructor {
	if (sprite != -1) {
		width = sprite_get_width(sprite);
		height = sprite_get_height(sprite);
	} else {
		width = 1;
		height = 1;
	}
	
	static toString = function() {
		return sprintf("{{0}x{1}}", width, height);
	}
}

