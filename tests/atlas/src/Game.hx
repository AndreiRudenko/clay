package;

import clay.Clay;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.utils.Color;
import clay.utils.Atlas;
import clay.events.AppEvent;
import clay.graphics.Sprite;

class Game {

	public function new() {
		Clay.resources.loadAll(
			[
				"sprites.png",
				"sprites.json",
			], 
			ready
		);
	}

	function ready() {
		var atlas = Atlas.loadFromPath("sprites.json");

		var sprite = new Sprite(atlas.texture);
		sprite.region = atlas.getRegion("square.png");
		sprite.size.set(64,64);
		sprite.transform.pos.set(128,128);
		Clay.layers.add(sprite);

		sprite = new Sprite(atlas.texture);
		sprite.region = atlas.getRegion("hexagon.png");
		sprite.size.set(96,96);
		sprite.transform.pos.set(256,128);
		Clay.layers.add(sprite);

		sprite = new Sprite(atlas.texture);
		sprite.region = atlas.getRegion("pentagon.png");
		sprite.size.set(96,96);
		sprite.transform.pos.set(128,256);
		Clay.layers.add(sprite);

		sprite = new Sprite(atlas.texture);
		sprite.region = atlas.getRegion("circle.png");
		sprite.size.set(64,64);
		sprite.transform.pos.set(256,256);
		Clay.layers.add(sprite);
	}

}
