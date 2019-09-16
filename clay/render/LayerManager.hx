package clay.render;


import kha.graphics4.Graphics;

import clay.render.Layer;
import clay.render.Camera;
import clay.ds.IntRingBuffer;
import clay.utils.Log.*;


@:access(
	clay.render.Camera,
	clay.render.Layer
)
class LayerManager {


	public var activeCount(get, never):Int;

	public var capacity(default, null):Int;
	public var used(default, null):Int;

	var _activeLayers:Array<Layer>;
	var _layers:Map<String, Layer>;

	var _layerIds:IntRingBuffer;


	public function new(capacity:Int) {

		this.capacity = capacity;
		used = 0;
		
		_activeLayers = [];
		_layers = new Map();
		
		_layerIds = new IntRingBuffer(capacity);

	}

	public function create(name:String, priority:Int = 0, depthSort:Bool = true, enabled:Bool = true):Layer {

		var _layer = new Layer(this, name, popLayerID(), priority, depthSort);

		handleDuplicateWarning(name);
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
			c._visibleLayersMask.enable(layer.id);
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
		for (i in 0..._activeLayers.length) {
			l = _activeLayers[i];
			if (layer.priority < l.priority) {
				_activeLayers.insert(i, layer);
				added = true;
				break;
			}
		}

		layer._active = true;

		if(!added) {
			_activeLayers.push(layer);
		}

	}

	public function disable(layer:Layer) {

		if(!layer._active) {
			return;
		}

		_activeLayers.remove(layer);
		layer._active = false;
		
	}

	public function clear() {

		for (l in _layers) {
			destroy(l);
		}
		
	}

	public inline function update(dt:Float) {
		
		for (l in _activeLayers) {
			l.update(dt);
		}

	}

	public inline function render(cam:Camera) {

		for (l in _activeLayers) {
			if(cam._visibleLayersMask[l.id]) {
				l.render(cam);
			}
		}
		
	}

	inline function handleDuplicateWarning(name:String) {

		var l:Layer = _layers.get(name);
		if(l != null) {
			log('adding a second layer named: "${name}"!
				This will replace the existing one, possibly leaving the previous one in limbo.');
			_layers.remove(name);
			disable(l);
		}

	}

	inline function get_activeCount():Int {
		
		return _activeLayers.length;

	}

	function popLayerID():Int {

		if(used >= capacity) {
			throw('Out of layers, max allowed ${capacity}');
		}

		++used;
		return _layerIds.pop();

	}

	function pushLayerID(id:Int) {

		--used;
		_layerIds.push(id);

	}

	@:noCompletion public inline function iterator():Iterator<Layer> {

		return _activeLayers.iterator();

	}


}