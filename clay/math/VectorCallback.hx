package clay.math;


class VectorCallback extends Vector {


    public var ignoreListeners:Bool = false;
    
    @:isVar public var listenX(default,default):(v:Float)->Void;
    @:isVar public var listenY(default,default):(v:Float)->Void;


    public function new(_x:Float = 0, _y:Float = 0) {

        super(_x, _y);
        
    }

    public function listen(f:(v:Float)->Void) {

        listenX = f;
        listenY = f;
        
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


}

