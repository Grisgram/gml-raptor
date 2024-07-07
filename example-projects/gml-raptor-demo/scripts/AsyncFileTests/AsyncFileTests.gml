/*
    short description here
*/
function load_testfile_async() {
	
	file_read_async("locale/locale_de.json", FILE_CRYPT_KEY, { testdata: 42 })
	.on_finished(function(buffer, data) {
		ilog($"In final callback with {buffer_get_size(buffer)} and testdata {data}.");
	})
	.start();
	
}