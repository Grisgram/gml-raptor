/// @description Log remove/destroy

BROADCASTER.remove_owner(self);
animation_abort_all(self);
if (log_create_destroy)
	vlog($"{MY_NAME} removed/destroyed.");
