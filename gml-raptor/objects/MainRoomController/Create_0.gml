/// @description onTransitFinished override
event_inherited();

onTransitFinished = function() {
}

// Invoked, when you start loading a game in a different room
// and when this room is the target room of the savegame.
// If something goes wrong during load and object restore,
// this function is invoked.
// The exception has already been written to the error log.
onGameLoadFailed = function(_exception) {
	elog($"**ERROR** Game load failed: {_exception.message}");
}

UI_ROOT
	.add_control(ListBox, {
		startup_width: 400,
		list_style: listbox_style.listview,
		items: ["1:Bissi","0:A kleines bissi mehr","2:C","3:D","4:Echt vui text is do drin","5:Fulminant","6:Ganz großes Kino","7:Heiho-Heiho","8:Ich bin vergnügt und froh","9:J","10:K","11:L","12:M","13:N","14:O","15:P"]
	})
	.set_dock(dock.left);