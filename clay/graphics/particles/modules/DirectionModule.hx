package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;



class DirectionModule extends ParticleModule {


	public var direction:Float;
	public var directionVariance:Float;
	public var speed:Float;
	public var speedVariance:Float;

	var _velComps:Components<Velocity>;


	public function new(_options:DirectionModuleOptions) {

		super(_options);

		direction = _options.direction != null ? _options.direction : 0;
		directionVariance = _options.directionVariance != null ? _options.directionVariance : 0;
		speed = _options.speed != null ? _options.speed : 60;
		speedVariance = _options.speedVariance != null ? _options.speedVariance : 0;

	}

	override function init() {
		
		_velComps = emitter.components.get(Velocity);

	}

	override function onDisabled() {

		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
		
	}
	
	override function onRemoved() {

		emitter.removeModule(VelocityUpdateModule);
		_velComps = null;
		
	}

	override function onSpawn(pd:Particle) {

		var angle:Float = (direction + directionVariance * emitter.random1To1()) * 0.017453292519943295; // Math.PI / 180

		var spd:Float = speed;

		if(speedVariance != 0) {
			spd += speedVariance * emitter.random1To1();
		}

		var v:Velocity = _velComps.get(pd.id);
		v.x = spd * Math.cos(angle);
		v.y = spd * Math.sin(angle);

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		direction = d.direction;
		directionVariance = d.directionVariance;
		speed = d.speed;
		speedVariance = d.speedVariance;

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.direction = direction;
		d.directionVariance = directionVariance;
		d.speed = speed;
		d.speedVariance = speedVariance;

		return d;
	    
	}


}


typedef DirectionModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var direction : Float;
	@:optional var directionVariance : Float;
	@:optional var speed : Float;
	@:optional var speedVariance : Float;

}


