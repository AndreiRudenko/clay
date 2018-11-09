package processors;


import clay.utils.Log.*;
import clay.input.Mouse;
import clay.math.Vector;
import clay.data.Color;

import clay.particles.ParticleEmitter;
import clay.particles.ParticleSystem;
import clay.particles.modules.*;


class ParticleTestProcessor extends clay.Processor {


	var ps:ParticleSystem;


	override function onenabled() {

		var ui_layer = Clay.layers.create('ui', 2);

		world.components.set_many(
			world.entities.create(), 
			[
				new components.FPS(),
				new clay.components.graphics.Text({
					text: 'FPS:0', 
					font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
					size: 24, 
					layer: ui_layer
				}),
				new clay.components.common.Transform({pos: new Vector(Clay.screen.width - 100, 16)})
			]
		);

		ps = new ParticleSystem();

		ps.add(new ParticleEmitter({
				name : 'test_emitter', 
				rate : 1400,
				cache_size : 10000,
				lifetime : 2,
				lifetime_max : 4,
				// cache_wrap : true,
				image_path: 'assets/particle.png',
				modules : [
					new SpawnModule(),
					new DirectionModule({
						direction_variance: 180,
						speed: 90
					}),
					new GravityModule({
						gravity : new Vector(0, 90)
					}),
					new ScaleLifeModule({
						initial_scale : 1,
						end_scale : 0
					}),
					new ColorLifeModule({
						initial_color : new Color(1,0,0),
						end_color : new Color(0,0,1)
					}),
				]

			})
		);
	    
	}

	override function ondisabled() {
	    
	}

	override function update(dt:Float) {

		ps.update(dt);
	    
	}

	override function onmousemove(e:MouseEvent) {

		ps.pos.set(e.x, e.y);

	}

	override function onmousewheel(e:MouseEvent) {

		ps.emitters[0].rate += e.wheel*10;
		trace(ps.emitters[0].rate);
		
	}



}
