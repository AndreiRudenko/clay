package;

import clay.Clay;
import clay.math.Vector;
import clay.utils.Color;
import clay.events.AppEvent;

class Game {

	public function new() {
		Clay.on(AppEvent.UPDATE, update);
	}

	function update(dt:Float) {
		Clay.draw.line({
			p0: new Vector(100, 100),
			p1: Clay.screen.cursor.pos,
			color0: new Color(1,0.3,0.2)
		});

		Clay.draw.quad({
			x: 500,
			y: 300,
			w: 128,
			h: 64,
			color: new Color(0,1,0.4)
		});
		
		Clay.draw.quadOutline({
			x: 700,
			y: 500,
			w: 80,
			h: 48,
			color: new Color(1,0,0.4)
		});

		Clay.draw.circle({
			x: 200,
			y: 300,
			color: new Color(0.5,1,0.5)
		});

		Clay.draw.circleOutline({
			x: 400,
			y: 300,
			color: new Color(0.5,0,0.5)
		});
	}

}
