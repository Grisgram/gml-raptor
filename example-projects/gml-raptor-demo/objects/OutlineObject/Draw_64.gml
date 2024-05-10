/// @desc draw outline if mouse is over
event_inherited();

if (sprite_index == -1 || !draw_on_gui) exit;
__draw();
