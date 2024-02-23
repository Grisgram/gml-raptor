/*
	Definition of the CI colors of your software label
*/

#macro CI_GLOBAL_BRIGHT			#DEDEDE
#macro CI_GLOBAL_DARK			#303030
#macro CI_GLOBAL_MAIN			#FAFAFA
#macro CI_GLOBAL_WHITE			#FAFAFA
#macro CI_GLOBAL_BLACK			#070707
#macro CI_GLOBAL_SHADOW			#808080
#macro CI_GLOBAL_ACCENT			#FFD800


#macro CI_COLDROCK_BLUE_LIGHT	#1CDCEA
#macro CI_COLDROCK_BLUE			#004FC5
#macro CI_COLDROCK_BLUE_DARK	#000E5E
#macro CI_COLDROCK_SHADOW		CI_GLOBAL_SHADOW
#macro CI_COLDROCK_ACCENT		#2378FF

#macro CI_INDIE_ALIEN_WHITE		#FAFAFA
#macro CI_INDIE_ALIEN_GREY		#B4B4B4
#macro CI_INDIE_SHADOW			#525252
#macro CI_INDIE_VIOLET			#4B4BA5
#macro CI_INDIE_ACCENT			#7B7BD5

#macro CI_MBAR_ORANGE_BRIGHT	#FFC77F
#macro CI_MBAR_ORANGE_MEDIUM	#FFB145
#macro CI_MBAR_SHADOW			#B77D33
#macro CI_MBAR_ORANGE_DARK		#CC8C39
#macro CI_MBAR_ACCENT			CI_MBAR_ORANGE_BRIGHT

#macro APP_THEME_MAIN			global.__ci_theme_main
#macro APP_THEME_BRIGHT			global.__ci_theme_bright
#macro APP_THEME_DARK			global.__ci_theme_dark
#macro APP_THEME_SHADOW			global.__ci_theme_shadow
#macro APP_THEME_ACCENT			global.__ci_theme_accent
#macro APP_THEME_WHITE			global.__ci_theme_white
#macro APP_THEME_BLACK			global.__ci_theme_black

// ci-colors // theming
enum ci_theme {
	none, mbar, indie, coldrock
}

/// @function				set_app_theme(theme)
/// @description			use enum ci_theme for parameter!
/// @param {enum ci_theme} 	theme
function set_app_theme(theme = ci_theme.none) {
	SCRIBBLE_COLORS.ci_white	= CI_GLOBAL_WHITE;
	SCRIBBLE_COLORS.ci_black	= CI_GLOBAL_BLACK;
	SCRIBBLE_COLORS.ci_main		= CI_GLOBAL_MAIN;
	SCRIBBLE_COLORS.ci_bright	= CI_GLOBAL_BRIGHT;
	SCRIBBLE_COLORS.ci_dark		= CI_GLOBAL_DARK;
	SCRIBBLE_COLORS.ci_shadow	= CI_GLOBAL_SHADOW;
	SCRIBBLE_COLORS.ci_accent	= CI_GLOBAL_ACCENT;
	
	switch (theme) {
		case ci_theme.none:
			break;
		case ci_theme.mbar:
			SCRIBBLE_COLORS.ci_main	  = CI_MBAR_ORANGE_MEDIUM;
			SCRIBBLE_COLORS.ci_bright = CI_MBAR_ORANGE_BRIGHT;
			SCRIBBLE_COLORS.ci_dark   = CI_MBAR_ORANGE_DARK;
			SCRIBBLE_COLORS.ci_shadow = CI_MBAR_SHADOW;
			SCRIBBLE_COLORS.ci_accent = CI_MBAR_ACCENT;
			break;					 
		case ci_theme.indie:		 
			SCRIBBLE_COLORS.ci_main	  = CI_GLOBAL_ACCENT;
			SCRIBBLE_COLORS.ci_bright = CI_INDIE_ALIEN_WHITE;
			SCRIBBLE_COLORS.ci_dark   = CI_INDIE_ALIEN_GREY;
			SCRIBBLE_COLORS.ci_shadow = CI_INDIE_SHADOW;
			SCRIBBLE_COLORS.ci_accent = CI_INDIE_ACCENT;
			break;					 
		case ci_theme.coldrock:		 
			SCRIBBLE_COLORS.ci_main	  = CI_COLDROCK_BLUE;
			SCRIBBLE_COLORS.ci_bright = CI_COLDROCK_BLUE_LIGHT;
			SCRIBBLE_COLORS.ci_dark   = CI_COLDROCK_BLUE_DARK;
			SCRIBBLE_COLORS.ci_shadow = CI_COLDROCK_SHADOW;
			SCRIBBLE_COLORS.ci_accent = CI_COLDROCK_ACCENT;
			break;
	}
	
	__copy_scribble_colors_to_app_theme();	
}

/// @function set_app_theme_custom(_white, _black, _main, _bright, _dark, _shadow, _accent)
function set_app_theme_custom(_white, _black, _main, _bright, _dark, _shadow, _accent) {
	
	SCRIBBLE_COLORS.ci_white	= _white;
	SCRIBBLE_COLORS.ci_black	= _black;
	SCRIBBLE_COLORS.ci_bright	= _main;
	SCRIBBLE_COLORS.ci_main		= _bright;
	SCRIBBLE_COLORS.ci_dark		= _dark;
	SCRIBBLE_COLORS.ci_shadow	= _shadow;
	SCRIBBLE_COLORS.ci_accent	= _accent;
	
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
	
	BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_APPTHEME_CHANGED);
}