package clay.particles.modules;

import clay.particles.core.ParticleModule;
import clay.particles.core.Particle;
import clay.particles.core.Components;
import clay.particles.components.ScaleDelta;
import clay.math.Mathf;


class ScaleLifeModule extends ParticleModule {


	public var initial_scale:Float;
	public var initial_scale_max:Float;
	public var end_scale:Float;
	public var end_scale_max:Float;

	var scale_delta:Components<ScaleDelta>;


	public function new(_options:ScaleLifeModuleOptions) {

		super(_options);

		initial_scale = _options.initial_scale != null ? _options.initial_scale : 1;
		initial_scale_max = _options.initial_scale_max != null ? _options.initial_scale_max : 0;
		end_scale = _options.end_scale != null ? _options.end_scale : 1;
		end_scale_max = _options.end_scale_max != null ? _options.end_scale_max : 0;

	}

	override function init() {

		scale_delta = emitter.components.get(ScaleDelta);

	}

	override function ondisabled() {

		for (pd in particles) {
			pd.s = 1;
		}
		
	}

	override function onspawn(p:Particle) {

		if(initial_scale_max > initial_scale) {
			p.s = emitter.random_float(initial_scale, initial_scale_max);
		} else {
			p.s = initial_scale;
		}

		if(end_scale_max > end_scale) {
			scale_delta.get(p.id).value = emitter.random_float(end_scale, end_scale_max) - p.s;
		} else {
			scale_delta.get(p.id).value = end_scale - p.s;
		}

		if(scale_delta.get(p.id).value != 0) {
			scale_delta.get(p.id).value /= p.lifetime;
		}

	}

	override function update(dt:Float) {

		for (p in particles) {
			if(scale_delta.get(p.id).value != 0) {
				p.s = Mathf.clamp_bottom(p.s + scale_delta.get(p.id).value * dt, 0);
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


