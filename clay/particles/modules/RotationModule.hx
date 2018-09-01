package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleData;
import clay.particles.core.Components;


class RotationModule extends ParticleModule {


	public var initial_rotation:Float;
	public var initial_rotation_max:Float;
	public var angular_velocity:Float;
	public var angular_velocity_max:Float;
	public var rotation_random:Float;

	var rotation_delta:Array<Float>;
	var particles_data:Array<ParticleData>;


	public function new(_options:RotationModuleOptions) {

		super(_options);

		rotation_delta = [];

		initial_rotation = _options.initial_rotation != null ? _options.initial_rotation : 0;
		initial_rotation_max = _options.initial_rotation_max != null ? _options.initial_rotation_max : 0;
		angular_velocity = _options.angular_velocity != null ? _options.angular_velocity : 1;
		angular_velocity_max = _options.angular_velocity_max != null ? _options.angular_velocity_max : 0;
		rotation_random = _options.rotation_random != null ? _options.rotation_random : 0;

	}

	override function init() {

		particles_data = emitter.particles_data;

		for (i in 0...particles.capacity) {
			rotation_delta[i] = 0;
		}
	    
	}

	override function ondisabled() {
		
		for (pd in particles_data) {
			pd.r = 0;
		}

	}

	override function onspawn(p:Particle) {

		var pd:ParticleData = particles_data[p.id];

		if(initial_rotation_max != 0) {
			pd.r = emitter.random_float(initial_rotation, initial_rotation_max);
		} else {
			pd.r = initial_rotation;
		}

		if(angular_velocity_max != 0) {
			rotation_delta[p.id] = emitter.random_float(angular_velocity, angular_velocity_max) * 360;
		} else {
			rotation_delta[p.id] = angular_velocity * 360;
		}

	}
	
	override function update(dt:Float) {

		if(rotation_random > 0) {
			for (p in particles) {
				if(rotation_delta[p.id] != 0) {
					particles_data[p.id].r += rotation_delta[p.id] * dt;
				}
				particles_data[p.id].r += rotation_random * 360 * emitter.random_1_to_1() * dt;
			}
		} else {
			for (p in particles) {
				if(rotation_delta[p.id] != 0) {
					particles_data[p.id].r += rotation_delta[p.id] * dt;
				}
			}
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_rotation = d.initial_rotation;
		initial_rotation_max = d.initial_rotation_max;
		angular_velocity = d.angular_velocity;
		angular_velocity_max = d.angular_velocity_max;
		rotation_random = d.rotation_random;
		
		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_rotation = initial_rotation;
		d.initial_rotation_max = initial_rotation_max;
		d.angular_velocity = angular_velocity;
		d.angular_velocity_max = angular_velocity_max;
		d.rotation_random = rotation_random;

		return d;
	    
	}


}


typedef RotationModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_rotation : Float;
	@:optional var initial_rotation_max : Float;
	@:optional var angular_velocity : Float;
	@:optional var angular_velocity_max : Float;
	@:optional var rotation_random : Float;

}


