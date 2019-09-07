package clay.math;


class VectorCallback extends Vector {


    public var ignore_listeners:Bool = false;
    
    @:isVar public var listen_x(default,default):Float -> Void;
    @:isVar public var listen_y(default,default):Float -> Void;


    public function new(_x:Float = 0, _y:Float = 0) {

        super(_x, _y);
        
    }

    public function listen(f:Float->Void) {

        listen_x = f;
        listen_y = f;
        
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


}

