package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.Components;
import clay.particles.components.Velocity;
import clay.math.Vector;

using clay.particles.utils.VectorExtender;


class VelocityModule extends ParticleModule {


	public var initial_velocity(default, null):Vector;
	public var initial_velocity_max:Vector; // variance?
	public var velocity_random:Vector;

	var vel_comps:Components<Velocity>;


	public function new(_options:VelocityModuleOptions) {

		super(_options);

		initial_velocity = _options.initial_velocity != null ? _options.initial_velocity : new Vector();
		initial_velocity_max = _options.initial_velocity_max;
		velocity_random = _options.velocity_random;

	}

	override function init() {

		vel_comps = emitter.components.get(Velocity);

	}

	override function onremoved() {

		vel_comps = null;
		
	}

	override function ondisabled() {

		particles.for_each(
			function(p) {
				vel_comps.get(p.id).set(0,0);
			}
		);
		
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

	}

	override function update(dt:Float) {

		if(velocity_random != null) {
			var v:Velocity;
			for (p in particles) {
				v = vel_comps.get(p.id);
				v.x += velocity_random.x * emitter.random_1_to_1();
				v.y += velocity_random.y * emitter.random_1_to_1();
			}
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_velocity.from_json(d.initial_velocity);

		if(d.initial_velocity_max != null) {
			if(initial_velocity_max == null) {
				initial_velocity_max = new Vector();
			}
			initial_velocity_max.from_json(d.initial_velocity_max);
		}
		
		if(d.velocity_random != null) {
			if(velocity_random == null) {
				velocity_random = new Vector();
			}
			velocity_random.from_json(d.velocity_random);
		}

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_velocity = initial_velocity.to_json();

		if(initial_velocity_max != null) {
			d.initial_velocity_max = initial_velocity_max.to_json();
		}

		if(velocity_random != null) {
			d.velocity_random = velocity_random.to_json();
		}

		return d;
	    
	}


}


typedef VelocityModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_velocity : Vector;
	@:optional var initial_velocity_max : Vector;
	@:optional var velocity_random : Vector;

}


