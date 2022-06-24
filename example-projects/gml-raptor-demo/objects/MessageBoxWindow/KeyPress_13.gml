/// @description Launch button with hotkey

var btnstruct = undefined;
for (var i = 0; i < array_length(ACTIVE_MESSAGE_BOX.__buttons); i++) {
	if (ACTIVE_MESSAGE_BOX.__buttons[i].hotkey == msgbox_key.enter) {
		btnstruct = ACTIVE_MESSAGE_BOX.__buttons[i];
		break;
	}
}
if (btnstruct != undefined) {
	log("Invoking MessageBox Button callback through hotkey 'enter'.");
	with (btnstruct.__button)
		__msgbox_callback_wrapper();
} else
	log("No MessageBox Button defined for hotkey 'enter' in __buttons array!");
