package clay.resources;


import haxe.io.Bytes;
import clay.utils.Log.def;
import clay.render.types.TextureFilter;
import clay.render.types.MipMapFilter;
import clay.render.types.TextureAddressing;
import clay.render.types.TextureFormat;
import clay.render.types.DepthStencilFormat;
import clay.render.types.Usage;
import clay.system.ResourceManager;


@:access(clay.render.Renderer)
class Texture extends clay.resources.Resource {


	public static function create(width:Int, height:Int, ?format:TextureFormat, ?usage:Usage, ?no_id:Bool) {
		
		var img = kha.Image.create(width, height, format, usage);
		return new Texture(img, no_id);

	}

	public static function create_from_bytes(bytes:Bytes, width:Int, height:Int, ?format:TextureFormat, ?usage:Usage, ?no_id:Bool) {
		
		var img = kha.Image.fromBytes(bytes, width, height, format, usage);
		return new Texture(img, no_id);

	}

	public static function create_rendertarget(width:Int, height:Int, ?format:TextureFormat, ?depth_stencil:DepthStencilFormat, ?antialiasing:Int, ?context_id:Int, ?no_id:Bool) {
		
		var img = kha.Image.createRenderTarget(width, height, format, depth_stencil, antialiasing, context_id);
		var t = new Texture(img, no_id);
		t.resource_type = ResourceType.render_texture;
		return t;

	}


	public var tid              (default, null):Int;

	public var width_actual 	(get, never):Int;
	public var height_actual	(get, never):Int;

	public var width        	(get, never):Int;
	public var height           (get, never):Int;

	public var filter_min:TextureFilter;
	public var filter_mag:TextureFilter;
	public var mipmap_filter:MipMapFilter;
	public var u_addressing:TextureAddressing;
	public var v_addressing:TextureAddressing;

	// public var format       	(get, never):TextureFormat;
	// public var usage        	(get, never):Usage;

	@:noCompletion public var image:kha.Image;

	var _no_id:Bool;


	public function new(image:kha.Image, no_id:Bool = false) {

		tid = 0;

		this.image = image;
		_no_id = no_id;

		if(!_no_id) {
			tid = Clay.renderer.pop_texture_id();
		}

		filter_min = TextureFilter.LinearFilter;
		filter_mag = TextureFilter.LinearFilter;
		mipmap_filter = MipMapFilter.NoMipFilter;
		u_addressing = TextureAddressing.Clamp;
		v_addressing = TextureAddressing.Clamp;

		resource_type = ResourceType.texture;

	}

	public inline function generate_mipmaps(levels:Int) {

		image.generateMipmaps(levels);

	}

	public inline function lock(level:Int = 0):Bytes {

		return image.lock(level);

	}

	public inline function unlock() {

		image.unlock();

	}

	public inline function get_bytes():Bytes {

		return image.getPixels();

	}

	override function unload() {

        if(!_no_id) {
			Clay.renderer.push_texture_id(tid);
		}

		image.unload();
		image = null;
		
	}

	override function memory_use() {
		
        return (width_actual * height_actual * image.depth);

	}

	inline function get_width_actual() return image.realWidth;
	inline function get_height_actual() return image.realHeight;
	inline function get_width() return image.width;
	inline function get_height() return image.height;
	// inline function get_format() return image.format;
	// inline function get_usage() return image.usage;


}
