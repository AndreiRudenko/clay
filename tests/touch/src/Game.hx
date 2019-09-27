package;


import clay.Clay;
import clay.events.AppEvent;
import clay.graphics.Text;

class Game {


	public function new() {

		Clay.on(AppEvent.UPDATE, update);

	}

	function update(dt:Float) {

		var ratio = Clay.screen.width / 960;
		var radius = 48 * ratio;
		var fontSize = 24 * ratio;

		for (t in Clay.input.touch.touches) {
			Clay.draw.circleOutline({
				x: t.x,
				y: t.y,
				r: radius,
				weight: 2 * ratio
			});

			Clay.draw.text({
				x: t.x,
				y: t.y - radius - 32 * ratio,
				text: Std.string(t.id),
				font: Clay.renderer.font,
				size: Math.floor(fontSize),
				align: TextAlign.CENTER
			});
		}
		
	}

}
