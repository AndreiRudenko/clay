package;


import clay.Clay;
import clay.math.Vector;
import clay.graphics.slice.NineSlice;
import clay.graphics.slice.ThreeSlice;
import clay.events.MouseEvent;


class Game {

	public function new() {

		Clay.resources.load_all(
			[
				'assets/threeslice.png',
				'assets/nineslice.png'
			], 
			ready
		);

	}

	var nineslice:NineSlice;
	var threeslice:ThreeSlice;

	function ready() {

		Clay.on(MouseEvent.MOUSE_MOVE, mousemove);

		nineslice = new NineSlice(32, 32, 32, 32);
		nineslice.width = 256;
		nineslice.height = 256;
		nineslice.texture = Clay.resources.texture('assets/nineslice.png');
		// nineslice.draw_cender = false;

		Clay.layer.add(nineslice);

		threeslice = new ThreeSlice(32, 32);
		threeslice.transform.pos.y = 480;
		threeslice.width = 256;
		threeslice.height = 32;
		threeslice.texture = Clay.resources.texture('assets/threeslice.png');

		Clay.layer.add(threeslice);

	}

	function mousemove(e:MouseEvent) {

		nineslice.width = e.x;
		nineslice.height = e.y;

		threeslice.width = e.x;
		
	}


}
