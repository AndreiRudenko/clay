package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleData;
import clay.particles.core.Components;


class ScaleModule extends ParticleModule {


	public var initial_scale:Float;
	public var initial_scale_max:Float;

	var particles_data:Array<ParticleData>;


	public function new(_options:ScaleModuleOptions) {

		super(_options);

		initial_scale = _options.initial_scale != null ? _options.initial_scale : 1;
		initial_scale_max = _options.initial_scale_max != null ? _options.initial_scale_max : 0;

	}

	override function init() {

		particles_data = emitter.particles_data;

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


