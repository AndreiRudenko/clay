package clay.objects;


import clay.Entity;
import clay.World;
import clay.components.common.Transform;
// import clay.components.graphics.Text;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.data.Color;
import clay.objects.GameObject;
import clay.resources.FontResource;
import clay.render.Shader;
import clay.render.Layer;
import clay.types.TextAlign;

import clay.utils.Log.*;


class Text extends GameObject {


	public var geometry	         (default, null):clay.components.graphics.Text;

	public var visible           (get,set):Bool;
	public var color             (get,set):Color;
	public var depth             (get,set):Float;
	public var layer             (get,never):Layer;

	public var clip_rect         (get,set):Rectangle;
	public var shader            (get,set):Shader;

	public var text          	(get, set):String;
	public var font          	(get, set):FontResource;
	public var size          	(get, set):Int; // expensive
	public var align         	(get, set):TextAlign;
	public var align_vertical	(get, set):TextAlign;

	public var width         	(get, set):Float;
	public var height        	(get, set):Float;
	public var line_spacing  	(get, set):Float;
	public var letter_spacing	(get, set):Float;
	public var tab_width     	(get, set):Int;
	public var wrap          	(get, set):Bool;

	public var text_width	    (get, never):Float;
	public var text_height	    (get, never):Float;


	public function new(_options:TextOptions) {

		super(_options);

		geometry = new clay.components.graphics.Text({
			color: _options.color,
			depth: _options.depth,
			size: _options.size,
			font: _options.font,
			text: _options.text,
			align: _options.align,
			align_vertical: _options.align_vertical,
			width: _options.width,
			height: _options.height,
			line_spacing: _options.line_spacing,
			letter_spacing: _options.letter_spacing,
			tab_width: _options.tab_width,
			wrap: _options.wrap,
			visible: _options.visible,
			clip_rect: _options.clip_rect,
			layer: _options.layer
		});

		world.components.set(entity, geometry);
		
	}

	override function destroy() {

		super.destroy();

		geometry = null;

	}

	public inline function add_text(t, ?c) geometry.add_text(t, c);

	inline function get_visible() return geometry.visible;
	inline function set_visible(v) return geometry.visible = v;

	inline function get_clip_rect() return geometry.clip_rect;
	inline function set_clip_rect(v) return geometry.clip_rect = v;

	inline function get_shader() return geometry.shader;
	inline function set_shader(v) return geometry.shader = v;

	inline function get_depth() return geometry.depth;
	inline function set_depth(v) return geometry.depth = v;

	inline function get_layer() return geometry.layer;

	inline function get_color() return geometry.color;
	inline function set_color(v) return geometry.color = v;

	inline function get_text() return geometry.text;
	inline function set_text(v) return geometry.text = v;
	
	inline function get_font() return geometry.font;
	inline function set_font(v) return geometry.font = v;
	
	inline function get_size() return geometry.size;
	inline function set_size(v) return geometry.size = v;
	
	inline function get_align() return geometry.align;
	inline function set_align(v) return geometry.align = v;
	
	inline function get_align_vertical() return geometry.align_vertical;
	inline function set_align_vertical(v) return geometry.align_vertical = v;
	
	inline function get_width() return geometry.width;
	inline function set_width(v) return geometry.width = v;
	
	inline function get_height() return geometry.height;
	inline function set_height(v) return geometry.height = v;

	inline function get_line_spacing() return geometry.line_spacing;
	inline function set_line_spacing(v) return geometry.line_spacing = v;
	
	inline function get_letter_spacing() return geometry.letter_spacing;
	inline function set_letter_spacing(v) return geometry.letter_spacing = v;
	
	inline function get_tab_width() return geometry.tab_width;
	inline function set_tab_width(v) return geometry.tab_width = v;
	
	inline function get_wrap() return geometry.wrap;
	inline function set_wrap(v) return geometry.wrap = v;

	inline function get_text_width() return geometry.text_width;
	inline function get_text_height() return geometry.text_height;
	
	
}


typedef TextOptions = {

	>GameObjectOptions,

	@:optional var text:String;
	@:optional var font:FontResource;

	@:optional var width:Float;
	@:optional var height:Float;
	@:optional var line_spacing:Float;
	@:optional var letter_spacing:Float;
	@:optional var tab_width:Int;
	@:optional var wrap:Bool;

	@:optional var size:Int;
	@:optional var depth:Float;
	@:optional var layer:Layer;
	@:optional var visible:Bool;
	@:optional var shader:Shader;
	@:optional var color:Color;
	// @:optional var geometry:clay.components.graphics.Text;
	@:optional var align:TextAlign;
	@:optional var align_vertical:TextAlign;
	@:optional var clip_rect:Rectangle;
	
}