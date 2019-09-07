package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.graphics.particles.components.VelocityDelta;
import clay.graphics.particles.modules.VelocityModule;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class VelocityLifeModule extends VelocityModule {


	public var end_velocity(default, null):Vector;
	public var end_velocity_max:Vector;

	var velocity_delta:Components<VelocityDelta>;


	public function new(_options:VelocityLifeModuleOptions) {

		super(_options);

		end_velocity = _options.end_velocity != null ? _options.end_velocity : new Vector();
		end_velocity_max = _options.end_velocity_max;

	}

	override function init() {

		super.init();

		velocity_delta = emitter.components.get(VelocityDelta);
	    
	}

	override function onspawn(p:Particle) {

		var v:Velocity = vel_comps.get(p.id);
		if(initial_velocity_max != null) {
			v.x = emitter.random_float(initial_velocity.x, initial_velocity_max.x);
			v.y = emitter.random_float(initial_velocity.y, initial_velocity_max.y);
		} else {
			v.x = initial_velocity.x;
			v.y = initial_velocity.y;
		}

		if(end_velocity_max != null) {
			velocity_delta.get(p.id).x = emitter.random_float(end_velocity.x, end_velocity_max.x) - v.x;
			velocity_delta.get(p.id).y = emitter.random_float(end_velocity.y, end_velocity_max.y) - v.y;
		} else {
			velocity_delta.get(p.id).x = end_velocity.x - v.x;
			velocity_delta.get(p.id).y = end_velocity.y - v.y;
		}

		if(velocity_delta.get(p.id).lengthsq != 0) {
			velocity_delta.get(p.id).divide_scalar(p.lifetime);
		}

	}

	override function update(dt:Float) {

		var v:Vector;
		if(velocity_random != null) {
			for (p in particles) {
				v = vel_comps.get(p.id);
				v.x += velocity_delta.get(p.id).x * dt + velocity_random.x * emitter.random_1_to_1();
				v.y += velocity_delta.get(p.id).y * dt + velocity_random.y * emitter.random_1_to_1();
			}
		} else {
			for (p in particles) {
				v = vel_comps.get(p.id);
				v.x += velocity_delta.get(p.id).x * dt;
				v.y += velocity_delta.get(p.id).y * dt;
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


