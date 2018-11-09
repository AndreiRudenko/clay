package;


class Game {


	public function new() {

		Clay.resources.load_all(
			[
				'assets/wabbit_alpha.png'
			], 
			ready
		);

	}

	function ready() {

		Clay.processors.add(new processors.FPSProcessor());
		Clay.processors.add(new processors.BunniesTestProcessor());

	}


}
