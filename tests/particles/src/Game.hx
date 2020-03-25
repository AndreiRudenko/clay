package;

import clay.Clay;
import clay.math.Vector;
import clay.events.AppEvent;
import clay.graphics.Sprite;
import clay.utils.Color;
import clay.events.MouseEvent;
import clay.events.KeyEvent;
import clay.input.Key;
import clay.graphics.particles.ParticleSystem;
import clay.graphics.particles.ParticleEmitter;
import clay.graphics.particles.modules.*;
import clay.graphics.particles.utils.ParticlesSortMode;
import clay.utils.BlendMode;

class Game {

	public function new() {
		Clay.resources.loadAll(
			[
				'circle.png',
				// 'fire_spritesheet.png' // TODO
			], 
			ready
		);
	}

	var ps:ParticleSystem;

	function ready() {
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(AppEvent.UPDATE, update);

		ps = new ParticleSystem();
		ps.localSpace = false;

		ps.addEmitter(new ParticleEmitter({
				name : 'test1', 
				// pos: new Vector(-48, 16),
				// enabled: false,
				// duration: 0.2,
				// rate: 1,
				// cacheSize: 4,
				rate: 400,
				// rateMax: 50,
				cacheSize: 512,
				// preprocess: 1,
				lifetime: 2,
				// lifetimeMax: 4,
				count: 1,
				cacheWrap: true,
				modules: [
					// new SpawnModule(),
					new AreaSpawnModule({
						size: new Vector(32, 8)
					}),
					new DirectionModule({
						direction: 270,
						directionVariance: 45,
						speedVariance: 100,
						speed: 300
					}),
					// new ForceModule({
					// 	// force: new Vector(0, 128),
					// 	forceRandom: new Vector(1000, 1000),
					// }),
					// new ForceLifeModule({
					// 	initialForce: new Vector(0, 0),
					// 	endForce: new Vector(0, 64),
					// 	// forceRandom: new Vector(0, 128),
					// }),
					new GravityModule({
						gravity: new Vector(0, 300)
					}),
					// new RadialAccelModule({
					// 	tangentAccel: 1000,
					// 	tangentAccelVariance: 300,
					// 	radialAccel: -1000,
					// 	offset: new Vector(128, 0),
					// }),
					new SizeModule({
						initialSize: new Vector(32,32)
					}),
					new ScaleLifeModule({
						initialScale: 0.75,
						initialScaleMax : 1,
						endScale: 0
					}),
					new ColorLifeModule({
						initialColor: new Color(0,0,1,1),
						// initialColorMax: new Color(1,1,0.5,1),
						endColor: new Color(1,0,1,1),
						// endColorMax: new Color(),
					}),
					new VelocityUpdateModule({
						// damping : 1,
					}),
					new SpriteRenderModule({
						sortMode: ParticlesSortMode.LIFETIME,
						texture: Clay.resources.texture('circle.png'),
						blendMode: BlendMode.ADD
						// region: new clay.math.Rectangle(0,192,192,192) 
					}),
				]

			})
		);
		ps.start();

		Clay.layers.add(ps);
	}

	function update(dt:Float) {
		ps.transform.pos.copyFrom(Clay.screen.cursor.pos);
	}

	function onKeyDown(e:KeyEvent) {

		if(e.key == Key.E) {
			ps.transform.rotation += 10;
		}
		if(e.key == Key.Q) {
			ps.transform.rotation -= 10;
		}

		if(e.key == Key.W) {
			ps.transform.scale.addScalar(0.1);
		}
		if(e.key == Key.S) {
			ps.transform.scale.subtractScalar(0.1);
		}

		if(e.key == Key.L) {
			ps.localSpace = !ps.localSpace;
			trace('local space: ${ps.localSpace}');
		}

	}
	
}
