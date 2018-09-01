package clay.processors;


import clay.ComponentMapper;
import clay.Processor;
import clay.Family;

import clay.components.Texture;
import clay.components.Transform;
import clay.components.Geometry;
import clay.components.QuadGeometry;
import clay.components.QuadPackGeometry;
import clay.components.Text;

import clay.render.Renderer;
import clay.utils.Log.*;


@:access(clay.render.Renderer)
class RenderProcessor extends Processor {


	var renderer:Renderer;

	var geom_family:Family<Geometry>;
	var quad_family:Family<QuadGeometry>;
	var quadpack_family:Family<QuadPackGeometry>;
	var text_family:Family<Text>;
	var gt_family:Family<Geometry,Transform>;
	var qt_family:Family<QuadGeometry,Transform>;
	var qpt_family:Family<QuadPackGeometry,Transform>;
	var tt_family:Family<Text,Transform>;
	var gtex_family:Family<Geometry,Texture>;
	var qtex_family:Family<QuadGeometry,Texture>;
	var qptex_family:Family<QuadPackGeometry,Texture>;

	var geom_comps:ComponentMapper<Geometry>;
	var quad_comps:ComponentMapper<QuadGeometry>;
	var quadpack_comps:ComponentMapper<QuadPackGeometry>;
	var transform_comps:ComponentMapper<Transform>;
	var texture_comps:ComponentMapper<Texture>;
	var text_comps:ComponentMapper<Text>;


	public function new() {

		renderer = Clay.renderer;

		super();

	}

	override function onadded() {
	
		geom_family.listen(geom_added, geom_removed);
		quad_family.listen(quad_added, quad_removed);
		quadpack_family.listen(quadpack_added, quadpack_removed);
		text_family.listen(text_added, text_removed);
		tt_family.listen(tt_added, tt_removed);
		gt_family.listen(gt_added, gt_removed);
		qt_family.listen(qt_added, qt_removed);
		qpt_family.listen(qpt_added, qpt_removed);
		gtex_family.listen(gtex_added, gtex_removed);
		qtex_family.listen(qtex_added, qtex_removed);
		qptex_family.listen(qptex_added, qptex_removed);

	}

	override function onremoved() {

		geom_family.unlisten(geom_added, geom_removed);
		quad_family.unlisten(quad_added, quad_removed);
		quadpack_family.unlisten(quadpack_added, quadpack_removed);
		text_family.unlisten(text_added, text_removed);
		tt_family.unlisten(tt_added, tt_removed);
		gt_family.unlisten(gt_added, gt_removed);
		qpt_family.unlisten(qpt_added, qpt_removed);
		qt_family.unlisten(qt_added, qt_removed);
		gtex_family.unlisten(gtex_added, gtex_removed);
		qptex_family.unlisten(qptex_added, qptex_removed);

	}

	// geometry

	function geom_added(e:Entity) {

		var geom = geom_comps.get(e);
		add_geom_to_renderer(geom);

	}
	
	function geom_removed(e:Entity) {

		// log('geom_removed');
		var geom = geom_comps.get(e);
		remove_geom_from_renderer(geom);

	}

	function quad_added(e:Entity) {

		var geom = quad_comps.get(e);
		add_geom_to_renderer(geom);

	}
	
	function quad_removed(e:Entity) {

		// log('geom_removed');
		var geom = quad_comps.get(e);
		remove_geom_from_renderer(geom);

	}

	function quadpack_added(e:Entity) {

		// log('quadpack_added');
		var geom = quadpack_comps.get(e);
		add_geom_to_renderer(geom);

	}
	
	function quadpack_removed(e:Entity) {

		// log('quadpack_removed');
		var geom = quadpack_comps.get(e);
		remove_geom_from_renderer(geom);

	}

	function gt_added(e:Entity) {

		var g = geom_comps.get(e);
		var t = transform_comps.get(e);
		g.transform_matrix.copy(t.world);

	}
	
	function gt_removed(e:Entity) {

		var g = geom_comps.get(e);
		g.transform_matrix.identity();

	}

	function qt_added(e:Entity) {

		var g = quad_comps.get(e);
		var t = transform_comps.get(e);
		g.transform_matrix.copy(t.world);

	}
	
	function qt_removed(e:Entity) {

		var g = quad_comps.get(e);
		g.transform_matrix.identity();

	}

	function qpt_added(e:Entity) {

		var g = quadpack_comps.get(e);
		var t = transform_comps.get(e);
		g.transform_matrix.copy(t.world);

	}
	
	function qpt_removed(e:Entity) {

		var g = quadpack_comps.get(e);
		g.transform_matrix.identity();

	}

	function gtex_added(e:Entity) {

		var g = geom_comps.get(e);
		var tex = texture_comps.get(e);
		g.texture = tex;
		// g.geometry_type = GeometryType.textured;

	}
	
	function gtex_removed(e:Entity) {

		var g = geom_comps.get(e);
		g.texture = null;
		// g.geometry_type = GeometryType.color;

	}

	function qtex_added(e:Entity) {

		var g = quad_comps.get(e);
		var tex = texture_comps.get(e);
		g.texture = tex;
		// g.geometry_type = GeometryType.textured;

	}
	
	function qtex_removed(e:Entity) {

		var g = quad_comps.get(e);
		g.texture = null;
		// g.geometry_type = GeometryType.color;

	}

	function qptex_added(e:Entity) {

		// log('qptex_added');
		var g = quadpack_comps.get(e);
		var tex = texture_comps.get(e);
		g.texture = tex;
		// g.geometry_type = GeometryType.textured;

	}
	
	function qptex_removed(e:Entity) {

		// log('qptex_removed');
		var g = quadpack_comps.get(e);
		g.texture = null;
		// g.geometry_type = GeometryType.color;

	}


	// text

	function text_added(e:Entity) {

		var txt = text_comps.get(e);
		add_geom_to_renderer(txt);
		// txt.geometry_type = GeometryType.text;

	}
	
	function text_removed(e:Entity) {

		// log('geom_removed');
		var txt = text_comps.get(e);
		remove_geom_from_renderer(txt);

	}

	function tt_added(e:Entity) {

		var txt = text_comps.get(e);
		var t = transform_comps.get(e);
		txt.transform_matrix.copy(t.world);

	}
	
	function tt_removed(e:Entity) {

		var txt = text_comps.get(e);
		txt.transform_matrix.identity();

	}

	inline function add_geom_to_renderer(g:Geometry) {

		var layer = renderer.layers.get(g.layer);
		if(layer == null) {
			log('Error adding geometry to layer ${g.layer}');
			return;
		}

		layer.add(g);

	}

	inline function remove_geom_from_renderer(g:Geometry) {
		
		var layer = renderer.layers.get(g.layer);
		if(layer == null) {
			log('Error removing geometry from layer ${g.layer}');
			return;
		}

		layer.remove(g);

	}

	override function update(dt:Float) {

		var g:Geometry = null;
		var q:QuadGeometry = null;
		var qp:QuadPackGeometry = null;
		var t:Transform = null;
		var txt:Text = null;

		for (e in gt_family) {	
			g = geom_comps.get(e);
			t = transform_comps.get(e);
			g.transform_matrix.copy(t.world);
		}

		for (e in qt_family) {	
			q = quad_comps.get(e);
			t = transform_comps.get(e);
			if(q.dirty) {
				if(q.centered) {
					t.origin.set(q.size.x*0.5, q.size.y*0.5);
				}
			}
			q.transform_matrix.copy(t.world);
		}

		for (e in qpt_family) {	
			qp = quadpack_comps.get(e);
			t = transform_comps.get(e);
			qp.transform_matrix.copy(t.world);
		}

		for (e in tt_family) {	
			txt = text_comps.get(e);
			t = transform_comps.get(e);
			txt.transform_matrix.copy(t.world);
		}

	}



}
