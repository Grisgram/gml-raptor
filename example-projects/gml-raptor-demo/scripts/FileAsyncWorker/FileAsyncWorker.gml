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

function __FileAsyncWorker(_filename, _crypt_key = "", _data = undefined) constructor {

	filename	= _filename;
	crypt_key	= _crypt_key;
	buffer		= undefined;
	data		= _data;
	
	__binder	= self;


	start = function() {
	}
	
	__finished = function(_success) {
	}

	/// @func on_finished(_callback)
	/// @desc Set the function to be called when the file access finishes successfully.
	///			The callback receives 2 arguments: 
	///				_buffer (the data loaded from file)
	///				_data (the data object you supplied initially)
	static on_finished = function(_callback) {
		__finished_callback = _callback;
		return self;
	}

	/// @func on_failed(_callback)
	/// @desc Set the function to be called when the file access fails.
	///			The callback receives 1 argument: _data (the data object you supplied initially)
	static on_failed = function(_callback) {
		__failed_callback = _callback;
		return self;
	}

	static __raptor_finished = function(_callback) {
		__raptor_finished_callback = _callback;
		return self;
	}
	
	static __raptor_failed = function(_callback) {
		__raptor_failed_callback = _callback;
		return self;
	}

	__raptor_finished_callback = function(_buffer, _data) {
		elog($"** RAPTOR INTERNAL ERROR ** source: file.async.__raptor_finished_callback");
		return false;
	}
	
	__raptor_failed_callback = function(_data) {
		TRY
			invoke_if_exists(self, "__failed_callback", _data);
		CATCH ENDTRY		
	}

	__finished_callback = function(_buffer, _data) {
		elog("** ERROR ** Default on_finished function in place for FileAsyncLoader! You must override this!");
	}

	__failed_callback = function(_data) {
		elog($"** ERROR ** Async load of '{filename}' failed!");
	}

	__cleanup = function() {
		if (buffer != undefined)
			buffer_delete(buffer);
	}

}

function __FileAsyncReader(_filename, _crypt_key = "", _data = undefined) :
 		 __FileAsyncWorker(_filename, _crypt_key, _data) constructor {

	start = function() {
		dlog($"Starting async file read for '{filename}'");
		buffer = buffer_create(0, buffer_grow, 1);
		var _id = buffer_load_async(buffer, filename, 0, -1);
		GAMECONTROLLER.__add_async_file_callback(self, _id, __finished, buffer, data);
		return self;
	}
	
	__finished = function(_success) {
		dlog($"Finished async file read for '{filename}' {(_success ? "successfully" : "with error")}");
		TRY
			if (_success) { 
				if (crypt_key != "") encrypt_buffer(buffer, crypt_key);
				if (__raptor_finished_callback(buffer, data)) {
					invoke_if_exists(self, "__finished_callback", buffer, data);
					return;
				}
			} 
			__raptor_failed_callback(data);
		CATCH 
		FINALLY
			__cleanup();
		ENDTRY
	}

}

function __FileAsyncWriter(_filename, _buffer, _crypt_key = "", _data = undefined) :
 		 __FileAsyncWorker(_filename, _crypt_key, _data) constructor {

	buffer = _buffer;

	start = function() {
		dlog($"Starting async file write for '{filename}'");
		if (crypt_key != "") encrypt_buffer(buffer, crypt_key);
		var _id = buffer_save_async(buffer, filename, 0, -1);
		GAMECONTROLLER.__add_async_file_callback(self, _id, __finished, buffer, data);
		return self;
	}
	
	__finished = function(_success) {
		dlog($"Finished async file write for '{filename}' {(_success ? "successfully" : "with error")}");
		TRY
			if (_success && __raptor_finished_callback(buffer, data))
				invoke_if_exists(self, "__finished_callback", buffer, data);
			else __raptor_failed_callback(data);
		CATCH 
		FINALLY
			__cleanup();
		ENDTRY
	}

}
