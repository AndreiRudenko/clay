package;



class Game {


	public function new() {

		Clay.resources.load_all(
			[
			'assets/particle.png'
			], 
			ready
		);


	}

	function ready() {

		Clay.processors.add(new processors.FPSProcessor());
		Clay.processors.add(new clay.processors.graphics.ParticlesProcessor());
		Clay.processors.add(new processors.ParticleTestProcessor());

	}


}
