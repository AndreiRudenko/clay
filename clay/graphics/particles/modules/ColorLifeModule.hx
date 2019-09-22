package clay.graphics.particles.modules;


import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.ColorDelta;
import clay.render.Color;
import clay.utils.Mathf;


class ColorLifeModule extends ParticleModule {


	public var initialColor	(default, null):Color;
	public var endColor    	(default, null):Color;
	public var initialColorMax:Color;
	public var endColorMax:Color;

	var _colorDelta:Components<ColorDelta>;
	var _color:Components<Color>;


	public function new(_options:ColorLifeModuleOptions) {

		super(_options);

		initialColor = _options.initialColor != null ? _options.initialColor : new Color();
		initialColorMax = _options.initialColorMax;
		endColor = _options.endColor != null ? _options.endColor : new Color();
		endColorMax = _options.endColorMax;

	}

	override function init() {

		_colorDelta = emitter.components.get(ColorDelta);
		_color = emitter.components.get(Color);
	    
	}

	override function onSpawn(p:Particle) {

		var cd:Color = _colorDelta.get(p.id);
		var pcolor:Color = _color.get(p.id);
		var lf:Float = p.lifetime;

		if(initialColorMax != null) {
			pcolor.r = emitter.randomFloat(initialColor.r, initialColorMax.r);
			pcolor.g = emitter.randomFloat(initialColor.g, initialColorMax.g);
			pcolor.b = emitter.randomFloat(initialColor.b, initialColorMax.b);
			pcolor.a = emitter.randomFloat(initialColor.a, initialColorMax.a);
		} else {
			pcolor.r = initialColor.r;
			pcolor.g = initialColor.g;
			pcolor.b = initialColor.b;
			pcolor.a = initialColor.a;
		}
		
		if(endColorMax != null) {
			cd.r = emitter.randomFloat(endColor.r, endColorMax.r) - pcolor.r;
			cd.g = emitter.randomFloat(endColor.g, endColorMax.g) - pcolor.g;
			cd.b = emitter.randomFloat(endColor.b, endColorMax.b) - pcolor.b;
			cd.a = emitter.randomFloat(endColor.a, endColorMax.a) - pcolor.a;
		} else {
			cd.r = endColor.r - pcolor.r;
			cd.g = endColor.g - pcolor.g;
			cd.b = endColor.b - pcolor.b;
			cd.a = endColor.a - pcolor.a;
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
			cd = _colorDelta.get(p.id);
			pcolor = _color.get(p.id);
			pcolor.r = Mathf.clamp(pcolor.r + cd.r * dt, 0, 1);
			pcolor.g = Mathf.clamp(pcolor.g + cd.g * dt, 0, 1);
			pcolor.b = Mathf.clamp(pcolor.b + cd.b * dt, 0, 1);
			pcolor.a = Mathf.clamp(pcolor.a + cd.a * dt, 0, 1);
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		if(d.initialColor != null) {
			initialColor.fromJson(d.initialColor);
		}

		if(d.endColor != null) {
			endColor.fromJson(d.endColor);
		}

		if(d.initialColorMax != null) {
			if(initialColorMax == null) {
				initialColorMax = new Color();
			}
			initialColorMax.fromJson(d.initialColorMax);
		}
		
		if(d.endColorMax != null) {
			if(endColorMax == null) {
				endColorMax = new Color();
			}
			endColorMax.fromJson(d.endColorMax);
		}

		return this;

	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialColor = initialColor.toJson();
		d.endColor = endColor.toJson();

		if(initialColorMax != null) {
			d.initialColorMax = initialColorMax.toJson();
		}
		
		if(endColorMax != null) {
			d.endColorMax = endColorMax.toJson();
		}

		return d;

	}


}

typedef ColorLifeModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initialColor : Color;
	@:optional var initialColorMax : Color;
	@:optional var endColor : Color;
	@:optional var endColorMax : Color;

}


