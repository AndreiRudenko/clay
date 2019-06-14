package clay.particles.modules;


import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.math.Vector;

using clay.particles.utils.VectorExtender;


class PolyLineSpawnModule extends ParticleModule {


	public var points(default, null):Array<Vector>;


	public function new(_options:PolyLineSpawnModuleOptions) {

		super(_options);

		points = _options.points != null ? _options.points : [];

		_priority = -999;
		
	}

	override function onspawn(p:Particle) {

		if(points.length > 1) {

			var rnd_idx = emitter.random_int(points.length-1);
			var p0 = points[rnd_idx];
			var p1 = points[rnd_idx+1];

			var rnd = emitter.random_float(1);

			p.x = emitter.system.pos.x + emitter.pos.x + (p0.x + (p1.x - p0.x) * rnd);
			p.y = emitter.system.pos.y + emitter.pos.y + (p0.y + (p1.y - p0.y) * rnd);
			
		}

	}

// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		for (i in 0...d.points.length) {
			points[i].from_json(d.points[i]);
		}

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.points = [];

		for (p in points) {
			d.points.push(p.to_json());
		}

		return d;
	    
	}


}

typedef PolyLineSpawnModuleOptions = {

	>ParticleModuleOptions,

	@:optional var points:Array<Vector>;

}
