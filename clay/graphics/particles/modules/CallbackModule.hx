package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import particles.ParticleEmitter;


class CallbackModule extends ParticleModule {


	public var onspawn_callback:Particle->ParticleEmitter->Void;
	public var onunspawn_callback:Particle->ParticleEmitter->Void;


	public function new(_options:ForceModuleOptions) {

		super();

		onspawn_callback = _options.onspawn_callback;
		onunspawn_callback = _options.onunspawn_callback;

	}

	override function onspawn(p:Particle) {

		if(onspawn_callback != null) {
			onspawn_callback(p, emitter);
		}

	}

	override function onunspawn(p:Particle) {
		
		if(onunspawn_callback != null) {
			onunspawn_callback(p, emitter);
		}
		
	}


}


typedef ForceModuleOptions = {

	@:optional var onspawn_callback : Particle->ParticleEmitter->Void;
	@:optional var onunspawn_callback : Particle->ParticleEmitter->Void;

}

