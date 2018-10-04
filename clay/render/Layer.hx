package clay.render;


import kha.graphics4.Graphics;

import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
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

		_debug('add geom: ${geom.sort_key}');

		if(ordered) {
			geometry_list.add(geom);
		} else {
			geometry_list.add_first(geom);
		}

		geom.added = true;
		geom.onadded();

	}

	public inline function remove(geom:Geometry) {
		
		_debug('remove geom: ${geom.sort_key}');

		geometry_list.remove(geom);
		geom.added = false;
		geom.onremoved();

	}

	public function render(g:Graphics, cam:Camera) {

		onprerender.emit();

		if(geometry_list.length > 0) {
			_verboser('layer $id render');

			var rp = renderer.renderpath;
			rp.onenter(this, g, cam);

			for (geom in geometry_list) {
				rp.batch(g, geom);
			}

			rp.draw(g);
			rp.onleave(this, g);
		}

		onpostrender.emit();

	}



}