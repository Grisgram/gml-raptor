/*
    A classic ringbuffer with high performance, a fixed size, 
	array oriented with an internal cursor item, no shifting and reordering.
*/

function RingBuffer(_size, _default = undefined) constructor {

	max_size = _size;
	buf = array_create(_size, _default);
	next = 0;
	used_size = 0;
	have_overflow = false;
	
	/// @function length()
	static length = function() {
		return have_overflow ? max_size : next;
	}

	/// @function buffer_index_of(_entry_index)
	static buffer_index_of = function(_entry_index) {
		return have_overflow ? (next + _entry_index) % max_size : _entry_index;
	}
	
	/// @function get(_index)
	static get = function(_index) {
		if (used_size > 0) {
			var i = buffer_index_of(_index);
			return i < used_size ? buf[@i] : undefined;	
		}
		return undefined;
	}
	
	/// @function add(_item)
	static add = function(_item) {
		buf[@next++] = _item;
		if (used_size < max_size)
			used_size++;
		if (next == max_size) {
			next = 0;
			have_overflow = true;
		}
	}

	/// @function add_range(_array)
	static add_range = function(_array) {
		for (var i = 0, len = array_length(_array); i < len; i++) {
			add(_array[@i]);
		}
	}

	/// @function snapshot(_array = undefined)
	/// @description Supply an existing array to avoid new memory allocation
	static snapshot = function(_array = undefined) {
		var needed_size = length();
		var rv = 
			(_array != undefined && array_length(_array) >= needed_size) ? _array : 
			array_create(needed_size);
		for (var i = 0; i < used_size; i++)
			rv[@i] = buf[@buffer_index_of(i)];
		return rv;
	}
	
	/// @function contains(_item)
	static contains = function(_item) {
		return array_contains(buf, _item);
	}
}