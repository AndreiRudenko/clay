package clay.particles.core;



abstract Particle(Int) {


	public var id(get, never):Int;


	public inline function new(id:Int):Void {

		this = id;

	}
	
	inline function get_id():Int {

		return this;

	}

}