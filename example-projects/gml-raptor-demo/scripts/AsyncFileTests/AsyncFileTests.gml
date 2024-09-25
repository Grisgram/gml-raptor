/*
    short description here
*/
function load_testfile_async() {
	
	file_read_text_file_async("locale/locale_de.json", FILE_CRYPT_KEY)
	.on_finished(function(str) {
		ilog($"<FILETEST>--- In final STRING callback with {string_length(str)} ");
	})
	.start();

	file_read_text_file_lines_async("locale/locale_de.json", FILE_CRYPT_KEY)
	.on_finished(function(arr) {
		ilog($"<FILETEST>--- In final ARRAY callback with {array_length(arr)} ");
	})
	.start();


}
