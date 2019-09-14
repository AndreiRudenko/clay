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
	public var clipRect     	(default, set):Rectangle;

	public var sortKey      	(default, null):SortKey;
	public var shaderDefault	(default, null):Shader;

	var _layer:Layer;


	public function new() {
		
		visible = true;
		renderable = true;
		name = 'displayObject.${ID++}';
		transform = new Transform();
		sortKey = new SortKey(0,0);
		depth = 0;
		shaderDefault = Clay.renderer.shaders.get('textured');

	}

	public function drop() {
		
		if(_layer != null) {
			_layer._removeUnsafe(this);
		}

	}

	public function update(dt:Float) {

		transform.update();

	}
	
	public function render(p:Painter) {}

	inline function get_layer():Layer {

		return _layer;

	}

	function set_layer(v:Layer):Layer {

		if(_layer != null) {
			_layer._removeUnsafe(this);
		}

		_layer = v;

		if(_layer != null) {
			_layer._addUnsafe(this);
		}

		return v;

	}

	function set_depth(v:Float):Float {

		sortKey.depth = v;

		dirtySort();

		return depth = v;

	}
	
	function set_shader(v:Shader):Shader {

		sortKey.shader = v != null ? v.id : shaderDefault.id;

		dirtySort();

		return shader = v;

	}

	function set_clipRect(v:Rectangle):Rectangle {

		sortKey.clip = v != null;

		if(clipRect == null && v != null || clipRect != null && v == null) {
			dirtySort();
		}

		return clipRect = v;

	}

	inline function dirtySort() {

		if(layer != null && layer.depthSort) {
			layer.dirtySort = true;
		}

	}
	

}