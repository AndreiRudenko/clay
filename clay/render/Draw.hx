package clay.render;


// import kha.graphics4.Graphics;
import clay.components.Geometry;
import clay.render.Layer;
import clay.math.Vector;
import clay.data.Color;


class Draw {

	// image, text, geom cache

	var to_remove:Array<Geometry>;


    @:allow(clay.Engine)
	inline function new() {

		to_remove = [];
		
	}

	public function line() {
		
	}

	public function rectangle() {
		
	}

	public function circle() {
		
	}

	public function polygon() {
		
	}

	public function texture() {
		
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

		if(to_remove.length > 0) {
			var lr:Layer = null;

			for (g in to_remove) {
				lr = Clay.renderer.layers.get(g.layer);
				lr.remove(g);
			}

			to_remove.splice(0, to_remove.length);
		}
		
	}
	

}