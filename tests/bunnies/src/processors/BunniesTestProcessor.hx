package processors;


import clay.Entity;
import clay.Family;
import components.Bunnie;
import components.Velocity;
import components.AngularVelocity;
import clay.components.common.Transform;
import clay.components.graphics.Text;
import clay.components.graphics.QuadGeometry;
import clay.utils.Log.*;
import clay.input.Mouse;
import clay.math.Vector;
import clay.render.types.TextureAddressing;
import clay.render.Layer;


class BunniesTestProcessor extends clay.Processor {


	var bunnies_family:Family<Bunnie, QuadGeometry, Transform, Velocity, AngularVelocity>;

	var bunnies_text:Text;
	var bg:QuadGeometry;

	var inc_bunnies:Int = 100;
	var num_bunnies:Int = 0;
	var gravity:Float = 90;

	var max_x:Int;
	var max_y:Int;

	var mouse_pressed:Bool = false;
	var ui_layer:Layer;


	override function onadded() {

		ui_layer = Clay.layers.create('ui', 2);
	    
		world.components.set_many(
			world.entities.create(), 
			[
				new components.FPS(),
				new Text({
					text: 'FPS:0', 
					font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
					size: 24, 
					layer: ui_layer
				}),
				new Transform({pos: new Vector(Clay.screen.width - 100, 16)})
			]
		);

		max_x = Clay.screen.width;
		max_y = Clay.screen.height;


		// text
		bunnies_text = new Text({
			text: 'bunnies: 0', 
			size: 18, 
			font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
			layer: ui_layer
		});

		world.components.set_many(
			world.entities.create(), 
			[
				bunnies_text,
				new Transform({pos: new Vector(16, 16)})
			]
		);

	}

	override function onmousedown(e:MouseEvent) {

		mouse_pressed = true;

	}

	override function onmouseup(e:MouseEvent) {

		mouse_pressed = false;

	}

	override function update(dt:Float) {

		if(mouse_pressed) {
			add_bunnies(inc_bunnies);
		}

		var t:Transform;
		var q:QuadGeometry;
		var v:Velocity;
		var av:AngularVelocity;

		for (e in bunnies_family) {
			q = bunnies_family.get_quadgeometry(e);
			t = bunnies_family.get_transform(e);
			v = bunnies_family.get_velocity(e);
			av = bunnies_family.get_angularvelocity(e);

			t.pos.x += v.x * dt;
			v.y += gravity * dt;
			t.pos.y += v.y * dt;
			t.rotation += av.amount * dt;

			q.color.a = 0.3 + 0.7 * t.pos.y / max_y;

			if (t.pos.x > max_x) {
				v.x *= -1;
				t.pos.x = max_x;
			} else if (t.pos.x < 0) {
				v.x *= -1;
				t.pos.x = 0;
			}
			if (t.pos.y > max_y) {
				v.y *= -0.8;
				t.pos.y = max_y;
				if (Math.random() > 0.5) v.y -= 50 + Math.random() * 60;
			} else if (t.pos.y < 0) {
				v.y *= -0.8;
				t.pos.y = 0;
			}

		}

	}

	function add_bunnies(num:Int) {

		for (i in 0...num) {
			create_bunnie();
		}

		bunnies_text.text = 'bunnies: $num_bunnies';
		
	}

	function create_bunnie() {

		var e = world.entities.create();

		var b = new Bunnie();

		var g = new QuadGeometry({
			size: new Vector(26, 37),
			texture: Clay.resources.texture('assets/wabbit_alpha.png'),
		});

		var s = 0.3 + Math.random();
		var t = new Transform({
			scale: new Vector(s, s),
			origin: new Vector(13, 18.5),
			// pos: new Vector(Clay.screen.width * Math.random(), Clay.screen.height * Math.random()),
			pos: new Vector(),
			rotation: 15 - Math.random() * 30,
		});

		var v = new Velocity(50 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1), 50 * ((Math.random() * 5) - 2.5) * (Math.random() < 0.5 ? 1 : -1));
		var av = new AngularVelocity(30 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1));

		world.components.set_many(e, [b,g,t,v,av]);

		num_bunnies++;

	}



}
