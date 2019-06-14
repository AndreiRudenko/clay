package clay.particles.modules;

import clay.particles.core.ParticleModule;
import clay.particles.core.Particle;
import clay.particles.core.Components;
import clay.math.Vector;
import clay.data.Color;


class ColorModule extends ParticleModule {


	public var initial_color	(default, null):Color;
	public var initial_color_max:Color;


	public function new(_options:ColorModuleOptions) {

		super(_options);

		initial_color = _options.initial_color != null ? _options.initial_color : new Color();
		initial_color_max = _options.initial_color_max;

	}

	override function onspawn(p:Particle) {

		var pcolor:Color = p.color;

		if(initial_color_max != null) {
			pcolor.r = initial_color_max.r > initial_color.r ? emitter.random_float(initial_color.r, initial_color_max.r) : initial_color.r;
			pcolor.g = initial_color_max.g > initial_color.g ? emitter.random_float(initial_color.g, initial_color_max.g) : initial_color.g;
			pcolor.b = initial_color_max.b > initial_color.b ? emitter.random_float(initial_color.b, initial_color_max.b) : initial_color.b;
			pcolor.a = initial_color_max.a > initial_color.a ? emitter.random_float(initial_color.a, initial_color_max.a) : initial_color.a;
		} else {
			pcolor.r = initial_color.r;
			pcolor.g = initial_color.g;
			pcolor.b = initial_color.b;
			pcolor.a = initial_color.a;
		}

	}

// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		if(d.initial_color != null) {
			initial_color.from_json(d.initial_color);
		}

		if(d.initial_color_max != null) {
			if(initial_color_max == null) {
				initial_color_max = new Color();
			}
			initial_color_max.from_json(d.initial_color_max);
		}

		return this;

	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_color = initial_color.to_json();

		if(initial_color_max != null) {
			d.initial_color_max = initial_color_max.to_json();
		}

		return d;

	}


}


typedef ColorModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_color : Color;
	@:optional var initial_color_max : Color;

}


