package clay.render;


import clay.math.Rectangle;
import clay.math.Transform;
import clay.math.VectorCallback;
import clay.render.SortKey;
import clay.render.Layer;
import clay.render.Shader;
import clay.render.Painter;
import clay.render.Camera;
import clay.utils.Log.*;


@:allow(clay.render.Layer)
class LayerObject {

		// The name
	public var name:String;
		// Controls whether `update()` is automatically called by `Layer`
	public var active(default, set):Bool;
		// Controls whether `render()` is automatically called by `Layer`
	public var visible(default, set):Bool;
		// Addition variable to control rendering, same as visible
	public var renderable:Bool;
		// Gets ot sets the layer of this object.
	public var layer(get, never):Layer;
		// Object depth, used for layer sorting
	public var depth(get, set):Float;
		// Object sort key, used for layer sorting
	public var sortKey(default, null):SortKey;

	var _layer:Layer;
	var _depth:Float;
	

	public function new() {
		
		visible = true;
		active = true;
		renderable = true;
		name = 'layerObject.${clay.utils.UUID.get()}';
		sortKey = new SortKey(0,0);
		_depth = 0;

	}

	public function drop() {
		
		if(_layer != null) {
			_layer.removeUnsafe(this);
		}

	}

	public function update(dt:Float) {}
	public function render(p:Painter) {}

	function onAdded(l:Layer) {}
	function onRemoved(l:Layer) {}

	function set_active(v:Bool):Bool {

		return active = v;

	}

	function set_visible(v:Bool):Bool {

		return visible = v;

	}

	inline function get_layer():Layer {

		return _layer;

	}

	inline function get_depth():Float {

		return _depth;

	}

	function set_depth(v:Float):Float {

		sortKey.depth = v;

		dirtySort();

		return _depth = v;

	}

	inline function dirtySort() {

		if(layer != null && layer.depthSort) {
			layer.dirtySort = true;
		}

	}
	

}