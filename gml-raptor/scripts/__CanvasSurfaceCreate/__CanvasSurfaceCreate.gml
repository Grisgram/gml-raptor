///@ignore
/// feather ignore all
function __CanvasSurfaceCreate(_width, _height, _format) {
	static __sys = __CanvasSystem();
	static _func = surface_create;
	if (__sys.supportsFormats) {
		return _func(_width, _height, _format);	
	}
	
	return _func(_width, _height);
}