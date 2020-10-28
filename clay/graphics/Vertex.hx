package clay.graphics;

import clay.graphics.Color;

class Vertex {

	public var x:Float;
	public var y:Float;
	public var color:Color;
	public var u:Float;
	public var v:Float;

	public function new(x:Float, y:Float, color:Color = Color.WHITE, u:Float = 0, v:Float = 0) {
		this.x = x;
		this.y = y;
		this.color = color;
		this.u = u;
		this.v = v;
	}
	
}