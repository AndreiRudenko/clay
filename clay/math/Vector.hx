package clay.math;


class Vector {


    public var x:Float;
    public var y:Float;

    public var length(get, set):Float;


    public function new(_x:Float = 0, _y:Float = 0) {

        x = _x;
        y = _y;
        
    }

    public inline function set(_x:Float, _y:Float) {

        x = _x;
        y = _y;

        return this;
        
    }

    public inline function copy_from(_other:Vector) {

        x = _other.x;
        y = _other.y;

        return this;
        
    }

    public inline function clone() {

        return new Vector(x, y);
        
    }

    public inline function normalize() {

        return divide_scalar(length);
        
    }

    public inline function dot(_other:Vector) {

        return x * _other.x + y * _other.y;

    }

    public inline function invert() {

        set(-x, -y);

        return this;
        
    }

    public inline function lengthsq() {

        return x * x + y * y;

    }

    public inline function add(_other:Vector) {

        set(x + _other.x, y + _other.y);

        return this;
        
    }

    public inline function add_xy(_x:Float, _y:Float) {

        set(x + _x, y + _y);

        return this;
        
    }

    public inline function add_scalar(_v:Float) {

        set(x + _v, y + _v);

        return this;
        
    }

    public inline function subtract(_other:Vector) {

        set(x - _other.x, y - _other.y);

        return this;
        
    }

    public inline function subtract_xy(_x:Float, _y:Float) {

        set(x - _x, y - _y);

        return this;
        
    }

    public inline function subtract_scalar(_v:Float) {

        set(x - _v, y - _v);

        return this;
        
    }

    public inline function multiply(_other:Vector) {

        set(x * _other.x, y * _other.y);

        return this;
        
    }

    public inline function multiply_xy(_x:Float, _y:Float) {

        set(x * _x, y * _y);

        return this;
        
    }

    public inline function multiply_scalar(_v:Float) {

        set(x * _v, y * _v);

        return this;
        
    }

    public inline function divide(_other:Vector) {

        set(x / _other.x, y / _other.y);

        return this;
        
    }

    public inline function divide_xy(_x:Float, _y:Float) {

        set(x / _x, y / _y);

        return this;
        
    }

    public inline function divide_scalar(_v:Float) {

        set(x / _v, y / _v);

        return this;
        
    }

    public function transform(_m:Matrix) {

        set(_m.a * x + _m.c * y + _m.tx, _m.b * x + _m.d * y + _m.ty);

        return this;
        
    }

    inline function get_length() {

        return Math.sqrt(x * x + y * y);

    }

    inline function set_length(_v:Float) {

        normalize().multiply_scalar(_v);
        return _v;

    }


}

