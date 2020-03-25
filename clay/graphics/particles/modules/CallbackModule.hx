package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.ParticleEmitter;

class CallbackModule extends ParticleModule {

	public var onSpawnCallback:(p:Particle, pe:ParticleEmitter)->Void;
	public var onUnSpawnCallback:(p:Particle, pe:ParticleEmitter)->Void;
	public var onUpdateCallback:(dt:Float, pe:ParticleEmitter)->Void;

	public function new(options:CallbackModuleOptions) {
		super();

		onSpawnCallback = options.onSpawn;
		onUnSpawnCallback = options.onUnSpawn;
		onUpdateCallback = options.onUpdate;
	}

	override function onSpawn(p:Particle) {
		if(onSpawnCallback != null) {
			onSpawnCallback(p, emitter);
		}
	}

	override function onUnspawn(p:Particle) {
		if(onUnSpawnCallback != null) {
			onUnSpawnCallback(p, emitter);
		}
	}

	override function update(dt:Float) {
		if(onUpdateCallback != null) {
			onUpdateCallback(dt, emitter);
		}
	}

}

typedef CallbackModuleOptions = {

	?onSpawn:(p:Particle, pe:ParticleEmitter)->Void,
	?onUnSpawn:(p:Particle, pe:ParticleEmitter)->Void,
	?onUpdate:(dt:Float, pe:ParticleEmitter)->Void,

}
