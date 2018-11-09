package clay.render;


import kha.graphics4.Graphics;

import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.render.GeometryList;
import clay.components.graphics.Geometry;
import clay.components.misc.Camera;
import clay.resources.Texture;
import clay.core.Signal;
import clay.utils.Log.*;

import clay.render.RenderStats;


@:access(clay.render.Renderer)
@:access(clay.render.LayerManager)
@:access(clay.components.graphics.Geometry)
class Layer {


	public var name         (default, null):String;
	public var id           (default, null):Int;
	public var active     	(get, set):Bool;

	public var priority     (default, null):Int;

	public var depth_sort:Bool = true; // todo: sort all geom on set?

	public var onprerender  (default, null):Signal<Void->Void>;
	public var onpostrender	(default, null):Signal<Void->Void>;

	public var blend_src:BlendMode;
	public var blend_dst:BlendMode;
	public var blend_eq:BlendEquation;

	#if !no_debug_console
	public var stats        (default, null):RenderStats;
	#end

	@:noCompletion public var geometry_list:GeometryList;

	var _active:Bool = false;

	var renderer:Renderer;
	var manager:LayerManager;


	function new(_manager:LayerManager, _name:String, _id:Int, _priority:Int, _depth_sort:Bool) {

		name = _name;
		id = _id;
		priority = _priority;
		depth_sort = _depth_sort;
		renderer = Clay.renderer;
		manager = _manager;
		geometry_list = new GeometryList();

		onprerender = new Signal();
		onpostrender = new Signal();

		blend_src = BlendMode.Undefined;
		blend_dst = BlendMode.Undefined;
		blend_eq = BlendEquation.Add;

		#if !no_debug_console
		stats = new RenderStats();
		#end
		
	}

	function destroy() {

		for (g in geometry_list) {
			g.added = false;
		}

		geometry_list.clear();

		name = null;
		onprerender = null;
		onpostrender = null;
		geometry_list = null;

	}

	public function add(geom:Geometry) {

		_debug('layer `$name` add geometry: ${geom.name}');

		if(geom._layer != null) {
			geom._layer._remove_unsafe(geom);
		}

		_add_unsafe(geom);

	}

	public function remove(geom:Geometry) {
		
		_debug('layer `$name` remove geometry: ${geom.name}');

		if(geom._layer != this) {
			log('can`t remove geometry `${geom.name}` from layer `$name`');
		} else {
			_remove_unsafe(geom);
		}

	}

	@:noCompletion public function _add_unsafe(geom:Geometry, _sort:Bool = true) {

		_debug('layer `$name` _add_unsafe geometry: ${geom.name}');
		
		if(_sort && depth_sort) {
			geometry_list.add(geom);
		} else {
			geometry_list.add_first(geom);
		}

		geom._layer = this;
		geom.added = true;

	}

	@:noCompletion public function _remove_unsafe(geom:Geometry) {

		_debug('layer `$name` _remove_unsafe geometry: ${geom.name}');

		geometry_list.remove(geom);
		geom._layer = null;
		geom.added = false;

	}

	public function render(g:Graphics, cam:Camera) {

		_verboser('layer `$name` render');

		onprerender.emit();

		#if !no_debug_console
		stats.reset();
		#end

		if(geometry_list.length > 0) {

			var rp = renderer.renderpath;
			rp.onenter(this, g, cam);

			for (geom in geometry_list) {
				rp.batch(g, geom);
			}

			rp.draw(g);
			rp.onleave(this, g);
		}

		#if !no_debug_console
		renderer.stats.add(stats);
		#end

		onpostrender.emit();

	}

	inline function get_active():Bool {

		return _active;

	}
	
	inline function set_active(value:Bool):Bool {

		_active = value;

		if(manager != null) {
			if(_active){
				manager.enable(this);
			} else {
				manager.disable(this);
			}
		}
		
		return _active;

	}


}