/// @function					Coord2(xp, yp)
/// @param {real} xp
/// @param {real} yp
/// @returns {Coord2}
function Coord2(xp = 0, yp = 0) constructor {
	set(xp, yp);
	
	/// @function				set(xp, yp)
	/// @description			set both values in one step
	/// @param {real} xp
	/// @param {real} yp
	static set = function(xp, yp) {
		x = xp;
		y = yp;		
	}
	
	/// @function				mul(factor_x, factor_y)
	/// @description			multiply both values in one step
	/// @param {real} factor_x
	/// @param {real} factor_y
	static mul = function(factor_x, factor_y) {
		x *= factor_x;
		y *= factor_y;
	}
	
	/// @function				mulxy(factor)
	/// @description			multiply both values in one step
	/// @param {real} factor
	static mulxy = function(factor) {
		x *= factor;
		y *= factor;
	}

	/// @function					length_xy()
	/// @description				hypotenuse
	/// @returns {real} length			
	static length_xy = function() { return sqrt(sqr(x) + sqr(y)); }
	
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
	
	static toString = function() {
		return sprintf("{{0}/{1}}", x, y);
	}
}

/// @function					Coord3(xp, yp, zp)
/// @param {real} xp
/// @param {real} yp
/// @param {real} zp
/// @returns {Coord3}
function Coord3(xp, yp, zp) : Coord2(xp, yp) constructor {
	z = zp;
	
	/// @function					length_xyz()
	/// @description				3D-hypotenuse
	/// @returns {real} length			
	static length_xyz = function() { return sqrt(sqr(x) + sqr(y) + sqr(z)); }
	
	/// @function				distance_to_coord3(other_Coord3)
	/// @description			distance between two vectors
	/// @param {Coord3} other_Coord3
	/// @returns {Coord3}	new Coord3
	static distance_to_coord3 = function(other_coord3) {
		return new Coord3(abs(x - other_coord3.x), abs(y - other_coord3.y), abs(z - other_coord3.z));
	}
	
	/// @function				distance_to_xyz(xp, yp, zp)
	/// @description			distance between vector and point in 3D space
	/// @param {real} xp
	/// @param {real} yp
	/// @param {real} zp
	/// @returns {Coord2}	new Coord3
	static distance_to_xyz = function(xp, yp, zp) { 
		return new Coord3(abs(x - xp), abs(y - yp), abs(z - zp));
	}

	/// @function				equals_xyz(other_coord3)
	/// @description			true, if all, x, y and z match	
	/// @returns {bool}			
	static equals_xyz = function(other_coord3) {
		return (x == other_coord3.x) && (y == other_coord3.y) && (z == other_coord3.z);
	}

	static toString = function() {
		return sprintf("{{0}/{1}/{2}}", x, y, z);
	}
}