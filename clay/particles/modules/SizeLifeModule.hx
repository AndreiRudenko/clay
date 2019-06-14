package clay.particles.modules;

import clay.particles.core.ParticleModule;
import clay.particles.core.Particle;
import clay.particles.core.Components;
import clay.particles.components.SizeDelta;
import clay.math.Vector;
import clay.math.Mathf;

using clay.particles.utils.VectorExtender;


class SizeLifeModule extends ParticleModule {


	public var initial_size	(default, null):Vector;
	public var end_size    	(default, null):Vector;
	public var initial_size_max:Vector;
	public var end_size_max:Vector;

	var size_delta:Components<SizeDelta>;


	public function new(_options:SizeLifeModuleOptions) {

		super(_options);

		initial_size = _options.initial_size != null ? _options.initial_size : new Vector(32, 32);
		initial_size_max = _options.initial_size_max;
		end_size = _options.end_size != null ? _options.end_size : new Vector(8, 8);
		end_size_max = _options.end_size_max;

	}

	override function init() {

		size_delta = emitter.components.get(SizeDelta);
		
	}

	override function onspawn(pd:Particle) {

		var szd:Vector = size_delta.get(pd.id);
		var lf:Float = pd.lifetime;

		if(initial_size_max != null) {
			pd.w = emitter.random_float(initial_size.x, initial_size_max.x);
			pd.h = emitter.random_float(initial_size.y, initial_size_max.y);
		} else {
			pd.w = initial_size.x;
			pd.h = initial_size.y;
		}
		
		if(end_size_max != null) {
			szd.x = emitter.random_float(end_size.x, end_size_max.x) - pd.w;
			szd.y = emitter.random_float(end_size.y, end_size_max.y) - pd.h;
		} else {
			szd.x = end_size.x - pd.w;
			szd.y = end_size.y - pd.h;
		}

		if(szd.x != 0) {
			szd.x /= lf;
		}

		if(szd.y != 0) {
			szd.y /= lf;
		}

	}

	override function update(dt:Float) {

		var szd:Vector;
		for (p in particles) {
			szd = size_delta.get(p.id);
			p.w = Mathf.clamp_bottom(p.w + szd.x * dt, 0);
			p.h = Mathf.clamp_bottom(p.h + szd.y * dt, 0);
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		initial_size.from_json(d.initial_size);
		end_size.from_json(d.end_size);

		if(d.initial_size_max != null) {
			if(initial_size_max == null) {
				initial_size_max = new Vector();
			}
			initial_size_max.from_json(d.initial_size_max);
		}
		
		if(d.end_size_max != null) {
			if(end_size_max == null) {
				end_size_max = new Vector();
			}
			end_size_max.from_json(d.end_size_max);
		}

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.initial_size = initial_size.to_json();
		d.end_size = end_size.to_json();

		if(initial_size_max != null) {
			d.initial_size_max = initial_size_max.to_json();
		}
		if(end_size_max != null) {
			d.end_size_max = end_size_max.to_json();
		}

		return d;
	    
	}


}


typedef SizeLifeModuleOptions = {
	
	>ParticleModuleOptions,
	@:optional var initial_size : Vector;
	@:optional var initial_size_max : Vector;
	@:optional var end_size : Vector;
	@:optional var end_size_max : Vector;

}


