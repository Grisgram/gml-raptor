/*
	Definition of the CI colors of your software label
*/

#macro CI_GLOBAL_WHITE			#FAFAFA
#macro CI_GLOBAL_BLACK			#070707

#macro CI_RISING_RED			#7D0000
#macro CI_RISING_RED_DARK		#390000
#macro CI_RISING_WHITE			#D5D5D5
#macro CI_RISING_BLACK			#040404
#macro CI_RISING_ACCENT			#FFAA00

#macro CI_INDIE_ALIEN_WHITE		#FAFAFA
#macro CI_INDIE_ALIEN_GREY		#B4B4B4
#macro CI_INDIE_SHADOW			#525252
#macro CI_INDIE_VIOLET			#4B4BA5
#macro CI_INDIE_ACCENT			CI_INDIE_VIOLET

#macro CI_MBAR_ORANGE_BRIGHT	#FFC77F
#macro CI_MBAR_ORANGE_MEDIUM	#FFB145
#macro CI_MBAR_SHADOW			#B77D33
#macro CI_MBAR_ORANGE_DARK		#CC8C39
#macro CI_MBAR_ACCENT			CI_MBAR_ORANGE_BRIGHT

#macro APP_THEME_BRIGHT			global.__ci_theme_bright
#macro APP_THEME_DARK			global.__ci_theme_dark
#macro APP_THEME_SHADOW			global.__ci_theme_shadow
#macro APP_THEME_ACCENT			global.__ci_theme_accent
#macro APP_THEME_WHITE			global.__ci_theme_white
#macro APP_THEME_BLACK			global.__ci_theme_black

// ci-colors // theming
enum ci_theme {
	mbar, indie, rising
}

/// @function				set_app_theme(theme)
/// @description			use enum ci_theme for parameter!
/// @param {enum ci_theme} 	theme
function set_app_theme(theme) {
	switch (theme) {
		case ci_theme.mbar:
			SCRIBBLE_COLORS.ci_bright = CI_MBAR_ORANGE_MEDIUM;
			SCRIBBLE_COLORS.ci_dark   = CI_MBAR_ORANGE_DARK;
			SCRIBBLE_COLORS.ci_shadow = CI_MBAR_SHADOW;
			SCRIBBLE_COLORS.ci_accent = CI_MBAR_ACCENT;
			
			APP_THEME_BRIGHT	= CI_MBAR_ORANGE_MEDIUM;
			APP_THEME_DARK		= CI_MBAR_ORANGE_DARK;
			APP_THEME_SHADOW	= CI_MBAR_SHADOW;
			APP_THEME_ACCENT	= CI_MBAR_ACCENT;
			break;					 
		case ci_theme.indie:		 
			SCRIBBLE_COLORS.ci_bright = CI_INDIE_ALIEN_WHITE;
			SCRIBBLE_COLORS.ci_dark   = CI_INDIE_ALIEN_GREY;
			SCRIBBLE_COLORS.ci_shadow = CI_INDIE_SHADOW;
			SCRIBBLE_COLORS.ci_accent = CI_INDIE_ACCENT;

			APP_THEME_BRIGHT	= CI_INDIE_ALIEN_WHITE;
			APP_THEME_DARK		= CI_INDIE_ALIEN_GREY;
			APP_THEME_SHADOW	= CI_INDIE_SHADOW;
			APP_THEME_ACCENT	= CI_INDIE_ACCENT;
			break;					 
		case ci_theme.rising:		 
			SCRIBBLE_COLORS.ci_bright = CI_RISING_RED;
			SCRIBBLE_COLORS.ci_dark   = CI_RISING_RED_DARK;
			SCRIBBLE_COLORS.ci_shadow = CI_RISING_BLACK;
			SCRIBBLE_COLORS.ci_accent = CI_RISING_ACCENT;

			APP_THEME_BRIGHT	= CI_RISING_RED;
			APP_THEME_DARK		= CI_RISING_RED_DARK;
			APP_THEME_SHADOW	= CI_RISING_BLACK;
			APP_THEME_ACCENT	= CI_RISING_ACCENT;
			break;
	}
	SCRIBBLE_COLORS.ci_white = CI_GLOBAL_WHITE;
	SCRIBBLE_COLORS.ci_black = CI_GLOBAL_BLACK;
	
	APP_THEME_WHITE	= CI_GLOBAL_WHITE;
	APP_THEME_BLACK	= CI_GLOBAL_BLACK;
}


