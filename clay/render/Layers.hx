package clay.render;


import kha.graphics4.Graphics;

import clay.render.Layer;
import clay.render.LayerObject;
import clay.render.Camera;
import clay.utils.Log.*;

@:access(
	clay.render.Camera,
	clay.render.Layer
)
class Layers {

	public static inline var DEFAULT:Int = 0;
	public static inline var DEBUG_DRAW:Int = 30;
	public static inline var DEBUG_UI:Int = 31;

	public var activeCount(get, never):Int;
	public var capacity(default, null):Int;
	public var used(default, null):Int;

	var _activeLayers:Array<Layer>;
	var _layers:haxe.ds.Vector<Layer>;

	public function new() {
		capacity = 32;
		used = 0;
		_activeLayers = [];
		_layers = new haxe.ds.Vector(capacity); 
	}

	public function add(object:LayerObject, layerId:Int = 0) {
		var layer = getLayer(layerId);
		if(layer != null) {
			layer.add(object);
		} else {
			log('can`t add object ${object.name} to layer ${layerId}');
		}
	}

	public function remove(object:LayerObject) {
		var layer = object.layer;
		if(layer != null) {
			layer.remove(object);
		} else {
			log('can`t remove object ${object.name} from layer ${object.layer}');
		}
	}

	public function enableLayer(layerId:Int) {
		var layer = getLayer(layerId);
		if(layer != null) {
			enableLayerInternal(layer);
		} else {
			log('can`t enable layer ${layerId}');
		}
	}

	public function disableLayer(layerId:Int) {
		var layer = getLayer(layerId);
		if(layer != null) {
			disableLayerInternal(layer);
		} else {
			log('can`t disable layer ${layerId}');
		}
	}

	public function getLayer(layerId:Int):Layer {
		var layer:Layer = null;
		if(layerId >= 0 && layerId < 32) {
			layer = _layers[layerId];
			if(layer == null) {
				layer = createLayer('layer $layerId', layerId);
			}
		} else {
			log('can`t get layer ${layerId}, id must be between 0 and 31');
		}
		return layer;
	}

	public inline function update(dt:Float) {
		for (l in _activeLayers) {
			Clay.debug.start('layer.${l.name}.update');
			l.update(dt);
			Clay.debug.end('layer.${l.name}.update');
		}
	}

	public inline function render(ctx:RenderContext, cam:Camera) {
		for (l in _activeLayers) {
			if(cam.inCullingMask(l.id)) {
				Clay.debug.start('layer.${l.name}.render');
				l.render(ctx);
				#if !no_debug_console
				Clay.renderer.stats.add(l.stats);
				#end
				Clay.debug.end('layer.${l.name}.render');
			}
		}
	}

	public function emptyLayers() {
		var len = capacity;

		#if !no_debug_console
		// do not empty DEBUG_UI layer
		len--;
		#end

		var l:Layer;
		for (i in 0...len) {
			l = _layers[i];
			if(l != null) {
				l.empty();
			}
		}
	}

	// public function destroyEmptyLayers() {
	// 	for (l in _layers) {
	// 		if(l != null && l.objects.length == 0) {
	// 			destroyLayer(l);
	// 		}
	// 	}
	// }

	function createLayer(name:String, id:Int):Layer {
		var layer = new Layer(name);
		layer.id = id;
		_layers[id] = layer;
		enableLayerInternal(layer);
		used++;

		return layer;
	}

	function destroyLayer(layer:Layer) {
		if(_layers[layer.id] != null) {
			_layers[layer.id] = null;
			disableLayerInternal(layer);
			used--;
		} else {
			log('can`t remove layer ${layer.id}: "${layer.name}" , already removed?');
		}

		// for (c in Clay.renderer.cameras.cameras) {
		// 	c._visibleLayersMask.enable(layer.id);
		// }

		layer.destroy();
	}

	inline function enableLayerInternal(layer:Layer) {
		if(!layer.active) {
			addSorted(layer);
			layer.active = true;
		}
	}

	inline function disableLayerInternal(layer:Layer) {
		if(layer.active) {
			_activeLayers.remove(layer);
			layer.active = false;
		}
	}

	inline function addSorted(layer:Layer) {
		var added:Bool = false;
		var l:Layer = null;
		for (i in 0..._activeLayers.length) {
			l = _activeLayers[i];
			if (layer.id < l.id) {
				_activeLayers.insert(i, layer);
				added = true;
				break;
			}
		}

		if(!added) {
			_activeLayers.push(layer);
		}
	}

	inline function get_activeCount():Int {
		return _activeLayers.length;
	}

}