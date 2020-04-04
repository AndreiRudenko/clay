package clay.render;

import kha.graphics4.Graphics;

import clay.render.LayerObject;
import clay.render.Camera;
import clay.events.Signal;
import clay.utils.ArrayTools;
import clay.utils.Log.*;

import clay.render.RenderStats;
import clay.render.RenderContext;
import haxe.ds.ArraySort;

@:access(
	clay.render.Renderer,
	clay.render.Layers,
	clay.render.LayerObject
)
class Layer {

	public var name:String;
	public var id(default, null):Int;
	public var active(default, null):Bool;

	public var objects(default, null):Array<LayerObject>;

	public var depthSort:Bool = true;
	public var dirtySort:Bool = true;

	#if !no_debug_console
	public var stats(default, null):RenderStats;
	#end

	var _objectsToRemove:Array<LayerObject>;

	public function new(name:String, id:Int = -1) {
		this.name = name;
		this.id = id;
		active = false;

		objects = [];
		_objectsToRemove = [];

		#if !no_debug_console
		stats = new RenderStats();
		#end
	}

	function destroy() {
		empty();
		name = null;
		objects = null;
	}

	public function add(obj:LayerObject) {
		_debug('layer `$name` add: ${obj.name}');

		if(obj.layer != this) {
			obj.drop();
			addUnsafe(obj);
		} else {
			log('`${obj.name}` already added to layer `$name`');
		}
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

	public function render(ctx:RenderContext) {
		_verboser('layer `$name` render');

		#if !no_debug_console
		stats.reset();
		#end

		if(objects.length > 0) {
			#if !no_debug_console
			ctx.setStats(stats);
			#end

			for (obj in objects) {
				#if !no_debug_console
				stats.geometry++;
				#end
				if(obj.visible && obj.renderable) {
					#if !no_debug_console
					stats.visibleGeometry++;
					#end
					obj.render(ctx);
				}
			}
			ctx.flush();
		}
	}

	public function empty() {
		removeObjects();
		for (g in objects) {
			g.layer = null;
		}
		ArrayTools.clear(objects);
	}

	public inline function dirty() {
		if(depthSort) {
			dirtySort = true;
		}
	}

	inline function setupAdded(obj:LayerObject) {
		obj.layer = this;
		obj.onAdded();
	}

	inline function setupRemoved(obj:LayerObject) {
		obj.onRemoved();
		obj.layer = null;
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

}