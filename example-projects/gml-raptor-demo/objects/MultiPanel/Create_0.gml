/// @description make button array
event_inherited();

var button = function(idx) {
	return {
		text: string(idx),
		autosize: false,
		min_width: 48, min_height: 48, max_width: 48, max_height: 48,
		startup_width: 48,
		startup_height: 48,
		on_left_click: function(s) { ilog($"--- click: {s.text} ---"); },
	};
}

var i = 0;
repeat(64) {
	control_tree.add_control(TextButton, button(i)).set_position(48*(i%8), 48*(int64(i/8)));
	i++;
}
