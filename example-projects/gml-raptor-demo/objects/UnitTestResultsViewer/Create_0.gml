/// @description event
event_inherited();

__lines_per_wheel	= 3;
__line_height		= 12;

last_down_y = -1;
startup_y = y;

/// @func report_log_line(line)
report_log_line = function(line) {
	if (!detail_mode) return;
	if (string_starts_with(line, "<--")) line = $"[ci_accent]{line}[/]";
	if (string_starts_with(line, " OK ")) line = $"[c_green] OK [/]{string_skip_start(line, 4)}";
	if (string_starts_with(line, "FAIL")) line = $"[c_red]FAIL[/]{string_skip_start(line, 4)}";
	
	text += $"{line}\n";
}

/// @func report_suite_line(line)
report_suite_line = function(line) {
	if (detail_mode) return;
	if (string_starts_with(line, "DONE")) {
		line = $"[ci_accent]DONE[/]{string_skip_start(line, 4)}";
		line = string_replace(line, " in '", " in [ci_accent]'") + "[/]";
	}
	text += $"{line}\n";	
}

__first_summary = true;
/// @func report_summary_line(line)
report_summary_line = function(line) {
	if (detail_mode) return;
	if (__first_summary) {
		__first_summary = false;
		text += "\n\n";
	}
	if (string_contains(line, "Unit tests finished")) line = $"\n\n{line}";
	text += $"{line}\n";	
}

mouse_wheel = function(_distance) {
	if (!mouse_is_over) return;
	y = clamp(y + __line_height * __lines_per_wheel * _distance, ROOM_HEIGHT - sprite_height - 40, startup_y);
}

mouse_drag = function() {
	y = clamp(y + MOUSE_DELTA_Y, ROOM_HEIGHT - sprite_height - 40, startup_y);
}