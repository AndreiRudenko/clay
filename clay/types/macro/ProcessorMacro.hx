package clay.types.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import clay.types.macro.MacroUtils;
import clay.utils.UUID;


class ProcessorMacro {

	public static var family_map:Map<String, String> = new Map();

	static var onadded_field:Field;
	static var onremoved_field:Field;
	static var listen_field:Field;
	static var unlisten_field:Field;
	static var init_field:Field;
	static var idx:Int = 0;


	public static function get_family_name(params:Array<TypeParam>):String {

	    var include_comps = [];
		var exclude_comps = [];
		// var one_comps = [];

		for(param in params) {
			switch(param) {
				case TPType(TPath(ctp)):
					switch (ctp.name) {
						case 'Exclude': 
						switch(ctp.params[0]) {
							case TPType(TPath(_t)):
							exclude_comps.push(Context.getType('${_t.name}'));
							default: null;
						}
						// case 'One': 
						// switch(ctp.params[0]) {
						// 	case TPType(TPath(_t)):
						// 	one_comps.push(Context.getType('${_t.name}'));
						// 	default: null;
						// }
						default: include_comps.push(Context.getType('${ctp.name}'));
					}
				default: null;
			}
		}

		var types_string = MacroUtils.create_string(include_comps);
		var exclude_types_string:String = '';
		if(exclude_comps.length > 0) {
			exclude_types_string = '_EX_${MacroUtils.create_string(exclude_comps)}';
		}
		// var one_types_string:String = '';
		// if(one_comps.length > 0) {
		// 	one_types_string = '_ONE_${MacroUtils.create_string(one_comps)}';
		// }
		// var name = 'Family_${types_string}${exclude_types_string}${one_types_string}';
		var name = 'Family_${types_string}${exclude_types_string}';

		var uuid:String = family_map.get(name);

		if(uuid == null) {
			uuid = 'Family_${UUID.get(idx++)}';
			family_map.set(name, uuid);
		}

		return uuid;

	}

	static function get_param_name(param:TypeParam):String {

		var name = '';
		switch(param) {
			case TPType(TPath(ctp)):{
				name = ctp.name;
			}
			default: null;
		}

		return name;

	}

	public static function build():Array<Field> {

		init_field = null;
		onadded_field = null;
		onremoved_field = null;
		listen_field = null;
		unlisten_field = null;

		var fields = Context.getBuildFields();

		for(field in fields) {
			switch(field.name) {
				case 'init': init_field = field;
				case 'onadded': onadded_field = field;
				case 'onremoved': onremoved_field = field;
				case '__listen_emitter': listen_field = field;
				case '__unlisten_emitter': unlisten_field = field;
			}
		}

		var nocomp_expr = {name:':noCompletion', pos:Context.currentPos()};

		if(init_field == null) {
			init_field = {
				name: 'init',
				doc: null, meta: [nocomp_expr],
				access: [AOverride],
				kind: FFun({ params:[], args:[], ret:null, expr:macro {  } }),
				pos: Context.currentPos()
			};
			fields.push(init_field);
		}

		if(onadded_field == null) {
			onadded_field = {
				name: 'onadded',
				doc: null, meta: [nocomp_expr],
				access: [AOverride],
				kind: FFun({ params:[], args:[], ret:null, expr:macro {  } }),
				pos: Context.currentPos()
			};
			fields.push(onadded_field);
		}

		if(onremoved_field == null) {
			onremoved_field = {
				name: 'onremoved',
				doc: null, meta: [nocomp_expr],
				access: [AOverride],
				kind: FFun({ params:[], args:[], ret:null, expr:macro {  } }),
				pos: Context.currentPos()
			};
			fields.push(onremoved_field);
		}

		if(listen_field == null) {
			listen_field = {
				name: '__listen_emitter',
				doc: null, meta: [nocomp_expr],
				access: [AOverride],
				kind: FFun({ params:[], args:[], ret:null, expr:macro {  } }),
				pos: Context.currentPos()
			};
			fields.push(listen_field);
		}

		if(unlisten_field == null) {
			unlisten_field = {
				name: '__unlisten_emitter',
				doc: null, meta: [nocomp_expr],
				access: [AOverride],
				kind: FFun({ params:[], args:[], ret:null, expr:macro {  } }),
				pos: Context.currentPos()
			};
			fields.push(unlisten_field);
		}

		for(field in fields) {
			switch(field.name) {
				case

					'onprerender',
					'onrender',
					'onpostrender',

					'ontickstart',
					'ontickend',

					'onforeground',
					'onbackground',
					'onpause',
					'onresume',

					'update',
					'fixedupdate',
					'ontimescale',

					'onkeydown',
					'onkeyup',
					'ontextinput',

					'oninputdown',
					'oninputup',

					'onmousedown',
					'onmouseup',
					'onmousemove',
					'onmousewheel',

					'ongamepadadd',
					'ongamepadremove',
					'ongamepaddown',
					'ongamepadup',
					'ongamepadaxis',

					'ontouchdown',
					'ontouchup',
					'ontouchmove',

					'onpendown',
					'onpenup',
					'onpenmove':

				{
					connect_event(field);
				}
			}
		}

		var inject_fields:Array<Field> = [];
		var inject_types:Array<String> = [];
		var inject_ffields:Array<Field> = [];
		var inject_ftypes:Array<String> = [];
		var inject_cfields:Array<Field> = [];
		var inject_ctypes:Array<String> = [];

		for(field in fields) {
			switch(field.kind) {
				case FieldType.FVar(t, e) | FieldType.FProp(_, _, t, e):
					if(t != null) {
						switch(t) {
							case ComplexType.TPath(tp):
								switch(tp.name) {
									case "Wire":{
										if(e != null) {
											Context.error("Remove initializer, Wire binding will be created at compile-time", field.pos);
										}
										if(tp.params != null && tp.params.length == 1) {
											inject_fields.push(field);
											switch(tp.params[0]) {
												case TPType(TPath(tp)):
													var it = tp.pack.concat([tp.name]).join(".");
													inject_types.push(it);
												default:
													Context.error("wrong", field.pos);
											}
										}
										else {
											Context.error("Wire require one Object Type", field.pos);
										}
									}
									case "ComponentMapper":{
										if(e != null) {
											Context.error("Remove initializer, Components binding will be created at compile-time", field.pos);
										}
										if(tp.params != null && tp.params.length == 1) {
											inject_cfields.push(field);
											var pr = get_param_name(tp.params[0]);
											inject_ctypes.push(pr);
										} else {
											Context.error("Components require one Object Type", field.pos);
										}
									}
									case "Family":{
										if(e != null) {
											Context.error("Remove initializer, Family binding will be created at compile-time", field.pos);
										}
										if(tp.params != null) {
											inject_ffields.push(field);
											var pr = get_family_name(tp.params);
											inject_ftypes.push(pr);
										} else {
											Context.error("Family require Component Types", field.pos);
										}
									}
								}
							default:
						}
					}
				default:
			}
		}

		switch(init_field.kind) {
			case FFun(f):{
				switch(f.expr.expr) {
					case EBlock(exprs):{
						for(i in 0...inject_fields.length) {
							var f = inject_fields[i];
							var expr = macro $i{f.name} = world.processors.get($i{inject_types[i]});
							exprs.insert(i,expr);
						}
					}
					default:
				}
			}
			default:
		}
		switch(onadded_field.kind) {
			case FFun(f):{
				switch(f.expr.expr) {
					case EBlock(exprs):{
						for(i in 0...inject_ftypes.length) {
							var f = inject_ffields[i];
							var fe = Context.parse('clay.families.${inject_ftypes[i]}', onadded_field.pos);
							var fetp = {name: inject_ftypes[i], pack: ['clay', 'families']};
							var expr = macro {
								$i{f.name} = world.families.get($fe);
								if($i{f.name} == null) {
									$i{f.name} = world.families.add(new $fetp());
								}
							}
							exprs.insert(i, expr);
						}
						for(i in 0...inject_ctypes.length) {
							var f = inject_cfields[i];
							var expr = Context.parse('${f.name} = world.components.get_mapper(${inject_ctypes[i]})', onadded_field.pos);
							exprs.insert(i, expr);
						}
					}
					default:
				}
			}
			default:
		}
		switch(onremoved_field.kind) {
			case FFun(f):{
				switch(f.expr.expr) {
					case EBlock(exprs):{
						for(i in 0...inject_fields.length) {
							var f = inject_fields[i];
							var expr = macro $i{f.name} = null;
							exprs.push(expr);
						}
						for(i in 0...inject_ftypes.length) {
							var f = inject_ffields[i];
							var expr = macro $i{f.name} = null;
							exprs.push(expr);
						}
						for(i in 0...inject_ctypes.length) {
							var f = inject_cfields[i];
							var expr = macro $i{f.name} = null;
							exprs.push(expr);
						}
					}
					default:
				}
			}
			default:
		}


		return fields;

	}

	static function get_event_name(name:String):String {

		return switch (name) {

			case 'onprerender':       	'clay.events.RenderEvent.PRERENDER';
			case 'onrender':       	    'clay.events.RenderEvent.RENDER';
			case 'onpostrender':       	'clay.events.RenderEvent.POSTRENDER';

			case 'ontickstart':       	'clay.events.AppEvent.TICKSTART';
			case 'ontickend':       	'clay.events.AppEvent.TICKEND';
			case 'onforeground':       	'clay.events.AppEvent.FOREGROUND';
			case 'onbackground':       	'clay.events.AppEvent.BACKGROUND';
			case 'onpause':       	    'clay.events.AppEvent.PAUSE';
			case 'onresume':       	    'clay.events.AppEvent.RESUME';
			case 'ontimescale':       	'clay.events.AppEvent.TIMESCALE';

			case 'update':       	    'clay.events.AppEvent.UPDATE';
			case 'fixedupdate':       	'clay.events.AppEvent.FIXEDUPDATE';

			case 'onkeydown':       	'clay.events.KeyEvent.KEY_DOWN';
			case 'onkeyup':         	'clay.events.KeyEvent.KEY_UP';
			case 'ontextinput':     	'clay.events.KeyEvent.TEXT_INPUT';

			case 'onmousedown':     	'clay.events.MouseEvent.MOUSE_DOWN';
			case 'onmouseup':       	'clay.events.MouseEvent.MOUSE_UP';
			case 'onmousemove':     	'clay.events.MouseEvent.MOUSE_MOVE';
			case 'onmousewheel':    	'clay.events.MouseEvent.MOUSE_WHEEL';

			case 'ongamepadadd':    	'clay.events.GamepadEvent.DEVICE_ADDED';
			case 'ongamepadremove': 	'clay.events.GamepadEvent.DEVICE_REMOVED';
			case 'ongamepaddown':   	'clay.events.GamepadEvent.BUTTON_DOWN';
			case 'ongamepadup':     	'clay.events.GamepadEvent.BUTTON_UP';
			case 'ongamepadaxis':   	'clay.events.GamepadEvent.AXIS';

			case 'onpendown':   	    'clay.events.PenEvent.PEN_DOWN';
			case 'onpenup':   	        'clay.events.PenEvent.PEN_UP';
			case 'onpenmove':   	    'clay.events.PenEvent.PEN_MOVE';

			case 'ontouchdown':   	    'clay.events.TouchEvent.TOUCH_DOWN';
			case 'ontouchup':   	    'clay.events.TouchEvent.TOUCH_UP';
			case 'ontouchmove':   	    'clay.events.TouchEvent.TOUCH_MOVE';

			case 'oninputdown':   	    'clay.events.InputEvent.INPUT_DOWN';
			case 'oninputup':   	    'clay.events.InputEvent.INPUT_UP';

			case _ : '';

		}

	}

	static function connect_event(field:haxe.macro.Field) {

		if(field.access.indexOf(AOverride) != -1) {

			var _event_name:String = field.name;
			var _event_field_name:String = field.name;

			switch (_event_name) {
				case 
					'update', 
					'onprerender', 
					'onrender', 
					'onpostrender', 
					'ontickstart', 
					'ontickend', 
					'onforeground', 
					'onbackground', 
					'onpause', 
					'onresume':
				{
					_event_field_name = '__${_event_name}';
				}
			}

			_event_name = get_event_name(_event_name);
			if(_event_name.length == 0) {
				return;
			}

			switch(listen_field.kind) {
				default:
				case FFun(f):{
					switch(f.expr.expr) {
						case EBlock(exprs):{
							exprs.push( Context.parse('world.emitter.on(${_event_name}, ${_event_field_name}, this.priority)', field.pos) );
						}
						default:
					}
				}
			}

			switch(unlisten_field.kind) {
				default:
				case FFun(f):{
					switch(f.expr.expr) {
						case EBlock(exprs):{
							exprs.push( Context.parse('world.emitter.off(${_event_name}, ${_event_field_name})', field.pos) );
						}
						default:
					}
				}

			}

		}

	}


}
#end
