package clay.processors.debug;


import clay.render.Camera;
import clay.objects.Text;
import clay.data.Color;
import clay.ds.Dll;
import clay.math.Vector;
import clay.math.Mathf;
import clay.core.Debug;
import clay.types.TextAlign;
import clay.input.Keyboard;
import clay.input.Key;
import clay.input.Mouse;
import clay.render.Layer;
import clay.utils.Log.*;


@:access(
	clay.render.Renderer, 
	clay.render.RenderPath, 
	clay.render.Camera
)
class StatsDebugView extends DebugView {


	var render_stats_text:Text;

    var font_size:Int = 15;
    var hide_layers:Bool = true;
    var camera_stats:String = '';


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Statistics';

	}

	override function onadded() {
		
		var rect = debug.inspector.viewrect;

		render_stats_text = new Text({
			name : 'debug.render.stats',
			world : world,
			depth : 999.3,
			color : new Color().from_int(0xffa563),
			pos: new Vector(rect.x, rect.y),
			width : rect.w,
			height : 0,
			clip_rect : rect,
			wrap : true,
			text : '',
			size : font_size,
			layer : debug.layer,
			visible : false
		});

		Clay.renderer.cameras.oncameracreate.add(camera_added);
		Clay.renderer.cameras.oncameradestroy.add(camera_removed);

		for (c in Clay.renderer.cameras) {
			camera_added(c);
		}

	}

	override function onremoved() {

		render_stats_text.destroy();
		render_stats_text = null;

		Clay.renderer.cameras.oncameracreate.remove(camera_added);
		Clay.renderer.cameras.oncameradestroy.remove(camera_removed);

	}

	override function onenabled() {

		render_stats_text.visible = true;
		refresh();

	}

	override function ondisabled() {

		render_stats_text.visible = false;

	}

	override function onkeydown(e:KeyEvent) {

		if(e.key == Key.three) {
			hide_layers = !hide_layers;
			refresh();
		}

	}

    override function onmousewheel(e:MouseEvent) {

        var h = render_stats_text.text_height;
        var vh = debug.inspector.size.y - debug.margin;
        var diff = h - vh;

        var new_y = render_stats_text.pos.y;
        var max_y = debug.padding.y +(debug.margin*1.5);
        var min_y = max_y;

        if(diff > 0) {
            min_y = (max_y - (diff+(debug.margin*2)));
        }

        new_y -= (debug.margin/2) * e.wheel;
        new_y = Mathf.clamp(new_y, min_y, max_y);

        render_stats_text.pos.y = new_y;

    }

	override function onrender() {

		refresh();

	}

	function camera_added(c:Camera) {
		
		c.onpostrender.add(add_camera_stats);

	}

	function camera_removed(c:Camera) {

		c.onpostrender.remove(add_camera_stats);
		
	}

	function add_camera_stats(c:Camera) {

		camera_stats += get_camera_info(c);
		
	}

    function get_render_stats() {

        var _render_stats = Clay.renderer.stats;

        return
            'Renderer Statistics\n\n' +
            'total geometry : ' + _render_stats.geometry + '\n' +
            'visible geometry : ' + _render_stats.visible_geometry + '\n' +
            'vertices : ' + _render_stats.vertices + '\n' +
            'indices : ' + _render_stats.indices + '\n' +
            'instanced : ' + _render_stats.instanced + '\n' +
            'draw calls : ' + _render_stats.draw_calls + '\n' +
            'layers : ' + Clay.renderer.layers.active_count + '\n' +
            'cameras : ' + Clay.renderer.cameras.length + '\n' +
            camera_stats;

    }

    inline function get_camera_info(c:Camera) {

    	var _layers = [];
    	for (l in Clay.renderer.layers) {
    		if(c.visible_layers_mask.get(l.id)) {
    			_layers.push(l);
    		}
    	}

        var _active = c.active ? '' : '/ inactive';

        var _s =  '    ${c.name} ( ${_layers.length} ) ${_active}\n';

    	if(!hide_layers && c.active) {
    		for (l in _layers) {
    			_s += get_layer_info(l);
    		}
    	}

        return _s;
    }

    inline function get_layer_info(l:Layer) {

        return
            '        ${l.name} | ${l.priority}\n' +
            '            total geometry : ' + l.stats.geometry + '\n' +
            '            visible geometry : ' + l.stats.visible_geometry + '\n' +
            '            vertices : ' + l.stats.vertices + '\n' +
            '            indices : ' + l.stats.indices + '\n' +
            '            instanced : ' + l.stats.instanced + '\n' +
            '            draw calls : ' + l.stats.draw_calls + '\n';

    }

    function refresh() {

        render_stats_text.text = get_render_stats();
        camera_stats = '';

    }

 	function tabs(_d:Int) {

        var res = '';
        for(i in 0 ... _d) res += '    ';
        return res;

    }


}
