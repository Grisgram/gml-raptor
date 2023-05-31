/// @ignore
/* feather ignore all */
function __CanvasGC() {
	static _i = 0;
	var _size = ds_list_size(refList);
	if (_size == 0) exit;
	_i = _i % _size;
	var _totalTime = get_timer() + 50;
	repeat(_size) {
		if (!weak_ref_alive(refList[| _i][0])) {
			var _contents = refList[| _i][1];
			ds_list_add(GCList, _contents);
			
			ds_list_delete(refList, _i);
			--_size;
			if (_size == 0) exit;
		}
		_i = (_i+1) % _size;
		
		if (get_timer() >= _totalTime) break;
	}
}