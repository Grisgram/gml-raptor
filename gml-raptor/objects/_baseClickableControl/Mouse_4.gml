/// @description log event

GUI_EVENT;

log(MY_NAME + ": onLeftDown");
await_click = true;

var elapsed = current_time - double_click_waiter;
if (double_click_waiter == 0 || elapsed > GUI_RUNTIME_CONFIG.mouse_double_click_speed) {
	double_click_waiter = current_time;
	double_click_counter = 1;
} else {
	double_click_counter = 2;
}
