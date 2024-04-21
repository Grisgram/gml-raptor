/// @description panel pooling
event_inherited();

listbox = undefined;
myscrollbar = undefined;

attach_to = function(_listbox) {
	listbox = _listbox;
	if (listbox != undefined) {
		depth = listbox.depth - 1;
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
			.set_scale_distance(0, textdims.y * len)
			.add_finished_trigger(function(adata) {
				__fill_list(adata._len, adata._dims);
			}
		);
		//scale_sprite_to(listbox.sprite_width, textdims.y * len);

	} else
		binder.unbind_all();
}

__fill_list = function(len, textdims) {		
	if (len > listbox.max_items_shown) {
		control_tree
			.add_control(Scrollbar, {
				orientation_horizontal: false,
				min_value: 0,
				max_value: max(1, len - listbox.max_items_shown)
			})
			.set_dock(dock.right)
			.set_name("scrollbar");
				
		myscrollbar = control_tree.get_element("scrollbar");
	}
		
	if (listbox.sorting == listbox_sort.ascending)
		array_sort(listbox.items, function(item1, item2) {
			return item1.displaymember < item2.displaymember ? -1 : 1;
		});
	else if (listbox.sorting == listbox_sort.descending)
		array_sort(listbox.items, function(item1, item2) {
			return item1.displaymember > item2.displaymember ? -1 : 1;
		});
	
	var me = self;
	for (var i = 0; i < len; i++) {
		var item = listbox.items[@i];
		item.index = i;
		control_tree
			.add_control(listbox.list_item_object, {
				font_to_use: listbox.font_to_use,
				text: LG_resolve(item.displaymember),
				panel: me,
				itemdata: item,
				startup_height: textdims.y,
				text_xoffset: 2
			})
			.set_dock(dock.top)
		;
	}

	control_tree.build();
}

close = function() {
	instance_destroy(self);
}