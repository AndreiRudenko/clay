package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.math.Vector;
import clay.utils.Color;
import clay.utils.Log.*;

using clay.graphics.particles.utils.ColorExtender;

class ColorModule extends ParticleModule {

	public var initialColor(default, null):Color;
	public var initialColorMax:Color;

	var _color:Components<Color>;

	public function new(options:ColorModuleOptions) {
		super(options);

		initialColor = def(options.initialColor, new Color());
		initialColorMax = options.initialColorMax;
	}

	override function onAdded() {
		_color = emitter.components.get(Color);
	}

	override function onRemoved() {
		emitter.components.put(_color);
		_color = null;
	}

	override function onSpawn(p:Particle) {
		var pcolor:Color = _color.get(p.id);

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
	
	?initialColor:Color,
	?initialColorMax:Color,

}


