package clay.processors.debug;


import clay.objects.Text;
import clay.data.Color;
import clay.ds.Dll;
import clay.math.Vector;
import clay.math.Mathf;
import clay.core.Debug;
import clay.types.TextAlign;
import clay.input.Mouse;
import clay.utils.Log.*;
import clay.events.*;


class ProcessorsDebugView extends DebugView {


	var items_list:Text;

    var font_size:Int = 15;
    var hide_ids:Bool = true;


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Processors';

	}

	override function onadded() {

        var rect = debug.inspector.viewrect;

		items_list = new Text({
			name : 'debug.processors.list',
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

	}

	override function onremoved() {

		items_list.destroy();
		items_list = null;

	}

	override function onenabled() {

		items_list.visible = true;
        Clay.next(refresh);
		
	}

	override function ondisabled() {

		items_list.visible = false;

	}

    override function onmousewheel(e:MouseEvent) {

        var h = items_list.text_height;
        var vh = debug.inspector.size.y - debug.margin;
        var diff = h - vh;

        var new_y = items_list.pos.y;
        var max_y = debug.padding.y +(debug.margin*1.5);
        var min_y = max_y;

        if(diff > 0) {
            min_y = (max_y - (diff+(debug.margin*2)));
        }

        new_y -= (debug.margin/2) * e.wheel;
        new_y = Mathf.clamp(new_y, min_y, max_y);

        items_list.pos.y = new_y;

    }
    
    override function update(dt:Float) {

        var has_changed = false;

        for(_world in Clay.worlds) {
            if(_world.has_changed) {
                has_changed = true;
                _world.has_changed = false;
                break;
            }
        }

        if(has_changed) {
            refresh();
        }

    }

    inline function get_list() : String {

        var _result = '';

            for(_world in Clay.worlds) {
                _result += '${_world.name} ';
                _result += '( ${Lambda.count(_world.processors)} )\n';

                var procs = [];
                for(_proc in _world.processors) {
                	procs.push(_proc);
                }

                procs.sort(function(v1, v2) return v1.priority - v2.priority);

                for(_proc in procs) {
                    _result = list_proc(_result, _proc);
                }
                _result += '\n';
            }

        return _result;

    }

    inline function list_proc(_list:String, p:clay.Processor, _depth:Int = 1):String {

        var _active = (p.active) ? '' : '| inactive';
        var _pre = (_depth == 1) ? tabs(_depth) : tabs(_depth)+'> ';
        var _prior = '| ' + p.priority;

        _list += '${tabs(_depth)} ${p.name} $_prior $_active\n';
        return _list;

    }

    function refresh() {

        items_list.text = get_list();

    }

 	function tabs(_d:Int) {

        var res = '';
        for(i in 0 ... _d) res += '    ';
        return res;

    }


}
