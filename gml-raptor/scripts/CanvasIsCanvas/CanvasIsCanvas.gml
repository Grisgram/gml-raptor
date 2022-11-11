function CanvasIsCanvas(_canvas) {
	return (is_struct(_canvas) && instanceof(_canvas) == "Canvas");
}