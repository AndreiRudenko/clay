package clay.math;


class VectorCallback extends Vector {

    public var ignoreListeners:Bool = false;
    public var listener:(v:Vector)->Void;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

    public function listen(f:(v:Vector)->Void) {
        listener = f;
    }

    override function set(x:Float, y:Float) {
        var prev = ignoreListeners;
        ignoreListeners = true;
        super.set(x, y);
        ignoreListeners = prev;
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

    inline function callListener() {
        if(listener != null && !ignoreListeners) {
            listener(this);
        }
    }

}

