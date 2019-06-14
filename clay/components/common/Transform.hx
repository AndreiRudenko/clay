package clay.components.common;


import clay.math.Vector;
import clay.math.VectorCallback;
import clay.math.Matrix;
import clay.math.Mathf;
import clay.utils.Log.*;

class Transform {


	public var parent(default, set):Transform;

	public var local(get, never):Spatial;
	public var world(get, never):Spatial;

	public var pos     	(get, never):VectorCallback;
	public var scale   	(get, never):VectorCallback;
	public var rotation	(get, set):Float; // todo, tween didn`t work with this
	public var origin   (default, null):VectorCallback;

	public var manual_update:Bool;
	public var dirty:Bool;

	var _local:Spatial;
	var _world:Spatial;
	var _cleaning:Bool;
	

	public function new(?_options:TransformOptions) {

		_local = new Spatial();
		_world = new Spatial();

		origin = new VectorCallback();
		// rotation = 0;
		
		dirty = true;
		manual_update = false;
		_cleaning = false;

		if(_options != null) {
			if(_options.pos != null) {
				pos.copy_from(_options.pos);
			}
			if(_options.scale != null) {
				scale.copy_from(_options.scale);
			}
			if(_options.rotation != null) {
				rotation = _options.rotation;
			}
			if(_options.manual_update != null) {
				manual_update = _options.manual_update;
			}
			if(_options.origin != null) {
				origin.copy_from(_options.origin);
			}
			if(_options.parent != null) {
				parent = _options.parent;
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

	public function update() { // todo: check dirty
		
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
				_world.matrix.copy(parent._world.matrix).multiply(_local.matrix);
			} else {
				_world.matrix.copy(_local.matrix);
			}

	        _world.decompose(false);

			_cleaning = false;
			dirty = false;
		}


	}

	function set_parent(v:Transform):Transform {

		parent = v;

		// if(parent != null) {
		// 	update();
		// }

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

		update(); // todo
		
		return _world;

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