/*
	Holds a 2D Coordinate pair (x,y)
*/

/// @function					Coord2(xp, yp)
/// @param {real} xp
/// @param {real} yp
/// @returns {Coord2}
function Coord2(xp = 0, yp = 0) constructor {
	construct(Coord2);
	
	set(xp, yp);
	
	/// @function		clone2()
	/// @description	Clones this as Coord2
	static clone2 = function() {
		return new Coord2(x, y);
	}
	
	/// @function				set(xp, yp)
	/// @description			set both values in one step
	/// @param {real} xp
	/// @param {real} yp
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static set = function(xp, yp) {
		x = xp;
		y = yp;
		return self;
	}
	
	/// @function				mul(factor_x, factor_y)
	/// @description			multiply both values in one step
	/// @param {real} factor_x
	/// @param {real} factor_y
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static mul = function(factor_x, factor_y) {
		x *= factor_x;
		y *= factor_y;
		return self;
	}
	
	/// @function				mulxy(factor)
	/// @description			multiply both values in one step
	/// @param {real} factor
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static mul_xy = function(factor) {
		x *= factor;
		y *= factor;
		return self;
	}

	/// @function				plus(other_coord2)
	/// @description			Add the values of other_coord2 into this one
	/// @param {Coord2} other_coord2
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static plus = function(other_coord2) {
		x += other_coord2.x;
		y += other_coord2.y;
		return self;
	}
	
	/// @function				minus(other_coord2)
	/// @description			Subtract the values in other_coord2 from this one
	/// @param {Coord2} other_coord2
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static minus = function(other_coord2) {
		x -= other_coord2.x;
		y -= other_coord2.y;
		return self;
	}

	/// @function				add(add_x, add_y)
	/// @description			add a value to the current values
	/// @param {real} add_x
	/// @param {real} add_y
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static add = function(add_x, add_y) {
		x += add_x;
		y += add_y;
		return self;
	}

	/// @function				addxy(value)
	/// @description			add the same value to the current values
	/// @param {real} value
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static add_xy = function(value) {
		x += value;
		y += value;
		return self;
	}

	/// @function					length_xy()
	/// @description				2D-hypotenuse
	/// @returns {real} length			
	static length_xy = function() { return sqrt(sqr(x) + sqr(y)); }
	
	/// @function		static angle_xy()
	/// @description	gets alpha (angle from horizontal to hypo). 0 degrees is right ccw
	static angle_xy = function() {
		var angle = abs(darcsin(y / length_xy()));
		if (x >= 0) {
			if (y >= 0) {
				return angle;
			} else {
				return 360 - angle;
			}
		} else {
			if (y >= 0) {
				return 180 - angle;
			} else {
				return 180 + angle;
			}
		}
	}
	
	/// @function				distance_to_coord2(other_Coord2)
	/// @description			distance between two vectors
	/// @param {Coord2} other_Coord2
	/// @returns {Coord2}	new Coord2
	static distance_to_coord2 = function(other_coord2) {
		return new Coord2(abs(x - other_coord2.x), abs(y - other_coord2.y));
	}
	
	/// @function				distance_to_xy(xp, yp)
	/// @description			distance between vector and point
	/// @param {real} xp
	/// @param {real} yp
	/// @returns {Coord2}	new Coord2
	static distance_to_xy = function(xp, yp) { 
		return new Coord2(abs(x - xp), abs(y - yp));
	}
	
	/// @function				equals_xy(other_coord2)
	/// @description			true, if both, x and y match	
	/// @returns {bool}			
	static equals_xy = function(other_coord2) {
		return (x == other_coord2.x) && (y == other_coord2.y);
	}
	
	toString = function() {
		return $"{x}/{y}";
	}
}
