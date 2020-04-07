package clay.render;

class RenderStats {

	public var totalObjects:Int = 0;
	public var visibleObjects:Int = 0;
	public var lockedObjects:Int = 0;
	public var geometry:Int = 0;
	public var vertices:Int = 0;
	public var indices:Int = 0;
	public var drawCalls:Int = 0;

	public function new() {}

	public function reset() {
		totalObjects = 0;
		visibleObjects = 0;
		lockedObjects = 0;
		geometry = 0;
		vertices = 0;
		indices = 0;
		drawCalls = 0;
	}

	public function add(stats:RenderStats) {
		totalObjects += stats.totalObjects;
		visibleObjects += stats.visibleObjects;
		lockedObjects += stats.lockedObjects;
		geometry += stats.geometry;
		vertices += stats.vertices;
		indices += stats.indices;
		drawCalls += stats.drawCalls;
	}
	
}