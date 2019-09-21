package clay.graphics.particles.core;

import clay.render.Color;

class Particle {

	@:allow(clay.graphics.particles.core.ParticleVector)
	public var id(default, null):Int;

	public var x:Float = 0;
	public var y:Float = 0;
	
	public var lifetime:Float = 1;
	public var age:Float = 0;


	public function new(id:Int) {
		
		this.id = id;

	}


}
