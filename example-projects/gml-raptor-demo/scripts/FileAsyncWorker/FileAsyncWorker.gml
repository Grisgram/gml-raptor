/*
    Loads a file into a buffer async through the GAMECONTROLLER.
	It's a builder pattern and constructed through the file_*_async functions.
	
	A common usage looks like this:
	
	file_read_struct_async("yourfilename", FILE_CRYPT_KEY)
	.on_finished(function(result) { 
		ilog("Loading complete");
	})
	.on_failed(function() {
		ilog("Loading failed");
	});
	
	NOTE:
	The on_failed callback gets invoked ONLY when an exception occurs!
	If the file is not found, on_finished is invoked normally, but the result likely contains undefined.
	
	About the argument in the on_finished callback:
	"result" is, whatever the file contained, a struct, a string, a byte[] or even undefined...
*/

function __FileAsyncWorker(_filename, _crypt_key = "") : DataBuilder() constructor {
	construct(__FileAsyncWorker);

	filename				= _filename;
	crypt_key				= _crypt_key;
	buffer					= undefined;
	raptor_data				= {};
	__started				= false;
	__finished_callbacks	= [];
	__failed_callbacks		= [];
	__raptor_chain			= [];
	__transactional			= false;
	
	/// @func	start()
	/// @desc	Starts the async file operation. You will receive either on_finished or on_failed
	///			when the operation is complete
	start = function() {
	}
	
	__finished = function(_success) {
	}

	/// @func __raptor_data(_property, _value)
	/// @desc Lets you set a property in the raptor_data struct to a value
	///			This raptor_data struct is provided to each __raptor callback
	static __raptor_data = function(_property, _value) {
		raptor_data[$ _property] = _value;
		return self;
	}

	/// @func	set_transaction_mode(_transactional)
	/// @desc	By default false, but if you activate this, the .on_finished and .on_failed
	///			callbacks will NOT be launched automatically, instead, you have to call
	///			.invoke_finished()/.invoke_failed() manually to launch the registered callbacks.
	///			Use this feature in delayed/split file operations that shall not autocomplete.
	static set_transaction_mode = function(_transactional) {
		__transactional = _transactional;
		ilog($"Transaction mode for '{file_get_filename(filename)}' is now {(__transactional ? "ON" : "OFF")}");
		return self;
	}

	/// @func	invoke_finished(_data = undefined)
	/// @desc	NOTE: Works only in transactional mode!
	///			Invokes the finished callbacks now (see set_transaction_mode)
	static invoke_finished = function(_data = undefined) {
		if (__transactional) {
			ilog($"Invoking transactional .on_finished callbacks");
			TRY		__invoke_array(__finished_callbacks, _data);
			CATCH	__invoke_array(__failed_callbacks, _data);
			FINALLY	__cleanup();
			ENDTRY
		} else
			wlog($"** WARNING ** Tried to invoke async finished callbacks, but this worker is not in transactional mode!");

		return self;
	}

	/// @func	invoke_failed()
	/// @desc	NOTE: Works only in transactional mode!
	///			Invokes the failed callbacks now (see set_transaction_mode)
	static invoke_failed = function() {
		if (__transactional) {
			ilog($"Invoking transactional .on_failed callbacks");
			TRY		__invoke_array(__failed_callbacks);
			CATCH 
			FINALLY	__cleanup();
			ENDTRY
		} else
			wlog($"** WARNING ** Tried to invoke async failed callbacks, but this worker is not in transactional mode!");
			
		return self;
	}
	
	/// @func	on_finished(_callback)
	/// @desc	Set the function to be called when the file access finishes successfully.
	///			The callback receives 1 argument: 
	///				result (the raptor_data loaded from file or undefined if nothing could be loaded)
	static on_finished = function(_callback) {
		array_push(__finished_callbacks, _callback);
		return self;
	}

	/// @func	on_failed(_callback)
	/// @desc	Set the function to be called when the file access fails.
	///			The callback receives no arguments
	static on_failed = function(_callback) {
		array_push(__failed_callbacks, _callback);
		return self;
	}

	static __raptor_finished = function(_callback) {
		array_push(__raptor_chain, method(self, _callback));
		return self;
	}
	
	static __raptor_failed = function(_callback) {
		__raptor_failed_callback = method(self, _callback);
		return self;
	}

	static __invoke_array = function(_array, _arg = undefined) {
		if (_arg == undefined)
			for (var i = 0, len = array_length(_array); i < len; i++)
				_array[@i](data);
		else
			for (var i = 0, len = array_length(_array); i < len; i++)
				_array[@i](_arg, data);
	}

	__raptor_finished_callbacks = function() {
		var rv = undefined;
		for (var i = 0, len = array_length(__raptor_chain); i < len; i++) {
			rv = __raptor_chain[@i](rv, buffer, raptor_data);
		}
		return rv;
	}
	
	__raptor_failed_callback = function() {
		TRY
			if (!__transactional)
				__invoke_array(__failed_callbacks);
		CATCH 
		if (!__transactional) __cleanup();
		ENDTRY		
	}

	__cleanup = function() {
		if (buffer != undefined)
			buffer_delete(buffer);
	}

}

function __FileAsyncReader(_filename, _crypt_key = "") :
 		 __FileAsyncWorker(_filename, _crypt_key) constructor {

	start = function() {
		if (__started) return self;
		__started = true;
		
		dlog($"Starting async file read for '{filename}'{(crypt_key == "" ? "" : " (encrypted)")}");
		buffer = buffer_create(0, buffer_grow, 1);
		var _id = buffer_load_async(buffer, filename, 0, -1);
		GAMECONTROLLER.__add_async_file_callback(self, _id, __finished);
		return self;
	}
	
	__finished = function(_success) {
		dlog($"Finished async file read for '{filename}' {(_success ? "successfully" : "with error")}");
		TRY
			var rv = undefined;
			if (_success) { 
				if (crypt_key != "") encrypt_buffer(buffer, crypt_key);
				buffer_seek(buffer, buffer_seek_start, 0);
				rv = __raptor_finished_callbacks();
			} 
			if (!__transactional)
				__invoke_array(__finished_callbacks, rv);
		CATCH 
			__raptor_failed_callback();
		FINALLY
			if (!__transactional) __cleanup();
		ENDTRY
	}

}

function __FileAsyncFailedWorker(_filename, _crypt_key = "") :
 		 __FileAsyncWorker(_filename, _crypt_key) constructor {
	start = function() {
		if (__started) return self;
		__started = true;
		
		__raptor_failed_callback();
		if (!__transactional) __cleanup();
		return self;
	}
	
	run_delayed(GAMESTARTER, 1, start);
}

function __FileAsyncWriter(_filename, _buffer, _crypt_key = "") :
 		 __FileAsyncWorker(_filename, _crypt_key) constructor {

	buffer = _buffer;
	
	start = function() {
		if (__started) return self;
		__started = true;
		
		dlog($"Starting async file write for '{filename}'{(crypt_key == "" ? "" : " (encrypted)")}");
		if (crypt_key != "") encrypt_buffer(buffer, crypt_key);
		var _id = buffer_save_async(buffer, filename, 0, -1);
		GAMECONTROLLER.__add_async_file_callback(self, _id, __finished);
		return self;
	}
	
	__finished = function(_success) {
		dlog($"Finished async file write for '{filename}' {(_success ? "successfully" : "with error")}");
		TRY
			var rv = undefined;
			if (_success)
				rv = __raptor_finished_callbacks();
			if (!__transactional)
				__invoke_array(__finished_callbacks, rv);
		CATCH 
			__raptor_failed_callback();
		FINALLY
			if (!__transactional) __cleanup();
		ENDTRY
	}

}

function __FileAsyncCacheHit(_filename, _cache_data) :
 		 __FileAsyncWorker(_filename, undefined, undefined) constructor {

	cachedata = _cache_data;

	start = function() {
		if (__started) return self;
		__started = true;
		
		vlog($"Cache hit for file '{filename}'");
		TRY
			if (!__transactional)
				__invoke_array(__finished_callbacks, cachedata);
		CATCH 
			__raptor_failed_callback();
		FINALLY
			if (!__transactional) __cleanup();
		ENDTRY
		return self;
	}

	run_delayed(GAMESTARTER, 1, start);
}

function __FileAsyncInstant(_filename, _crypt_key) :
 		 __FileAsyncWorker(_filename, _crypt_key) constructor {
	
	start = function() {
		__started = true;
		return self;
	}
}