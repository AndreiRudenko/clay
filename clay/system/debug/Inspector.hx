package clay.system.debug;



import clay.Clay;
import clay.utils.Log.*;
import clay.graphics.shapes.Quad;
import clay.graphics.Text;
import clay.render.Color;
import clay.math.Vector;
import clay.input.Keyboard;
import clay.input.Key;
import clay.input.Touch;
// import clay.types.TextAlign;
import clay.system.Debug;
import clay.utils.Mathf;
import clay.math.Rectangle;
import clay.events.RenderEvent;
import clay.events.TouchEvent;
import clay.events.KeyEvent;


class Inspector {


	public var visible(default, set):Bool = false;

	public var overlay:Quad;
	// public var window:Sprite;
	public var fpsText:Text;
	public var debug:Debug;
	public var viewrect:Rectangle;

	public var tabs:Array<InspectorTab>;

    var dtAverage : Float = 0;
    var dtAverageAccum : Float = 0;
    var dtAverageSpan : Int = 60;
    var dtAverageCount : Int = 0;

	public var size:Vector;
	public var pos:Vector;

	public function new(_debug:Debug) {

		tabs = [];
		debug = _debug;

        size = new Vector(Clay.screen.width-(debug.padding.x*2), Clay.screen.height-(debug.padding.y*2));
        pos = new Vector(debug.padding.x, debug.padding.y);

		viewrect = new Rectangle(
            pos.x + (debug.margin/2),
            pos.y + (debug.margin*1.5),
            size.x - debug.margin,
            size.y - debug.margin - (debug.margin*1.5)
        );

		overlay = new Quad(Clay.screen.width, Clay.screen.height);
		overlay.visible = false;
		overlay.color = new Color(0,0,0,0.8);
		overlay.depth = 999;
		overlay.layer = debug.layer;

		fpsText = new Text(Clay.resources.font("assets/Muli-Regular.ttf"));
		fpsText.align = TextAlign.LEFT;
		fpsText.fontSize = 15;
		fpsText.visible = false;
		fpsText.color = new Color().fromInt(0xffa563);
		fpsText.transform.pos.set(debug.padding.x, debug.padding.y-16);
		fpsText.layer = debug.layer;
		fpsText.depth = 999.2;

		Clay.on(RenderEvent.RENDER, onrender);
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(TouchEvent.TOUCH_DOWN, onTouchDown);

	}

	public function addTab(name:String) {
		
		var tab = new InspectorTab(this, name);
		tab.index = tabs.length;
		tabs.push(tab);

		var ttwidth:Float = 0;
		for (t in tabs) {
			ttwidth += t.textWidth;
		}

		var rw:Float = Clay.screen.width - ttwidth - debug.margin*2;
		var td:Float = rw / (tabs.length-1);

		var ps:Float = debug.margin;
		for (t in tabs) {
			// ps += td;
			t.setPos(ps);
			ps += t.textWidth + td;
		}

	}

	public function enableTab(index:Int) {

		for (t in tabs) {
			t.disable();
		}

		tabs[index].enable();

	}

	public function destroy() {

		overlay.drop();
		// window.destroy();
		fpsText.drop();

		overlay = null;
		// window = null;
		fpsText = null;

	}

	function onrender(e) {
	    
        dtAverageAccum += Clay.app.frameDelta;
        dtAverageCount++;

        if(dtAverageCount == dtAverageSpan - 1) {
            dtAverage = dtAverageAccum/dtAverageSpan;
            dtAverageAccum = dtAverage;
            dtAverageCount = 0;
        }

        if(!visible) {
            return;
        }

            //update the fpsText
        fpsText.text = Math.round(1/dtAverage) + " / " + Mathf.fixed(dtAverage,5) + " / " + Mathf.fixed(Clay.app.frameDelta,5);

	}

	function onKeyDown(e:KeyEvent) {

		if(e.key == Key.BACKQUOTE || e.key == Key.F1) {
			visible = !visible;
		}

		if(visible) {
			if(e.key == Key.ONE) {
				debug.switchView(Clay.debug.currentView.index - 1);
			} else if(e.key == Key.TWO) {
				debug.switchView(Clay.debug.currentView.index + 1);
			}
		}

	}

	function onTouchDown(e:TouchEvent) {

		if(Clay.input.touch.count == 3) {
			visible = !visible;
		}

		if(visible) {
			if(Clay.input.touch.count == 2) {
				debug.switchView(Clay.debug.currentView.index + 1);
			}
		}

	}

	function set_visible(v:Bool):Bool {
		
		visible = v;

		overlay.visible = visible;
		// window.visible = visible;
		fpsText.visible = visible;

		if(visible) {
			debug.currentView.active = true;
			for (t in tabs) {
				t.show();
			}
		} else {
			debug.currentView.active = false;
			for (t in tabs) {
				t.hide();
			}
		}

		return v;

	}


}

private class InspectorTab {


	public var name:String;
	public var title:Text;
	public var inspector:Inspector;
	public var index:Int = 0;
	public var textWidth:Float = 0;


	public function new(inspector:Inspector, name:String, size:Int = 15) {

		this.inspector = inspector;
		this.name = name;

		title = new Text(Clay.resources.font("assets/Muli-Bold.ttf"));
		title.text = name;
		title.fontSize = size;
		title.align = TextAlign.LEFT;
		title.visible = false;
		title.color = new Color().fromInt(0xffa563);
		title.transform.pos.set(Clay.debug.padding.x+14, Clay.debug.padding.y+6);
		title.layer = Clay.debug.layer;
		title.depth = 999.2;

		var	_kravur = title.font.font._get(size);
		textWidth = _kravur.stringWidth(name);

	}

	public function setPos(pos:Float) {

		// if(inspector.tabs.length > 0) {
			// var w = Clay.screen.width / inspector.tabs.length;
			// title.pos.x = w * index + w/2;
		// }
			title.transform.pos.x = pos;

	}

	public function enable() {

		title.color.a = 1;

	}

	public function disable() {

		title.color.a = 0.5;

	}

	public function show() {

		title.visible = true;

	}

	public function hide() {
		
		title.visible = false;

	}


}
