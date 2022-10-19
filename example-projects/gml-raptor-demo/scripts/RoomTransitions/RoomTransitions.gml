/*
    Contains transition classes that transfer from one room to another.
	There is a base class __RoomTransition common for all transitions.
	They are executed (depending on type of transition) in either one of the
	step events or in one of the draw events of the ROOMCONTROLLER.
	
	Transitions always have 2 parts: an "_out" part (ending the current room)
	and an "_in" part (showing the new room).
	Both parts are controlled by the ROOMCONTROLLER.
	The _out part is handled by the current ROOMCONTROLLER and the _in part
	from the new ROOMCONTROLLER in the next room.
*/


function __RoomTransition(_target_room, _need_fx_layer) constructor {
	
	target_room		= _target_room;
	need_fx_layer	= _need_fx_layer;
	
	in_step			= EMPTY_FUNC;
	in_draw			= EMPTY_FUNC;
	in_draw_gui		= EMPTY_FUNC;
	
	out_step		= EMPTY_FUNC;
	out_draw		= EMPTY_FUNC;
	out_draw_gui	= EMPTY_FUNC;

	fx				= undefined;
	frame_counter	= 0;

	static __create_fx_layer = function() {
		fx_layer = (need_fx_layer ? layer_create(ROOMCONTROLLER.depth + 1) : undefined);
		if (fx_layer != undefined && fx != undefined)
			layer_set_fx(fx_layer, fx);
	}

	static __destroy_fx_layer = function() {
		if (fx_layer != undefined)
			layer_destroy(fx_layer);
	}

	/// @function		do_transit()
	/// @description	Perform transit to next room
	static do_transit = function() {
		log(sprintf("Out-Animation finished for transit to '{0}'", room_get_name(target_room)));
		__ACTIVE_TRANSITION_STEP = 1;
		frame_counter = 0;
		__destroy_fx_layer();
		if (target_room != room)
			room_goto(target_room);
	}

	/// @function		transit_finished()
	/// @description	Call this, when transit is done
	static transit_finished = function() {
		log(sprintf("Transit to '{0}' finished", room_get_name(target_room)));
		__ACTIVE_TRANSITION		 = undefined;
		__ACTIVE_TRANSITION_STEP = -1;
		TRANSITION_RUNNING = false;
		__destroy_fx_layer();
	}

	/// @function		get_app_canvas()
	/// @description	Copy the app surface to a canvas
	static get_app_canvas = function() {
		var rv = new Canvas(VIEW_WIDTH, VIEW_HEIGHT);
		rv.Start();
		rv.CopySurface(application_surface, 0, 0);
		rv.Finish();
		return rv;
	}

	__create_fx_layer();
}

function FadeTransition(_target_room, _fade_out_frames, _fade_in_frames) : __RoomTransition(_target_room, true) constructor {
		
	fx = fx_create("_filter_tintfilter");
	layer_set_fx(fx_layer, fx);

	fade_out_frames = _fade_out_frames;
	fade_in_frames  = _fade_in_frames;
	
	running = 1;
	
	in_step = function() {
		running = clamp((frame_counter / fade_in_frames), 0, 1);
		fx_set_parameter(fx, "g_TintCol", [running, running, running, 1]);
		if (frame_counter >= fade_in_frames) {
			transit_finished();
		}
	}
	
	out_step = function() {
		running = clamp(1 - (frame_counter / fade_out_frames), 0, 1);
		fx_set_parameter(fx, "g_TintCol", [running, running, running, 1]);
		if (frame_counter >= fade_out_frames) {
			running = 0;
			do_transit();
		}
	}
	
	out_step();
}

function PixelateTransition(_target_room, _fade_out_frames, _fade_in_frames, _max_pixelation) : __RoomTransition(_target_room, true) constructor {
	fx = fx_create("_filter_pixelate");
	layer_set_fx(fx_layer, fx);

	fade_out_frames = _fade_out_frames;
	fade_in_frames  = _fade_in_frames;
	max_pixelation  = _max_pixelation;
	
	running = 1;
	
	in_step = function() {
		running = clamp(1 - (frame_counter / fade_in_frames), 0, 1);
		fx_set_parameter(fx, "g_CellSize", max_pixelation * running);
		if (frame_counter >= fade_in_frames) {
			transit_finished();
		}
	}
	
	out_step = function() {
		running = clamp((frame_counter / fade_out_frames), 0, 1);
		fx_set_parameter(fx, "g_CellSize", max_pixelation * running);
		if (frame_counter >= fade_out_frames) {
			running = 0;
			do_transit();
		}
	}
	
	out_step();
}

function BlendTransition(_target_room, _blend_frames) : __RoomTransition(_target_room, false) constructor {
	canvas = undefined;
	
	blend_frames = _blend_frames;
	running		 = 1;
	
	in_draw_gui = function() {
		running = clamp(1 - (frame_counter / blend_frames), 0, 1);
		draw_surface_stretched_ext(canvas.GetSurfaceID(), 0, 0, CAM_WIDTH, CAM_HEIGHT, c_white, running);
		if (frame_counter >= blend_frames) {
			canvas.Free();
			transit_finished();
		}
	}
	
	out_draw_gui = function() {
		canvas = get_app_canvas();
		do_transit();
	}
}

function SlideTransition(_target_room, _slide_frames, _animcurve) : __RoomTransition(_target_room, false) constructor {
	source_canvas	= undefined;
	dest_canvas		= undefined;
	
	animcurve		= animcurve_get_ext(_animcurve);
	values			= animcurve.values;
	slide_frames	= _slide_frames;
	running			= 1;
					
	slide_frames	= _slide_frames;
	first_in		= true;
	have_x			= false;
	have_y			= false;
	
	in_draw_gui = function() {
		animcurve.update(frame_counter, slide_frames);
		
		if (first_in) {
			first_in = false;
			dest_canvas = get_app_canvas();
			have_x = variable_struct_exists(values, "x");
			have_y = variable_struct_exists(values, "y");
		}

		var srcx = CAM_WIDTH  * (have_x ? values.x() : 0);
		var srcy = CAM_HEIGHT * (have_y ? values.y() : 0);
		var destx = (have_x ? CAM_WIDTH : 0); // start outside of the view
		var desty = (have_y ? CAM_HEIGHT : 0);

		if (srcx != 0 || srcy != 0) {
			// draw the new surface only if anything has changed (i.e. not in the first frame)
			if (srcx < 0) destx = srcx + CAM_WIDTH; else
			if (srcx > 0) destx = srcx - CAM_WIDTH;
			if (srcy < 0) desty = srcy + CAM_HEIGHT; else
			if (srcy > 0) desty = srcy - CAM_HEIGHT;
		}

		draw_clear_alpha(c_black, 0.0); // in case of an overshoot animation, make sure, the surface is cleared
		draw_surface_stretched_ext(source_canvas.GetSurfaceID(), srcx, srcy, CAM_WIDTH, CAM_HEIGHT, c_white, 1);
		draw_surface_stretched_ext(dest_canvas.GetSurfaceID(), destx, desty, CAM_WIDTH, CAM_HEIGHT, c_white, 1);
		
		if (frame_counter >= slide_frames) {
			source_canvas.Free();
			dest_canvas.Free();
			transit_finished();
		}
	}

	out_draw_gui = function() {
		source_canvas = get_app_canvas();
		do_transit();
	}
	
}