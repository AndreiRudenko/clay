package clay.math;


class Rectangle {


    public var x(default, set):Float;
    public var y(default, set):Float;
    public var w(default, set):Float;
    public var h(default, set):Float;


    public function new(_x:Float = 0, _y:Float = 0, _w:Float = 0, _h:Float = 0) {
        
        x = _x;
        y = _y;
        w = _w;
        h = _h;

    }

    public function set(_x:Float, _y:Float, _w:Float, _h:Float):Rectangle {
        
        x = _x;
        y = _y;
        w = _w;
        h = _h;
        
        return this;

    }
    
    public function pointInside(_p:Vector) {

        if(_p.x < x) return false;
        if(_p.y < y) return false;
        if(_p.x > x+w) return false;
        if(_p.y > y+h) return false;

        return true;

    }

    public function overlaps(_other:Rectangle) {

        if( x < (_other.x + _other.w) &&
            y < (_other.y + _other.h) &&
            (x + w) > _other.x        &&
            (y + h) > _other.y ) {
            return true;
        }

        return false;
    }

    public function equals(_other:Rectangle):Bool {

        if(_other == null) {
            return false;
        }
        
        return x == _other.x && 
            y == _other.y && 
            w == _other.w && 
            h == _other.h;

    }

    public function clone():Rectangle {

        return new Rectangle(x,y,w,h);

    }

    public function copyFrom(_rect:Rectangle):Rectangle {

        x = _rect.x;
        y = _rect.y;
        w = _rect.w;
        h = _rect.h;

        return this;

    }

    function set_x(_v:Float) {

        return x = _v;

    }

    function set_y(_v:Float) {

        return y = _v;

    }
    function set_w(_v:Float) {

        return w = _v;

    }

    function set_h(_v:Float) {

        return h = _v;

    }


}