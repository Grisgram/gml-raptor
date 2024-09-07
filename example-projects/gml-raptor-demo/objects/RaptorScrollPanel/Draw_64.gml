/// @description event

draw_set_color(draw_color);
draw_rectangle(x,y,x+sprite_width-1,y+sprite_height-1,false);

event_inherited();

draw_set_color(c_green);
draw_rectangle(x,y,x+sprite_width-1,y+sprite_height-1,true);

draw_set_color(c_yellow);
draw_rectangle(x,y,x+__clipw-1,y+__cliph-1,true);

draw_set_color(c_white);