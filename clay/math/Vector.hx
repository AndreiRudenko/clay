package clay.math;


class Vector {


    public var x(default, set):Float;
    public var y(default, set):Float;

    public var length(get, set):Float;
    public var lengthsq(get, never):Float;


    public function new(_x:Float = 0, _y:Float = 0) {

        x = _x;
        y = _y;
        
    }

    @:extern public inline function set(_x:Float, _y:Float) {

        x = _x;
        y = _y;

        return this;
        
    }

    @:extern public inline function copy_from(_other:Vector) {

        x = _other.x;
        y = _other.y;

        return this;
        
    }

    @:extern public inline function equals(_other:Vector):Bool {

        return x == _other.x && y == _other.y;
        
    }

    @:extern public inline function clone() {

        return new Vector(x, y);
        
    }

    @:extern public inline function normalize() {

        return divide_scalar(length);
        
    }

    @:extern public inline function dot(_other:Vector) {

        return x * _other.x + y * _other.y;

    }

    @:extern public inline function invert() {

        set(-x, -y);

        return this;
        
    }

    @:extern public inline function add(_other:Vector) {

        set(x + _other.x, y + _other.y);

        return this;
        
    }

    @:extern public inline function add_xy(_x:Float, _y:Float) {

        set(x + _x, y + _y);

        return this;
        
    }

    @:extern public inline function add_scalar(_v:Float) {

        set(x + _v, y + _v);

        return this;
        
    }

    @:extern public inline function subtract(_other:Vector) {

        set(x - _other.x, y - _other.y);

        return this;
        
    }

    @:extern public inline function subtract_xy(_x:Float, _y:Float) {

        set(x - _x, y - _y);

        return this;
        
    }

    @:extern public inline function subtract_scalar(_v:Float) {

        set(x - _v, y - _v);

        return this;
        
    }

    @:extern public inline function multiply(_other:Vector) {

        set(x * _other.x, y * _other.y);

        return this;
        
    }

    @:extern public inline function multiply_xy(_x:Float, _y:Float) {

        set(x * _x, y * _y);

        return this;
        
    }

    @:extern public inline function multiply_scalar(_v:Float) {

        set(x * _v, y * _v);

        return this;
        
    }

    @:extern public inline function divide(_other:Vector) {

        set(x / _other.x, y / _other.y);

        return this;
        
    }

    @:extern public inline function divide_xy(_x:Float, _y:Float) {

        set(x / _x, y / _y);

        return this;
        
    }

    @:extern public inline function divide_scalar(_v:Float) {

        set(x / _v, y / _v);

        return this;
        
    }

    @:extern public inline function transform(_m:Matrix) {

        set(_m.a * x + _m.c * y + _m.tx, _m.b * x + _m.d * y + _m.ty);

        return this;
        
    }
    
    inline function get_lengthsq() {

        return x * x + y * y;

    }

    inline function get_length() {

        return Math.sqrt(x * x + y * y);

    }

    inline function set_length(_v:Float) {

        normalize().multiply_scalar(_v);
        return _v;

    }

    function set_x(_v:Float) {

        return x = _v;

    }

    function set_y(_v:Float) {

        return y = _v;

    }


}

