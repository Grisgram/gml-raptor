/*
    Holds the color values for one single ui theme.
*/

// The default colors of raptor3
#macro CI_GLOBAL_MAIN			#4080FF
#macro CI_GLOBAL_BRIGHT			#60AAFF
#macro CI_GLOBAL_DARK			#3060DD
#macro CI_GLOBAL_ACCENT			#8080FF

#macro CI_GLOBAL_WHITE			#FAFAFA
#macro CI_GLOBAL_BLACK			#070707
#macro CI_GLOBAL_SHADOW			#808080

// Variables to store the active theme
// These MUST be one variable per color! Otherwise, the ui system would not be able
// to use these macros in their color defaults in the variable definitions
#macro APP_THEME_MAIN			global.__ci_theme_main
#macro APP_THEME_BRIGHT			global.__ci_theme_bright
#macro APP_THEME_DARK			global.__ci_theme_dark
#macro APP_THEME_ACCENT			global.__ci_theme_accent

#macro APP_THEME_WHITE			global.__ci_theme_white
#macro APP_THEME_BLACK			global.__ci_theme_black
#macro APP_THEME_SHADOW			global.__ci_theme_shadow

/// @function UiTheme(_name = "default")
/// @description create a new ui theme.
///				 NOTE: If the name already exists, when you add it to the UiThemeManager,
///				 the existing theme will be overwritte by the added theme!
///				 After the constructor ran, the new theme is initialized with raptor's default colors,
///				 and you can use the "set_colors" function to define (main, bright, dark, accent)
///				 and "set_grayscales" to define (white, black, shadow) colors.
///				 But the best way is to derive your own theme from this and just set the colors you wish.
function UiTheme(_name = "default") constructor {
	construct(UiTheme);

	name = _name;
	
	main	= CI_GLOBAL_MAIN;
	bright	= CI_GLOBAL_BRIGHT;
	dark	= CI_GLOBAL_DARK;
	accent	= CI_GLOBAL_ACCENT;

	white	= CI_GLOBAL_WHITE;
	black	= CI_GLOBAL_BLACK;
	shadow	= CI_GLOBAL_SHADOW;

	/// @function set_colors(_main, _bright, _dark, _accent)
	static set_colors = function(_main, _bright, _dark, _accent) {
		main	= _main;
		bright	= _bright;
		dark	= _dark;
		accent	= _accent;
	}
	
	/// @function set_grayscales(_white, _black, _shadow)
	static set_grayscales = function(_white, _black, _shadow) {
		white	= _white;
		black	= _black;
		shadow	= _shadow;
	}

}