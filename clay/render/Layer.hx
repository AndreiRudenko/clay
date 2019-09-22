package clay.render;


import kha.graphics4.Graphics;

import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.render.DisplayObject;
import clay.render.Camera;
import clay.resources.Texture;
import clay.events.Signal;
import clay.utils.Log.*;

import clay.render.RenderStats;
import haxe.ds.ArraySort;


@:access(clay.render.Renderer)
@:access(clay.render.LayerManager)
@:access(clay.render.DisplayObject)
class Layer {


	public var name(default, null):String;
	public var id(default, null):Int;
	public var active(get, set):Bool;

	public var objects(default, null):Array<DisplayObject>;

	public var priority(default, null):Int;

	public var depthSort:Bool = true;
	public var dirtySort:Bool = true;

	public var onpreRender(default, null):Signal<()->Void>;
	public var onpostRender(default, null):Signal<()->Void>;

	public var blendSrc:BlendFactor;
	public var blendDst:BlendFactor;
	public var blendOp:BlendOperation;

	#if !no_debug_console
	public var stats(default, null):RenderStats;
	#end

	var _active:Bool;
	var _objectsToRemove:Array<DisplayObject>;
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

		onpreRender = new Signal();
		onpostRender = new Signal();

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
		onpreRender = null;
		onpostRender = null;
		objects = null;

	}

	public function add(geom:DisplayObject) {

		_debug('layer `$name` add geometry: ${geom.name}');

		if(geom._layer != null) {
			geom._layer._removeUnsafe(geom);
		}

		_addUnsafe(geom);

	}

	public function remove(geom:DisplayObject) {
		
		_debug('layer `$name` remove geometry: ${geom.name}');

		if(geom._layer != this) {
			log('can`t remove geometry `${geom.name}` from layer `$name`');
		} else {
			_removeUnsafe(geom);
		}

	}

	@:noCompletion public function _addUnsafe(geom:DisplayObject, _dirtySort:Bool = true) {

		_debug('layer `$name` _addUnsafe geometry: ${geom.name}');
		
		objects.push(geom);
		geom._layer = this;

		if(_dirtySort) {
			dirtySort = true;
		}

	}

	@:noCompletion public function _removeUnsafe(geom:DisplayObject) {

		_debug('layer `$name` _removeUnsafe geometry: ${geom.name}');

		_objectsToRemove.push(geom);
		geom._layer = null;

	}

	public function update(dt:Float) {

		for (o in objects) {
			o.update(dt);
		}
		
	}

	public function render(cam:Camera) {

		_verboser('layer `$name` render');

		Clay.debug.start('renderer.layer.$name');

		onpreRender.emit();

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : Clay.screen.buffer.image.g4;

		removeObjects();
		sortObjects();

		#if !no_debug_console
		stats.reset();
		#end

		if(objects.length > 0) {
			var p = _renderer.painter;
			p.begin(g, cam.viewport);
			p.setProjection(cam.projectionMatrix);
			for (o in objects) {
				#if !no_debug_console
				stats.geometry++;
				#end
				if(o.visible) {
					#if !no_debug_console
					stats.visibleGeometry++;
					#end
					o.render(p);
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

		onpostRender.emit();

		Clay.debug.end('renderer.layer.$name');

	}

	inline function sortObjects() {

		if(depthSort && dirtySort) {
			ArraySort.sort(objects, sortDisplayObjects);
			dirtySort = false;
		}

	}

	inline function removeObjects() {
		
		if(_objectsToRemove.length > 0) {
			for (o in _objectsToRemove) {
				objects.remove(o);
			}
			_objectsToRemove.splice(0, _objectsToRemove.length);
		}

	}

	inline function sortDisplayObjects(a:DisplayObject, b:DisplayObject):Int {

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