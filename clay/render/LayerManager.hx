package clay.render;


import kha.graphics4.Graphics;

import clay.render.Layer;
import clay.components.misc.Camera;
import clay.ds.Int32RingBuffer;
import clay.utils.Log.*;


@:access(
	clay.components.misc.Camera,
	clay.render.Layer
)
class LayerManager {


	public var active_count(get, never):Int;

	public var capacity(default, null):Int;
	public var used(default, null):Int;

	var _ids:Int32RingBuffer;

	var active_layers:Array<Layer>;
	var layers:Map<String, Layer>;


	public function new(_capacity:Int) {

		capacity = _capacity;
		used = 0;
		_ids = new Int32RingBuffer(capacity);
		
		active_layers = [];
		layers = new Map();

	}

	public function create(_name:String, _priority:Int = 0, _depth_sort:Bool = true, _enabled:Bool = true):Layer {

		var _layer = new Layer(this, _name, pop_layer_id(), _priority, _depth_sort);

		handle_duplicate_warning(_name);
		layers.set(_name, _layer);

		if(_enabled) {
			enable(_layer);
		}

		return _layer;

	}

	public function destroy(_layer:Layer) {
		
		if(layers.exists(_layer.name)) {
			layers.remove(_layer.name);
			disable(_layer);
		} else {
			log('can`t remove layer: "${_layer.name}" , already removed?');
		}

		for (c in Clay.renderer.cameras.cameras) {
			c.visible_layers_mask.enable(_layer.id);
		}

		_layer.destroy();

	}

	public inline function get(_name:String):Layer {

		return layers.get(_name);

	}

	public function enable(_layer:Layer) {

		if(_layer._active) {
			return;
		}
		
		var added:Bool = false;
		var l:Layer = null;
		for (i in 0...active_layers.length) {
			l = active_layers[i];
			if (_layer.priority < l.priority) {
				active_layers.insert(i, _layer);
				added = true;
				break;
			}
		}

		_layer._active = true;

		if(!added) {
			active_layers.push(_layer);
		}

	}

	public function disable(_layer:Layer) {

		if(!_layer._active) {
			return;
		}

		active_layers.remove(_layer);
		_layer._active = false;
		
	}

	public function clear() {

		for (l in layers) {
			destroy(l);
		}
		
	}

	public inline function render(_:Graphics, cam:Camera) {

		for (l in active_layers) {
			if(cam.visible_layers_mask[l.id]) {
				l.render(Clay.renderer.target.image.g4, cam);
			}
		}
		
	}

	inline function handle_duplicate_warning(_name:String) {

		var l:Layer = layers.get(_name);
		if(l != null) {
			log('adding a second layer named: "${_name}"!
				This will replace the existing one, possibly leaving the previous one in limbo.');
			layers.remove(_name);
			disable(l);
		}

	}

	inline function get_active_count():Int {
		
		return active_layers.length;

	}

	function pop_layer_id():Int {

		if(used >= capacity) {
			throw('Out of layers, max allowed ${capacity}');
		}

		++used;
		return _ids.pop();

	}

	function push_layer_id(_id:Int) {

		--used;
		_ids.push(_id);

	}

	@:noCompletion public inline function iterator():Iterator<Layer> {

		return active_layers.iterator();

	}


}