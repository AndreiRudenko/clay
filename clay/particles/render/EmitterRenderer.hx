package clay.particles.render;


import clay.particles.ParticleEmitter;
import clay.particles.core.ParticleData;
import clay.particles.core.Particle;
import clay.render.types.BlendMode;
import clay.render.Layer;


class EmitterRenderer {


	var emitter:ParticleEmitter;


	public function new(_emitter:ParticleEmitter) {

		emitter = _emitter;

	}

	public function init() {}
	public function destroy() {}

	public function onparticleshow(p:Particle) {}
	public function onparticlehide(p:Particle) {}

	public function ontexture(path:String) {}
	public function update(dt:Float) {}

	public function ondepth(v:Float) {}
	public function onlayer(v:Layer) {}

	public function onblendsrc(v:BlendMode) {}
	public function onblenddest(v:BlendMode) {}
	

}