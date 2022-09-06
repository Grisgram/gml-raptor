#macro GML_HIGHSCORER_VERSION	"1.3"
#macro GML_HIGHSCORER_NAME		"gml-highscorer "
#macro GML_HIGHSCORER_COPYRIGHT	"(c)2022* indievidualgames, @Grisgram (github)"

var cpyrght = (current_year == 2022) ?
	string_replace(GML_HIGHSCORER_COPYRIGHT, "*", "") :
	string_replace(GML_HIGHSCORER_COPYRIGHT, "*", "-" + string(current_year));
show_debug_message(GML_HIGHSCORER_NAME + GML_HIGHSCORER_VERSION + " loaded. " + cpyrght);
