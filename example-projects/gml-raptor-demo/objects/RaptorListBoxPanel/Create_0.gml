/// @description panel pooling
event_inherited();

listbox = undefined;
myscrollbar = undefined;
myitems = [];

current_scroll_index = 0;
max_scroll_index = 0;

attach_to = function(_listbox) {
	listbox = _listbox;
	if (listbox != undefined) {
		depth = listbox.depth - 1;
		draw_on_gui = listbox.draw_on_gui;
		with(listbox) {
			other.x = x;
			other.y = SELF_VIEW_BOTTOM_EDGE + 1;
		}
		binder.bind_pull("x", listbox, "x",,
			function() { control_tree.move_children_after_sizing(true); }
		);
		binder.bind_pull("y", listbox, "y", 
			function(v) { with(listbox) return SELF_VIEW_BOTTOM_EDGE + 1; },
			function() { control_tree.move_children_after_sizing(true); }
		);
		
		var len = array_length(listbox.items);
		var textdims = scribble_measure_text("A", listbox.font_to_use);
		scale_sprite_to(listbox.sprite_width, 1);
		animation_run(self, 0, 6, acLinearScale,,, {_len: len, _dims: textdims})
			.set_scale_distance(0, textdims.y * min(len, listbox.max_items_shown))
			.add_finished_trigger(function(adata) {
				__fill_list(adata._len, adata._dims);
			}
		);
		//scale_sprite_to(listbox.sprite_width, textdims.y * len);

	} else
		binder.unbind_all();
}

__fill_list = function(len, textdims) {
	max_scroll_index = max(0, len - listbox.max_items_shown);
	
	var me = self;
	var myright = SELF_VIEW_RIGHT_EDGE;
	var mygui = draw_on_gui;
	
	if (len > listbox.max_items_shown) {
		control_tree
			.add_control(Scrollbar, {
				orientation_horizontal: false,
				min_value: 0,
				max_value: max(1, max_scroll_index),
				wheel_value_change: listbox.wheel_scroll_lines,
				startup_width: 24,
				draw_on_gui: mygui,
				depth: listbox.depth - 1
			})
			.set_dock(dock.right)
			.set_name("scrollbar");

		myscrollbar = control_tree.get_element("scrollbar");
		myscrollbar.on_value_changed = function(newvalue, oldvalue) {
			scroll_to_index(newvalue);
		};
		//run_delayed(self, 3, function() { myscrollbar.depth = listbox.depth - 1; });
	}
		
	if (listbox.sorting == listbox_sort.ascending)
		array_sort(listbox.items, function(item1, item2) {
			return item1.displaymember < item2.displaymember ? -1 : 1;
		});
	else if (listbox.sorting == listbox_sort.descending)
		array_sort(listbox.items, function(item1, item2) {
			return item1.displaymember > item2.displaymember ? -1 : 1;
		});

	// first, assign a correct index to all itemdata objects of the listbox
	for (var i = 0; i < len; i++) {
		var item = listbox.items[@i];
		item.index = i;
	}
	
	// then render as many as needed
	myitems = [];
	for (var i = 0; i < min(len, listbox.max_items_shown); i++) {
		var item = listbox.items[@i];
		array_push(myitems,
			control_tree
				.add_control(listbox.list_item_object, {
					font_to_use: listbox.font_to_use,
					text: LG_resolve(item.displaymember),
					panel: me,
					itemdata: item,
					startup_width: me.sprite_width,
					startup_height: textdims.y,
					text_xoffset: 2,
					draw_on_gui: mygui
				})
				.set_dock(dock.top)
				.step_out()
				.get_instance()
		);
	}

	control_tree.build();
	scroll_to_index(max(listbox.selected_index, current_scroll_index));
}

close = function() {
	instance_destroy(self);
}

scroll_to_index = function(_idx) {
	current_scroll_index = clamp(max_scroll_index - _idx, 0, max_scroll_index);
	vlog($"{MY_NAME} scrolling to index {current_scroll_index}");
	
	for (var i = 0, len = array_length(myitems); i < len; i++) {
		var lbitem = listbox.items[@ current_scroll_index + i];
		var item = myitems[@i];
		item.assign_data(lbitem);
	}
}

wheel_scroll = function(_direction) {
	if (myscrollbar == undefined || __SLIDER_IN_FOCUS == myscrollbar) return;
	var moveby = listbox.wheel_scroll_lines * _direction;
	myscrollbar.set_value(clamp(myscrollbar.value - moveby, 0, max_scroll_index));
}