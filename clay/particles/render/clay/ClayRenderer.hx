package clay.particles.render.clay;


// import clay.particles.render.Renderer;
import clay.render.Layer;


// import phoenix.Batcher;


class ClayRenderer extends Renderer {


	public function new() {

		super();

	}

	override function get( emitter:clay.particles.ParticleEmitter ) : EmitterRenderer {

		return new ClayEmitter(this, emitter);

	}


}
