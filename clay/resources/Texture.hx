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


	public static function create(width:Int, height:Int, ?format:TextureFormat, ?usage:Usage, ?noID:Bool) {
		
		var img = kha.Image.create(width, height, format, usage);
		return new Texture(img, noID);

	}

	public static function createFromBytes(bytes:Bytes, width:Int, height:Int, ?format:TextureFormat, ?usage:Usage, ?noID:Bool) {
		
		var img = kha.Image.fromBytes(bytes, width, height, format, usage);
		return new Texture(img, noID);

	}

	public static function createRenderTarget(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, ?antialiasing:Int, ?contextID:Int, ?noID:Bool) {
		
		var img = kha.Image.createRenderTarget(width, height, format, depthStencil, antialiasing, contextID);
		var t = new Texture(img, noID);
		t.resourceType = ResourceType.RENDERTEXTURE;
		return t;

	}


	public var tid(default, null):Int;

	public var widthActual(get, never):Int;
	public var heightActual(get, never):Int;

	public var width(get, never):Int;
	public var height(get, never):Int;

	public var filterMin:TextureFilter;
	public var filterMag:TextureFilter;
	public var mipmapFilter:MipMapFilter;
	public var uAddressing:TextureAddressing;
	public var vAddressing:TextureAddressing;

	// public var format       	(get, never):TextureFormat;
	// public var usage        	(get, never):Usage;

	@:noCompletion public var image:kha.Image;

	var _noID:Bool;


	public function new(image:kha.Image, noID:Bool = false) {

		tid = 0;

		this.image = image;
		_noID = noID;

		if(!_noID) {
			tid = Clay.renderer.popTextureID();
		}

		filterMin = TextureFilter.LinearFilter;
		filterMag = TextureFilter.LinearFilter;
		mipmapFilter = MipMapFilter.NoMipFilter;
		uAddressing = TextureAddressing.Clamp;
		vAddressing = TextureAddressing.Clamp;

		resourceType = ResourceType.TEXTURE;

	}

	public inline function generateMipmaps(levels:Int) {

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

		if(!_noID) {
			Clay.renderer.pushTextureID(tid);
		}

		image.unload();
		image = null;
		
	}

	override function memoryUse() {
		
		return (widthActual * heightActual * image.depth);

	}

	inline function get_widthActual() return image.realWidth;
	inline function get_heightActual() return image.realHeight;
	inline function get_width() return image.width;
	inline function get_height() return image.height;
	// inline function get_format() return image.format;
	// inline function get_usage() return image.usage;


}
