package clay.graphics.particles.utils;

import clay.math.Rectangle;

class RectangleExtender {

	public static inline function toJson(v:Rectangle):Dynamic {
		return { x: v.x, y: v.y, w: v.w, h: v.h };
	}

	public static inline function fromJson(v:Rectangle, json:Dynamic):Rectangle {
		return v.set(json.x, json.y, json.w, json.h);
	}

}