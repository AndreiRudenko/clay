package clay.processors.graphics;


import clay.Processor;
import clay.Family;

import clay.components.graphics.Texture;
import clay.components.common.Transform;
import clay.components.graphics.Geometry;
import clay.components.graphics.QuadGeometry;
import clay.components.graphics.QuadPack;
import clay.components.graphics.NineSlice;
import clay.components.graphics.Text;
import clay.components.graphics.LineGeometry;

import clay.math.Matrix;
import clay.render.Renderer;
import clay.utils.Log.*;


@:access(clay.render.Renderer)
class RenderProcessor extends Processor {


	var renderer:Renderer;

	var geom_family:Family<Geometry>;
	var gt_family:Family<Geometry,Transform>;
	var gtex_family:Family<Geometry,Texture>;

	var quad_family:Family<QuadGeometry>;
	var qt_family:Family<QuadGeometry,Transform>;
	var qtex_family:Family<QuadGeometry,Texture>;

	var quadpack_family:Family<QuadPack>;
	var qpt_family:Family<QuadPack,Transform>;
	var qptex_family:Family<QuadPack,Texture>;

	var text_family:Family<Text>;
	var tt_family:Family<Text,Transform>;

	var ns_family:Family<NineSlice>;
	var nst_family:Family<NineSlice,Transform>;
	var nstex_family:Family<NineSlice,Texture>;

	var lg_family:Family<LineGeometry>;


	public function new() {

		renderer = Clay.renderer;

		super();

	}

	override function onadded() {
	
		geom_family.listen(geom_added, geom_removed);
		gt_family.listen(gt_added, gt_removed);
		gtex_family.listen(gtex_added, gtex_removed);

		quad_family.listen(quad_added, quad_removed);
		qt_family.listen(qt_added, qt_removed);
		qtex_family.listen(qtex_added, qtex_removed);

		quadpack_family.listen(quadpack_added, quadpack_removed);
		qpt_family.listen(qpt_added, qpt_removed);
		qptex_family.listen(qptex_added, qptex_removed);

		text_family.listen(text_added, text_removed);
		tt_family.listen(tt_added, tt_removed);

		ns_family.listen(ns_added, ns_removed);
		nst_family.listen(nst_added, nst_removed);
		nstex_family.listen(nstex_added, nstex_removed);

		lg_family.listen(lg_added, lg_removed);

	}

	override function onremoved() {

		geom_family.unlisten(geom_added, geom_removed);
		gt_family.unlisten(gt_added, gt_removed);
		gtex_family.unlisten(gtex_added, gtex_removed);

		quad_family.unlisten(quad_added, quad_removed);
		qt_family.unlisten(qt_added, qt_removed);
		qtex_family.unlisten(qtex_added, qtex_removed);

		quadpack_family.unlisten(quadpack_added, quadpack_removed);
		qpt_family.unlisten(qpt_added, qpt_removed);
		qptex_family.unlisten(qptex_added, qptex_removed);

		text_family.unlisten(text_added, text_removed);
		tt_family.unlisten(tt_added, tt_removed);

		ns_family.unlisten(ns_added, ns_removed);
		nst_family.unlisten(nst_added, nst_removed);
		nstex_family.unlisten(nstex_added, nstex_removed);

		lg_family.listen(lg_added, lg_removed);

	}

	// geometry

	function geom_added(e:Entity) {

		var geom = geom_family.get_geometry(e);
		add_geom_to_renderer(geom);

	}
	
	function geom_removed(e:Entity) {

		var geom = geom_family.get_geometry(e);
		remove_geom_from_renderer(geom);

	}

	function gt_added(e:Entity) {

		var g = gt_family.get_geometry(e);
		var t = gt_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function gt_removed(e:Entity) {

		var g = gt_family.get_geometry(e);
		remove_transform_from_geom(g);

	}

	function gtex_added(e:Entity) {

		var g = gtex_family.get_geometry(e);
		var tex = gtex_family.get_texture(e);
		g.texture = tex;

	}
	
	function gtex_removed(e:Entity) {

		var g = gtex_family.get_geometry(e);
		g.texture = null;

	}



	// quad

	function quad_added(e:Entity) {

		var geom = quad_family.get_quadGeometry(e);
		add_geom_to_renderer(geom);

	}
	
	function quad_removed(e:Entity) {

		var geom = quad_family.get_quadGeometry(e);
		remove_geom_from_renderer(geom);

	}

	function qt_added(e:Entity) {

		var g = qt_family.get_quadGeometry(e);
		var t = qt_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function qt_removed(e:Entity) {

		var g = qt_family.get_quadGeometry(e);
		remove_transform_from_geom(g);

	}

	function qtex_added(e:Entity) {

		var g = qtex_family.get_quadGeometry(e);
		var tex = qtex_family.get_texture(e);
		g.texture = tex;

	}
	
	function qtex_removed(e:Entity) {

		var g = qtex_family.get_quadGeometry(e);
		g.texture = null;

	}


	// quadpack

	function quadpack_added(e:Entity) {

		var geom = quadpack_family.get_quadPack(e);
		add_geom_to_renderer(geom);

	}
	
	function quadpack_removed(e:Entity) {

		var geom = quadpack_family.get_quadPack(e);
		remove_geom_from_renderer(geom);

	}

	function qpt_added(e:Entity) {

		var g = qpt_family.get_quadPack(e);
		var t = qpt_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function qpt_removed(e:Entity) {

		var g = qpt_family.get_quadPack(e);
		remove_transform_from_geom(g);

	}

	function qptex_added(e:Entity) {

		var g = qptex_family.get_quadPack(e);
		var tex = qptex_family.get_texture(e);
		g.texture = tex;

	}
	
	function qptex_removed(e:Entity) {

		var g = qptex_family.get_quadPack(e);
		g.texture = null;

	}

	// nineslice

	function ns_added(e:Entity) {

		var g = ns_family.get_nineSlice(e);
		add_geom_to_renderer(g);

	}
	
	function ns_removed(e:Entity) {

		var g = ns_family.get_nineSlice(e);
		remove_geom_from_renderer(g);

	}

	function nst_added(e:Entity) {

		var g = nst_family.get_nineSlice(e);
		var t = nst_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function nst_removed(e:Entity) {

		var g = nst_family.get_nineSlice(e);
		remove_transform_from_geom(g);

	}

	function nstex_added(e:Entity) {

		var g = nstex_family.get_nineSlice(e);
		var tex = nstex_family.get_texture(e);
		g.texture = tex;

	}
	
	function nstex_removed(e:Entity) {

		var g = nstex_family.get_nineSlice(e);
		g.texture = null;

	}

	// text

	function text_added(e:Entity) {

		var txt = text_family.get_text(e);
		add_geom_to_renderer(txt);

	}
	
	function text_removed(e:Entity) {

		var txt = text_family.get_text(e);
		remove_geom_from_renderer(txt);

	}

	function tt_added(e:Entity) {

		var g = tt_family.get_text(e);
		var t = tt_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function tt_removed(e:Entity) {

		var g = tt_family.get_text(e);
		remove_transform_from_geom(g);

	}


	// line
	
	function lg_added(e:Entity) {

		var g = lg_family.get_lineGeometry(e);
		add_geom_to_renderer(g);

	}
	
	function lg_removed(e:Entity) {

		var g = lg_family.get_lineGeometry(e);
		remove_geom_from_renderer(g);

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

	@:access(clay.components.graphics.Geometry)
	inline function add_transform_to_geom(t:Transform, g:Geometry) {

		g.transform_matrix = t.world;

	}

	@:access(clay.components.graphics.Geometry)
	inline function remove_transform_from_geom(g:Geometry) {

		g.transform_matrix = new Matrix();

	}


}
