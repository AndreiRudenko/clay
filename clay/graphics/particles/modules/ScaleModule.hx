package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;


class ScaleModule extends ParticleModule {


	public var initial_scale:Float;
	public var initial_scale_max:Float;


	public function new(_options:ScaleModuleOptions) {

		super(_options);

		initial_scale = _options.initial_scale != null ? _options.initial_scale : 1;
		initial_scale_max = _options.initial_scale_max != null ? _options.initial_scale_max : 0;

	}

	override function init() {

	}

	override function ondisabled() {

		for (p in particles) {
			p.s = 1;
		}
		
	}

	override function onspawn(p:Particle) {

		if(initial_scale_max > initial_scale) {
			p.s = emitter.random_float(initial_scale, initial_scale_max);
		} else {
			p.s = initial_scale;
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_scale = d.initial_scale;
		initial_scale_max = d.initial_scale_max;
		
		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_scale = initial_scale;
		d.initial_scale_max = initial_scale_max;

		return d;
	    
	}


}


typedef ScaleModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_scale : Float;
	@:optional var initial_scale_max : Float;

}


