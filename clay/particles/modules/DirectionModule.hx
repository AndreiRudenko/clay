package clay.particles.modules;

import clay.particles.core.ParticleModule;
import clay.particles.core.Particle;
import clay.particles.core.Components;
import clay.particles.components.Velocity;



class DirectionModule extends ParticleModule {


	public var direction:Float;
	public var direction_variance:Float;
	public var speed:Float;
	public var speed_variance:Float;

	var vel_comps:Components<Velocity>;


	public function new(_options:DirectionModuleOptions) {

		super(_options);

		direction = _options.direction != null ? _options.direction : 0;
		direction_variance = _options.direction_variance != null ? _options.direction_variance : 0;
		speed = _options.speed != null ? _options.speed : 60;
		speed_variance = _options.speed_variance != null ? _options.speed_variance : 0;

	}

	override function init() {
		
		vel_comps = emitter.components.get(Velocity);

	}

	override function ondisabled() {

		particles.for_each(
			function(p) {
				vel_comps.get(p.id).set(0,0);
			}
		);
		
	}
	
	override function onremoved() {

		emitter.remove_module(VelocityUpdateModule);
		vel_comps = null;
		
	}

	override function onspawn(pd:Particle) {

		var angle:Float = (direction + direction_variance * emitter.random_1_to_1()) * 0.017453292519943295; // Math.PI / 180

		var spd:Float = speed;

		if(speed_variance != 0) {
			spd += speed_variance * emitter.random_1_to_1();
		}

		var v:Velocity = vel_comps.get(pd.id);
		v.x = spd * Math.cos(angle);
		v.y = spd * Math.sin(angle);

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		direction = d.direction;
		direction_variance = d.direction_variance;
		speed = d.speed;
		speed_variance = d.speed_variance;

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.direction = direction;
		d.direction_variance = direction_variance;
		d.speed = speed;
		d.speed_variance = speed_variance;

		return d;
	    
	}


}


typedef DirectionModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var direction : Float;
	@:optional var direction_variance : Float;
	@:optional var speed : Float;
	@:optional var speed_variance : Float;

}


