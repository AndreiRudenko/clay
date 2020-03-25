package clay.graphics.particles.utils;

import clay.utils.Color;

class ColorExtender {

	public static inline function toJson(c:Color):Dynamic {
		return { r: c.r, g: c.g, b: c.b, a: c.a };
	}

	public static inline function fromJson(c:Color, json:Dynamic):Color {
		return c.set(json.r, json.g, json.b, json.a);
	}

}