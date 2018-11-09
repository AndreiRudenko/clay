package clay.processors.debug;



import clay.utils.Log.*;
import clay.objects.Sprite;
import clay.objects.Text;
import clay.Entity;
import clay.data.Color;
import clay.math.Vector;
import clay.input.Keyboard;
import clay.input.Key;
import clay.types.TextAlign;
import clay.core.Debug;
import clay.math.Mathf;
import clay.math.Rectangle;


class Inspector extends Processor {


	public var visible(default, set):Bool = false;

	public var overlay:Sprite;
	public var window:Sprite;
	public var title:Text;
	public var debug:Debug;
	public var viewrect:Rectangle;

    var dt_average : Float = 0;
    var dt_average_accum : Float = 0;
    var dt_average_span : Int = 60;
    var dt_average_count : Int = 0;

	public var size:Vector;
	public var pos:Vector;

	public function new(_debug:Debug) {

		super();

		debug = _debug;

        size = new Vector(Clay.screen.width-(debug.padding.x*2), Clay.screen.height-(debug.padding.y*2));
        pos = new Vector(debug.padding.x, debug.padding.y);

		viewrect = new Rectangle(
            pos.x + (debug.margin/2),
            pos.y + (debug.margin*1.5),
            size.x - debug.margin,
            size.y - debug.margin - (debug.margin*1.5)
        );

	}

	override function onadded() {

		overlay = new Sprite({
			world: world,
			name: 'debug.overlay',
			size: new Vector(Clay.screen.width, Clay.screen.height),
			color: new Color(0,0,0,0.8),
			depth : 999,    //debug depth
			visible: false, //default invisible
			layer: debug.layer
		});

		window = new Sprite({
			name: 'debug.window',
			world: world,
			depth: 999.1,
			visible: false,
			color: new Color().from_int(0x161619),
			size: new Vector(Clay.screen.width-(debug.padding.x*2), Clay.screen.height-(debug.padding.y*2)),
			pos: new Vector(debug.padding.x, debug.padding.y),
			layer: debug.layer
		});
		
		title = new Text({
			name: 'debug.title',
			world: world,
			font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
			depth: 999.2,
			visible: false,
			color: new Color().from_int(0xffa563),
			pos: new Vector(debug.padding.x+14, debug.padding.y+6),
			text: 'Inspector',
			size: 15,
			align: TextAlign.left,
			layer: debug.layer
		});

	}

	override function onremoved() {

		overlay.destroy();
		window.destroy();
		title.destroy();

		overlay = null;
		window = null;
		title = null;

	}

	override function onrender() {
	    
        dt_average_accum += Clay.engine.frame_delta;
        dt_average_count++;

        if(dt_average_count == dt_average_span - 1) {
            dt_average = dt_average_accum/dt_average_span;
            dt_average_accum = dt_average;
            dt_average_count = 0;
        }

        if(!visible) {
            return;
        }

            //update the title
        title.text = '[${debug.current_view.debug_name}] / ${Math.round(1/dt_average)} / ${Mathf.fixed(dt_average,5)} / ${Mathf.fixed(Clay.engine.frame_delta,5)}';

	}

	override function onkeydown(e:KeyEvent) {

		if(e.key == Key.backquote) {
			visible = !visible;
		}

		if(visible) {
			if(e.key == Key.one) {
				debug.switch_view(false);
			} else if(e.key == Key.two) {
				debug.switch_view(true);
			}
		}

	}

	override function onkeyup(e:KeyEvent) {

	}

	function set_visible(v:Bool):Bool {
		
		visible = v;

		overlay.visible = visible;
		window.visible = visible;
		title.visible = visible;

		if(visible) {
			debug.current_view.enable();
		} else {
			debug.current_view.disable();
		}

		return v;

	}


}
