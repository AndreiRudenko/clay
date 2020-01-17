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

	public var pos(get, never):VectorCallback;
	public var scale(get, never):VectorCallback;
	public var rotation(get, set):Float;
	public var origin(default, null):VectorCallback;

	public var manualUpdate:Bool;
	public var dirty:Bool;

	var _local:Spatial;
	var _world:Spatial;
	var _cleaning:Bool;
	var _cleanHandlers:Array<(t:Transform)->Void>;
	

	public function new() {

		_local = new Spatial();
		_world = new Spatial();

		origin = new VectorCallback();
		
		dirty = true;
		manualUpdate = false;
		_cleaning = false;

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

		if(dirty && !_cleaning && !manualUpdate) {
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

			if(_cleanHandlers != null && _cleanHandlers.length > 0) {
				for(handler in _cleanHandlers) {
					handler(this);
				}
			}
		}

	}

	public function listen(handler:(t:Transform)->Void) {

		if(_cleanHandlers == null) {
			_cleanHandlers = [];
		}

		_cleanHandlers.push(handler);

	}

	public function unlisten(handler:(t:Transform)->Void) {

		if(_cleanHandlers == null) {
			_cleanHandlers.remove(handler);
			if(_cleanHandlers.length == 0) {
				_cleanHandlers = null;
			}
		}

	}

	function set_parent(v:Transform):Transform {

		if(parent != null) {
			parent.unlisten(onParentCleaned);
		}

		parent = v;

		if(parent != null) {
			parent.listen(onParentCleaned);
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

	inline function get_world():Spatial {
		
		return _world;

	}

	inline function onParentCleaned(p:Transform) {

		dirty = true;

	}


}

class Spatial {


	public var pos:VectorCallback;
	public var scale:VectorCallback;
	public var rotation:Float;

	public var matrix:Matrix;
	public var autoDecompose:Bool = false;


	public function new() {
		
		pos = new VectorCallback();
		scale = new VectorCallback(1,1);
		rotation = 0;
		matrix = new Matrix();

	}

		//assigns the local values (pos/rotation/scale) according to the matrix
		//when called manually, will make sure it happens using force.
		//if force is false, autoDecompose will apply
	public inline function decompose(_force:Bool = true):Spatial {

		if(autoDecompose || _force) {
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
	@:optional var manualUpdate:Bool;
	@:optional var parent:Transform;

}