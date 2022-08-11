/*
    Helper functions for arrays
*/

/// @function		array_clear(array, with_value = undefined)
/// @description	Clear the contents of the array to undefined or a specified default value
/// @param {array} array	The array to clear
/// @returns {array}		Cleaned array (same as input parameter, for chaining)
function array_clear(array, with_value = undefined) {
	var i = 0; repeat(array_length(array)) {
		array[@ i] = with_value;
		i++;
	}
	return array;
}

/// @function		array_shuffle(array)
/// @description	Shuffles the given array, randomizing the position of its items
/// @param {array} array	The array to shuffle
/// @returns {array}		Re-ordered array (same as input parameter, for chaining)
function array_shuffle(array) {
    var len = array_length(array),
        random_index = 0,
        value;

    while(len > 0){
		len--;
        random_index = irandom(len);
        
        value = array[@ len];
        array[len] = array[@ random_index];
        array[@ random_index] = value;
    }

	return array;
}

/// @function		array_contains(array, value)
/// @description	Searches the array for the specified value.
/// @param {array} array	The array to search
/// @param {any} value		The value to find
/// @returns {bool}			True, if value is contained in array, otherwise false
function array_contains(array, value) {
	if (array == undefined)
		return false;
		
	for (var i = 0; i < array_length(array); i++) {
		if (array[@ i] == value)
			return true;
	}
	return false;
}