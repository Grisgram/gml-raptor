/*
    This script holds all macros to define behavior and optics of
	the MessageBox system.
	You can change used sprites, window classes and other settings to match
	the theme of your game without modifying raptor base code.
*/

// This layer is used for all message boxes.
// Leave this macro here even if you don't use messageboxes, otherwise you get a compile error
#macro MESSAGEBOX_LAYER					"MessageBox"

// Asset name of the Window object to use for Messageboxes
#macro MESSAGEBOX_WINDOW				MessageBoxWindow
#macro MESSAGEBOX_BUTTON				TextButton

// The sprite to use to the X-Button on a messagebox - ORIGIN ALIGN MIDDLE-RIGHT!
#macro MESSAGEBOX_XBUTTON_SPRITE		sprDefaultXButton
#macro MESSAGEBOX_XBUTTON_CLICK_SOUND	undefined
#macro MESSAGEBOX_XBUTTON_ENTER_SOUND	undefined
#macro MESSAGEBOX_XBUTTON_LEAVE_SOUND	undefined

// MessageBox colors
#macro MESSAGEBOX_WINDOW_BLEND			APP_THEME_WHITE
#macro MESSAGEBOX_TITLE_BLEND			APP_THEME_WHITE
#macro MESSAGEBOX_TEXT_BLEND			APP_THEME_WHITE

#macro MESSAGEBOX_BUTTON_TEXT_COLOR		APP_THEME_WHITE
#macro MESSAGEBOX_BUTTON_TEXT_MOUSEOVER	APP_THEME_BRIGHT
#macro MESSAGEBOX_BUTTON_DRAW_COLOR		APP_THEME_WHITE
#macro MESSAGEBOX_BUTTON_DRAW_MOUSEOVER APP_THEME_WHITE
