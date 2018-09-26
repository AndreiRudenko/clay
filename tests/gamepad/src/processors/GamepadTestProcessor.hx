package processors;


import clay.utils.Log.*;
import clay.input.Gamepad;


class GamepadTestProcessor extends clay.Processor {


	override function ongamepadadd(e:GamepadEvent) {

		log('ongamepadadd: $e');

	}

	override function ongamepadremove(e:GamepadEvent) {

		log('ongamepadremove: $e');

	}

	override function ongamepaddown(e:GamepadEvent) {

		log('ongamepaddown: $e');

	}

	override function ongamepadup(e:GamepadEvent) {

		log('ongamepadup: $e');

	}

	override function ongamepadaxis(e:GamepadEvent) {
		
		log('ongamepadaxis: $e');

	}


}
