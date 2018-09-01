package clay.math;


class Rectangle {


    public var x:Float;
    public var y:Float;
    public var w:Float;
    public var h:Float;


    public function new(_x:Float = 0, _y:Float = 0, _w:Float = 0, _h:Float = 0) {
        
        x = _x;
        y = _y;
        w = _w;
        h = _h;

    }

    public function set(_x:Float, _y:Float, _w:Float, _h:Float):Void {
        
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        
    }
    

}