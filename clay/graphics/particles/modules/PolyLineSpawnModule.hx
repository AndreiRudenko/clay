package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class PolyLineSpawnModule extends ParticleModule {


	public var points(default, null):Array<Vector>;


	public function new(_options:PolyLineSpawnModuleOptions) {

		super(_options);

		points = _options.points != null ? _options.points : [];

		_priority = -999;
		
	}

	override function onSpawn(p:Particle) {

		if(points.length > 1) {

			var rndIdx = emitter.randomInt(points.length-1);
			var p0 = points[rndIdx];
			var p1 = points[rndIdx+1];

			var rnd = emitter.randomFloat(1);

			p.x = emitter.system.pos.x + emitter.pos.x + (p0.x + (p1.x - p0.x) * rnd);
			p.y = emitter.system.pos.y + emitter.pos.y + (p0.y + (p1.y - p0.y) * rnd);
			
		}

	}

// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		for (i in 0...d.points.length) {
			points[i].fromJson(d.points[i]);
		}

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.points = [];

		for (p in points) {
			d.points.push(p.toJson());
		}

		return d;
	    
	}


}

typedef PolyLineSpawnModuleOptions = {

	>ParticleModuleOptions,

	@:optional var points:Array<Vector>;

}
