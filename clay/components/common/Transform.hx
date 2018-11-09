package clay.components.common;


import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Mathf;
import clay.utils.Log.*;

class Transform {


	public var parent(default, set):Transform;

	public var local(default, null):Matrix;
	public var world(default, null):Matrix;

	public var pos:Vector;
	public var origin:Vector;
	public var scale:Vector;
	public var rotation:Float;
	
	public var manual_update:Bool = false;


	public function new(?_options:TransformOptions) {

		if(_options != null) {
			pos = def(_options.pos, new Vector());
			origin = def(_options.origin, new Vector());
			scale = def(_options.scale, new Vector(1,1));
			rotation = def(_options.rotation, 0);
			manual_update = def(_options.manual_update, false);
			if(_options.parent != null) {
				parent = _options.parent;
			}
		} else {
			pos = new Vector();
			origin = new Vector();
			scale = new Vector(1,1);
			rotation = 0;
		}

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


typedef TransformOptions = {

	@:optional var pos:Vector;
	@:optional var scale:Vector;
	@:optional var origin:Vector;
	@:optional var rotation:Float;
	@:optional var manual_update:Bool;
	@:optional var parent:Transform;

}