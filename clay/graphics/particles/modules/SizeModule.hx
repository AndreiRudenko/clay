package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Size;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class SizeModule extends ParticleModule {


	public var initialSize	(default, null):Vector;
	public var initialSizeMax:Vector;

	var _size:Components<Size>;


	public function new(_options:SizeModuleOptions) {

		super(_options);

		initialSize = _options.initialSize != null ? _options.initialSize : new Vector(32, 32);
		initialSizeMax = _options.initialSizeMax;
		
	}

	override function init() {

		_size = emitter.components.get(Size);

	}

	override function onSpawn(pd:Particle) {
		
		var sz:Vector = _size.get(pd.id);

		if(initialSizeMax != null) {
			sz.x = emitter.randomFloat(initialSize.x, initialSizeMax.x);
			sz.y = emitter.randomFloat(initialSize.y, initialSizeMax.y);
		} else {
			sz.x = initialSize.x;
			sz.y = initialSize.y;
		}
		
	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		initialSize.fromJson(d.initialSize);

		if(d.initialSizeMax != null) {
			if(initialSizeMax == null) {
				initialSizeMax = new Vector();
			}
			initialSizeMax.fromJson(d.initialSizeMax);
		}
		

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialSize = initialSize.toJson();

		if(initialSizeMax != null) {
			d.initialSizeMax = initialSizeMax.toJson();
		}

		return d;
	    
	}


}


typedef SizeModuleOptions = {
	
	>ParticleModuleOptions,
	@:optional var initialSize : Vector;
	@:optional var initialSizeMax : Vector;

}


