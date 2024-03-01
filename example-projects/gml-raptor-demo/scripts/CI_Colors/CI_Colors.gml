/*
	Definition of the CI colors of your software label
*/

#macro CI_GLOBAL_WHITE			#FAFAFA
#macro CI_GLOBAL_BLACK			#070707
#macro CI_GLOBAL_MAIN			#004FC5
#macro CI_GLOBAL_BRIGHT			#96C3FF
#macro CI_GLOBAL_DARK			#001699
#macro CI_GLOBAL_SHADOW			#808080
#macro CI_GLOBAL_ACCENT			#4992FF

#macro APP_THEME_MAIN			global.__ci_theme_main
#macro APP_THEME_BRIGHT			global.__ci_theme_bright
#macro APP_THEME_DARK			global.__ci_theme_dark
#macro APP_THEME_SHADOW			global.__ci_theme_shadow
#macro APP_THEME_ACCENT			global.__ci_theme_accent
#macro APP_THEME_WHITE			global.__ci_theme_white
#macro APP_THEME_BLACK			global.__ci_theme_black

/// @function set_app_theme_custom(_white, _black, _main, _bright, _dark, _shadow, _accent)
function set_app_theme_custom(_white, _black, _main, _bright, _dark, _shadow, _accent) {
	
	SCRIBBLE_COLORS.ci_white	= _white;
	SCRIBBLE_COLORS.ci_black	= _black;
	SCRIBBLE_COLORS.ci_bright	= _bright;
	SCRIBBLE_COLORS.ci_main		= _main;
	SCRIBBLE_COLORS.ci_dark		= _dark;
	SCRIBBLE_COLORS.ci_shadow	= _shadow;
	SCRIBBLE_COLORS.ci_accent	= _accent;
	
	SCRIBBLE_REFRESH;
	__copy_scribble_colors_to_app_theme();	
}

function __copy_scribble_colors_to_app_theme() {
	APP_THEME_WHITE		= SCRIBBLE_COLORS.ci_white;
	APP_THEME_BLACK		= SCRIBBLE_COLORS.ci_black;
	APP_THEME_MAIN		= SCRIBBLE_COLORS.ci_main;
	APP_THEME_BRIGHT	= SCRIBBLE_COLORS.ci_bright;
	APP_THEME_DARK		= SCRIBBLE_COLORS.ci_dark;
	APP_THEME_SHADOW	= SCRIBBLE_COLORS.ci_shadow;
	APP_THEME_ACCENT	= SCRIBBLE_COLORS.ci_accent;
}

// Initialize the default app theme
set_app_theme_custom(
	CI_GLOBAL_WHITE, 
	CI_GLOBAL_BLACK, 
	CI_GLOBAL_MAIN, 
	CI_GLOBAL_BRIGHT, 
	CI_GLOBAL_DARK, 
	CI_GLOBAL_SHADOW, 
	CI_GLOBAL_ACCENT
);
