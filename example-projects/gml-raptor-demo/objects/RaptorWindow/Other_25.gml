/// @description event
control_tree.layout(true);
event_inherited();

if (__RAPTORDATA.has_focus) {
	take_focus();
	run_delayed(self, 0, function() { __reorder_focus_index(__RAPTORDATA.focus_index); });
}
