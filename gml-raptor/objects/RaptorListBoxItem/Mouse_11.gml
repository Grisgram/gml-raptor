/// @description preserve if selected
event_inherited();

if (panel.listbox.get_selected_value() == itemdata.valuemember) {
	__animate_draw_color(draw_color_mouse_over);
	__animate_text_color(text_color_mouse_over);
}
