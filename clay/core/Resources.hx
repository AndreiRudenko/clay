package clay.core;


import clay.resources.Resource;
import clay.resources.AudioResource;
import clay.resources.BytesResource;
import clay.resources.FontResource;
import clay.resources.JsonResource;
// import clay.resources.ShaderResource;
import clay.resources.Texture;
import clay.resources.VideoResource;
import clay.resources.TextResource;
import clay.utils.Log.*;

import haxe.io.Path;


@:allow(clay.Engine)
class Resources {


	public var cache(default, null):Map<String, Resource>;

    var texture_ext:Array<String>;
    var audio_ext:Array<String>;
    var font_ext:Array<String>;
    var video_ext:Array<String>;
    

	function new() {
		
		texture_ext = kha.Assets.imageFormats;
		audio_ext = kha.Assets.soundFormats;
		font_ext = kha.Assets.fontFormats;
		video_ext = kha.Assets.videoFormats;

		cache = new Map();

	}

	function destroy() {
		
		unload_all();

	}

	public function load_all(arr:Array<String>, oncomplete:Void->Void, ?onprogress:Float->Void) {

		if(arr.length == 0) {
			if(onprogress != null) {
				onprogress(1);
			}
			oncomplete();
			return;
		}

		var progress:Float = 0;
		var count:Int = arr.length;
		var left:Int = count;

		var i:Int = 0;

		var cb:Resource->Void = null;

		cb = function(r) {
			i++;
			left--;
			progress = 1 - left / count;

			if(onprogress != null) {
				onprogress(progress);
			}

			if(i < count) {
				load(arr[i], cb);
			} else {
				oncomplete();
			}

		}

		load(arr[i], cb);
		
	}

	public function unload_all() {

		for (r in cache) {
			r.unload();
		}
		cache = new Map();

	}

	public function load(id:String, ?oncomplete:Resource->Void) {

		var res = get(id);
		if(res != null) {
            log('resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

        var ext = Path.extension(id);

        switch (ext) {
            case e if (texture_ext.indexOf(e) != -1):{
                load_texture(id, oncomplete);
            }
            case e if (font_ext.indexOf(e) != -1):{
                load_font(id, oncomplete);
            }
            case e if (audio_ext.indexOf(e) != -1):{
                load_audio(id, oncomplete);
            }
            case e if (video_ext.indexOf(e) != -1):{
                load_video(id, oncomplete);
            }
            case "json":{
                load_json(id, oncomplete);
            }
            case "txt":{
                load_text(id, oncomplete);
            }
            default:{
                load_bytes(id, oncomplete);
            }
        }
		
	}

	public function load_bytes(id:String, ?oncomplete:BytesResource->Void) {

		var res:BytesResource = bytes(id);

		if(res != null) {
			log('bytes resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('bytes / loading / $id');

		kha.Assets.loadBlobFromPath(
			id, 
			function(blob:kha.Blob){
				res = new BytesResource(blob);
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function load_text(id:String, ?oncomplete:TextResource->Void) {

		var res:TextResource = text(id);

		if(res != null) {
			log('text resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('text / loading / $id');

		kha.Assets.loadBlobFromPath(
			id, 
			function(blob:kha.Blob){
				res = new TextResource(blob.toString());
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function load_json(id:String, ?oncomplete:JsonResource->Void) {

		var res:JsonResource = json(id);

		if(res != null) {
			log('json resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('json / loading / $id');

		kha.Assets.loadBlobFromPath(
			id, 
			function(blob:kha.Blob){
				res = new JsonResource(haxe.Json.parse(blob.toString()));
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function load_texture(id:String, ?oncomplete:Texture->Void) {

		var res:Texture = texture(id);

		if(res != null) {
			log('texture resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('texture / loading / $id');

		kha.Assets.loadImageFromPath(
			id, 
			false, 
			function(img:kha.Image){
				res = new Texture(img);
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function load_font(id:String, ?oncomplete:FontResource->Void) {

		var res:FontResource = font(id);

		if(res != null) {
			log('font resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('font / loading / $id');

		kha.Assets.loadFontFromPath(
			id, 
			function(f:kha.Font){
				res = new FontResource(f);
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function load_video(id:String, ?oncomplete:VideoResource->Void) {

		var res:VideoResource = video(id);

		if(res != null) {
			log('video resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('video / loading / $id');

		kha.Assets.loadVideoFromPath(
			id, 
			function(v:kha.Video){
				res = new VideoResource(v);
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function load_audio(id:String, ?oncomplete:AudioResource->Void) {

		var res:AudioResource = audio(id);

		if(res != null) {
			log('audio resource already exists: $id');
			if(oncomplete != null) {
				oncomplete(res);
			}
			return;
		}

		_debug('audio / loading / $id');

		kha.Assets.loadSoundFromPath(
			id, 
			function(snd:kha.Sound){
				res = new AudioResource(snd);
				res.id = id;
				cache.set(id, res);
				if(oncomplete != null) {
					oncomplete(res);
				}
			},
			onerror
		);

	}

	public function unload(id:String):Bool {

		var res = get(id);
		if(res != null) {
			res.unload();
			cache.remove(res.id);
			return true;
		}

		return false;

	}

	// get
	public inline function has      (id:String):Bool           return cache.exists(id);
	public inline function get      (id:String):Resource       return fetch(id);
	public inline function bytes    (id:String):BytesResource          return fetch(id);
	public inline function text     (id:String):TextResource           return fetch(id);
	public inline function json     (id:String):JsonResource           return fetch(id);
	public inline function texture    (id:String):Texture        return fetch(id);
	public inline function font     (id:String):FontResource           return fetch(id);
	public inline function video    (id:String):VideoResource         return fetch(id);
	public inline function audio    (id:String):AudioResource          return fetch(id);

	inline function fetch<T>(id:String):T {

		return cast cache.get(id);

	}
	
	function onerror(err:kha.AssetError) {

		log('failed to load resource: ${err.url}');

	}


}
