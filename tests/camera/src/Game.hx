package;

import clay.Clay;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Camera;
import clay.render.Layers;
import clay.graphics.Sprite;
import clay.graphics.shapes.QuadOutline;
import clay.render.types.TextureAddressing;
import clay.events.MouseEvent;
import clay.events.KeyEvent;
import clay.events.AppEvent;
import clay.input.Key;

class Game {

	var width:Int = 960;
	var height:Int = 640;

	var mouseDown = false;
	var dragStartPos:Vector = new Vector();
	var dragPos:Vector = new Vector();
	var uiCamera:Camera;
	var uiLayer:Int = 1;

	public function new() {
		Clay.resources.loadAll(
			[
				"test.png"
			], 
			ready
		);
	}

	function ready() {
		Clay.on(AppEvent.UPDATE, update);
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		Clay.on(MouseEvent.MOUSE_DOWN, onMouseDown);
		Clay.on(MouseEvent.MOUSE_UP, onMouseUp);
		Clay.on(MouseEvent.MOUSE_MOVE, onMouseMove);

		var t = Clay.resources.texture('test.png');

		var ratio = height / width;
		var sd = 2;

		var bg = new Sprite(t);
		bg.textureParameters.uAddressing = TextureAddressing.Repeat;
		bg.textureParameters.vAddressing = TextureAddressing.Repeat;

		bg.centered = false;
		bg.transform.origin.set(0,0);
		bg.setUV(0,0,1*sd,ratio*sd);
		bg.size.set(width, height);
		Clay.layers.add(bg);

		var rect = new Rectangle(0, 0, 1024, 768);

		uiCamera = Clay.cameras.create("uiCamera");
		uiCamera.hideAll();
		uiCamera.show(uiLayer);
		Clay.camera.hide(uiLayer);

		var midX = Clay.screen.mid.x;
		var midY = Clay.screen.mid.y;
		
		Clay.camera.viewport = new Rectangle(0, 0, midX, midY);
		Clay.camera.size.set(width, height);
		Clay.camera.sizeMode = SizeMode.CONTAIN;

		var cam2 = Clay.cameras.create("cam2");
		cam2.viewport = new Rectangle(midX, 0, midX, midY);
		cam2.hideAll();
		cam2.show(Layers.DEFAULT);
		cam2.zoom = 0.75;

		var cam3 = Clay.cameras.create("cam3");
		cam3.viewport = new Rectangle(0, midY, midX, midY);
		cam3.hideAll();
		cam3.show(Layers.DEFAULT);
		cam3.zoom = 0.5;

		var cam4 = Clay.cameras.create("cam4");
		cam4.viewport = new Rectangle(midX, midY, midX, midY);
		cam4.hideAll();
		cam4.show(Layers.DEFAULT);
		cam4.zoom = 0.25;
	}

	function update(dt:Float) {
		var cam = Clay.camera;
		Clay.draw.text({
			x: 32,
			y: 32,
			font: Clay.renderer.font,
			fontSize: 16,
			layer: Clay.layers.getLayer(uiLayer),
			text: '
Camera
	pos: {${cam.pos.x}, ${cam.pos.y}}
	anchor: {${cam.anchor.x}, ${cam.anchor.y}}
	zoom: ${cam.zoom}
transform
	pos: {${cam.transform.pos.x}, ${cam.transform.pos.y}}
	origin: {${cam.transform.origin.x}, ${cam.transform.origin.y}}
	scale: {${cam.transform.scale.x}, ${cam.transform.scale.y}}

Mouse: {${Clay.screen.cursor.pos.x},${Clay.screen.cursor.pos.y}}'
		});
	}

	function onKeyDown(e:KeyEvent) {
		if(e.key == Key.E) {
			Clay.camera.rotation += 15;
		} else if(e.key == Key.Q) {
			Clay.camera.rotation -= 15;
		}

		if(e.key == Key.LEFT) {
			Clay.camera.pos.x -= 20;
		} else if(e.key == Key.RIGHT) {
			Clay.camera.pos.x += 20;
		}

		if(e.key == Key.UP) {
			Clay.camera.pos.y -= 20;
		} else if(e.key == Key.DOWN) {
			Clay.camera.pos.y += 20;
		}

		if(e.key == Key.Z) {
			Clay.camera.resolution -= 0.1;
		} else if(e.key == Key.X) {
			Clay.camera.resolution += 0.1;
		}
	}

	function onMouseWheel(e:MouseEvent) {
		if(e.wheel > 0) {
			if(Clay.camera.zoom > 0.2) {
				Clay.camera.zoom -= 0.1;
			}
		} else {
			Clay.camera.zoom += 0.1;
		}

		var cam = Clay.camera;
		var z = cam.zoom;
		var v = new Vector(e.x, e.y);
		cam.screenToWorld(v, v);

		var prevX = v.x;
		var prevY = v.y;

		cam.anchor.set(e.x / cam.viewport.w, e.y / cam.viewport.h);

		v.set(e.x, e.y);
		cam.screenToWorld(v, v);

		var curX = v.x;
		var curY = v.y;
		cam.pos.addXY((prevX - curX), (prevY - curY));
	}

	function onMouseDown(e:MouseEvent) {
		mouseDown = true;
		dragStartPos.set(e.x, e.y);
		dragPos.copyFrom(Clay.camera.pos);
	}

	function onMouseUp(e:MouseEvent) {
		mouseDown = false;
	}

	function onMouseMove(e:MouseEvent) {
		if(mouseDown) {
			var camera = Clay.camera;
			var diffx:Float = (e.x - dragStartPos.x) * camera.transform.scale.x;
			var diffy:Float = (e.y - dragStartPos.y) * camera.transform.scale.y;
			camera.pos.set(dragPos.x - diffx, dragPos.y - diffy);
		}
	}

}
