package clay.render;


import kha.graphics4.Graphics;

import clay.Entity;
import clay.math.Rectangle;
import clay.components.misc.Camera;
import clay.core.Signal;
import clay.utils.Log.*;

@:access(clay.components.misc.Camera)
class CameraManager {


	public var oncameracreate    (default, null):Signal<Camera->Void>;
	public var oncameradestroy	(default, null):Signal<Camera->Void>;

	public var length(default, null):Int;

	var active_cameras:Array<Camera>;
	var cameras:Map<String, Camera>;


	public function new() {
		
		active_cameras = [];
		cameras = new Map();
		length = 0;

		oncameracreate = new Signal();
		oncameradestroy = new Signal();

	}

	public function create(_name:String, ?_viewport:Rectangle, _priority:Int = 0, _enabled:Bool = true):Camera {

		var _camera = new Camera(this, _name, _viewport, _priority);

		handle_duplicate_warning(_name);
		cameras.set(_name, _camera);
		length++;

		if(_enabled) {
			enable(_camera);
		}

		oncameracreate.emit(_camera);

		return _camera;

	}

	public function destroy(_camera:Camera) {
		
		if(cameras.exists(_camera.name)) {
			cameras.remove(_camera.name);
			length--;
			disable(_camera);
		} else {
			log('can`t remove camera: "${_camera.name}" , already removed?');
		}

		oncameradestroy.emit(_camera);

		_camera.destroy();

	}

	public inline function get(name:String):Camera {

		return cameras.get(name);

	}

	public function enable(_camera:Camera) {

		if(_camera._active) {
			return;
		}
		
		var added:Bool = false;
		var c:Camera = null;
		for (i in 0...active_cameras.length) {
			c = active_cameras[i];
			if (_camera.priority < c.priority) {
				active_cameras.insert(i, _camera);
				added = true;
				break;
			}
		}

		_camera._active = true;

		if(!added) {
			active_cameras.push(_camera);
		}

	}

	public function disable(_camera:Camera) {

		if(!_camera._active) {
			return;
		}

		active_cameras.remove(_camera);
		_camera._active = false;
		
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

	@:noCompletion public inline function iterator():Iterator<Camera> {

		return active_cameras.iterator();

	}


}