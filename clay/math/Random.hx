package clay.math;



abstract Random(kha.math.Random) from kha.math.Random to kha.math.Random {


    public inline function new(?seed:Int) {

        if(seed == null) {
            seed = Std.random(0x7fffffff);
        }

        this = new kha.math.Random(seed);
        
    }

        /** Returns a float number between [0,1) */
    public inline function get():Float {

        return this.GetFloat();

    }

        /** Returns a number between [min,max).
            max is optional, returning a number between [0,min) */
    public inline function float( min:Float, ?max:Null<Float>=null ):Float {

        if(max == null) { max = min; min = 0; }
        return get() * ( max - min ) + min;

    }

        /** Return a number between [min, max).
            max is optional, returning a number between [0,min) */
    public inline function int( min:Float, ?max:Null<Float>=null ):Int {

        if(max == null) { max = min; min=0; }
        return Math.floor( float(min,max) );

    }

        /** Returns true or false based on a chance of [0..1] percent.
            Given 0.5, 50% chance of true, with 0.9, 90% chance of true and so on. */
    public inline function bool( chance:Float = 0.5 ):Bool {

        return (get() < chance);

    }

        /** Returns 1 or -1 based on a chance of [0..1] percent.
            Given 0.5, 50% chance of 1, with 0.9, 90% chance of 1 and so on. */
    public inline function sign( chance:Float = 0.5):Int {

        return (get() < chance) ? 1 : -1;

    }

        /** Returns 1 or 0 based on a chance of [0..1] percent.
            Given 0.5, 50% chance of 1, with 0.9, 90% chance of 1 and so on. */
    public inline function bit( chance:Float = 0.5):Int {

        return (get() < chance) ? 1 : 0;

    }


}
