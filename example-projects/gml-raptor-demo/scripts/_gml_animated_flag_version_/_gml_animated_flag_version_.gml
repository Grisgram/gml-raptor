#macro GML_ANIMATED_FLAG_VERSION	"1.3.2"
#macro GML_ANIMATED_FLAG_NAME		"gml-animated-flag "
#macro GML_ANIMATED_FLAG_COPYRIGHT	"(c)2022* coldrock.games, @Grisgram (github)"

var cpyrght = (current_year == 2022) ?
	string_replace(GML_ANIMATED_FLAG_COPYRIGHT, "*", "") :
	string_replace(GML_ANIMATED_FLAG_COPYRIGHT, "*", "-" + string(current_year));
show_debug_message(GML_ANIMATED_FLAG_NAME + GML_ANIMATED_FLAG_VERSION + " loaded. " + cpyrght);
