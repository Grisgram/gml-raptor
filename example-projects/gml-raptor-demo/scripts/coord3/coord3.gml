/*
	Holds a 3D Coordinate pair (x,y,z)
*/

/// @function					Coord3(xp, yp, zp)
/// @param {real} xp
/// @param {real} yp
/// @param {real} zp
/// @returns {Coord3}
function Coord3(xp = 0, yp = 0, zp = 0) : Coord2(xp, yp) constructor {
	construct(Coord3);
	
	z = zp;

	/// @function		clone3()
	/// @description	Clones this as Coord3
	static clone3 = function() {
		return new Coord3(x, y, z);
	}

	/// @function				set(xp, yp, zp)
	/// @description			set all values in one step
	/// @param {real} xp
	/// @param {real} yp
	/// @param {real} zp
	/// @returns {Coord3} self for command chaining
	static set = function(xp, yp, zp) {
		x = xp;
		y = yp;
		z = zp;
		return self;
	}

	/// @function				mul(factor_x, factor_y, factor_z)
	/// @description			multiply all values in one step
	/// @param {real} factor_x
	/// @param {real} factor_y
	/// @param {real} factor_z
	/// @returns {Coord3} self for command chaining
	static mul = function(factor_x, factor_y, factor_z) {
		x *= factor_x;
		y *= factor_y;
		z *= factor_z;
		return self;
	}
	
	/// @function				mul_xyz(factor)
	/// @description			multiply all values in one step
	/// @param {real} factor
	/// @returns {Coord3} self for command chaining
	static mul_xyz = function(factor) {
		x *= factor;
		y *= factor;
		z *= factor;
		return self;
	}

	/// @function				add(factor_x, factor_y)
	/// @description			add a value to the current values
	/// @param {real} add_x
	/// @param {real} add_y
	/// @param {real} add_z
	/// @returns {Coord3} self for command chaining
	static add = function(add_x, add_y, add_z) {
		x += add_x;
		y += add_y;
		z += add_z;
		return self;
	}

	/// @function				add_xyz(factor_x, factor_y)
	/// @description			add the same value to the current values
	/// @param {real} value
	/// @returns {Coord3} self for command chaining
	static add_xyz = function(value) {
		x += value;
		y += value;
		z += value;
		return self;
	}

	/// @function				plus(other_coord3)
	/// @description			Add the values of other_coord3 into this one
	/// @param {Coord3} other_coord3
	/// @returns {Coord3} self for command chaining
	static plus = function(other_coord3) {
		x += other_coord3.x;
		y += other_coord3.y;
		z += other_coord3.z;
		return self;
	}
	
	/// @function				minus(other_coord3)
	/// @description			Subtract the values in other_coord3 from this one
	/// @param {Coord3} other_coord3
	/// @returns {Coord3} self for command chaining
	static minus = function(other_coord3) {
		x -= other_coord3.x;
		y -= other_coord3.y;
		z -= other_coord3.z;
		return self;
	}

	/// @function					length_xyz()
	/// @description				3D-hypotenuse
	/// @returns {real} length			
	static length_xyz = function() { return sqrt(sqr(length_xy()) + sqr(z)); }
	
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
	/// @returns {Coord3}	new Coord3
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