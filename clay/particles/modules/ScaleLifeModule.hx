package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleData;
import clay.particles.core.Components;


class ScaleLifeModule extends ParticleModule {


	public var initial_scale:Float;
	public var initial_scale_max:Float;
	public var end_scale:Float;
	public var end_scale_max:Float;

	var scale_delta:Array<Float>;
	var particles_data:Array<ParticleData>;


	public function new(_options:ScaleLifeModuleOptions) {

		super(_options);

		scale_delta = [];

		initial_scale = _options.initial_scale != null ? _options.initial_scale : 1;
		initial_scale_max = _options.initial_scale_max != null ? _options.initial_scale_max : 0;
		end_scale = _options.end_scale != null ? _options.end_scale : 1;
		end_scale_max = _options.end_scale_max != null ? _options.end_scale_max : 0;

	}

	override function init() {

		particles_data = emitter.particles_data;

		for (i in 0...particles.capacity) {
			scale_delta[i] = 0;
		}
	    
	}

	override function ondisabled() {

		for (pd in particles_data) {
			pd.s = 1;
		}
		
	}

	override function onspawn(p:Particle) {

		var pd:ParticleData = particles_data[p.id];

		if(initial_scale_max > initial_scale) {
			pd.s = emitter.random_float(initial_scale, initial_scale_max);
		} else {
			pd.s = initial_scale;
		}

		if(end_scale_max > end_scale) {
			scale_delta[p.id] = emitter.random_float(end_scale, end_scale_max) - pd.s;
		} else {
			scale_delta[p.id] = end_scale - pd.s;
		}

		if(scale_delta[p.id] != 0) {
			scale_delta[p.id] /= pd.lifetime;
		}

	}

	override function update(dt:Float) {

		for (p in particles) {
			if(scale_delta[p.id] != 0) {
				particles_data[p.id].s += scale_delta[p.id] * dt;
			}
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_scale = d.initial_scale;
		initial_scale_max = d.initial_scale_max;
		end_scale = d.end_scale;
		end_scale_max = d.end_scale_max;
		
		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_scale = initial_scale;
		d.initial_scale_max = initial_scale_max;
		d.end_scale = end_scale;
		d.end_scale_max = end_scale_max;

		return d;
	    
	}


}


typedef ScaleLifeModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_scale : Float;
	@:optional var initial_scale_max : Float;
	@:optional var end_scale : Float;
	@:optional var end_scale_max : Float;

}


