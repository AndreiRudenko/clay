package clay.processors.debug;


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
import clay.utils.Log.*;


@:access(
	clay.Family, 
	clay.core.ecs.Families, 
	clay.core.ecs.Components, 
	clay.FamilyData
)
class FamiliesDebugView extends DebugView {


	var items_list:Text;

    var font_size:Int = 15;
    var hide_ids:Bool = true;
    var hide_ents:Bool = true;
    var hide_empty:Bool = true;


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Families';

	}

	override function onadded() {

		var rect = debug.inspector.viewrect;

		items_list = new Text({
			name : 'debug.families.list',
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
		refresh();

	}

	override function ondisabled() {

		items_list.visible = false;

	}

	override function onkeydown(e:KeyEvent) {

		if(e.key == Key.four) {
			hide_empty = !hide_empty;
			refresh();
		}

		if(e.key == Key.three) {
			hide_ents = !hide_ents;
			refresh();
		}

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
                _result += '( ${_world.families.families.length} )\n';

                for(_family in _world.families.families) {
                    _result = list_family(_result, _world, _family);
                }

                _result += '\n';
            }

        return _result;

    }

    inline function list_family(_list:String, w:clay.World, f:clay.Family.FamilyData, _depth:Int = 1):String {

    	if(f.entities.length > 0 || !hide_empty) {
	    	var _cnames = [];

	    	f.include_flags.for_each(
	    		function(i) {
	    			for (k in w.components.types.keys()) {
	    				if(w.components.types.get(k).id == i) {
	    					_cnames.push(k.split('.').pop());
	    					break;
	    				}
	    			}
	    		}
	    	);

	        _list += '${tabs(_depth)} ( ${f.entities.length} ) < ${_cnames.join(", ")} >\n';

	        if(!hide_ents && f.entities.length > 0) {
	        	var _ents = f.entities.toArray().join(', ');
	        	_list += '${tabs(_depth+1)} [ $_ents ]\n';
	        }

    	}

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
