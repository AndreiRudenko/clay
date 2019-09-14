package clay.math;


class Vector {


    public var x(default, set):Float;
    public var y(default, set):Float;

    public var length(get, set):Float;
    public var lengthSq(get, never):Float;


    public function new(_x:Float = 0, _y:Float = 0) {

        x = _x;
        y = _y;
        
    }

    public inline function set(_x:Float, _y:Float) {

        x = _x;
        y = _y;

        return this;
        
    }

    public inline function copyFrom(_other:Vector) {

        x = _other.x;
        y = _other.y;

        return this;
        
    }

    public inline function equals(_other:Vector):Bool {

        return x == _other.x && y == _other.y;
        
    }

    public inline function clone() {

        return new Vector(x, y);
        
    }

    public inline function normalize() {

        return divideScalar(length);
        
    }

    public inline function dot(_other:Vector) {

        return x * _other.x + y * _other.y;

    }

    public inline function distance(_other:Vector) {

        return Math.sqrt((_other.y - y) * (_other.y - y) + (_other.x - x) * (_other.x - x));

    }

    public inline function invert() {

        set(-x, -y);

        return this;
        
    }

    public inline function add(_other:Vector) {

        set(x + _other.x, y + _other.y);

        return this;
        
    }

    public inline function addXY(_x:Float, _y:Float) {

        set(x + _x, y + _y);

        return this;
        
    }

    public inline function addScalar(_v:Float) {

        set(x + _v, y + _v);

        return this;
        
    }

    public inline function subtract(_other:Vector) {

        set(x - _other.x, y - _other.y);

        return this;
        
    }

    public inline function subtractXY(_x:Float, _y:Float) {

        set(x - _x, y - _y);

        return this;
        
    }

    public inline function subtractScalar(_v:Float) {

        set(x - _v, y - _v);

        return this;
        
    }

    public inline function multiply(_other:Vector) {

        set(x * _other.x, y * _other.y);

        return this;
        
    }

    public inline function multiplyXY(_x:Float, _y:Float) {

        set(x * _x, y * _y);

        return this;
        
    }

    public inline function multiplyScalar(_v:Float) {

        set(x * _v, y * _v);

        return this;
        
    }

    public inline function divide(_other:Vector) {

        set(x / _other.x, y / _other.y);

        return this;
        
    }

    public inline function divideXY(_x:Float, _y:Float) {

        set(x / _x, y / _y);

        return this;
        
    }

    public inline function divideScalar(_v:Float) {

        set(x / _v, y / _v);

        return this;
        
    }

    public inline function transform(_m:Matrix) {

        set(_m.a * x + _m.c * y + _m.tx, _m.b * x + _m.d * y + _m.ty);

        return this;
        
    }
    
    inline function get_lengthSq() {

        return x * x + y * y;

    }

    inline function get_length() {

        return Math.sqrt(x * x + y * y);

    }

    inline function set_length(_v:Float) {

        normalize().multiplyScalar(_v);
        return _v;

    }

    function set_x(_v:Float) {

        return x = _v;

    }

    function set_y(_v:Float) {

        return y = _v;

    }


}

