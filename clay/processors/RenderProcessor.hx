package clay.processors;


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
	var gt_family:Family<Geometry,Transform>;
	var gtex_family:Family<Geometry,Texture>;

	var quad_family:Family<QuadGeometry>;
	var qt_family:Family<QuadGeometry,Transform>;
	var qtex_family:Family<QuadGeometry,Texture>;

	var quadpack_family:Family<QuadPackGeometry>;
	var qpt_family:Family<QuadPackGeometry,Transform>;
	var qptex_family:Family<QuadPackGeometry,Texture>;

	var text_family:Family<Text>;
	var tt_family:Family<Text,Transform>;


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

		var geom = geom_family.get_geometry(e);
		add_geom_to_renderer(geom);

	}
	
	function geom_removed(e:Entity) {

		var geom = geom_family.get_geometry(e);
		remove_geom_from_renderer(geom);

	}

	function quad_added(e:Entity) {

		var geom = quad_family.get_quadGeometry(e);
		add_geom_to_renderer(geom);

	}
	
	function quad_removed(e:Entity) {

		var geom = quad_family.get_quadGeometry(e);
		remove_geom_from_renderer(geom);

	}

	function quadpack_added(e:Entity) {

		var geom = quadpack_family.get_quadPackGeometry(e);
		add_geom_to_renderer(geom);

	}
	
	function quadpack_removed(e:Entity) {

		var geom = quadpack_family.get_quadPackGeometry(e);
		remove_geom_from_renderer(geom);

	}

	function gt_added(e:Entity) {

		var g = gt_family.get_geometry(e);
		var t = gt_family.get_transform(e);
		g.transform_matrix.copy(t.world);

	}
	
	function gt_removed(e:Entity) {

		var g = gt_family.get_geometry(e);
		g.transform_matrix.identity();

	}

	function qt_added(e:Entity) {

		var g = qt_family.get_quadGeometry(e);
		var t = qt_family.get_transform(e);
		g.transform_matrix.copy(t.world);

	}
	
	function qt_removed(e:Entity) {

		var g = qt_family.get_quadGeometry(e);
		g.transform_matrix.identity();

	}

	function qpt_added(e:Entity) {

		var g = qpt_family.get_quadPackGeometry(e);
		var t = qpt_family.get_transform(e);
		g.transform_matrix.copy(t.world);

	}
	
	function qpt_removed(e:Entity) {

		var g = qpt_family.get_quadPackGeometry(e);
		g.transform_matrix.identity();

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

	function qtex_added(e:Entity) {

		var g = qtex_family.get_quadGeometry(e);
		var tex = qtex_family.get_texture(e);
		g.texture = tex;

	}
	
	function qtex_removed(e:Entity) {

		var g = qtex_family.get_quadGeometry(e);
		g.texture = null;

	}

	function qptex_added(e:Entity) {

		var g = qptex_family.get_quadPackGeometry(e);
		var tex = qptex_family.get_texture(e);
		g.texture = tex;

	}
	
	function qptex_removed(e:Entity) {

		var g = qptex_family.get_quadPackGeometry(e);
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

		var txt = tt_family.get_text(e);
		var t = tt_family.get_transform(e);
		txt.transform_matrix.copy(t.world);

	}
	
	function tt_removed(e:Entity) {

		var txt = tt_family.get_text(e);
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
			g = gt_family.get_geometry(e);
			t = gt_family.get_transform(e);
			g.transform_matrix.copy(t.world);
		}

		for (e in qt_family) {	
			q = qt_family.get_quadGeometry(e);
			t = qt_family.get_transform(e);
			q.transform_matrix.copy(t.world);
		}

		for (e in qpt_family) {	
			qp = qpt_family.get_quadPackGeometry(e);
			t = qpt_family.get_transform(e);
			qp.transform_matrix.copy(t.world);
		}

		for (e in tt_family) {	
			txt = tt_family.get_text(e);
			t = tt_family.get_transform(e);
			txt.transform_matrix.copy(t.world);
		}

	}


}
