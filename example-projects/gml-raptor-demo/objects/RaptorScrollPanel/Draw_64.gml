/// @description event
event_inherited();

draw_set_color(c_green);
draw_rectangle(x,y,x+sprite_width-1,y+sprite_height-1,true);

draw_set_color(c_yellow);
with(__panel) draw_rectangle(x,y,x+sprite_width-1,y+sprite_height-1,true);

draw_set_color(c_white);