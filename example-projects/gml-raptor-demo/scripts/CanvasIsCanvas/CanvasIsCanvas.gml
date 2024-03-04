/// feather ignore all
/// @func CanvasICanvas
/// @param {Any} value
function CanvasIsCanvas(_canvas) {
	return (is_struct(_canvas) && is_instanceof(_canvas, Canvas));
}