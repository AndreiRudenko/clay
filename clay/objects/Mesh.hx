package clay.objects;


import clay.Entity;
import clay.World;
import clay.components.common.Transform;
import clay.components.graphics.Geometry;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.data.Color;
import clay.objects.GameObject;
import clay.resources.Texture;
import clay.render.Shader;
import clay.render.Layer;
import clay.render.Vertex;

import clay.utils.Log.*;


class Mesh extends GameObject {


	public var geometry	         (default, null):Geometry;

	public var visible           (get,set):Bool;
	public var texture           (get,set):Texture;
	public var color             (get,set):Color;
	public var depth             (get,set):Float;
	public var layer             (get,never):Layer;

	public var clip_rect         (get,set):Rectangle;
	public var region            (get,set):Rectangle;
	public var shader            (get,set):Shader;
	
	public var vertices          (get,set):Array<Vertex>;
	public var indices           (get,set):Array<Int>;


	public function new(_options:MeshOptions) {

		super(_options);

		geometry = new Geometry({
			vertices: _options.vertices,
			indices: _options.indices,
			layer: _options.layer,
			texture: _options.texture,
			color: _options.color,
			depth: _options.depth,
			visible: _options.visible,
			region: _options.region,
			clip_rect: _options.clip_rect
		});

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

	inline function get_region() return geometry.region;
	inline function set_region(v) return geometry.region = v;

	inline function get_vertices() return geometry.vertices;
	inline function set_vertices(v) return geometry.vertices = v;

	inline function get_indices() return geometry.indices;
	inline function set_indices(v) return geometry.indices = v;

	inline function get_shader() return geometry.shader;
	inline function set_shader(v) return geometry.shader = v;

	inline function get_texture() return geometry.texture;
	inline function set_texture(v) return geometry.texture = v;

	inline function get_depth() return geometry.depth;
	inline function set_depth(v) return geometry.depth = v;

	inline function get_layer() return geometry.layer;

	inline function get_color() return geometry.color;
	inline function set_color(v) return geometry.color = v;

	
}


typedef MeshOptions = {

	>GameObjectOptions,

	@:optional var vertices:Array<Vertex>;
	@:optional var indices:Array<Int>;
	@:optional var texture:Texture;
	@:optional var depth:Float;
	@:optional var layer:Layer;
	@:optional var visible:Bool;
	@:optional var shader:Shader;
	@:optional var color:Color;
	@:optional var clip_rect:Rectangle;
	@:optional var region:Rectangle;
	
}