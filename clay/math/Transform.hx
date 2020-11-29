package clay.math;

import clay.math.Vector2;
import clay.math.Vector2Callback;
import clay.math.Matrix;
import clay.utils.Math;

class Transform {

	public var parent(default, set):Transform;

	public var local(get, never):Spatial;
	inline function get_local() return _local;

	public var world(get, never):Spatial;
	inline function get_world() return _world;

	public var pos(get, never):Vector2Callback;
	inline function get_pos() return _local.pos;

	public var scale(get, never):Vector2Callback;
	inline function get_scale() return _local.scale;

	public var rotation(get, set):Float;
	inline function get_rotation() return _local.rotation;
	function set_rotation(v:Float):Float {
		setDirty();
		return _local.rotation = v;
	}

	public var origin(default, null):Vector2Callback;

	public var skew(get, never):Vector2Callback;
	inline function get_skew() return _local.skew;

	public var manualUpdate:Bool;
	public var dirty:Bool;

	var _local:Spatial;
	var _world:Spatial;
	var _cleaning:Bool;
	var _cleanHandlers:Array<(t:Transform)->Void>;
	
	public function new() {
		_local = new Spatial();
		_world = new Spatial();
		origin = new Vector2Callback();

		manualUpdate = false;
		dirty = true;
		_cleaning = false;

		_local.pos.listen(setDirtyCallback);
		_local.scale.listen(setDirtyCallback);
		_local.skew.listen(setDirtyCallback);
		origin.listen(setDirtyCallback);
	}

	public function update() {
		updateParent();

		if(dirty && !_cleaning && !manualUpdate) {
			_cleaning = true;

			updateLocalMatrix();
			appendWorldMatrix();

			_world.decompose(false);

			_cleaning = false;
			dirty = false;

			updateListeners();
		}
	}

	public function listen(handler:(t:Transform)->Void) {
		if(_cleanHandlers == null) {
			_cleanHandlers = [];
		}
		_cleanHandlers.push(handler);
	}

	public function unlisten(handler:(t:Transform)->Void) {
		if(_cleanHandlers != null) {
			_cleanHandlers.remove(handler);
			if(_cleanHandlers.length == 0) {
				_cleanHandlers = null;
			}
		}
	}

	inline function updateParent() {
		if(parent != null) {
			parent.update();
		}
	}

	inline function updateLocalMatrix() {
		// _local.matrix.setTransform(pos.x, pos.y, Math.radians(-rotation), scale.x, scale.y, origin.x, origin.y, skew.x, skew.y);
		_local.matrix.identity()
		.translate(pos.x, pos.y)
		.rotate(Math.radians(-rotation))
		.scale(scale.x, scale.y)
		.prependTranslate(-origin.x, -origin.y);
	}

	inline function appendWorldMatrix() {
		if(parent != null) {
			_world.matrix.copyFrom(parent._world.matrix).append(_local.matrix);
		} else {
			_world.matrix.copyFrom(_local.matrix);
		}
	}

	inline function updateListeners() {
		if(_cleanHandlers != null && _cleanHandlers.length > 0) {
			for(handler in _cleanHandlers) {
				handler(this);
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

	function setDirtyCallback(v:Vector2) {
		setDirty();
	}
	
	inline function onParentCleaned(p:Transform) {
		setDirty();
	}

	inline function setDirty() {
		dirty = true;
	}
	
}

class Spatial {

	public var pos:Vector2Callback;
	public var scale:Vector2Callback;
	public var skew:Vector2Callback;
	public var rotation:Float;
	public var matrix:Matrix;
	public var autoDecompose:Bool = false;

	public function new() {
		pos = new Vector2Callback();
		scale = new Vector2Callback(1,1);
		skew = new Vector2Callback();
		rotation = 0;
		matrix = new Matrix();
	}

		//assigns the local values (pos/rotation/scale/skew) according to the matrix
		//when called manually, will make sure it happens using force.
		//if force is false, autoDecompose will apply
	public inline function decompose(force:Bool = true):Spatial {
		if(autoDecompose || force) {
		    var a = matrix.a;
		    var b = matrix.b;
		    var c = matrix.c;
		    var d = matrix.d;

		    var skewX = -Math.atan2(-c, d);
		    var skewY = Math.atan2(b, a);

		    var delta = Math.abs(skewX + skewY);

		    if(delta < Math.EPSILON || Math.abs(Math.TAU - delta) < Math.EPSILON) {
		    	rotation = skewY;
		    	skew.set(0, 0);
		    } else {
		    	rotation = 0;
		    	skew.set(skewX, skewY);
		    }

		    scale.set(Math.sqrt((a * a) + (b * b)), Math.sqrt((c * c) + (d * d)));
		    pos.set(matrix.tx, matrix.ty);
		}
		return this;
	} 

}
