/// @function					layer_set_all_visible(wildcard, vis)
/// @description				Sets the visible state of all layers where the name matches
///								the specified wildcard.
///								Wildcard character is '*'. It can be at the beginning, the end or both.
function layer_set_all_visible(wildcard, vis) {
	var layers = layer_get_all();
	for (var i = 0; i < array_length(layers); i++) {
		var lid = layers[i];
		var lname = layer_get_name(lid);
		
		if (string_match(lname, wildcard)) {
			layer_set_visible(lid, vis);
			log(sprintf("Setting layer visibility: layer='{0}'; visible={1};", lname, vis));
		}
	}
}