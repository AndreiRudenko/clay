package;

import clay.Clay;
import clay.math.Vector;
import clay.utils.Color;
import clay.utils.StrokeAlign;
import clay.graphics.shapes.Quad;
import clay.graphics.shapes.QuadOutline;
import clay.graphics.shapes.Line;
import clay.graphics.shapes.Circle;
import clay.graphics.shapes.CircleOutline;
import clay.graphics.shapes.PolyLine;
import clay.graphics.shapes.PolygonOutline;

class Game {

	public function new() {
		Clay.resources.loadAll(
			[
				'test.png',
				'thread.png'
			], 
			ready
		);
	}

	function ready() {
		var quad = new Quad(32,32);
		quad.transform.pos.set(128, 128);
		Clay.layers.add(quad);

		var line = new Line();
		line.point0.set(256,64);
		line.point1.set(64,32);
		line.strength = 4;
		line.color0 = new Color(1,0,1);
		line.color1 = new Color(0,0,1);
		Clay.layers.add(line);

		var quad2 = new QuadOutline(64,64,16);
		quad2.texture = Clay.resources.texture('thread.png');
		// quad2.color.set(1,0.5,0);
		quad2.transform.pos.set(256, 64);
		quad2.transform.origin.set(32, 32);
		Clay.tween.object(quad2.transform).to({rotation: 360}, 4).repeat().start();
		Clay.layers.add(quad2);

		var circle = new Circle(64);
		circle.texture = Clay.resources.texture('test.png');
		// circle.color.set(0,0.5,1);
		circle.transform.pos.copyFrom(Clay.screen.mid);
		Clay.layers.add(circle);

		var circle2 = new CircleOutline(96, 16);
		circle2.texture = Clay.resources.texture('test.png');
		circle2.align = StrokeAlign.OUTSIDE;
		// circle2.color.set(0,0.5,1);
		circle2.transform.pos.copyFrom(Clay.screen.mid);
		Clay.tween.object(circle2).to({radius: 128}, 1)
		.ease(clay.tween.easing.Quad.easeIn)
		.repeat()
		.reflect()
		.start();
		Clay.layers.add(circle2);

		var points = [
			new Vector(0, 0),
			new Vector(100, 0),
			new Vector(100, 150),
			new Vector(200, 100)
		];

		var polyline = new PolyLine(points, 16);
		polyline.texture = Clay.resources.texture('test.png');
		// polyline.texture = Clay.resources.texture('thread.png');
		// polyline.color = Color.random();
		polyline.transform.pos.set(600, 400);
		Clay.layers.add(polyline);

		var points = [
			new Vector(0, 0),
			new Vector(100, 0),
			new Vector(100, 100),
			new Vector(50, 150),
			new Vector(0, 200)
		];

		var polygon = new PolygonOutline(points, 4);
		polygon.texture = Clay.resources.texture('test.png');
		polygon.align = StrokeAlign.INSIDE;
		polygon.color = Color.random();
		polygon.transform.pos.set(600, 50);
		Clay.tween.object(polygon).to({weight: 16}, 1).repeat().reflect().start();
		Clay.layers.add(polygon);
	}

}