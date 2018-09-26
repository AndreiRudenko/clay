package processors;


import clay.utils.Log.*;
import clay.input.Mouse;


class MouseTestProcessor extends clay.Processor {



	override function onmousedown(e:MouseEvent) {

		log('onmousedown: $e');

	}

	override function onmouseup(e:MouseEvent) {

		log('onmouseup: $e');

	}

	override function onmousemove(e:MouseEvent) {

		log('onmousemove: $e');

	}

	override function onmousewheel(e:MouseEvent) {

		log('onmousewheel: $e');

	}



}
