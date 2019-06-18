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

		Clay.resources.load_all(
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

		var anim_sprite = new AnimatedSprite();
		anim_sprite.size.set(64,64);
		anim_sprite.transform.origin.set(32, 32);
		anim_sprite.transform.pos.set(-32, Clay.screen.mid.y-64);

		anim_sprite.from_textures(
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
		.set_speed(24)
		.set_all()
		.loop();

		anim_sprite.set_animation('walk');
		anim_sprite.play();

		Clay.layer.add(anim_sprite);
		Clay.tween.object(anim_sprite.transform.pos).to({x: Clay.screen.width + 32}, 4).repeat().start();


		var anim_sprite2 = new AnimatedSprite();
		anim_sprite2.size.set(64,64);
		anim_sprite2.transform.origin.set(32, 32);
		anim_sprite2.transform.pos.set(-32, Clay.screen.mid.y+64);

		anim_sprite2.events = new Events();
		anim_sprite2.events.listen('test', function(e) {trace(e);});

		anim_sprite2.from_grid(
			'walk', 
			'assets/walk_spritesheet.png',
			4,
			4
		)
		.set_speed(32)
		.set_all()
		.loop();
		anim_sprite2.add_event('walk', 6, 'test');

		anim_sprite2.set_animation('walk');
		anim_sprite2.play();

		Clay.layer.add(anim_sprite2);
		Clay.tween.object(anim_sprite2.transform.pos).to({x: Clay.screen.width + 32}, 3).repeat().start();

	}


}
