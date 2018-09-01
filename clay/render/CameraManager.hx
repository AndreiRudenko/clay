package clay.render;


import kha.graphics4.Graphics;

import clay.Entity;
import clay.components.Camera;
import clay.utils.Log.*;

@:access(clay.components.Camera)
class CameraManager {


	var cameras:Map<String, Camera>;


	public function new() {
		
		cameras = new Map();

	}

	public function create(name:String, x:Int = 0, y:Int = 0, ?w:Int, ?h:Int):Camera {

		var c = new Camera(name, x, y, w, h);
		add(c);

		return c;

	}

	public function add(c:Camera) {

		handle_duplicate_warning(c.name);
		cameras.set(c.name, c);
		c.added = true;

	}

	public inline function get(name:String):Camera {

		return cameras.get(name);

	}

	public function remove(name:String):Bool {

		var c = cameras.get(name);
		if(c != null) {
			c.added = false;
			return true;
		}
		return false;
	    

	}

	public function clear() {

		for (c in cameras) {
			c.added = false;
		}
		cameras = new Map();
		
	}

	function handle_duplicate_warning(name:String) {

		var c:Camera = cameras.get(name);
		if(c != null) {
			log('adding a second camera named: "${name}"!
				This will replace the existing one, possibly leaving the previous one in limbo.');
			cameras.remove(name);
		}

	}

	@:noCompletion public inline function iterator():Iterator<Camera> {

		return cameras.iterator();

	}


}