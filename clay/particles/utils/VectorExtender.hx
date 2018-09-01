package clay.particles.utils;


import clay.math.Vector;


class VectorExtender {


	public static inline function to_json(v:Vector):Dynamic {

		return { x: v.x, y: v.y };
	    
	}

	public static inline function from_json(v:Vector, json:Dynamic):Vector {

		return v.set(json.x, json.y);
	    
	}
	

}