/// @description react on size change

if (__active && (browser_width != curr_width || browser_height != curr_height))
	update_canvas();
