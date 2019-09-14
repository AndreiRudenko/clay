package clay.render;


class RenderStats {


	public var geometry:Int = 0;
	public var visibleGeometry:Int = 0;
	public var vertices:Int = 0;
	public var indices:Int = 0;
	public var locked:Int = 0;
	public var drawCalls:Int = 0;


	public function new() {}

	public function reset() {

		geometry = 0;
		visibleGeometry = 0;
		vertices = 0;
		indices = 0;
		locked = 0;
		drawCalls = 0;

	}

	public function add(_stats:RenderStats) {
		
		geometry += _stats.geometry;
		visibleGeometry += _stats.visibleGeometry;
		vertices += _stats.vertices;
		indices += _stats.indices;
		locked += _stats.locked;
		drawCalls += _stats.drawCalls;

	}
	

}