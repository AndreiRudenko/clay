package clay.utils;

abstract Random(kha.math.Random) from kha.math.Random to kha.math.Random {

    public inline function new(?seed:Int) {
        if(seed == null) seed = Std.random(0x7fffffff);
        this = new kha.math.Random(seed);
    }

    public inline function get():Int {
        return this.Get();
    }
        /** Returns a float number between [0,1) */
    public inline function getFloat():Float {
        return this.GetFloat();
    }

        /** Returns a number between [min,max).
            max is optional, returning a number between [0,min) */
    public inline function float(min:Float, ?max:Null<Float>):Float {
        if(max == null) { max = min; min = 0; }
        return getFloat() * (max - min) + min;
    }

        /** Return a number between [min, max).
            max is optional, returning a number between [0,min) */
    public inline function int(min:Int, ?max:Null<Int>):Int {
        return Math.floor(float(min, max));
    }

        /** Returns true or false based on a chance of [0..1] percent.
            Given 0.5, 50% chance of true, with 0.9, 90% chance of true and so on. */
    public inline function bool(chance:Float = 0.5):Bool {
        return (getFloat() < chance);
    }

        /** Returns 1 or -1 based on a chance of [0..1] percent.
            Given 0.5, 50% chance of 1, with 0.9, 90% chance of 1 and so on. */
    public inline function sign(chance:Float = 0.5):Int {
        return (getFloat() < chance) ? 1 : -1;
    }

        /** Returns 1 or 0 based on a chance of [0..1] percent.
            Given 0.5, 50% chance of 1, with 0.9, 90% chance of 1 and so on. */
    public inline function bit(chance:Float = 0.5):Int {
        return (getFloat() < chance) ? 1 : 0;
    }

}
