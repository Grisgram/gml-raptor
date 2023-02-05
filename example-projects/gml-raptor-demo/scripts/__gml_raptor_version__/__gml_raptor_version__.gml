#macro GML_RAPTOR_VERSION	"2.4"
#macro GML_RAPTOR_NAME		"gml-raptor "
#macro GML_RAPTOR_COPYRIGHT	"(c)2022* indievidualgames, @Grisgram (github)"

var cpyrght = (current_year == 2022) ?
	string_replace(GML_RAPTOR_COPYRIGHT, "*", "") :
	string_replace(GML_RAPTOR_COPYRIGHT, "*", "-" + string(current_year));
show_debug_message(GML_RAPTOR_NAME + GML_RAPTOR_VERSION + " loaded. " + cpyrght);
