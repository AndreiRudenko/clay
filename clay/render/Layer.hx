package clay.render;


import kha.graphics4.Graphics;

import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.render.LayerObject;
import clay.render.Camera;
import clay.resources.Texture;
import clay.events.Signal;
import clay.utils.ArrayTools;
import clay.utils.Log.*;

import clay.render.RenderStats;
import haxe.ds.ArraySort;


@:access(clay.render.Renderer)
@:access(clay.render.LayerManager)
@:access(clay.render.LayerObject)
class Layer {


	public var name(default, null):String;
	public var id(default, null):Int;
	public var active(get, set):Bool;

	public var objects(default, null):Array<LayerObject>;

	public var priority(default, null):Int;

	public var depthSort:Bool = true;
	public var dirtySort:Bool = true;

	public var onPreRender(default, null):Signal<()->Void>;
	public var onPostRender(default, null):Signal<()->Void>;

	public var blendSrc:BlendFactor;
	public var blendDst:BlendFactor;
	public var blendOp:BlendOperation;

	#if !no_debug_console
	public var stats(default, null):RenderStats;
	#end

	var _active:Bool;
	var _objectsToRemove:Array<LayerObject>;
	var _renderer:Renderer;
	var _manager:LayerManager;


	function new(manager:LayerManager, name:String, id:Int, priority:Int, depthSort:Bool) {

		this.name = name;
		this.id = id;
		this.priority = priority;
		this.depthSort = depthSort;
		_renderer = Clay.renderer;
		_manager = manager;
		objects = [];
		_objectsToRemove = [];
		_active = false;

		onPreRender = new Signal();
		onPostRender = new Signal();

		blendSrc = BlendFactor.Undefined;
		blendDst = BlendFactor.Undefined;
		blendOp = BlendOperation.Add;

		#if !no_debug_console
		stats = new RenderStats();
		#end
		
	}

	function destroy() {

		for (g in objects) {
			g._layer = null;
		}

		name = null;
		onPreRender = null;
		onPostRender = null;
		objects = null;

	}

	public function add(obj:LayerObject) {

		_debug('layer `$name` add: ${obj.name}');

		if(obj.layer != null) {
			obj.layer.removeUnsafe(obj);
		}

		addUnsafe(obj);

	}

	public function remove(obj:LayerObject) {
		
		_debug('layer `$name` remove: ${obj.name}');

		if(obj.layer != this) {
			log('can`t remove `${obj.name}` from layer `$name`');
		} else {
			removeUnsafe(obj);
		}

	}

	@:noCompletion public function addUnsafe(obj:LayerObject, sort:Bool = true) {

		_debug('layer `$name` addUnsafe: ${obj.name}');
		
		objects.push(obj);

		setupAdded(obj);

		if(sort) {
			dirtySort = true;
		}

	}

	@:noCompletion public function removeUnsafe(obj:LayerObject) {

		_debug('layer `$name` removeUnsafe: ${obj.name}');

		_objectsToRemove.push(obj);

		setupRemoved(obj);

	}

	public function update(elapsed:Float) {

		_verboser('layer `$name` update, elapsed: $elapsed');

		removeObjects();
		sortObjects();
		
		for (o in objects) {
			if(o.active) {
				o.update(elapsed);
			}
		}
		
	}

	public function render(camera:Camera) {

		_verboser('layer `$name` render');

		Clay.debug.start('renderer.layer.$name');

		onPreRender.emit();

		#if !no_debug_console
		stats.reset();
		#end

		if(objects.length > 0) {
			var p = _renderer.painter;
			p.begin(getTargetGraphics(), camera.viewport);
			p.setProjection(camera.projectionMatrix);
			for (obj in objects) {
				#if !no_debug_console
				stats.geometry++;
				#end
				if(obj.visible && obj.renderable) {
					#if !no_debug_console
					stats.visibleGeometry++;
					#end
					obj.render(p);
				}
			}
			p.end();
			#if !no_debug_console
			stats.add(p.stats);
			#end
		}

		#if !no_debug_console
		_renderer.stats.add(stats);
		#end

		onPostRender.emit();

		Clay.debug.end('renderer.layer.$name');

	}

	inline function getTargetGraphics():Graphics {

		return Clay.renderer.target != null ? Clay.renderer.target.image.g4 : Clay.screen.buffer.image.g4;

	}

	inline function setupAdded(obj:LayerObject) {
		
		obj._layer = this;
		obj.onAdded(this);

	}

	inline function setupRemoved(obj:LayerObject) {
		
		obj.onRemoved(this);
		obj._layer = null;

	}

	inline function sortObjects() {

		if(depthSort && dirtySort) {
			ArraySort.sort(objects, sortLayerObjects);
			dirtySort = false;
		}

	}

	inline function removeObjects() {
		
		if(_objectsToRemove.length > 0) {
			for (o in _objectsToRemove) {
				objects.remove(o);
			}
			ArrayTools.clear(_objectsToRemove);
		}

	}

	inline function sortLayerObjects(a:LayerObject, b:LayerObject):Int {

		if(a.sortKey < b.sortKey) {
			return -1;
		} else if(a.sortKey > b.sortKey) {
			return 1;
		}

		return 0;

	}

	inline function get_active():Bool {

		return _active;

	}
	
	inline function set_active(value:Bool):Bool {

		_active = value;

		if(_manager != null) {
			if(_active){
				_manager.enable(this);
			} else {
				_manager.disable(this);
			}
		}
		
		return _active;

	}


}