package;


import clay.Clay;
import clay.math.Vector;
import clay.graphics.shapes.Line;
import clay.graphics.Sprite;
import clay.events.MouseEvent;

class Game {

	var sprite:Sprite;

	public function new() {

		Clay.on(MouseEvent.MOUSE_MOVE, mouseMove);

		sprite = new Sprite();
		sprite.size.set(128,128);
		sprite.color.set(1,0,1,1);
		sprite.transform.pos.set(Clay.screen.mid.x, Clay.screen.mid.y);

		Clay.tween.object(sprite.transform).to({rotation: 360}, 4).repeat().start();

		Clay.layer.add(sprite);

		var s2 = new Sprite();
		s2.size.set(32,32);
		s2.color.set(1,0,1,1);
		s2.transform.parent = sprite.transform;
		s2.transform.pos.set(128, 0);
		Clay.tween.object(s2.transform).to({rotation: 360}, 2).repeat().start();

		Clay.layer.add(s2);

		var s3 = new Sprite();
		s3.size.set(16,16);
		s2.color.set(1,0,1,1);
		s3.transform.parent = s2.transform;
		s3.transform.pos.set(32, 0);
		Clay.tween.object(s2.transform).to({rotation: 360}, 2).repeat().start();

		Clay.layer.add(s3);

		var l1 = new Line();
		l1.p0.copyFrom(Clay.screen.mid);
		l1.strength = 8;
		Clay.layer.add(l1);

		s2.transform.listen(function(t) {
			l1.p1.copyFrom(sprite.transform.pos);
			t.world.decompose();
			l1.p0.copyFrom(t.world.pos);
		});

	}

	function mouseMove(e:MouseEvent) {

		sprite.transform.pos.set(e.x, e.y);
		
	}


}
