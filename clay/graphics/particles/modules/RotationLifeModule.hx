package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.RotationDelta;


class RotationLifeModule extends ParticleModule {


	public var initial_rotation:Float;
	public var initial_rotation_max:Float;
	public var end_rotation:Float;
	public var end_rotation_max:Float;
	public var rotation_random:Float;

	var rotation_delta:Components<RotationDelta>;


	public function new(_options:RotationLifeModuleOptions) {

		super(_options);

		initial_rotation = _options.initial_rotation != null ? _options.initial_rotation : 0;
		initial_rotation_max = _options.initial_rotation_max != null ? _options.initial_rotation_max : 0;
		end_rotation = _options.end_rotation != null ? _options.end_rotation : 1;
		end_rotation_max = _options.end_rotation_max != null ? _options.end_rotation_max : 0;
		rotation_random = _options.rotation_random != null ? _options.rotation_random : 0;

	}

	override function init() {

		rotation_delta = emitter.components.get(RotationDelta);

	}

	override function ondisabled() {
		
		for (p in particles) {
			p.r = 0;
		}

	}

	override function onspawn(p:Particle) {

		if(initial_rotation_max != 0) {
			p.r = emitter.random_float(initial_rotation, initial_rotation_max) * 360;
		} else {
			p.r = initial_rotation * 360;
		}

		if(end_rotation_max != 0) {
			rotation_delta.get(p.id).value = emitter.random_float(end_rotation, end_rotation_max) * 360 - p.r;
		} else {
			rotation_delta.get(p.id).value = end_rotation * 360 - p.r;
		}

		if(rotation_delta.get(p.id).value != 0) {
			rotation_delta.get(p.id).value /= p.lifetime;
		}

	}
	
	override function update(dt:Float) {

		if(rotation_random > 0) {
			for (p in particles) {
				if(rotation_delta.get(p.id).value != 0) {
					p.r += rotation_delta.get(p.id).value * dt;
				}
				p.r += rotation_random * 360 * emitter.random_1_to_1() * dt;
			}
		} else {
			for (p in particles) {
				if(rotation_delta.get(p.id).value != 0) {
					p.r += rotation_delta.get(p.id).value * dt;
				}
			}
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_rotation = d.initial_rotation;
		initial_rotation_max = d.initial_rotation_max;
		end_rotation = d.end_rotation;
		end_rotation_max = d.end_rotation_max;
		rotation_random = d.rotation_random;
		
		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_rotation = initial_rotation;
		d.initial_rotation_max = initial_rotation_max;
		d.end_rotation = end_rotation;
		d.end_rotation_max = end_rotation_max;
		d.rotation_random = rotation_random;

		return d;
	    
	}


}


typedef RotationLifeModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_rotation : Float;
	@:optional var initial_rotation_max : Float;
	@:optional var end_rotation : Float;
	@:optional var end_rotation_max : Float;
	@:optional var rotation_random : Float;

}


