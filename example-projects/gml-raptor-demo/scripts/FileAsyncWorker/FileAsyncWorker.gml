/*
    Loads a file into a buffer async through the GAMECONTROLLER.
	It's a builder pattern and constructed through the file_*_async functions.
	
	A common usage looks like this:
	
	file_read_struct_async("yourfilename", FILE_CRYPT_KEY, your_data_to_forward_to_callbacks)
	.on_success(function(buffer, data) {
		ilog("Loading complete");
	})
	.on_failed(function(data) {
		ilog("Loading failed");
	})
	.start();
	
*/

enum __raptor_file_access_mode {
	read, write
}

function __FileAsyncWorker(_mode, _filename, _crypt_key, _data = undefined) constructor {

	mode		= _mode;
	filename	= _filename;
	crypt_key	= _crypt_key;
	buffer		= undefined;
	data		= _data;

	static start = function() {
		vlog($"Starting async file {(mode == __raptor_file_access_mode.read ? "read" : "write")} for '{filename}'");
		buffer = buffer_create(0, buffer_grow, 1);
		var _id = mode == __raptor_file_access_mode.read ?
			buffer_load_async(buffer, filename, 0, -1) :
			buffer_save_async(buffer, filename, 0, -1);
		GAMECONTROLLER.add_async_file_callback(_id, __finished, buffer, data);
		return self;
	}
	
	static __finished = function(_success) {
		vlog($"Finished async file {(mode == __raptor_file_access_mode.read ? "read" : "write")} for '{filename}' {(_success ? "successfully" : "with error")}");
		TRY
			if (_success)
				invoke_if_exists(self, "__finished_callback", buffer, data);
			else
				invoke_if_exists(self, "__failed_callback", data);
		CATCH ENDTRY
		if (buffer != undefined)
			buffer_delete(buffer);
	}

	static on_finished = function(_callback) {
		__finished_callback = _callback;
		return self;
	}
	
	static on_failed = function(_callback) {
		__failed_callback = _callback;
		return self;
	}

	__finished_callback = function(_buffer, _data) {
		elog("** ERROR ** Default on_finished function in place for FileAsyncLoader! You must override this!");
	}

	__failed_callback = function(_data) {
		elog($"** ERROR ** Async load of '{filename}' failed!");
	}

}
