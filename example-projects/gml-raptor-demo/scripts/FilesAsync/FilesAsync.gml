
function file_read_async(_filename, _crypt_key = "", _data = undefined) { 
	return new __FileAsyncWorker(__raptor_file_access_mode.read, _filename, _crypt_key, _data)
	.__raptor_finished(function(buffer, data) {
		ilog($"--- LOADED {buffer_get_size(buffer)} bytes!");
		return true;
	});
}
		 
function file_write_async(_filename, _crypt_key = "", _data = undefined) {
	return new __FileAsyncWorker(__raptor_file_access_mode.write, _filename, _crypt_key, _data);
}

		 