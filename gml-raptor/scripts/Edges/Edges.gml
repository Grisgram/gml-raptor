/// @function					Edges(obj)
/// @description				Reads all the edges of an object, that is:
///								left, top, right, bottom, center x/y, width and height
///								based on the sprite of the object
/// @param {instance} obj
/// @returns {Edges}
function Edges(obj) constructor {
	__inst = obj;
	
	left	 = 0;
	right	 = 0;
	top		 = 0;
	bottom	 = 0;
	center_x = 0;
	center_y = 0;
	width	 = 0;
	height	 = 0;
	
	/// @function					update()
	/// @description				re-read the properties of the object
	static update = function() {
		with (__inst) {
			other.left		= x - sprite_xoffset;
			other.top		= y - sprite_yoffset;
			other.right		= x + sprite_width  - 1 - sprite_xoffset;
			other.bottom	= y + sprite_height - 1 - sprite_yoffset;
			other.center_x	= x + sprite_width  / 2 - sprite_xoffset;
			other.center_y	= y + sprite_height / 2 - sprite_yoffset;
			other.width		= other.right - other.left + 1;
			other.height	= other.bottom - other.top + 1;
		}
	}
	
	static toString = function() {
		return sprintf("{Edges l/t/r/b={0}/{1}/{2}/{3}; w/h={4}/{5}; center={6}/{7}}",
			left, top, right, bottom, width, height, center_x, center_y);
	}
	
	update();
}