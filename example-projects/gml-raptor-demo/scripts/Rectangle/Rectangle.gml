/// @function					Rectangle(rect_left = 0, rect_top = 0, rect_width = 0, rect_height = 0)
/// @description				define a rectangle as struct
/// @param {real=0} rect_left
/// @param {real=0} rect_top
/// @param {real=0} rect_width
/// @param {real=0} rect_height
/// @returns {struct}			
function Rectangle(rect_left = 0, rect_top = 0, rect_width = 0, rect_height = 0) constructor {
	left = rect_left;
	top = rect_top;
	width = rect_width;
	height = rect_height;
	
	/// @function					get_right()
	/// @description				right edge of the rectangle
	static get_right  = function() { return left + width - 1; }
	/// @function					get_bottom()
	/// @description				bottom edge of the rectangle
	static get_bottom = function() { return top + height - 1; }	
	/// @function					get_diagonal()
	/// @description				length of the diagonal
	static get_diagonal = function() { return sqrt(sqr(width) + sqr(height)); }
	/// @function					get_center_x()
	/// @description				left + width / 2
	static get_center_x = function() { return left + width / 2; }
	/// @function					get_center_y()
	/// @description				top + height / 2
	static get_center_y = function() { return top + height / 2; }
	
	/// @function					set(rect_left, rect_top, rect_width, rect_height)
	/// @description				set all values in one go
	/// @param {real} rect_left
	/// @param {real} rect_top
	/// @param {real} rect_width
	/// @param {real} rect_height
	static set = function(rect_left, rect_top, rect_width, rect_height) {
		left = rect_left;
		top = rect_top;
		width = rect_width;
		height = rect_height;
	}
	
	/// @function				intersects_rect(other_rect)	
	/// @description			Determines if the other_rect intersects at least with
	///							one corner with this rect
	/// @param {Rectangle} other_rect
	/// @returns {bool}			true if intersecting
	static intersects_rect = function(other_rect) {
		if (is_between(other_rect.left		 , left, left + width - 1) ||
			is_between(other_rect.get_right() , left, left + width - 1)) {
			return 
				(is_between(other_rect.top		  , top , top + height - 1) ||
				 is_between(other_rect.get_bottom(), top , top + height - 1));

		}
		return false;
	}
	
	/// @function				intersects_point(xp, yp)	
	/// @description			Determines if the xp/yp intersect this rect
	/// @param {real} xp
	/// @param {real} yp
	/// @returns {bool}			true if intersecting
	static intersects_point = function(xp, yp) {
		return is_between(xp, left, left + width - 1) && is_between(yp, top, top + height - 1);
	}
	
	static toString = function() {
		return sprintf("{{0}/{1}; {2}x{3}}", left, top, width, height);
	}
}