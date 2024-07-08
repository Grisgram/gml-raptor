/*
    short description here
*/
function load_testfile_async() {
	
	file_read_async("locale/locale_de.json", FILE_CRYPT_KEY, { testdata: 42 })
	.on_finished(function(buffer, data) {
		var len = buffer_get_size(buffer);
		ilog($"--- In final callback with {len} and testdata {data}.");
		var p = SnapFromJSON(buffer_read(buffer, buffer_string));
		ilog($"--- Text nodes: {struct_get_names(p)}");
		var savebuf = buffer_create(len, buffer_grow, 1);
		buffer_copy(buffer,0,len,savebuf,0);
		file_write_async("locale/locale_de_copy.json", savebuf, FILE_CRYPT_KEY, data)
		.on_finished(function(buf2, data2) {
			ilog($"--- In final SAVE callback with {buffer_get_size(buf2)} and testdata {data2}.");
			return true;
		})
		.start();
	})
	.start();
}

function write_testfile_async() {
	
	file_write_async("testfile.json", FILE_CRYPT_KEY, { testdata: 42 })
	.on_finished(function(buffer, data) {
		ilog($"--- In final callback with {buffer_get_size(buffer)} and testdata {data}.");
		var p = SnapFromJSON(buffer_read(buffer, buffer_string));
		ilog($"--- Text nodes: {struct_get_names(p)}");
	})
	.start();
	
}
