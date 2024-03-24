/*
	The UiThemeManager holds the colors for one single theme of your game.
	Create as many as you need and activate a theme through the manager by invoking
	"UI_THEME.activate(_theme_name)"
*/

#macro ENSURE_THEMES			if (!variable_global_exists("__ui_themes")) UI_THEMES = new UiThemeManager(); \
								if (UI_THEMES.get_theme(__DEFAULT_UI_THEME_NAME) == undefined) \
									UI_THEMES.add_theme(new DefaultTheme(__DEFAULT_UI_THEME_NAME), true);

#macro UI_THEMES				global.__ui_themes
#macro APP_THEME				UI_THEMES.active_theme

#macro __DEFAULT_UI_THEME_NAME	"default"

/// @function UiThemeManager()
/// @description The global theme manager. Accessible through UI_THEMES
function UiThemeManager() constructor {
	construct(UiThemeManager);
	
	_themes = {
	};
	
	active_theme = undefined;
	
	/// @function add_theme(_theme, _activate_now = false)
	static add_theme = function(_theme, _activate_now = false) {
		var was_active = ((active_theme != undefined) && (active_theme.name == _theme.name));
		_themes[$ _theme.name] = _theme;
		ilog($"UiThemeManager registered theme '{_theme.name}'");
		if (_activate_now || was_active)
			activate_theme(_theme.name);
	}
	
	/// @function refresh_theme()
	/// @description Invoked from RoomController in RoomStart event to transport the
	///				 active theme from room to room
	static refresh_theme = function() {
		if (active_theme != undefined)
			activate_theme(active_theme.name);
	}
	
	/// @function activate_theme(_theme_name)
	static activate_theme = function(_theme_name) {
		var th = vsget(_themes, _theme_name);
		if (th != undefined) {
			active_theme = th;
			__copy_theme_to_global_colors(th);
			__copy_app_theme_to_scribble_colors();
			ilog($"UiThemeManager activated theme '{th.name}'");
		} else {
			elog($"** ERROR ** UiThemeManager could not activate theme '{_theme_name}' (THEME-NOT-FOUND)");
		}
	}
	
	/// @function remove_theme(_theme_name)
	static remove_theme = function(_theme_name) {
		if (_theme_name == __DEFAULT_UI_THEME_NAME) {
			elog($"** ERROR ** UiThemeManager can not remove the '{__DEFAULT_UI_THEME_NAME}' theme!");
			return;
		}
		if (vsget(_themes, _theme_name) != undefined) {
			variable_struct_remove(_themes, _theme_name);
			ilog($"UiThemeManager removed theme '{_theme_name}'");
		}
	}
	
	/// @function get_theme(_theme_name)
	static get_theme = function(_theme_name) {
		return vsget(_themes, _theme_name);
	}
	
	static __copy_theme_to_global_colors = function(_theme) {
		APP_THEME_WHITE		= _theme.white	;
		APP_THEME_BLACK		= _theme.black	;
		APP_THEME_MAIN		= _theme.main	;
		APP_THEME_BRIGHT	= _theme.bright	;
		APP_THEME_DARK		= _theme.dark	;
		APP_THEME_SHADOW	= _theme.shadow	;
		APP_THEME_ACCENT	= _theme.accent	;
	}
	
	static __copy_app_theme_to_scribble_colors = function() {
		SCRIBBLE_COLORS.ci_white	= APP_THEME_WHITE	;
		SCRIBBLE_COLORS.ci_black	= APP_THEME_BLACK	;
		SCRIBBLE_COLORS.ci_main		= APP_THEME_MAIN	;
		SCRIBBLE_COLORS.ci_bright	= APP_THEME_BRIGHT	;
		SCRIBBLE_COLORS.ci_dark		= APP_THEME_DARK	;
		SCRIBBLE_COLORS.ci_shadow	= APP_THEME_SHADOW	;
		SCRIBBLE_COLORS.ci_accent	= APP_THEME_ACCENT	;
		SCRIBBLE_REFRESH;
	}
	
}

ENSURE_LOGGER;
ENSURE_THEMES;
