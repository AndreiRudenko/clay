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
import clay.events.*;


@:access(
	clay.Family, 
	clay.core.ecs.Families, 
	clay.core.ecs.Entities, 
	clay.core.ecs.Components, 
	clay.FamilyData
)
class EntitesDebugView extends DebugView {


	var items_list:Text;

	var font_size:Int = 15;
	var hide_ents:Bool = true;
	var hide_comps:Bool = true;


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Entites';

	}

	override function onadded() {

		var rect = debug.inspector.viewrect;

		items_list = new Text({
			name : 'debug.entities.list',
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

		if(e.key == Key.three) {
			hide_ents = !hide_ents;
			refresh();
		}

		if(e.key == Key.four) {
			hide_comps = !hide_comps;
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
				_result += '( ${_world.entities.used} / ${_world.entities.capacity} )\n';

				if(!hide_ents) {
					for(_entity in _world.entities._entities) {
						var tmp = list_entity('', _world, _entity);
						if((_result.length + tmp.length) * 4 >= Clay.renderer.batch_size) {
							break;
						}
						_result += tmp;
					}
				}

				_result += '\n';
			}

		return _result;

	}

	inline function list_entity(_list:String, w:clay.World, e:clay.Entity, _depth:Int = 1):String {

		var _comps = w.components.get_all(e);
		var _comps_count = _comps.length;
		var _active = (w.entities.is_active(e)) ? '' : '/ inactive';

		_list += '${tabs(_depth)} ${e.id} ( ${_comps_count} ) ${_active}\n';

		if(!hide_comps) {
			for (c in _comps) {
				_list += '${tabs(_depth+1)} ${Type.getClassName(Type.getClass(c))}\n';
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
