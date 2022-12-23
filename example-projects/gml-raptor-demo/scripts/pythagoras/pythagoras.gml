/*
    A group of functions calculating rectangles.

	The corners (ABC) and sides (abc) and the angles(alpha,beta,gamma) are as follows:
	
	
	
	so, for pythagoras functions, this is always true:
	- c is the hypothenusis
	- gamma is 90°
	
	                          C
	                       ...
	           b      .....gamma
	            .....           \  a
	      .....                  \
	..... alpha              beta \
	-------------------------------
    A             c                 B
	
	you always need 2 sides or 1 side + 1 angle to calculate the missing values
	
*/

function Pythagoras() constructor {
	construct("Pythagoras");
	
	static calculate = function(x1, y1, x2, y2) {
		a		= x2 - x1;
		b		= y2 - y1;
		c		= sqrt(a*a + b*b);
		if (c != 0) {
			alpha	= radtodeg(arcsin(a / c));
			beta	= radtodeg(arcsin(b / c));
			var q = (x2 > x1 ? 
				(y2 < y1 ? 0 : 3) :
				(y2 < y1 ? 1 : 2));
			if (q == 0) angle = -beta;
			else if (q == 1) angle = 180 + beta;
			else if (q == 2) angle = 180 + beta;
			else if (q == 3) angle = 360 - beta;
			gamma = 180 - (alpha + beta);
		} else 
			return clear();
	}

	static clear = function() {
		a		= 0;
		b		= 0;
		c		= 0;
		alpha	= 0;
		beta	= 0;
		gamma	= 0;
		angle	= 0;
		return self;
	}
	
	clear();
}


/// @function		pyth_obj_obj(obj1, obj2, pyth = undefined)
/// @description	Calculate a pythagoras from the positions of two objects
///					If the result contains a negative a, it means the obj2 is LEFT of obj1
///					If the result contains a negative b, it means the obj2 is ABOVE obj1
/// @returns {Pythagoras} Pythagoras struct containing all data of the rectangle
function pyth_obj_obj(obj1, obj2, pyth = undefined) {
	var p = (pyth == undefined ? new Pythagoras() : pyth);
	return p.calculate(obj1.x, obj1.y, obj2.x, obj2.y);
}

/// @function		pyth_obj_mouse(obj, pyth = undefined)
/// @description	Calculate a pythagoras from the positions of an object and the mouse
///					If the result contains a negative a, it means the mouse is LEFT of the object
///					If the result contains a negative b, it means the mouse is ABOVE the object
/// @returns {Pythagoras} Pythagoras struct containing all data of the rectangle
function pyth_obj_mouse(obj, pyth = undefined) {
	var p = (pyth == undefined ? new Pythagoras() : pyth);
	return p.calculate(obj.x, obj.y, mouse_x, mouse_y);
}

/// @function		pyth_xy(x1, y1, x2, y2, pyth = undefined)
/// @description	Calculate a pythagoras from two coordinates
///					If the result contains a negative a, it means x1 is LEFT of x2
///					If the result contains a negative b, it means y1 is ABOVE y2
/// @returns {Pythagoras} Pythagoras struct containing all data of the rectangle
function pyth_xy(x1, y1, x2, y2, pyth = undefined) {
	var p = (pyth == undefined ? new Pythagoras() : pyth);
	return p.calculate(x1, y1, x2, y2);
}
