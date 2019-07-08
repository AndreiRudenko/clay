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
	public var fps_text:Text;
	public var debug:Debug;
	public var viewrect:Rectangle;

	public var tabs:Array<InspectorTab>;

    var dt_average : Float = 0;
    var dt_average_accum : Float = 0;
    var dt_average_span : Int = 60;
    var dt_average_count : Int = 0;

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

		fps_text = new Text(Clay.resources.font('assets/Muli-Bold.ttf'));
		fps_text.align = TextAlign.left;
		fps_text.size = 15;
		fps_text.visible = false;
		fps_text.color = new Color().from_int(0xffa563);
		fps_text.transform.pos.set(debug.padding.x, debug.padding.y-16);
		fps_text.layer = debug.layer;
		fps_text.depth = 999.2;

		Clay.on(RenderEvent.RENDER, onrender);
		Clay.on(KeyEvent.KEY_DOWN, onkeydown);
		Clay.on(TouchEvent.TOUCH_DOWN, ontouchdown);

	}

	public function add_tab(name:String) {
		
		var tab = new InspectorTab(this, name);
		tab.index = tabs.length;
		tabs.push(tab);

		var ttwidth:Float = 0;
		for (t in tabs) {
			ttwidth += t.text_width;
		}

		var rw:Float = Clay.screen.width - ttwidth - debug.margin*2;
		var td:Float = rw / (tabs.length-1);

		var ps:Float = debug.margin;
		for (t in tabs) {
			// ps += td;
			t.set_pos(ps);
			ps += t.text_width + td;
		}

	}

	public function enable_tab(index:Int) {

		for (t in tabs) {
			t.disable();
		}

		tabs[index].enable();

	}

	public function destroy() {

		// overlay.destroy();
		// window.destroy();
		// fps_text.destroy();

		overlay = null;
		// window = null;
		fps_text = null;

	}

	function onrender(e) {
	    
        dt_average_accum += Clay.app.frame_delta;
        dt_average_count++;

        if(dt_average_count == dt_average_span - 1) {
            dt_average = dt_average_accum/dt_average_span;
            dt_average_accum = dt_average;
            dt_average_count = 0;
        }

        if(!visible) {
            return;
        }

            //update the fps_text
        fps_text.text = '${Math.round(1/dt_average)} / ${Mathf.fixed(dt_average,5)} / ${Mathf.fixed(Clay.app.frame_delta,5)}';

	}

	function onkeydown(e:KeyEvent) {

		if(e.key == Key.backquote || e.key == Key.f1) {
			visible = !visible;
		}

		if(visible) {
			if(e.key == Key.one) {
				debug.switch_view(Clay.debug.current_view.index - 1);
			} else if(e.key == Key.two) {
				debug.switch_view(Clay.debug.current_view.index + 1);
			}
		}

	}

	function ontouchdown(e:TouchEvent) {

		if(Clay.input.touch.count > 2) {
			visible = !visible;
		}

		if(visible) {
			if(Clay.input.touch.count < 2) {
				debug.switch_view(Clay.debug.current_view.index + 1);
			}
		}

	}

	function set_visible(v:Bool):Bool {
		
		visible = v;

		overlay.visible = visible;
		// window.visible = visible;
		fps_text.visible = visible;

		if(visible) {
			debug.current_view.active = true;
			for (t in tabs) {
				t.show();
			}
		} else {
			debug.current_view.active = false;
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
	public var text_width:Float = 0;


	public function new(inspector:Inspector, name:String, size:Int = 15) {

		this.inspector = inspector;
		this.name = name;

		title = new Text(Clay.resources.font('assets/Muli-Bold.ttf'));
		title.text = name;
		title.size = size;
		title.align = TextAlign.left;
		title.visible = false;
		title.color = new Color().from_int(0xffa563);
		title.transform.pos.set(Clay.debug.padding.x+14, Clay.debug.padding.y+6);
		title.layer = Clay.debug.layer;
		title.depth = 999.2;

		var	_kravur = title.font.font._get(size);
		text_width = _kravur.stringWidth(name);

	}

	public function set_pos(pos:Float) {

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
