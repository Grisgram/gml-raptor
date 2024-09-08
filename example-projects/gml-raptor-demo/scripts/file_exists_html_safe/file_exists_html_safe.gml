/// @function	file_exists_html_safe(_filename, _return_code_or_function_for_html = true)
/// @desc		A small cheat to work around malfunctioning file_exists checks on
///				some web providers.
///				This function can't do much to make your life easier, but it will try
///				to open the file for read and try to close it again.
///				According to GameMaker docs, either file_text_open_read(...) returns -1
///				OR file_text_close(...) returns false if the file can't be read.
///				And this is, what this function does, when running HTML.
function file_exists_html_safe(_filename) {
	if (!IS_HTML)
		return file_exists(_filename);
	else {
		var fid = file_text_open_read(_filename);
		return (fid != -1 && !file_text_close(fid)) || fid == -1;
	}
}