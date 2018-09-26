package processors;


import clay.utils.Log.*;
import clay.input.Keyboard;


class KeyboardTestProcessor extends clay.Processor {


	override function onkeydown(e:KeyEvent) {

		log('onkeydown: $e');

	}

	override function onkeyup(e:KeyEvent) {

		log('onkeyup: $e');

	}


}
