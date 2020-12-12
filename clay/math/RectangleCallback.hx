package clay.math;

@:structInit
class RectangleCallback extends Rectangle {

	public var ignoreListeners:Bool = false;
	public var listener:(v:Rectangle)->Void;

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		super(x, y, w, h);
	}

	override function set(x:Float, y:Float, w:Float, h:Float) {
		_x = x;
		_y = y;
		_w = w;
		_h = h;
		callListener();
	    return this;
	}

	override function set_x(v:Float):Float {
		super.set_x(v);
		callListener();
		return v;
	}

	override function set_y(v:Float):Float {
		super.set_y(v);
		callListener();
		return v;
	}

	override function set_w(v:Float):Float {
		super.set_w(v);
		callListener();
		return v;
	}

	override function set_h(v:Float):Float {
		super.set_h(v);
		callListener();
		return v;
	}

	public inline function listen(f:(r:Rectangle)->Void):RectangleCallback {
		listener = f;
		return this;
	}

	inline function callListener() {
		if(listener != null && !ignoreListeners) {
			listener(this);
		}
	}

}