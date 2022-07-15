/*
    This script holds all macros to define behavior and optics of
	the MessageBox system.
	You can change used sprites, window classes and other settings to match
	the theme of your game without modifying raptor base code.
*/

// This layer is used for all message boxes.
// Leave this macro here even if you don't use messageboxes, otherwise you get a compile error
#macro MESSAGEBOX_LAYER				"popup_instances"

// Asset name of the Window object to use for Messageboxes
#macro MESSAGEBOX_WINDOW			MessageBoxWindow
#macro MESSAGEBOX_BUTTON			TextButton

// The sprite to use to the X-Button on a messagebox - ORIGIN ALIGN MIDDLE-RIGHT!
#macro MESSAGEBOX_XBUTTON_SPRITE	sprDefaultXButton
// MessageBox colors
#macro MESSAGEBOX_WINDOW_BLEND		APP_THEME_BRIGHT
#macro MESSAGEBOX_TITLE_BLEND		APP_THEME_BRIGHT
#macro MESSAGEBOX_TEXT_BLEND		APP_THEME_BRIGHT
