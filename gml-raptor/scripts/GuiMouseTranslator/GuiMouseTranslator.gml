/*
	GuiMouseTranslator
	Watch the mouse, translate from world to ui coordinates and forward
	(redirect) events to the object when the mouse touches them on ui level.
	
	NOTE: You must check if event_redirection_active == true in the mouse events
	of your object! While this is true, the event got redirected from this class.
	If not, it's the native event of GMS (in world coordinates), which is a bug,
	because the object is not at that position when drawn to the ui layer.
*/

/// @function					GuiMouseTranslator()
/// @description				translates mouse coordinates from viewport to gui
///								and forwards click events
function GuiMouseTranslator() constructor {
	gui_mouse_is_over = false;
	gui_last_mouse_is_over = false;
	event_redirection_active = false;

	gui_left_is_down = false;
	gui_middle_is_down = false;
	gui_right_is_down = false;

	gui_last_left_is_down = false;
	gui_last_middle_is_down = false;
	gui_last_right_is_down = false;

	/// @function					update_gui_mouse_over()
	/// @description				check if mouse is over the control and perform enter/leave events accordingly
	static update_gui_mouse_over = function() {
		event_redirection_active = true;
		
		with (other) {
			if (!visible || (layer_exists(layer) && !layer_get_visible(layer))) 
				return;
				
			other.gui_mouse_is_over = point_in_rectangle(
				GUI_MOUSE_X, GUI_MOUSE_Y, 
				SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, 
				SELF_VIEW_RIGHT_EDGE, SELF_VIEW_BOTTOM_EDGE);
			
			if (other.gui_last_mouse_is_over != other.gui_mouse_is_over) {
				
				if (other.gui_mouse_is_over) {
					// make all buttons equal, so no "pressed" event can trigger
					other.gui_left_is_down	 = mouse_check_button(mb_left);
					other.gui_middle_is_down = mouse_check_button(mb_middle);
					other.gui_right_is_down	 = mouse_check_button(mb_right);
					other.gui_last_left_is_down		= other.gui_left_is_down;
					other.gui_last_middle_is_down	= other.gui_middle_is_down;
					other.gui_last_right_is_down	= other.gui_right_is_down;
					event_perform(ev_mouse, ev_mouse_enter) 
				} else 
					event_perform(ev_mouse, ev_mouse_leave);
					
				other.gui_last_mouse_is_over = other.gui_mouse_is_over;
			}
		}
		
		event_redirection_active = false;
	}
	
	/// @function					check_gui_mouse_clicks()
	/// @description				check mouse button states and perform press/release events accordingly
	static check_gui_mouse_clicks = function() {
		event_redirection_active = true;

		with (other) {
			if (!visible || (layer_exists(layer) && !layer_get_visible(layer))) return;
			// check clicks only if mouse is over
			if (other.gui_mouse_is_over) {
				other.gui_left_is_down	 = mouse_check_button(mb_left);
				other.gui_middle_is_down = mouse_check_button(mb_middle);
				other.gui_right_is_down	 = mouse_check_button(mb_right);
		
				if (other.gui_left_is_down != other.gui_last_left_is_down) {
					if (other.gui_left_is_down) 
						event_perform(ev_mouse, ev_left_press); 
					else 
						event_perform(ev_mouse, ev_left_release);
						
					other.gui_last_left_is_down = other.gui_left_is_down;
				}
				
				if (other.gui_middle_is_down != other.gui_last_middle_is_down) {
					if (other.gui_middle_is_down) 
						event_perform(ev_mouse, ev_middle_press); 
					else 
						event_perform(ev_mouse, ev_middle_release);
						
					other.gui_last_middle_is_down = other.gui_middle_is_down;
				}
				
				if (other.gui_right_is_down != other.gui_last_right_is_down) {
					if (other.gui_right_is_down) 
						event_perform(ev_mouse, ev_right_press); 
					else 
						event_perform(ev_mouse, ev_right_release);
						
					other.gui_last_right_is_down = other.gui_right_is_down;
				}
			}
		}
		
		event_redirection_active = false;
	}
	
}

