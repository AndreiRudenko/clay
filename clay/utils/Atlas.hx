package clay.utils;

import clay.Clay;
import clay.resources.Texture;
import clay.math.RectangleInt;
import haxe.io.Path;

class Atlas {

	static public function loadFromPath(path:String):Atlas {
		var jsonRes = Clay.resources.json(path);
		var data:AtlasData = jsonRes.json;
		var dir = Path.directory(path);
		var p = Path.join([dir, data.textureName]);
		var texture = Clay.resources.texture(p);
	    var atlas = new Atlas(texture);
		for (r in data.regions) {
			atlas.addRegion(r.name, new RectangleInt(r.x, r.y, r.w, r.h));
		}
	    return atlas;
	}

	public var texture:Texture;
	var regions:Map<String, RectangleInt>;

	public function new(texture:Texture) {
		this.texture = texture;
		this.regions = new Map();
	}

	public function addRegion(name:String, rect:RectangleInt) {
		return regions.set(name, rect);
	}

	public function getRegion(name:String):RectangleInt {
		return regions.get(name);
	}

	public function removeRegion(name:String) {
		return regions.remove(name);
	}

	public function toJson():AtlasData {
		var regionsData:Array<AtlasRegionData> = [];
		var rect:RectangleInt;
		for (k in regions.keys()) {
			rect = regions.get(k);
			regionsData.push(
				{
					name: k,
					x: rect.x,
					y: rect.y,
					w: rect.w,
					h: rect.h
				}
			);
		}
		return {
			textureName: Path.withoutDirectory(texture.id),
			regions: regionsData,
		}
	}

}

typedef AtlasData = {
	textureName:String,
	regions:Array<AtlasRegionData>
}

typedef AtlasRegionData = {
	name:String,
	x:Int,
	y:Int,
	w:Int,
	h:Int
}