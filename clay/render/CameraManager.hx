package clay.render;


import kha.graphics4.Graphics;

import clay.math.Rectangle;
import clay.render.Camera;
import clay.events.Signal;
import clay.utils.Log.*;

@:access(clay.render.Camera)
class CameraManager {


	public var oncameracreate    (default, null):Signal<Camera->Void>;
	public var oncameradestroy	(default, null):Signal<Camera->Void>;

	public var length(default, null):Int;

	@:noCompletion public var active_cameras:Array<Camera>;
	@:noCompletion public var cameras:Map<String, Camera>;


	public function new() {
		
		active_cameras = [];
		cameras = new Map();
		length = 0;

		oncameracreate = new Signal();
		oncameradestroy = new Signal();

	}

	public function create(name:String, ?viewport:Rectangle, priority:Int = 0, enabled:Bool = true):Camera {

		var camera = new Camera(this, name, viewport, priority);

		handle_duplicate_warning(name);
		cameras.set(name, camera);
		length++;

		if(enabled) {
			enable(camera);
		}

		oncameracreate.emit(camera);

		return camera;

	}

	public function destroy(camera:Camera) {
		
		if(cameras.exists(camera.name)) {
			cameras.remove(camera.name);
			length--;
			disable(camera);
		} else {
			log('can`t remove camera: "${camera.name}" , already removed?');
		}

		oncameradestroy.emit(camera);

		camera.destroy();

	}

	public inline function get(name:String):Camera {

		return cameras.get(name);

	}

	public function enable(camera:Camera) {

		if(camera._active) {
			return;
		}
		
		var added:Bool = false;
		var c:Camera = null;
		for (i in 0...active_cameras.length) {
			c = active_cameras[i];
			if (camera.priority < c.priority) {
				active_cameras.insert(i, camera);
				added = true;
				break;
			}
		}

		camera._active = true;

		if(!added) {
			active_cameras.push(camera);
		}

	}

	public function disable(camera:Camera) {

		if(!camera._active) {
			return;
		}

		active_cameras.remove(camera);
		camera._active = false;
		
	}

	public function clear() {

		for (c in cameras) {
			destroy(c);
		}
		length = 0;
		
	}

	function handle_duplicate_warning(name:String) {

		var c:Camera = cameras.get(name);
		if(c != null) {
			log('adding a second camera named: "${name}"!
				This will replace the existing one, possibly leaving the previous one in limbo.');
			cameras.remove(name);
			disable(c);
		}

	}

	@:noCompletion public inline function iterator():Iterator<Camera> { // todo: using this is broke hashlink build, ftw?

		return active_cameras.iterator();

	}


}