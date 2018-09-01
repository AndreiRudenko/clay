package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleData;
import clay.particles.core.Components;
import clay.math.Vector;
import clay.data.Color;



class ColorLifeModule extends ParticleModule {


	public var initial_color	(default, null):Color;
	public var end_color    	(default, null):Color;
	public var initial_color_max:Color;
	public var end_color_max:Color;

	var color_delta:Array<Color>;
	var particles_data:Array<ParticleData>;


	public function new(_options:ColorLifeModuleOptions) {

		super(_options);

		color_delta = [];

		initial_color = _options.initial_color != null ? _options.initial_color : new Color();
		initial_color_max = _options.initial_color_max;
		end_color = _options.end_color != null ? _options.end_color : new Color();
		end_color_max = _options.end_color_max;

	}

	override function init() {

		particles_data = emitter.particles_data;

		for (i in 0...particles.capacity) {
			color_delta[i] = new Color();
		}
	    
	}

	override function onremoved() {

	    particles_data = null;
	    color_delta.splice(0, color_delta.length);

	}

	override function onspawn(p:Particle) {

		var pd:ParticleData = particles_data[p.id];
		var cd:Color = color_delta[p.id];
		var lf:Float = pd.lifetime;
		var pcolor:Color = pd.color;

		if(initial_color_max != null) {
			pcolor.r = emitter.random_float(initial_color.r, initial_color_max.r);
			pcolor.g = emitter.random_float(initial_color.g, initial_color_max.g);
			pcolor.b = emitter.random_float(initial_color.b, initial_color_max.b);
			pcolor.a = emitter.random_float(initial_color.a, initial_color_max.a);
		} else {
			pcolor.r = initial_color.r;
			pcolor.g = initial_color.g;
			pcolor.b = initial_color.b;
			pcolor.a = initial_color.a;
		}
		
		if(end_color_max != null) {
			cd.r = emitter.random_float(end_color.r, end_color_max.r) - pcolor.r;
			cd.g = emitter.random_float(end_color.g, end_color_max.g) - pcolor.g;
			cd.b = emitter.random_float(end_color.b, end_color_max.b) - pcolor.b;
			cd.a = emitter.random_float(end_color.a, end_color_max.a) - pcolor.a;
		} else {
			cd.r = end_color.r - pcolor.r;
			cd.g = end_color.g - pcolor.g;
			cd.b = end_color.b - pcolor.b;
			cd.a = end_color.a - pcolor.a;
		}

		if(cd.r != 0) { cd.r /= lf; }
		if(cd.g != 0) { cd.g /= lf; }
		if(cd.b != 0) { cd.b /= lf; }
		if(cd.a != 0) { cd.a /= lf; }

	}

	override function update(dt:Float) {

		var cd:Color;
		var pcolor:Color;
		for (p in particles) {
			cd = color_delta[p.id];
			pcolor = particles_data[p.id].color;
			pcolor.r += cd.r * dt;
			pcolor.g += cd.g * dt;
			pcolor.b += cd.b * dt;
			pcolor.a += cd.a * dt;
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		if(d.initial_color != null) {
			initial_color.from_json(d.initial_color);
		}

		if(d.end_color != null) {
			end_color.from_json(d.end_color);
		}

		if(d.initial_color_max != null) {
			if(initial_color_max == null) {
				initial_color_max = new Color();
			}
			initial_color_max.from_json(d.initial_color_max);
		}
		
		if(d.end_color_max != null) {
			if(end_color_max == null) {
				end_color_max = new Color();
			}
			end_color_max.from_json(d.end_color_max);
		}

		return this;

	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_color = initial_color.to_json();
		d.end_color = end_color.to_json();

		if(initial_color_max != null) {
			d.initial_color_max = initial_color_max.to_json();
		}
		
		if(end_color_max != null) {
			d.end_color_max = end_color_max.to_json();
		}

		return d;

	}


}


typedef ColorLifeModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initial_color : Color;
	@:optional var initial_color_max : Color;
	@:optional var end_color : Color;
	@:optional var end_color_max : Color;

}


