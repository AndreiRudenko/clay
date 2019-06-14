package clay.render;


import kha.graphics4.Graphics;

import clay.render.Layer;
import clay.render.Camera;
import clay.ds.Int32RingBuffer;
import clay.utils.Log.*;


@:access(
	clay.render.Camera,
	clay.render.Layer
)
class LayerManager {


	public var active_count(get, never):Int;

	public var capacity(default, null):Int;
	public var used(default, null):Int;

	var _ids:Int32RingBuffer;
	var _active_layers:Array<Layer>;
	var _layers:Map<String, Layer>;


	public function new(_capacity:Int) {

		capacity = _capacity;
		used = 0;
		_ids = new Int32RingBuffer(capacity);
		
		_active_layers = [];
		_layers = new Map();

	}

	public function create(name:String, priority:Int = 0, depth_sort:Bool = true, enabled:Bool = true):Layer {

		var _layer = new Layer(this, name, pop_layer_id(), priority, depth_sort);

		handle_duplicate_warning(name);
		_layers.set(name, _layer);

		if(enabled) {
			enable(_layer);
		}

		return _layer;

	}

	public function destroy(layer:Layer) {
		
		if(_layers.exists(layer.name)) {
			_layers.remove(layer.name);
			disable(layer);
		} else {
			log('can`t remove layer: "${layer.name}" , already removed?');
		}

		for (c in Clay.renderer.cameras.cameras) {
			c._visible_layers_mask.enable(layer.id);
		}

		layer.destroy();

	}

	public inline function get(name:String):Layer {

		return _layers.get(name);

	}

	public function enable(layer:Layer) {

		if(layer._active) {
			return;
		}
		
		var added:Bool = false;
		var l:Layer = null;
		for (i in 0..._active_layers.length) {
			l = _active_layers[i];
			if (layer.priority < l.priority) {
				_active_layers.insert(i, layer);
				added = true;
				break;
			}
		}

		layer._active = true;

		if(!added) {
			_active_layers.push(layer);
		}

	}

	public function disable(layer:Layer) {

		if(!layer._active) {
			return;
		}

		_active_layers.remove(layer);
		layer._active = false;
		
	}

	public function clear() {

		for (l in _layers) {
			destroy(l);
		}
		
	}

	public inline function render(_:Graphics, cam:Camera) {

		for (l in _active_layers) {
			if(cam._visible_layers_mask[l.id]) {
				l.render(Clay.renderer.target.image.g4, cam);
			}
		}
		
	}

	inline function handle_duplicate_warning(name:String) {

		var l:Layer = _layers.get(name);
		if(l != null) {
			log('adding a second layer named: "${name}"!
				This will replace the existing one, possibly leaving the previous one in limbo.');
			_layers.remove(name);
			disable(l);
		}

	}

	inline function get_active_count():Int {
		
		return _active_layers.length;

	}

	function pop_layer_id():Int {

		if(used >= capacity) {
			throw('Out of layers, max allowed ${capacity}');
		}

		++used;
		return _ids.pop();

	}

	function push_layer_id(id:Int) {

		--used;
		_ids.push(id);

	}

	@:noCompletion public inline function iterator():Iterator<Layer> {

		return _active_layers.iterator();

	}


}