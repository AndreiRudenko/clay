package;

import clay.Clay;
import clay.math.Vector;
import clay.graphics.slice.NineSlice;
import clay.graphics.slice.ThreeSlice;
import clay.events.MouseEvent;

class Game {

	public function new() {
		Clay.resources.loadAll(
			[
				'threeslice.png',
				'nineslice.png'
			], 
			ready
		);
	}

	var nineslice:NineSlice;
	var threeslice:ThreeSlice;
	var threeslice2:ThreeSlice;

	function ready() {
		Clay.on(MouseEvent.MOUSE_MOVE, mouseMove);
		Clay.on(MouseEvent.MOUSE_WHEEL, onMouseWheel);

		nineslice = new NineSlice(32, 32, 32, 32);
		nineslice.width = 256;
		nineslice.height = 256;
		nineslice.texture = Clay.resources.texture('nineslice.png');
		// nineslice.drawCender = false;

		Clay.layers.add(nineslice);

		threeslice = new ThreeSlice(32, 32);
		threeslice.transform.pos.x = 64;
		threeslice.transform.pos.y = 400;
		threeslice.width = 256;
		threeslice.height = 32;
		threeslice.texture = Clay.resources.texture('threeslice.png');

		Clay.layers.add(threeslice);
	}

	function mouseMove(e:MouseEvent) {
		nineslice.width = e.x;
		nineslice.height = e.y;
		threeslice.width = e.x;
	}

	function onMouseWheel(e:MouseEvent) {
		nineslice.edgeScale -= e.wheel * 0.1;
	}

}
