package clay.render;


import clay.math.Vector;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.data.Color;
import clay.render.SortKey;
import clay.utils.Log.*;

@:keep
class DisplayObject {


    static var ID:Int = 0; // for debug


    public var visible:Bool;
    public var renderable:Bool;
    public var added            (default, null):Bool = false;

    public var name             (default, null):String;

    public var layer            (get, set):Layer;
    public var depth            (default, set):Float;

    public var shader           (get, set):Shader;
    public var clip_rect        (default, set):Rectangle;

    public var matrix:Matrix;

    @:noCompletion public var bounds:Rectangle;
    @:noCompletion public var sort_key      (default, null):SortKey;

    var _layer:Layer;
    var _shader:Shader;
    var _custom_shader:Bool = false;


    public function new(options:DisplayObjectOptions) {
        
    	bounds = new Rectangle();
		matrix = new Matrix();
		sort_key = new SortKey(0,0);

        name = def(options.name, 'display_object.${ID++}');
        visible = def(options.visible, true);
        renderable = def(options.renderable, true);
        depth = def(options.depth, 0);
        shader = options.shader;
        if(options.clip_rect != null) {
            clip_rect = options.clip_rect;
        }

        _layer = def(options.layer, null);

    }

    public function drop() {
        
        if(added && _layer != null) {
            _layer._remove_unsafe(this);
        }

    }
    
    public function render(r:RenderPath, c:Camera) {}

    function get_default_shader():Shader {

        return Clay.renderer.shaders.get('textured');

    }

    inline function update_sorting() {

        if(added && _layer != null && _layer.depth_sort) {
            _layer.dirty_sort = true;
        }

    }

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

        update_sorting();

        return depth = v;

    }

    inline function get_shader():Shader {

        return _shader;

    }

    function set_shader(v:Shader):Shader {

        _custom_shader = v != null;

        if(!_custom_shader) {
            v = get_default_shader();
        }

        return _set_shader(v);

    }

    inline function _set_shader(v:Shader) {

        sort_key.shader = v.id;

        update_sorting();

        return _shader = v;
    }

    function set_clip_rect(v:Rectangle):Rectangle {

        sort_key.clip = v != null;

        if(clip_rect == null && v != null || clip_rect != null && v == null) {
            update_sorting();
        }

        return clip_rect = v;

    }
    

}

typedef DisplayObjectOptions = {

    @:optional var name:String;
    @:optional var visible:Bool;
    @:optional var renderable:Bool;
    @:optional var layer:Layer;
    @:optional var shader:Shader;
    @:optional var depth:Float;
    @:optional var clip_rect:Rectangle;

}