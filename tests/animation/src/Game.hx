package;


import clay.Clay;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Color;
import clay.graphics.animation.AnimatedSprite;
import clay.graphics.Sprite;
import clay.events.Events;

class Game {


	public function new() {

		Clay.resources.loadAll(
			[
				'assets/walk_spritesheet.png',
				'assets/walk_1.png',
				'assets/walk_2.png',
				'assets/walk_3.png',
				'assets/walk_4.png',
				'assets/walk_5.png',
				'assets/walk_6.png',
				'assets/walk_7.png',
				'assets/walk_8.png',
				'assets/walk_9.png',
				'assets/walk_10.png',
				'assets/walk_11.png',
				'assets/walk_12.png',
				'assets/walk_13.png',
				'assets/walk_14.png',
				'assets/walk_15.png',
				'assets/walk_16.png',
			], 
			ready
		);

	}

	function ready() {

		var animSprite = new AnimatedSprite();
		animSprite.size.set(64,64);
		animSprite.transform.origin.set(32, 32);
		animSprite.transform.pos.set(-32, Clay.screen.mid.y-64);

		animSprite.fromTextures(
			'walk', 
			[			
			'assets/walk_1.png',
			'assets/walk_2.png',
			'assets/walk_3.png',
			'assets/walk_4.png',
			'assets/walk_5.png',
			'assets/walk_6.png',
			'assets/walk_7.png',
			'assets/walk_8.png',
			'assets/walk_9.png',
			'assets/walk_10.png',
			'assets/walk_11.png',
			'assets/walk_12.png',
			'assets/walk_13.png',
			'assets/walk_14.png',
			'assets/walk_15.png',
			'assets/walk_16.png'
			]
		)
		.setSpeed(24)
		.setAll()
		.loop();

		animSprite.setAnimation('walk');
		animSprite.play();

		Clay.layer.add(animSprite);
		Clay.tween.object(animSprite.transform.pos).to({x: Clay.screen.width + 32}, 4).repeat().start();


		var animSprite2 = new AnimatedSprite();
		animSprite2.size.set(64,64);
		animSprite2.transform.origin.set(32, 32);
		animSprite2.transform.pos.set(-32, Clay.screen.mid.y+64);

		animSprite2.events = new Events();
		animSprite2.events.listen('test', function(e) {trace(e);});

		animSprite2.fromGrid(
			'walk', 
			'assets/walk_spritesheet.png',
			4,
			4
		)
		.setSpeed(32)
		.setAll()
		.loop();
		animSprite2.addEvent('walk', 6, 'test');

		animSprite2.setAnimation('walk');
		animSprite2.play();

		Clay.layer.add(animSprite2);
		Clay.tween.object(animSprite2.transform.pos).to({x: Clay.screen.width + 32}, 3).repeat().start();

	}


}
