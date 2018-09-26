package;


import clay.math.Vector;


class Game {


	public function new() {

		Clay.renderer.layers.create();
		Clay.processors.add(new clay.processors.AnimationProcessor(), 0);

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
			init
		);

	}

	function init() {

		// images animation
		var e = Clay.entities.create();
		var g = new clay.components.QuadGeometry({size: new Vector(64,64)});

		var t = new clay.components.Transform();
		t.origin.set(32, 32);
		t.pos.set(Clay.screen.mid.x-128, Clay.screen.mid.y);

		var a = new clay.components.Animation();
		a.from_textures(
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

		a.set('walk');
		a.play();

		Clay.components.set_many(e, [g,t,a]);

		// spritesheet animation
		var e = Clay.entities.create();
		var g = new clay.components.QuadGeometry({size: new Vector(64, 64)});

		var t = new clay.components.Transform();
		t.origin.set(32, 32);
		t.pos.set(Clay.screen.mid.x+128, Clay.screen.mid.y);

		var a = new clay.components.Animation();
		a.from_grid(
			'walk', 
			'assets/walk_spritesheet.png',
			4,
			4
		)
		.set_speed(24)
		.set_all()
		.loop();

		a.set('walk');
		a.play();

		Clay.components.set_many(e, [g,t,a]);
		
	}

}
