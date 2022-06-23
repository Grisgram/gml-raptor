/// @function					SpriteDim(sprite)
/// @description				Scan a sprite's width and height (asset dimensions)
/// @param {asset} sprite
function SpriteDim(sprite) constructor {
	width = sprite_get_width(sprite);
	height = sprite_get_height(sprite);
	
	static toString = function() {
		return sprintf("{{0}x{1}}", width, height);
	}
}

