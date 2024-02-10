/// @description 

var w = (startup_width  >= 0 ? startup_width  : sprite_width);
var h = (startup_height >= 0 ? startup_height : sprite_height);
sprite_index = if_null(sprite_to_use, sprite_index);
scale_sprite_to(w, h);

// Inherit the parent event
event_inherited();

__apply_autosize_alignment = function() {
}

__apply_post_positioning = function() {
}
