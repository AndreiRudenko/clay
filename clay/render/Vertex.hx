package clay.render;

import clay.math.Vector;
import clay.utils.Color;

class Vertex {

	public var pos:Vector;
	public var tcoord:Vector;
	public var color:Color;

	public function new(?pos:Vector, ?color:Color, ?tcoord:Vector) {
		this.pos = pos == null ? new Vector() : pos;
		this.color = color == null ? new Color() : color;
		this.tcoord = tcoord == null ? new Vector() : tcoord;
	}
	
}