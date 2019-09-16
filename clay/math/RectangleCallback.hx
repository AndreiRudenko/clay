package clay.math;


class RectangleCallback extends Rectangle {


	public var ignoreListeners:Bool = false;

	@:isVar public var listenX:(v:Float)->Void;
	@:isVar public var listenY:(v:Float)->Void;
	@:isVar public var listenW:(v:Float)->Void;
	@:isVar public var listenH:(v:Float)->Void;


	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		
		super(x, y, w, h);

	}

	public function listen(f:(v:Float)->Void):RectangleCallback {

		listenX = f;
		listenY = f;
		listenW = f;
		listenH = f;

		return this;
		
	}

	override function set_x(v:Float):Float {

		super.set_x(v);

		if(listenX != null && !ignoreListeners) {
			listenX(v);
		}

		return v;

	}

	override function set_y(v:Float):Float {

		super.set_y(v);

		if(listenY != null && !ignoreListeners) {
			listenY(v);
		}

		return v;

	}

	override function set_w(v:Float):Float {

		super.set_w(v);

		if(listenW != null && !ignoreListeners) {
			listenW(v);
		}

		return v;

	}

	override function set_h(v:Float):Float {

		super.set_h(v);

		if(listenH != null && !ignoreListeners) {
			listenH(v);
		}

		return v;

	}

}