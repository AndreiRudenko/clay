package;

import clay.Clay;
import clay.events.AppEvent;
import clay.events.RenderEvent;
import clay.events.KeyEvent;
import clay.events.TouchEvent;
import clay.input.Key;
import clay.graphics.Text;
import clay.utils.Align;
import clay.utils.Color;
import clay.utils.Mathf;
import clay.render.Shader;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;

import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class Game {

	var bunnies:Array<Bunnie>;
	var incBunnies:Int = 1000;
	var gravity:Float = 90;
	var maxX:Int;
	var maxY:Int;
	var bunniesText:Text;
	var fpsText:Text;

	// fps
    var dtAverage:Float = 0;
    var dtAverageAccum:Float = 0;
    var dtAverageSpan:Int = 60;
    var dtAverageCount:Int = 0;
    var lastTime:Float = 0;

    var sepiaShader:Shader;
    var uiLayer:Int = 1;

	public function new() {
		Clay.resources.loadAll(
			[
				"bunnie.png"
			], 
			ready
		);
	}

	function ready() {
		maxX = Clay.screen.width;
		maxY = Clay.screen.height;

		bunnies = [];
		Clay.on(AppEvent.UPDATE, update);
		Clay.on(RenderEvent.RENDER, render);
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(TouchEvent.TOUCH_DOWN, onTouchDown);

		var camUI = Clay.cameras.create("camUI");
		camUI.hideAll();
		camUI.show(uiLayer);

		Clay.camera.hide(uiLayer);
		
		bunniesText = new Text(Clay.renderer.font);
		bunniesText.fontSize = 20;
		bunniesText.text = 'Bunnies: ${bunnies.length}';
		bunniesText.transform.pos.set(16, 16);
		bunniesText.depth = 999;
		Clay.layers.add(bunniesText, uiLayer);

		fpsText = new Text(Clay.renderer.font);
		fpsText.fontSize = 20;
		fpsText.transform.pos.set(maxX - 100, 16);
		fpsText.depth = 999;
		Clay.layers.add(fpsText, uiLayer);
	}

	function onKeyDown(e:KeyEvent) {
		if(e.key == Key.SPACE) {
			addBunnies(incBunnies);
		}
		
		var cam = Clay.camera;
		var aa = cam.antialiasing;
		var res = cam.resolution;

		if(e.key == Key.LEFT) {
			aa--;
			aa = Mathf.clampi(aa, 0, 16);
			cam.antialiasing = aa;
		}
		if(e.key == Key.RIGHT) {
			aa++;
			aa = Mathf.clampi(aa, 0, 16);
			cam.antialiasing = aa;
		}

		if(e.key == Key.UP) {
			res += 0.1;
			res = Mathf.clamp(res, 0.1, 1);
			cam.resolution = res;
		}
		if(e.key == Key.DOWN) {
			res -= 0.1;
			res = Mathf.clamp(res, 0.1, 1);
			cam.resolution = res;
		}
	}

	function onTouchDown(e:TouchEvent) {
		addBunnies(incBunnies);
	}

	function update(dt:Float) {
		for (b in bunnies) {
			b.x += b.vx * dt;
			b.vy += gravity * dt;
			b.y += b.vy * dt;

			if (b.x > maxX) {
				b.vx *= -1;
				b.x = maxX;
			} else if (b.x < 0) {
				b.vx *= -1;
				b.x = 0;
			}
			if (b.y > maxY) {
				b.vy *= -0.8;
				b.y = maxY;
				if (Math.random() > 0.5) b.vy -= 50 + Math.random() * 60;
			} else if (b.y < 0) {
				b.vy *= -0.8;
				b.y = 0;
			}
		}
	}

	function render(e:RenderEvent) {
		var time = Clay.time;

		dtAverageAccum += time - lastTime;
		dtAverageCount++;

		if(dtAverageCount == dtAverageSpan - 1) {
			dtAverage = dtAverageAccum/dtAverageSpan;
			dtAverageAccum = dtAverage;
			dtAverageCount = 0;
		}

		lastTime = time;

		fpsText.text = 'FPS: ${Math.round(1/dtAverage)}';
	}

	function addBunnies(num:Int) {
		for (i in 0...num) {
			createBunnie();
		}
		bunniesText.text = 'Bunnies: ${bunnies.length}';
	}

	function createBunnie() {
		var b = new Bunnie(0, 0, 32, 32);
		bunnies.push(b);
	}

}
