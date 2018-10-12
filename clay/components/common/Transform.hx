package clay.components.common;


import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Mathf;


class Transform {


	public var parent(default, set):Transform;

	public var local(default, null):Matrix;
	public var world(default, null):Matrix;

	public var pos:Vector;
	public var scale:Vector;
	public var rotation:Float;
	public var origin:Vector;
	
	public var manual_update:Bool = false;


	public function new() {

		pos = new Vector();
		scale = new Vector(1,1);
		origin = new Vector();
		rotation = 0;

		local = new Matrix();
		world = new Matrix();
		
	}

	public function update() { // todo: check dirty

		if(parent != null) {
			parent.update();
		}
		
		if(manual_update) {
			return;
		}
		
		local.identity()
		.translate(pos.x, pos.y)
		.rotate(Mathf.radians(-rotation))
		.scale(scale.x, scale.y)
		.apply(-origin.x, -origin.y);

		if(parent != null) {
			world.copy(parent.world).multiply(local);
		} else {
			world.copy(local);
		}

	}

	function set_parent(v:Transform):Transform {

		parent = v;

		return v;

	}

}