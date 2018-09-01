package clay.render;


import kha.graphics4.Graphics;

import clay.render.Painter;
import clay.render.GeometryList;
import clay.components.Geometry;
import clay.components.Camera;
import clay.components.Texture;
import clay.emitters.Signal;
// import ds.DynamicPool;

import clay.utils.Log.*;


@:access(clay.render.Renderer)
@:access(clay.render.LayerManager)
@:access(clay.components.Geometry)
class Layer {


	public var id(default, null):Int;
	public var ordered:Bool = true;

	public var onprerender  (default, null):Signal<Void->Void>;
	public var onpostrender	(default, null):Signal<Void->Void>;

	public var blend_src:BlendMode;
	public var blend_dst:BlendMode;
	public var blend_eq:BlendEquation;

	var renderer:Renderer;
	var geometry_list:GeometryList;
	var manager:LayerManager;

	var inited:Bool = false;


	public function new(_id:Int, _manager:LayerManager, _ordered:Bool) {

		id = _id;
		ordered = _ordered;
		renderer = Clay.renderer;
		manager = _manager;
		geometry_list = new GeometryList();

		onprerender = new Signal();
		onpostrender = new Signal();

		blend_src = BlendMode.SourceAlpha;
		blend_dst = BlendMode.InverseSourceAlpha;
		blend_eq = BlendEquation.Add;
		
	}

	public function destroy() {

		inited = false;

		for (g in geometry_list) {
			g.added = false;
		}

		geometry_list.clear();

	}

	public inline function add(geom:Geometry) {

		_debug('add geom: ${geom.id}');

		if(ordered) {
			geometry_list.add(geom);
		} else {
			geometry_list.add_first(geom);
		}

		geom.added = true;

	}

	public inline function remove(geom:Geometry) {
		
		_debug('remove geom: ${geom.id}');

		geometry_list.remove(geom);
		geom.added = false;

	}

	public function render(g:Graphics, cam:Camera) {

		if(geometry_list.length == 0) {
			return;
		}

		_verboser('layer $id render');

		var ptrs = Clay.renderer.painters;

		var p:Painter = null;
		var lst_p:Painter = null;
		for (geom in geometry_list) {
			p = ptrs[geom.geometry_type];
			if(lst_p != p) {
				if(lst_p != null) {
					lst_p.draw(g);
					lst_p.onleave(this, g);
				}
				lst_p = p;
				p.onenter(this, g, cam);
			}
			p.batch(g, geom);
		}

		for (o in ptrs) {
			o.draw(g);
		}

		if(lst_p != null) {
			lst_p.onleave(this, g);
		}

	}



}