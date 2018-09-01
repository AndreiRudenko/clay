package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleData;
import clay.particles.core.Components;
import clay.particles.components.Velocity;
import clay.particles.modules.VelocityModule;
import clay.math.Vector;


class VelocityLifeModule extends VelocityModule {


	public var end_velocity(default, null):Vector;
	public var end_velocity_max:Vector;

	var velocity_delta:Array<Vector>;
	var particles_data:Array<ParticleData>;


	public function new(_options:VelocityLifeModuleOptions) {

		super(_options);

		velocity_delta = [];

		end_velocity = _options.end_velocity != null ? _options.end_velocity : new Vector();
		end_velocity_max = _options.end_velocity_max;

	}

	override function init() {

		super.init();

		particles_data = emitter.particles_data;

		for (i in 0...particles.capacity) {
			velocity_delta[i] = new Vector();
		}
	    
	}

	override function onspawn(p:Particle) {

		var v:Velocity = vel_comps.get(p);
		if(initial_velocity_max != null) {
			v.x = emitter.random_float(initial_velocity.x, initial_velocity_max.x);
			v.y = emitter.random_float(initial_velocity.y, initial_velocity_max.y);
		} else {
			v.x = initial_velocity.x;
			v.y = initial_velocity.y;
		}

		if(end_velocity_max != null) {
			velocity_delta[p.id].x = emitter.random_float(end_velocity.x, end_velocity_max.x) - v.x;
			velocity_delta[p.id].y = emitter.random_float(end_velocity.y, end_velocity_max.y) - v.y;
		} else {
			velocity_delta[p.id].x = end_velocity.x - v.x;
			velocity_delta[p.id].y = end_velocity.y - v.y;
		}

		if(velocity_delta[p.id].lengthsq() != 0) {
			velocity_delta[p.id].divide_scalar(particles_data[p.id].lifetime);
		}

	}

	override function update(dt:Float) {

		var v:Vector;
		if(velocity_random != null) {
			for (p in particles) {
				v = vel_comps.get(p);
				v.x += velocity_delta[p.id].x * dt + velocity_random.x * emitter.random_1_to_1();
				v.y += velocity_delta[p.id].y * dt + velocity_random.x * emitter.random_1_to_1();
			}
		} else {
			for (p in particles) {
				v = vel_comps.get(p);
				v.x += velocity_delta[p.id].x * dt;
				v.y += velocity_delta[p.id].y * dt;
			}
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		end_velocity.from_json(d.end_velocity);

		if(d.end_velocity_max != null) {
			if(end_velocity_max == null) {
				end_velocity_max = new Vector();
			}
			end_velocity_max.from_json(d.end_velocity_max);
		}

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.end_velocity = end_velocity.to_json();

		if(end_velocity_max != null) {
			d.end_velocity_max = end_velocity_max.to_json();
		}

		return d;
	    
	}


}


typedef VelocityLifeModuleOptions = {

	> VelocityModuleOptions,
	
	@:optional var end_velocity : Vector;
	@:optional var end_velocity_max : Vector;

}


