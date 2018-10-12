package clay.math;


class VectorCallback {


    public var x(get, set):Float;
    public var y(get, set):Float;

    public var length(get, set):Float;

    public var ignore_listeners:Bool = false;
    @:isVar public var listen_x(default,default):Float -> Void;
    @:isVar public var listen_y(default,default):Float -> Void;

    var _x:Float;
    var _y:Float;


    public function new(x_:Float = 0, y_:Float = 0) {

        _x = x_;
        _y = y_;
        
    }

    public inline function set(x_:Float, y_:Float) {

        _x = x_;
        _y = y_;

        if(listen_x != null && !ignore_listeners) listen_x(_x);
        if(listen_y != null && !ignore_listeners) listen_y(_y);

        return this;
        
    }

    public inline function copy_from(_other:VectorCallback) {

        set(_other.x, _other.y);

        return this;
        
    }

    public inline function copy_from_vec(_other:Vector) {

        set(_other.x, _other.y);

        return this;
        
    }

    public inline function clone() {

        return new VectorCallback(_x, _y);
        
    }

    public inline function clone_vec() {

        return new Vector(_x, _y);
        
    }

    public inline function normalize() {

        return divide_scalar(length);
        
    }

    public inline function dot(_other:VectorCallback) {

        return _x * _other.x + _y * _other.y;

    }

    public inline function dot_vec(_other:Vector) {

        return _x * _other.x + _y * _other.y;

    }

    public inline function invert() {

        set(-_x, -_y);

        return this;
        
    }

    public inline function lengthsq() {

        return _x * _x + _y * _y;

    }

    public inline function add(_other:VectorCallback) {

        set(_x + _other.x, _y + _other.y);

        return this;
        
    }

    public inline function add_vec(_other:Vector) {

        set(_x + _other.x, _y + _other.y);

        return this;
        
    }

    public inline function add_xy(x_:Float, y_:Float) {

        set(_x + x_, _y + y_);

        return this;
        
    }

    public inline function add_scalar(_v:Float) {

        set(_x + _v, _y + _v);

        return this;
        
    }

    public inline function subtract(_other:VectorCallback) {

        set(_x - _other.x, _y - _other.y);

        return this;
        
    }

    public inline function subtract_vec(_other:Vector) {

        set(_x - _other.x, _y - _other.y);

        return this;
        
    }

    public inline function subtract_xy(x_:Float, y_:Float) {

        set(_x - x_, _y - y_);

        return this;
        
    }

    public inline function subtract_scalar(_v:Float) {

        set(_x - _v, _y - _v);

        return this;
        
    }

    public inline function multiply(_other:VectorCallback) {

        set(_x * _other.x, _y * _other.y);

        return this;
        
    }

    public inline function multiply_vec(_other:Vector) {

        set(_x * _other.x, _y * _other.y);

        return this;
        
    }

    public inline function multiply_xy(x_:Float, y_:Float) {

        set(_x * x_, _y * y_);

        return this;
        
    }

    public inline function multiply_scalar(_v:Float) {

        set(_x * _v, _y * _v);

        return this;
        
    }

    public inline function divide(_other:VectorCallback) {

        set(_x / _other.x, _y / _other.y);

        return this;
        
    }

    public inline function divide_vec(_other:Vector) {

        set(_x / _other.x, _y / _other.y);

        return this;
        
    }

    public inline function divide_xy(x_:Float, y_:Float) {

        set(_x / x_, _y / y_);

        return this;
        
    }

    public inline function divide_scalar(_v:Float) {

        set(_x / _v, _y / _v);

        return this;
        
    }

    public inline function listen(f:Float->Void) {

        listen_x = f;
        listen_y = f;
        
    }

    public function transform(_m:Matrix) {

        set(_m.a * x + _m.c * y + _m.tx, _m.b * x + _m.d * y + _m.ty);

        return this;
        
    }
    
    inline function get_x():Float {

        return _x;
        
    }

    inline function set_x(v:Float):Float {

        _x = v;

        if(listen_x != null && !ignore_listeners) {
            listen_x(_x);
        }

        return _x;

    }

    inline function get_y():Float {

        return _y;
        
    }

    inline function set_y(v:Float):Float {

        _y = v;

        if(listen_y != null && !ignore_listeners) {
            listen_y(_y);
        }

        return _y;

    }

    inline function get_length() {

        return Math.sqrt(x * x + y * y);

    }

    inline function set_length(_v:Float) {

        normalize().multiply_scalar(_v);
        return _v;

    }


}

