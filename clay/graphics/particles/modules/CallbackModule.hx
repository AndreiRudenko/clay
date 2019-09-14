package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import particles.ParticleEmitter;


class CallbackModule extends ParticleModule {


	public var onSpawnCallback:(p:Particle, pe:ParticleEmitter)->Void;
	public var onUnSpawnCallback:(p:Particle, pe:ParticleEmitter)->Void;


	public function new(_options:ForceModuleOptions) {

		super();

		onSpawnCallback = _options.onSpawnCallback;
		onUnSpawnCallback = _options.onUnSpawnCallback;

	}

	override function onSpawn(p:Particle) {

		if(onSpawnCallback != null) {
			onSpawnCallback(p, emitter);
		}

	}

	override function onUnSpawn(p:Particle) {
		
		if(onUnSpawnCallback != null) {
			onUnSpawnCallback(p, emitter);
		}
		
	}


}


typedef ForceModuleOptions = {

	@:optional var onSpawnCallback:(p:Particle, pe:ParticleEmitter)->Void;
	@:optional var onUnSpawnCallback:(p:Particle, pe:ParticleEmitter)->Void;

}

