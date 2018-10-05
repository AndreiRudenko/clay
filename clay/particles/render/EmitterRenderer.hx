package clay.particles.render;


import clay.particles.ParticleEmitter;
import clay.particles.core.ParticleData;
import clay.particles.core.Particle;
import clay.particles.data.BlendMode;


class EmitterRenderer {


	var emitter:ParticleEmitter;


	public function new(_emitter:ParticleEmitter) {

		emitter = _emitter;

	}

	public function init() {}
	public function destroy() {}
	
	public function onspritecreate(p:Particle):ParticleData { return null; }
	public function onspritedestroy(pd:ParticleData) {}
	public function onspriteshow(pd:ParticleData) {}
	public function onspritehide(pd:ParticleData) {}
	public function onspriteupdate(pd:ParticleData) {}

	public function ondepth(v:Float) {}
	public function ontexture(path:String) {}
	public function onupdate(dt:Float) {}

	public function onblendsrc(v:BlendMode) {}
	public function onblenddest(v:BlendMode) {}
	public function onlayerchanged(v:Int) {}


}