package clay;

import clay.resources.Resource;
import clay.resources.AudioResource;
import clay.resources.BytesResource;
import clay.resources.JsonResource;
import clay.resources.TextResource;
import clay.graphics.Font;
import clay.graphics.Texture;
import clay.graphics.Video;
import clay.utils.Log;
import clay.utils.IdGenerator;

import haxe.io.Path;

@:allow(clay.App)
class Resources {

	static final resourcesPath:String = 'data';

	public var cache(default, null):Map<String, Resource>;
	public var stats:ResourceStats;

	var _textureExt:Array<String>;
	var _audioExt:Array<String>;
	var _fontExt:Array<String>;
	var _videoExt:Array<String>;
	// var _ids:IdGenerator;

	function new() {
		_textureExt = kha.Assets.imageFormats;
		_audioExt = kha.Assets.soundFormats;
		_videoExt = [];
		// _videoExt = kha.Assets.videoFormats; // TODO: bug on hl
		_fontExt = kha.Assets.fontFormats;

		// _ids = new IdGenerator();

		cache = new Map();
		stats = new ResourceStats();
	}

	function destroy() {
		unloadAll();
	}

	public function loadAll(arr:Array<String>, onComplete:()->Void, ?onProgress:(p:Float)->Void) {
		if(arr.length == 0) {
			if(onProgress != null) {
				onProgress(1);
			}
			onComplete();
			return;
		}

		var progress:Float = 0;
		var count:Int = arr.length;
		var left:Int = count;

		var i:Int = 0;

		var cb:(r:Resource)->Void = null;

		cb = function(r) {
			i++;
			left--;
			progress = 1 - left / count;

			if(onProgress != null) {
				onProgress(progress);
			}

			if(i < count) {
				load(arr[i], cb);
			} else {
				onComplete();
			}

		}

		load(arr[i], cb);
	}

	public function unloadAll() {
		for (r in cache) {
			r.unload();
		}
		cache = new Map();
	}

	public function load(name:String, ?onComplete:(r:Resource)->Void) {
		var res = cache.get(name);
		if(res != null) {
			Log.warning("resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		var ext = Path.extension(name);

		switch (ext) {
			case e if (_textureExt.indexOf(e) != -1):{
				loadTexture(name, onComplete);
			}
			case e if (_fontExt.indexOf(e) != -1):{
				loadFont(name, onComplete);
			}
			case e if (_audioExt.indexOf(e) != -1):{
				loadAudio(name, onComplete);
			}
			case e if (_videoExt.indexOf(e) != -1):{
				loadVideo(name, onComplete);
			}
			case "json":{
				loadJson(name, onComplete);
			}
			case "txt":{
				loadText(name, onComplete);
			}
			default:{
				loadBytes(name, onComplete);
			}
		}
	}

	public function loadBytes(name:String, ?onComplete:(r:BytesResource)->Void) {
		var res:BytesResource = cast cache.get(name);

		if(res != null) {
			Log.warning("bytes resource already exists: " + name);
			// res.ref++;
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("bytes / loading / " + name);

		kha.Assets.loadBlobFromPath(
			getResourcePath(name), 
			function(blob:kha.Blob){
				res = new BytesResource(blob);
				res.name = name;
				add(res);
				if(onComplete != null) {
					onComplete(res);
				}
			},
			onError
		);
	}

	public function loadText(name:String, ?onComplete:(r:TextResource)->Void) {
		var res:TextResource = cast cache.get(name);

		if(res != null) {
			Log.warning("text resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("text / loading / " + name);

		kha.Assets.loadBlobFromPath(
			getResourcePath(name), 
			function(blob:kha.Blob){
				res = new TextResource(blob.toString());
				res.name = name;
				add(res);
				if(onComplete != null) {
					onComplete(res);
				}
			},
			onError
		);
	}

	public function loadJson(name:String, ?onComplete:(r:JsonResource)->Void) {
		var res:JsonResource = cast cache.get(name);

		if(res != null) {
			Log.warning("json resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("json / loading / " + name);

		kha.Assets.loadBlobFromPath(
			getResourcePath(name), 
			function(blob:kha.Blob){
				res = new JsonResource(haxe.Json.parse(blob.toString()));
				res.name = name;
				add(res);
				if(onComplete != null) {
					onComplete(res);
				}
			},
			onError
		);
	}

	public function loadTexture(name:String, ?onComplete:(r:Texture)->Void) {
		var res:Texture = cast cache.get(name);

		if(res != null) {
			Log.warning("texture resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("texture / loading / " + name);

		kha.Assets.loadImageFromPath(
			getResourcePath(name), 
			false, 
			function(img:kha.Image){
				res = new Texture(img);
				res.name = name;
				add(res);
				if(onComplete != null) {
					onComplete(res);
				}
			},
			onError
		);
	}

	public function loadFont(name:String, ?onComplete:(r:Font)->Void) {
		var res:Font = cast cache.get(name);

		if(res != null) {
			Log.warning("font resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("font / loading / " + name);

		kha.Assets.loadFontFromPath(
			getResourcePath(name), 
			function(f:kha.Font){
				res = new Font(f);
				res.name = name;
				add(res);
				if(onComplete != null) {
					onComplete(res);
				}
			},
			onError
		);
	}

	public function loadVideo(name:String, ?onComplete:(r:Video)->Void) {
		var res:Video = cast cache.get(name);

		if(res != null) {
			Log.warning("video resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("video / loading / " + name);

		kha.Assets.loadVideoFromPath(
			getResourcePath(name), 
			function(v:kha.Video){
				res = new Video(v);
				res.name = name;
				add(res);
				if(onComplete != null) {
					onComplete(res);
				}
			},
			onError
		);
	}

	public function loadAudio(name:String, ?onComplete:(r:AudioResource)->Void) {
		var res:AudioResource = cast cache.get(name);

		if(res != null) {
			Log.warning("audio resource already exists: " + name);
			if(onComplete != null) {
				onComplete(res);
			}
			return;
		}

		Log.debug("audio / loading / " + name);

		kha.Assets.loadSoundFromPath(
			getResourcePath(name), 
			function(snd:kha.Sound){
				snd.uncompress(function() {
					res = new AudioResource(snd);
					res.name = name;
					add(res);
					if(onComplete != null) {
						onComplete(res);
					}
				});
			},
			onError
		);
	}

	public function add(resource:Resource) {
		Log.assert(!cache.exists(resource.name));

		// resource.id = _ids.get();
		cache.set(resource.name, resource);

		updateStats(resource, 1);
	}

	public function remove(resource:Resource):Bool {
		Log.assert(cache.exists(resource.name));

		updateStats(resource, -1);
		// _ids.put(resource.id);
		
		return cache.remove(resource.name);
	}

	public function unload(name:String):Bool {
		var res = get(name);
		if(res != null) {
			res.unload();
			cache.remove(res.name);
			return true;
		}

		return false;
	}

	public inline function has(name:String):Bool return cache.exists(name);

	public function get(name:String):Resource return fetch(name);
	public function bytes(name:String):BytesResource return fetch(name);
	public function text(name:String):TextResource return fetch(name);
	public function json(name:String):JsonResource return fetch(name);
	public function texture(name:String):Texture return fetch(name);
	public function font(name:String):Font return fetch(name);
	public function video(name:String):Video return fetch(name);
	public function audio(name:String):AudioResource return fetch(name);

	inline function fetch<T>(name:String):T {
		var res:T = cast cache.get(name);

		if(res == null) {
			Log.warning("failed to get resource: " + name);
		}

		return res;
	}

	inline function updateStats(_res:Resource, _offset:Int) {
		switch(_res.resourceType) {
			case ResourceType.UNKNOWN:          stats.unknown   += _offset;
			case ResourceType.BYTES:            stats.bytes     += _offset;
			case ResourceType.TEXT:             stats.texts     += _offset;
			case ResourceType.JSON:             stats.jsons     += _offset;
			case ResourceType.TEXTURE:          stats.textures  += _offset;
			case ResourceType.RENDERTEXTURE:    stats.rtt       += _offset;
			case ResourceType.FONT:             stats.fonts     += _offset;
			case ResourceType.AUDIO:            stats.audios    += _offset;
			case ResourceType.VIDEO:            stats.videos    += _offset;
			default:
		}

		stats.total += _offset;
	}

	inline function getResourcePath(path:String):String {
		return Path.join([resourcesPath, path]);
	}
	
	function onError(err:kha.AssetError) { // TODO: remove from path resourcesPath
		Log.warning("failed to load resource: " + err.url);
	}

}

class ResourceStats {

	public var total:Int = 0;
	public var fonts:Int = 0;
	public var textures:Int = 0;
	public var rtt:Int = 0;
	public var texts:Int = 0;
	public var jsons:Int = 0;
	public var bytes:Int = 0;
	public var audios:Int = 0;
	public var videos:Int = 0;
	public var unknown:Int = 0;

	public function new() {} 

	function toString() {
		return
			"Resource Statistics\n" +
			"\ttotal : " + total + "\n" +
			"\ttexture : " + textures + "\n" +
			"\trender texture : " + rtt + "\n" +
			"\tfont : " + fonts + "\n" +
			"\ttext : " + texts + "\n" +
			"\tjson : " + jsons + "\n" +
			"\tbytes : " + bytes + "\n" +
			"\taudios : " + audios + "\n" +
			"\tvideos : " + audios + "\n" +
			"\tunknown : " + unknown;
	} 

	public function reset() {
		total = 0;
		fonts = 0;
		textures = 0;
		rtt = 0;
		texts = 0;
		jsons = 0;
		bytes = 0;
		audios = 0;
		videos = 0;
		unknown = 0;
	} 

}

enum abstract ResourceType(Int) {
	var UNKNOWN;
	var TEXT;
	var JSON;
	var BYTES;
	var TEXTURE;
	var RENDERTEXTURE;
	var FONT;
	var AUDIO;
	var VIDEO;
}