package clay.math;


class Rectangle {


    public var x(default, set):Float;
    public var y(default, set):Float;
    public var w(default, set):Float;
    public var h(default, set):Float;


    public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
        
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;

    }

    public function set(x:Float, y:Float, w:Float, h:Float):Rectangle {
        
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;

        return this;

    }
    
    public function pointInside(point:Vector) {

        if(point.x < x) return false;
        if(point.y < y) return false;
        if(point.x > x+w) return false;
        if(point.y > y+h) return false;

        return true;

    }

    public function overlaps(other:Rectangle) {

        if( x < (other.x + other.w) &&
            y < (other.y + other.h) &&
            (x + w) > other.x        &&
            (y + h) > other.y ) {
            return true;
        }

        return false;
    }

    public function equals(other:Rectangle):Bool {

        if(other == null) {
            return false;
        }
        
        return x == other.x && 
            y == other.y && 
            w == other.w && 
            h == other.h;

    }

    public function clone():Rectangle {

        return new Rectangle(x, y, w, h);

    }

    public function copyFrom(other:Rectangle):Rectangle {

        x = other.x;
        y = other.y;
        w = other.w;
        h = other.h;

        return this;

    }

    function set_x(v:Float) {

        return x = v;

    }

    function set_y(v:Float) {

        return y = v;

    }
    function set_w(v:Float) {

        return w = v;

    }

    function set_h(v:Float) {

        return h = v;

    }


}