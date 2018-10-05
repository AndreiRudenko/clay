package clay.render;


import kha.graphics4.Graphics;

import clay.render.Layer;
import clay.components.misc.Camera;

@:access(clay.components.misc.Camera)
class LayerManager {


	var ids:Int = 0;
	var layers:Array<Layer>;


	public function new() {
		
		layers = [];

	}

	public inline function get(i:Int):Layer {

		return layers[i];

	}

	public function create(_ordered:Bool = true):Int {

		layers.push(new Layer(ids++, this, _ordered));

		return layers.length-1;

	}

	public function clear() {

		for (l in layers) {
			l.destroy();
		}

		layers.splice(0, layers.length);

		ids = 0;
		
	}

	public inline function render(_:Graphics, cam:Camera) {

		for (l in layers) {
			if(cam.visible_layers_mask[l.id]) {
				l.render(Clay.renderer.target.image.g4, cam);
			}
		}
		
	}

}