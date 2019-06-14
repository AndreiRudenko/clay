package clay.math;


class RectangleCallback extends Rectangle {


	public var ignore_listeners:Bool = false;

	@:isVar public var listen_x(default,default):Float -> Void;
	@:isVar public var listen_y(default,default):Float -> Void;
	@:isVar public var listen_w(default,default):Float -> Void;
	@:isVar public var listen_h(default,default):Float -> Void;


	public function new(_x:Float = 0, _y:Float = 0, _w:Float = 0, _h:Float = 0) {
		
		super(_x, _y, _w, _h);

	}

	public function listen(f:Float->Void):RectangleCallback {

		listen_x = f;
		listen_y = f;
		listen_w = f;
		listen_h = f;

		return this;
		
	}

	override function set_x(v:Float):Float {

		super.set_x(v);

		if(listen_x != null && !ignore_listeners) {
			listen_x(v);
		}

		return v;

	}

	override function set_y(v:Float):Float {

		super.set_y(v);

		if(listen_y != null && !ignore_listeners) {
			listen_y(v);
		}

		return v;

	}

	override function set_w(v:Float):Float {

		super.set_w(v);

		if(listen_w != null && !ignore_listeners) {
			listen_w(v);
		}

		return v;

	}

	override function set_h(v:Float):Float {

		super.set_h(v);

		if(listen_h != null && !ignore_listeners) {
			listen_h(v);
		}

		return v;

	}

}