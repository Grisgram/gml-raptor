/// @description set up typist
event_inherited();

#macro STORY_TELLER_ANIMATIONS		global.__STORY_TELLER_ANIMATIONS
if (!variable_global_exists("__STORY_TELLER_ANIMATIONS"))
	STORY_TELLER_ANIMATIONS = {};

typist_active = false;

__draw_self = function() {
	if (typist_active) {
		scrib.draw(x, y, typist);
		if (animate_only_once && !already_animated() && typist.get_state() == 1) {
			skip_to_end();
		}
	} else if (already_animated())
		scrib.draw(x, y);	
}

skip_to_end = function() {
	typist_active = false;
	STORY_TELLER_ANIMATIONS[$ MY_NAME] = true;
	invoke_completed();
}

already_animated = function() {
	return vsget(STORY_TELLER_ANIMATIONS, MY_NAME, false);
}

invoke_started = function() {
	if (on_typist_started != undefined)
		on_typist_started(self);
}

invoke_completed = function() {
	if (on_typist_completed != undefined)
		on_typist_completed(self);
}

reset_text = function(_text) {
	typist = scribble_typist();
	typist.in(chars_per_frame, smoothness);
	scrib = scribble(LG_resolve(_text), MY_NAME)
		.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, animated_text_color);
	invoke_started();
}

reset_text(text);

if (!already_animated() || !animate_only_once) {
	run_delayed(self, activation_delay, function() { typist_active = true; });
} else
	invoke_completed();