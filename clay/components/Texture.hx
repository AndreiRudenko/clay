package clay.components;


import haxe.io.Bytes;
import clay.utils.Log.def;
import clay.render.TextureFilter;
import clay.render.MipMapFilter;
import clay.render.TextureAddressing;


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
		return new Texture(img, no_id);

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

	var no_id:Bool;


	public function new(_image:kha.Image, _no_id:Bool = false) {

		tid = 0;
		no_id = _no_id;

		if(!no_id) {
			tid = Clay.renderer.pop_texture_id();
		}

		image = _image;

		filter_min = TextureFilter.LinearFilter;
		filter_mag = TextureFilter.LinearFilter;
		mipmap_filter = MipMapFilter.NoMipFilter;
		u_addressing = TextureAddressing.Clamp;
		v_addressing = TextureAddressing.Clamp;

	}

	public inline function generate_mipmaps(_levels:Int) {

		image.generateMipmaps(_levels);

	}

	public inline function lock(_levels:Int = 0):Bytes {

		return image.lock(_levels);

	}

	public inline function unlock() {

		image.unlock();

	}

	public function destroy() {

        if(!no_id) {
			Clay.renderer.push_texture_id(tid);
		}

		image.unload();
		image = null;
		
	}

	override function unload() {

		image.unload();
		
	}

	inline function get_width_actual() return image.realWidth;
	inline function get_height_actual() return image.realHeight;
	inline function get_width() return image.width;
	inline function get_height() return image.height;
	// inline function get_format() return image.format;
	// inline function get_usage() return image.usage;


}

typedef TextureFormat = kha.graphics4.TextureFormat;
typedef Usage = kha.graphics4.Usage;
typedef DepthStencilFormat = kha.graphics4.DepthStencilFormat;