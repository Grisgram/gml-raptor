/// @description pooling
event_inherited();

#macro __RAPTOR_SPRITE_ANIM_POOL		"__raptor_sprite_anims"

onPoolActivate = function() {
	sprite_index = -1;
	image_index = 0;
}

onPoolDeactivate = function() {
	sprite_index = -1;
	image_index = 0;
}
