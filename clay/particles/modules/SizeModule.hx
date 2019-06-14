package clay.particles.modules;

import clay.particles.core.ParticleModule;
import clay.particles.core.Particle;
import clay.particles.core.Components;
import clay.math.Vector;

using clay.particles.utils.VectorExtender;


class SizeModule extends ParticleModule {


	public var initial_size	(default, null):Vector;
	public var initial_size_max:Vector;


	public function new(_options:SizeModuleOptions) {

		super(_options);

		initial_size = _options.initial_size != null ? _options.initial_size : new Vector(32, 32);
		initial_size_max = _options.initial_size_max;
		
	}

	override function init() {

	}

	override function onspawn(pd:Particle) {

		if(initial_size_max != null) {
			pd.w = emitter.random_float(initial_size.x, initial_size_max.x);
			pd.h = emitter.random_float(initial_size.y, initial_size_max.y);
		} else {
			pd.w = initial_size.x;
			pd.h = initial_size.y;
		}
		
	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_size.from_json(d.initial_size);

		if(d.initial_size_max != null) {
			if(initial_size_max == null) {
				initial_size_max = new Vector();
			}
			initial_size_max.from_json(d.initial_size_max);
		}
		

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_size = initial_size.to_json();

		if(initial_size_max != null) {
			d.initial_size_max = initial_size_max.to_json();
		}

		return d;
	    
	}


}


typedef SizeModuleOptions = {
	
	>ParticleModuleOptions,
	@:optional var initial_size : Vector;
	@:optional var initial_size_max : Vector;

}


