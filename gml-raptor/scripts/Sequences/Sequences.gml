/*
	Utility functions to work with sequences.
	
	Sequences are a powerful tool but they lack some QoL features.
	The functions in this script shall help a bit.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

#macro SEQUENCE_CUSTOM_ATTRIBUTES		"indie_attributes"
#macro SEQUENCE_CUSTOM_INSTANCES		"indie_instances"

/// @function							seq_create_with_attributes(sequence, layer, x, y)
/// @description						Create a sequence instance with the specified parameters and return the instance.
///										This function will add the indievidual indie_attributes struct to the instance.
/// @param {objecttype} sequence		The object type to create an instance of
/// @param {layer} layer				The layer on which to create the instance
/// @param {real} x						x-position
/// @param {real} y						y-position
///	@returns {struct}					The instance struct of this sequence.
function seq_create_with_attributes(sequence, layer, x, y) {
	var seq = layer_sequence_create(layer, x, y, sequence);
	var inst = layer_sequence_get_instance(seq);
	inst.name = sequence_get(sequence).name;
	variable_struct_set(inst,SEQUENCE_CUSTOM_ATTRIBUTES,{});
	log(sprintf("Created sequence: sequence='{0}'; elementID={1};", sequence_get(sequence).name, inst.elementID));
	return inst;
}

/// @function						seq_create_for_instance(sequence,objecttype,instance,store_as_name = "")
/// @description					A convenience shortcut function that creates a sequence on the layer and
///									position of the instance and even replaces the specified objecttype in 
///									the sequence with the instance.
///									This function will add the indievidual indie_attributes struct to the instance.
/// @param {objecttype} sequence	The object type to create an instance of
/// @param {objecttype} object		The object type IN the sequence to be replaced
/// @param {instance} instance		The instance to replace it with
/// @param {string=""} store_as_name	(Optional) a custom name to store the instance
///	@returns {struct}				The instance struct of this sequence.
function seq_create_for_instance(sequence,object,instance,store_as_name = "") {
	var inst = seq_create_with_attributes(sequence,instance.layer,instance.x,instance.y);
	with(instance)
		log(sprintf("Replacing instance in sequence: sequence='{0}', instance='{1}'", inst.name, MY_NAME));
	seq_modify_instance(inst,object,instance,store_as_name);
	return inst;
}

/// @function					seq_get_custom_attributes(sequence)
/// @description				Gets the struct of all stored custom attributes from a sequence instance.
/// @param {struct} sequence	The instance of the sequence
/// @returns {struct}			The custom attributes
function seq_get_custom_attributes(sequence) {
	return variable_struct_get(sequence,SEQUENCE_CUSTOM_ATTRIBUTES);
}

/// @function					seq_set_attribute(sequence,name,value)
/// @description				Set the specified custom attribute to the specified value.
/// @param {struct} sequence	The instance of the sequence
/// @param {string} name		The attribute to set
/// @param {any} value			The value to assign
function seq_set_attribute(sequence,name,value) {
	variable_struct_set(seq_get_custom_attributes(sequence),name,value);
}

/// @function					seq_get_attribute(sequence,name)
/// @description				Gets the specified stored custom attributes from a sequence instance.
/// @param {struct} sequence	The instance of the sequence
/// @param {string} name		The attribute to get
/// @returns {any}				The value of the attribute
function seq_get_attribute(sequence,name) {
	return variable_struct_get(seq_get_custom_attributes(sequence),name);
}

/// @function						seq_modify_instance(sequence,object,instance,store_as_name = "")
/// @description					Replaces the object in a sequence with a specified living instance.
/// @param {struct} sequence		The instance of the sequence
/// @param {objecttype} object		The object type IN the sequence to be replaced
/// @param {instance} instance		The instance to replace it with
/// @param {string=""} store_as_name	You may specify an alternative to name this instance in the sequence.
///									By default, the object name is used (=the name of whatever you supplied
///									in the instance parameter).
function seq_modify_instance(sequence,object,instance,store_as_name = "") {
	seq_store_instance(sequence, instance, store_as_name);
	sequence_instance_override_object(sequence,object,instance);
}

/// @function					seq_store_instance(sequence, instance, store_as_name = "")
/// @description				Store any instance in the sequence for later retrieval
/// @param {struct} sequence		The instance of the sequence
/// @param {instance} instance		The instance to store
/// @param {string=""} store_as_name	You may specify an alternative to name this instance in the sequence.
///									By default, the object name is used (=the name of whatever you supplied
///									in the instance parameter).
function seq_store_instance(sequence, instance, store_as_name = "") {
	if (store_as_name == "") store_as_name = object_get_name(instance.object_index);
	vs_set_by_path(sequence, SEQUENCE_CUSTOM_INSTANCES + "/" + store_as_name,instance);
}

/// @function					seq_get_stored_instance(sequence,stored_name)
/// @description				Get a stored instance out of a sequence instance
/// @param {struct} sequence	The instance of the sequence
/// @param {string} stored_name	The name of the instance to retrieve (see seq_modify_instance).
/// @returns {instance}			The instance retrieved.
function seq_get_stored_instance(sequence,stored_name) {
	if (!is_string(stored_name)) stored_name = object_get_name(stored_name.object_index);
	return vs_get_by_path(sequence, SEQUENCE_CUSTOM_INSTANCES + "/" + stored_name);
}

/// @function					seq_get_stored_instances(sequence)
/// @description				Gets the struct of all stored instances from a sequence instance.
/// @param {struct} sequence	The instance of the sequence
/// @returns {struct}			The stored instances
function seq_get_stored_instances(sequence) {
	return variable_struct_get(sequence,SEQUENCE_CUSTOM_INSTANCES);
}

/// @function					seq_destroy(sequence)
/// @description				Shortcut for layer_sequence_destroy(sequence.elementID)
/// @param {struct} sequence	The instance of the sequence to destroy
function seq_destroy(sequence) {
	log(sprintf("Destroying sequence: sequence='{0}'; elementID={1};", sequence.name, sequence.elementID));
	layer_sequence_destroy(sequence.elementID);
}