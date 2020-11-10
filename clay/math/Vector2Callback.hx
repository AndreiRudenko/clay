package clay.math;

@:structInit
class Vector2Callback extends Vector2 {

    public var ignoreListeners:Bool = false;
    public var listener:(v:Vector2)->Void;

    public inline function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

    override function set(x:Float, y:Float) {
        _x = x;
        _y = y;
        callListener();
        return this;
    }

    override function set_x(v:Float):Float {
        _x = v;
        callListener();
        return v;
    }

    override function set_y(v:Float):Float {
        _y = v;
        callListener();
        return v;
    }

    public function listen(f:(v:Vector2)->Void) {
        listener = f;
    }

    inline function callListener() {
        if(listener != null && !ignoreListeners) {
            listener(this);
        }
    }

}

