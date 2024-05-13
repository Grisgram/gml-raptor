/*
	How to use this file
	--------------------
	
	The Browser click extension needs a script to be called when the user clicks in the browser.
	This script allows us to open links in a new tab, without triggering the popup warning of the browser.
	
	Normally, you implement this with a loop like this.
	("LinkButton" is a template name of an object that you want to open an url in a new tab.)

	with (LinkButton) {
		if (visible && position_meeting(mouse_x, mouse_y, id)) {
			url_open_ext(url, "_blank");
			return;
		}
	}

	NOTE
	-------------------
	Code in this function has no effect, if running any target that is *not* HTML5.
	You do *not* need to put "if..." statements around it to check whether you are running HTML.
	This is covered for you.

	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/


/// @func					open_link_in_new_tab()
/// @desc				Opens the link in the variable browser_click_handler in a new tab
function open_link_in_new_tab() {
	
}

