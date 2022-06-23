/// @description Launch button with hotkey

var btnstruct = undefined;
for (var i = 0; i < array_length(ACTIVE_MESSAGE_BOX.__buttons); i++) {
	if (ACTIVE_MESSAGE_BOX.__buttons[i].hotkey == msgbox_key.escape) {
		btnstruct = ACTIVE_MESSAGE_BOX.__buttons[i];
		break;
	}
}
if (btnstruct != undefined) {
	log("Invoking MessageBox Button callback through hotkey 'escape'.");
	with (btnstruct.__button)
		__msgbox_callback_wrapper();
} else
	log("No MessageBox Button defined for hotkey 'escape' in __buttons array!");
