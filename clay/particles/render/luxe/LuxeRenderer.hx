package sparkler.render.luxe;


import phoenix.Batcher;


class LuxeRenderer extends Renderer {


	public var batcher:Batcher;


	public function new(?_batcher:Batcher) {

		super();
		batcher = _batcher;
		
		if(_batcher == null) {
			batcher = Luxe.renderer.batcher;
		}

	}

	override function get( emitter:sparkler.ParticleEmitter ) : EmitterRenderer {

		return new LuxeEmitter(this, emitter);

	}


}
