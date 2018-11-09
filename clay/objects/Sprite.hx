package clay.objects;


import clay.Entity;
import clay.World;
import clay.components.common.Transform;
import clay.components.graphics.QuadGeometry;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.data.Color;
import clay.objects.GameObject;
import clay.resources.Texture;
import clay.render.Shader;
import clay.render.Layer;

import clay.utils.Log.*;


class Sprite extends GameObject {


	public var geometry	         (default, null):QuadGeometry;

	public var visible           (get,set):Bool;
	public var texture           (get,set):Texture;
	public var size              (get,never):Vector;
	public var color             (get,set):Color;
	public var depth             (get,set):Float;
	public var layer             (get,never):Layer;

	public var clip_rect         (get,set):Rectangle;
	public var shader            (get,set):Shader;

	public var uv                (get,never):Rectangle;
	public var flipx             (get,set):Bool;
	public var flipy             (get,set):Bool;


	public function new(_options:SpriteOptions) {

		super(_options);

		geometry = new QuadGeometry({
			layer: _options.layer,
			texture: _options.texture,
			uv: _options.uv,
			size: _options.size,
			color: _options.color,
			flipx: _options.flipx,
			flipy: _options.flipy,
			depth: _options.depth,
			visible: _options.visible,
			clip_rect: _options.clip_rect
		});

		// if(centered && _options.origin == null) {
		// 	transform.origin.set(geometry.size.x*0.5, geometry.size.y *0.5);
		// }

		world.components.set(entity, geometry);
		
	}

	override function destroy() {

		super.destroy();

		geometry = null;

	}
	
	inline function get_visible() return geometry.visible;
	inline function set_visible(v) return geometry.visible = v;

	inline function get_clip_rect() return geometry.clip_rect;
	inline function set_clip_rect(v) return geometry.clip_rect = v;

	inline function get_shader() return geometry.shader;
	inline function set_shader(v) return geometry.shader = v;

	inline function get_texture() return geometry.texture;
	inline function set_texture(v) return geometry.texture = v;

	inline function get_size() return geometry.size;

	inline function get_uv() return geometry.uv;

	inline function get_flipx() return geometry.flipx;
	inline function set_flipx(v) return geometry.flipx = v;

	inline function get_flipy() return geometry.flipy;
	inline function set_flipy(v) return geometry.flipy = v;

	inline function get_depth() return geometry.depth;
	inline function set_depth(v) return geometry.depth = v;

	inline function get_layer() return geometry.layer;

	inline function get_color() return geometry.color;
	inline function set_color(v) return geometry.color = v;

	
}


typedef SpriteOptions = {

	>GameObjectOptions,

	@:optional var texture:Texture;
	@:optional var size:Vector;
	@:optional var uv:Rectangle;
	@:optional var flipx:Bool;
	@:optional var flipy:Bool;
	@:optional var depth:Float;
	@:optional var layer:Layer;
	@:optional var visible:Bool;
	@:optional var shader:Shader;
	@:optional var color:Color;
	// @:optional var geometry:QuadGeometry;
	@:optional var clip_rect:Rectangle;
	
}