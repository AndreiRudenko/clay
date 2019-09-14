package clay.math;


class Bounds {


    public var min:Vector;
    public var max:Vector;


    public function new(_minx:Float = 0, _miny:Float = 0, _maxx:Float = 0, _maxy:Float = 0) {
        
        min = new Vector(_minx, _miny);
        max = new Vector(_maxx, _maxy);

    }

    public function set(_minx:Float, _miny:Float, _maxx:Float, _maxy:Float):Bounds {
        
        min.set(_minx, _miny);
        max.set(_maxx, _maxy);
        
        return this;

    }
    
    public function pointInside(_p:Vector):Bool {

        if(_p.x < min.x) return false;
        if(_p.y < min.y) return false;
        if(_p.x > max.x) return false;
        if(_p.y > max.y) return false;

        return true;

    }

    public function overlaps(_other:Bounds) {

        if( min.x < (_other.max.x) &&
            min.y < (_other.max.y) &&
            (max.x) > _other.min.x &&
            (max.y) > _other.min.y ) {
            return true;
        }

        return false;
    }

    public function equals(_other:Bounds):Bool {
        
        return min.equals(_other.min) && max.equals(_other.max);

    }

    public function clone():Bounds {

        return new Bounds(min.x, min.y, max.x, max.y);

    }

    public function copyFrom(_other:Bounds):Bounds {

        min.copyFrom(_other.min);
        max.copyFrom(_other.max);

        return this;

    }


}