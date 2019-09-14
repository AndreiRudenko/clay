package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.math.Vector;
import clay.render.Color;


class ColorModule extends ParticleModule {


	public var initialColor(default, null):Color;
	public var initialColorMax:Color;


	public function new(_options:ColorModuleOptions) {

		super(_options);

		initialColor = _options.initialColor != null ? _options.initialColor : new Color();
		initialColorMax = _options.initialColorMax;

	}

	override function onSpawn(p:Particle) {

		var pcolor:Color = p.color;

		if(initialColorMax != null) {
			pcolor.r = initialColorMax.r > initialColor.r ? emitter.randomFloat(initialColor.r, initialColorMax.r) : initialColor.r;
			pcolor.g = initialColorMax.g > initialColor.g ? emitter.randomFloat(initialColor.g, initialColorMax.g) : initialColor.g;
			pcolor.b = initialColorMax.b > initialColor.b ? emitter.randomFloat(initialColor.b, initialColorMax.b) : initialColor.b;
			pcolor.a = initialColorMax.a > initialColor.a ? emitter.randomFloat(initialColor.a, initialColorMax.a) : initialColor.a;
		} else {
			pcolor.r = initialColor.r;
			pcolor.g = initialColor.g;
			pcolor.b = initialColor.b;
			pcolor.a = initialColor.a;
		}

	}

// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		if(d.initialColor != null) {
			initialColor.fromJson(d.initialColor);
		}

		if(d.initialColorMax != null) {
			if(initialColorMax == null) {
				initialColorMax = new Color();
			}
			initialColorMax.fromJson(d.initialColorMax);
		}

		return this;

	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialColor = initialColor.toJson();

		if(initialColorMax != null) {
			d.initialColorMax = initialColorMax.toJson();
		}

		return d;

	}


}


typedef ColorModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initialColor : Color;
	@:optional var initialColorMax : Color;

}


