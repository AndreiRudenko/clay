package clay.render;


class RenderStats {


	public var batched:Int = 0;
	public var geometry:Int = 0;
	public var visible_geometry:Int = 0;
	public var vertices:Int = 0;
	public var indices:Int = 0;
	public var locked:Int = 0;
	public var draw_calls:Int = 0;


	public function new() {}

	public function reset() {

		batched = 0;
		geometry = 0;
		visible_geometry = 0;
		vertices = 0;
		indices = 0;
		locked = 0;
		draw_calls = 0;

	}

	public function add(_stats:RenderStats) {
		
		batched += _stats.batched;
		geometry += _stats.geometry;
		visible_geometry += _stats.visible_geometry;
		vertices += _stats.vertices;
		indices += _stats.indices;
		locked += _stats.locked;
		draw_calls += _stats.draw_calls;

	}
	

}