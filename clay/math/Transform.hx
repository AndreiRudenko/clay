package clay.math;


import clay.math.Vector;
import clay.math.VectorCallback;
import clay.math.Matrix;
import clay.utils.Mathf;
import clay.utils.Log.*;

class Transform {


	public var parent(default, set):Transform;

	public var local(get, never):Spatial;
	public var world(get, never):Spatial;

	public var pos     	(get, never):VectorCallback;
	public var scale   	(get, never):VectorCallback;
	public var rotation	(get, set):Float;
	public var origin   (default, null):VectorCallback;

	public var manual_update:Bool;
	public var dirty:Bool;

	var _local:Spatial;
	var _world:Spatial;
	var _cleaning:Bool;
	var _clean_handlers:Array<(t:Transform)->Void>;
	

	public function new(?options:TransformOptions) {

		_local = new Spatial();
		_world = new Spatial();

		origin = new VectorCallback();
		
		dirty = true;
		manual_update = false;
		_cleaning = false;

		if(options != null) {
			if(options.pos != null) {
				pos.copy_from(options.pos);
			}
			if(options.scale != null) {
				scale.copy_from(options.scale);
			}
			if(options.rotation != null) {
				rotation = options.rotation;
			}
			if(options.manual_update != null) {
				manual_update = options.manual_update;
			}
			if(options.origin != null) {
				origin.copy_from(options.origin);
			}
			if(options.parent != null) {
				parent = options.parent;
			}
		}

		_local.pos.listen(
			function(v) {
				dirty = true;
			}
		);

		_local.scale.listen(
			function(v) {
				dirty = true;
			}
		);

		origin.listen(
			function(v) {
				dirty = true;
			}
		);

	}

	public function update() {
		
		if(parent != null) {
			parent.update();
		}

		if(dirty && !_cleaning && !manual_update) {
			_cleaning = true;

			_local.matrix.identity()
			.translate(pos.x, pos.y)
			.rotate(Mathf.radians(-rotation))
			.scale(scale.x, scale.y)
			.apply(-origin.x, -origin.y);

			if(parent != null) {
				_world.matrix.copy(parent._world.matrix).append(_local.matrix);
			} else {
				_world.matrix.copy(_local.matrix);
			}

			_world.decompose(false);

			_cleaning = false;
			dirty = false;

			if(_clean_handlers != null && _clean_handlers.length > 0) {
				for(handler in _clean_handlers) {
					handler(this);
				}
			}
		}

	}

	public function listen(handler:(t:Transform)->Void) {

		if(_clean_handlers == null) {
			_clean_handlers = [];
		}

		_clean_handlers.push(handler);

	}

	public function unlisten(handler:(t:Transform)->Void) {

		if(_clean_handlers == null) {
			_clean_handlers.remove(handler);
			if(_clean_handlers.length == 0) {
				_clean_handlers = null;
			}
		}

	}

	function set_parent(v:Transform):Transform {

		if(parent != null) {
			parent.unlisten(on_parent_cleaned);
		}

		parent = v;

		if(parent != null) {
			parent.listen(on_parent_cleaned);
		}

		return v;

	}

	inline function get_pos():VectorCallback {

		return _local.pos;

	}

	inline function get_scale():VectorCallback {

		return _local.scale;

	}

	inline function get_rotation():Float {

		return _local.rotation;

	}

	function set_rotation(v:Float):Float {

		dirty = true;

		return _local.rotation = v;

	}

	inline function get_local():Spatial {
		
		return _local;

	}

	function get_world():Spatial {

		// update(); // todo
		
		return _world;

	}

	inline function on_parent_cleaned(p:Transform) {

		dirty = true;

	}


}

class Spatial {


	public var pos:VectorCallback;
	public var scale:VectorCallback;
	public var rotation:Float;

	public var matrix:Matrix;
	public var auto_decompose:Bool = false;


	public function new() {
		
		pos = new VectorCallback();
		scale = new VectorCallback(1,1);
		rotation = 0;
		matrix = new Matrix();

	}

		//assigns the local values (pos/rotation/scale) according to the matrix
		//when called manually, will make sure it happens using force.
		//if force is false, auto_decompose will apply
	public inline function decompose(_force:Bool = true):Spatial {

		if(auto_decompose || _force) {
			matrix.decompose(this);
		}

		return this;

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