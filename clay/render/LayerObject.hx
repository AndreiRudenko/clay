package clay.render;

import clay.math.Rectangle;
import clay.math.Transform;
import clay.math.VectorCallback;
import clay.render.SortKey;
import clay.render.Layer;
import clay.render.Shader;
import clay.render.RenderContext;
import clay.render.Camera;
import clay.utils.Log.*;

@:allow(clay.render.Layer)
class LayerObject {

	public var name:String;
	public var active(default, set):Bool;
	public var visible(default, set):Bool;
	public var renderable:Bool;
	public var layer(default, null):Layer;
	public var depth(get, set):Float;
	public var sortKey(default, null):SortKey;

	public function new() {
		name = 'layerObject.${clay.utils.UUID.get()}';
		active = true;
		visible = true;
		renderable = true;
		sortKey = new SortKey(0,0);
	}

	public function drop() {
		if(layer != null) {
			layer.removeUnsafe(this);
		}
	}

	public function update(dt:Float) {}
	public function render(ctx:RenderContext) {}

	public function destroy() {
		drop();
		name = null;
		sortKey = null;
	}

	function onAdded() {}
	function onRemoved() {}

	function set_active(v:Bool):Bool {
		return active = v;
	}

	function set_visible(v:Bool):Bool {
		return visible = v;
	}

	inline function get_depth():Float {
		return sortKey.depth;
	}

	function set_depth(v:Float):Float {
		sortKey.depth = v;
		dirtySort();
		return v;
	}

	inline function dirtySort() {
		if(layer != null) {
			layer.dirty();
		}
	}

}