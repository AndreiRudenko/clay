package clay.particles.core;

import clay.data.Color;

class Particle {

	@:allow(clay.particles.core.ParticleVector)
	public var id(default, null):Int;

	public var x:Float = 0;
	public var y:Float = 0;
	
	public var ox:Float = 0;
	public var oy:Float = 0;

	public var r:Float = 0;

	public var w:Float = 32;
	public var h:Float = 32;

	public var s:Float = 1;
	public var lifetime:Float = 1;
	public var age:Float = 0;

	public var centered:Bool = true;
	
	public var color:Color;


	public function new(id:Int) {
		
		this.id = id;
		color = new Color();

	}


}
