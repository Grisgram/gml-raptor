/*
	Message Broadcasting subsystem.
	Part of gml-raptor.
	
	This subsystem consists of three classes:
	- The "Sender": This is your main object.
					The Sender is kind of a radio-station, 
					sending out broadcasts to all listening receivers.
					Just create a new Sender() and add receivers to it.
					NOTE: gml-raptor creates one Sender per Room in the ROOMCONTROLLER
					object. You can use it by adding receivers to ROOMCONTROLLER.Sender
					
	- The "Receiver":	Create a new Receiver(...) and add it to any sender so it can receive
						Broadcast messages that match its message_filter (See Receiver for details).
						
	- The "Broadcast":	This is the message object to be broadcasted. It contains three members:
						"from" - the sender of the broadcast
						"title" - the name of the broadcast (this one must pass the message_filter
									of a receiver)
						"data" - optional struct that holds any additional data for this broadcast.
						
	How to use the subsystem:
	If you want to send something, just create a new Broadcast(...) and call Sender.send(broadcast).
	
	Here is a small example:
	var snd = new Sender();
	var rcv = new Receiver("achievement_counter", "*_died", my_achievement_counter_function);
	snd.add_receiver(rcv);
	
	... when a monster dies you could invoke
	snd.send(new Broadcast(self, "dragon_died"));
	
	HINT: To avoid creating "new Broadcast"s for every message, you can prepare them and store them
	in instance variables for a object or even globally and then you can reuse broadcasts.
	Just take care, that you adapt the data{} struct if necessary before sending.
	
	You may return "true" from your callback function if it shall be removed from the queue after
	processing the callback. This is a comfortable way to take a receiver out, when its work is done.
	
*/

function Sender() constructor {
	
	receivers = [];
	removers = [];
	
	__in_send = false;

	/// @function		add_receiver(_receiver)
	/// @description	adds a listener for a specific kind of message.
	///					NOTE: If a receiver with that name already exists, it gets overwritten!
	///					The _message_filter is a wildcard string, that may
	///					contain "*" as placeholder either at the start of the string,
	///					at the end, or both, but not in-between.
	///					VALID FILTERS are:
	///					*_died
	///					enemy*
	///					*dragon*
	///					INVALID FILTERS are all that contain * in the middle, like
	///					enemy_*_died
	///					So, plan your broadcast names accordingly to be able to filter
	///					as you need!
	static add_receiver = function(_receiver) {
		remove_receiver(_receiver.name);
		array_push(receivers, _receiver);
	}

	/// @function		remove_receiver(_name)
	/// @description	Removes the listener with the specified name and returns true, if found.
	///					If it does not exist, it is silently ignored, but false is returned.
	static remove_receiver = function(_name) {
		for (var i = 0, len = array_length(receivers); i < len; i++) {
			var r = receivers[@ i];
			if (r.name == _name) {
				if (__in_send) // we do not modify the array during send, so we buffer the remove.
					array_push(removers, r.name);
				else
					array_delete(receivers, i, 1);
				return true;
			}
		}
		return false;
	}

	/// @function		send(_broadcast)
	/// @description	Sends a broadcast and returns self for call chaining if you want to
	///					send multiple broadcasts.
	static send = function(_broadcast) {
		__in_send = true;
		removers = [];
		for (var i = 0, len = array_length(receivers); i < len; i++) {
			var r = receivers[@ i];
			if (string_match(_broadcast.title, r.message_filter)) {
				if (r.callback(_broadcast))
					array_push(removers, r.name);
			}
		}
		__in_send = false;
		for (var i = 0, len = array_length(removers); i < len; i++) {
			remove_receiver(removers[@ i]);
		}
		return self;
	}
	
	/// @function		clear()
	/// @description	Removes all receivers.	
	static clear = function() {
		receivers = [];
	}

}

/*
    A receiver for broadcast messages sent through a Sender.
	
	The callback will receive 1 parameter: The Broadcast message,
	containing "from", "title" and (optional) "data" members.
*/

function Receiver(_name, _message_filter, _callback) constructor {
	name			= _name;
	message_filter	= _message_filter;
	callback		= _callback;
}

/// @function		Broadcast(_from, _title, _data = undefined)
/// @description	Contains a broadcast message with at least a "from" and a "title".
function Broadcast(_from, _title, _data = undefined) constructor {
	from	= _from;
	title	= _title;
	data	= _data;
}