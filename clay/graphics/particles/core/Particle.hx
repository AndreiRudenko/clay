package clay.graphics.particles.core;

import clay.render.Color;

class Particle {

	@:allow(clay.graphics.particles.core.ParticleVector)
	public var id(default, null):Int;

	public var x:Float = 0;
	public var y:Float = 0;
	
	public var ox:Float = 0; // separate
	public var oy:Float = 0; // separate

	public var r:Float = 0; // separate

	public var w:Float = 32; // separate
	public var h:Float = 32; // separate

	public var s:Float = 1;
	public var lifetime:Float = 1;
	public var age:Float = 0;

	public var centered:Bool = true; // separate
	
	public var color:Color; // separate


	public function new(id:Int) {
		
		this.id = id;
		color = new Color();

	}


}
