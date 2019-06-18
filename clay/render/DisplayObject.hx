package clay.render;


import clay.math.Rectangle;
import clay.math.Transform;
import clay.render.SortKey;
import clay.utils.Log.*;


class DisplayObject {


	static var ID:Int = 0; // for debug

	public var visible:Bool;
	public var renderable:Bool;
	public var name:String;

	public var transform:Transform;

	public var layer         	(get, set):Layer;
	public var depth         	(default, set):Float;

	public var shader        	(default, set):Shader;
	public var clip_rect     	(default, set):Rectangle;

	public var sort_key      	(default, null):SortKey;
	public var shader_default	(default, null):Shader;

	var _layer:Layer;


	public function new() {
		
		visible = true;
		renderable = true;
		name = 'display_object.${ID++}';
		transform = new Transform();
		sort_key = new SortKey(0,0);
		depth = 0;
		shader_default = Clay.renderer.shaders.get('textured');

	}

	public function drop() {
		
		if(_layer != null) {
			_layer._remove_unsafe(this);
		}

	}

	public function update(dt:Float) {

		transform.update();

	}
	
	public function render(r:RenderPath, c:Camera) {}

	inline function get_layer():Layer {

		return _layer;

	}

	function set_layer(v:Layer):Layer {

		if(_layer != null) {
			_layer._remove_unsafe(this);
		}

		_layer = v;

		if(_layer != null) {
			_layer._add_unsafe(this);
		}

		return v;

	}

	function set_depth(v:Float):Float {

		sort_key.depth = v;

		dirty_sort();

		return depth = v;

	}
	
	function set_shader(v:Shader):Shader {

		sort_key.shader = v != null ? v.id : shader_default.id;

		dirty_sort();

		return shader = v;

	}

	function set_clip_rect(v:Rectangle):Rectangle {

		sort_key.clip = v != null;

		if(clip_rect == null && v != null || clip_rect != null && v == null) {
			dirty_sort();
		}

		return clip_rect = v;

	}

	inline function dirty_sort() {

		if(layer != null && layer.depth_sort) {
			layer.dirty_sort = true;
		}

	}
	

}