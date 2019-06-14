package clay.particles.core;


import haxe.ds.Vector;


class Components<T> {


	public var length(get, never):Int;
	public var name(default, null):String;

	var _buffer:Vector<T>;


	public inline function new(name:String, length:Int) {

		this.name = name;
		_buffer = new Vector<T>(length);
		
	}

	@:arrayAccess
	public inline function get(id:Int):T {

		return _buffer[id];

	}

	@:arrayAccess
	public inline function set(id:Int, element:T):Void {

		_buffer[id] = element;

	}

	public inline function remove(id:Int):Void {

		_buffer[id] = null;

	}

	public inline function swap(a:Int, b:Int) {

		var ea = _buffer[a];
		_buffer[a] = _buffer[b];
		_buffer[b] = ea;
	    
	}

	public inline function clear():Void {

		for (i in 0..._buffer.length) {
			_buffer[i] = null;
		}

	}

	inline function get_length() {

		return _buffer.length;

	}

	// @:noCompletion public inline function iterator():Iterator<T> {

	// 	return _buffer.toData().iterator();

	// }

}

