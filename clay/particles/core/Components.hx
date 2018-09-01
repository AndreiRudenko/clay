package clay.particles.core;


import clay.particles.core.Particle;
import haxe.ds.Vector;


abstract Components<T>(Vector<T>) from Vector<T> {


	public var length(get, never):Int;


	public inline function new(length:Int) {

		this = new Vector(length);

	}

	@:arrayAccess
	public inline function get(p:Particle):T {

		return this[p.id];

	}

	@:arrayAccess
	public inline function set(p:Particle, element:T):Void {

		this[p.id] = element;

	}

	public inline function remove(p:Particle):Void {

		this[p.id] = null;

	}

	public inline function clear():Void {

		for (i in 0...this.length) {
			this[i] = null;
		}

	}

	inline function get_length() {

		return this.length;

	}


}

