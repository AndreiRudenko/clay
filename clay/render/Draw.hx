package clay.render;


// import kha.graphics4.Graphics;
import clay.components.graphics.Geometry;
import clay.render.Layer;
import clay.math.Vector;
import clay.data.Color;


class Draw {

	// image, text, geom cache

	var geometry:Array<Geometry>;


    @:allow(clay.Engine)
	inline function new() {

		geometry = [];
		
	}

	public function line() {
		
	}

	public function rectangle() {
		
	}

	public function circle() {
		
	}

	public function polygon() {
		
	}

	public function image() {
		
	}

	public function text() {
		
	}

    @:allow(clay.Engine)
	function init() {
		
	}

    @:allow(clay.Engine)
	function prerender() {
		
	}

    @:allow(clay.Engine)
	function postrender() {

		if(geometry.length > 0) {
			var lr:Layer = null;

			for (g in geometry) {
				lr = Clay.renderer.layers.get(g.layer);
				lr.remove(g);
			}

			geometry.splice(0, geometry.length);
		}
		
	}
	

}