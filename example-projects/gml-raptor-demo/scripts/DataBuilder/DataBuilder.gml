/*
    This is like an abstract base class which provides a "data" variable plus
	a builder-pattern-style set_data method to set any property to a value in the .data
	struct.
*/

/// @function DataBuilder()
function DataBuilder() constructor {
	construct(DataBuilder);
	
	data = {};
	
	/// @func	set_data(_property, _value)
	/// @desc	Lets you set a property in the .data struct to a value.
	///			This method is a convenience function for the builder pattern,
	///			so you can declare your initial data values directly while
	///			building the class
	static set_data = function(_property, _value) {
		data[$ _property] = _value;
		return self;
	}

}

/// @function BindableDataBuilder()
/// @desc Same as a DataBuilder but the data struct is a Bindable()
function BindableDataBuilder() : DataBuilder() constructor {
	construct(BindableDataBuilder);
	
	data = new Bindable(self);
	
	/// @func binder()
	/// @desc Gets the PropertyBinder for the values in the .data struct
	static binder = function() {
		return data.binder();
	}

}