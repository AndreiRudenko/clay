package clay.processors.graphics;


import clay.Processor;
import clay.Family;

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

	var quad_family:Family<QuadGeometry>;
	var qt_family:Family<QuadGeometry,Transform>;

	var quadpack_family:Family<QuadPack>;
	var qpt_family:Family<QuadPack,Transform>;

	var text_family:Family<Text>;
	var tt_family:Family<Text,Transform>;

	var ns_family:Family<NineSlice>;
	var nst_family:Family<NineSlice,Transform>;

	var lg_family:Family<LineGeometry>;


	public function new() {

		renderer = Clay.renderer;

		super();

	}

	override function onadded() {
	
		geom_family.listen(geom_added, geom_removed);
		gt_family.listen(gt_added, gt_removed);

		quad_family.listen(quad_added, quad_removed);
		qt_family.listen(qt_added, qt_removed);

		quadpack_family.listen(quadpack_added, quadpack_removed);
		qpt_family.listen(qpt_added, qpt_removed);

		text_family.listen(text_added, text_removed);
		tt_family.listen(tt_added, tt_removed);

		ns_family.listen(ns_added, ns_removed);
		nst_family.listen(nst_added, nst_removed);

		lg_family.listen(lg_added, lg_removed);

	}

	override function onremoved() {

		geom_family.unlisten(geom_added, geom_removed);
		gt_family.unlisten(gt_added, gt_removed);

		quad_family.unlisten(quad_added, quad_removed);
		qt_family.unlisten(qt_added, qt_removed);

		quadpack_family.unlisten(quadpack_added, quadpack_removed);
		qpt_family.unlisten(qpt_added, qpt_removed);

		text_family.unlisten(text_added, text_removed);
		tt_family.unlisten(tt_added, tt_removed);

		ns_family.unlisten(ns_added, ns_removed);
		nst_family.unlisten(nst_added, nst_removed);

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


	// quad

	function quad_added(e:Entity) {

		var geom = quad_family.get_quadgeometry(e);
		add_geom_to_renderer(geom);

	}
	
	function quad_removed(e:Entity) {

		var geom = quad_family.get_quadgeometry(e);
		remove_geom_from_renderer(geom);

	}

	function qt_added(e:Entity) {

		var g = qt_family.get_quadgeometry(e);
		var t = qt_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function qt_removed(e:Entity) {

		var g = qt_family.get_quadgeometry(e);
		remove_transform_from_geom(g);

	}


	// quadpack

	function quadpack_added(e:Entity) {

		var geom = quadpack_family.get_quadpack(e);
		add_geom_to_renderer(geom);

	}
	
	function quadpack_removed(e:Entity) {

		var geom = quadpack_family.get_quadpack(e);
		remove_geom_from_renderer(geom);

	}

	function qpt_added(e:Entity) {

		var g = qpt_family.get_quadpack(e);
		var t = qpt_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function qpt_removed(e:Entity) {

		var g = qpt_family.get_quadpack(e);
		remove_transform_from_geom(g);

	}


	// nineslice

	function ns_added(e:Entity) {

		var g = ns_family.get_nineslice(e);
		add_geom_to_renderer(g);

	}
	
	function ns_removed(e:Entity) {

		var g = ns_family.get_nineslice(e);
		remove_geom_from_renderer(g);

	}

	function nst_added(e:Entity) {

		var g = nst_family.get_nineslice(e);
		var t = nst_family.get_transform(e);
		add_transform_to_geom(t, g);

	}
	
	function nst_removed(e:Entity) {

		var g = nst_family.get_nineslice(e);
		remove_transform_from_geom(g);

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

		var g = lg_family.get_linegeometry(e);
		add_geom_to_renderer(g);

	}
	
	function lg_removed(e:Entity) {

		var g = lg_family.get_linegeometry(e);
		remove_geom_from_renderer(g);

	}

	inline function add_geom_to_renderer(g:Geometry) {

		if(g.added) {
			log('Error geometry `${g.name}` already added');
		} else {
			if(g.layer == null) {
				if(Clay.renderer.layer != null) {
					Clay.renderer.layer._add_unsafe(g);
				} else {
					log('Error adding geometry `${g.name}` to Clay.renderer.layer');
				}
			} else {
				g.layer._add_unsafe(g);
			}
		}

	}

	inline function remove_geom_from_renderer(g:Geometry) {
		
		g.drop();

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
