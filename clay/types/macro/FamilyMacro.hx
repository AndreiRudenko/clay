package clay.types.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import clay.types.macro.MacroUtils;

class FamilyMacro {

	public static var type_name:String = "Family";

	static var init_field:Field;
	static var add_field:Field;
	static var remove_field:Field;
	static var swap_field:Field;

	static var families:Array<String> = [];

	static function build() {

		return switch (Context.getLocalType()) {
			case TInst(_.get() => {name: type_name}, types):
				build_family(types);
			default:
				throw false;
		}

	}

	static function build_family(types:Array<Type>) {

		init_field = null;
		add_field = null;
		remove_field = null;
		swap_field = null;

		var fields = Context.getBuildFields();
		var pos = Context.currentPos();


		for(field in fields) {
			switch(field.name) {
				case 'init': init_field = field;
				case 'add_components': add_field = field;
				case 'remove_components': remove_field = field;
				case 'swap_components': swap_field = field;
			}
		}

		if(init_field == null) {
			init_field = MacroUtils.build_function(
					'init', 
					[AOverride], 
					[],
					macro: Void,
					[]
				);
			fields.push(init_field);
		}

		if(add_field == null) {
			add_field = MacroUtils.build_function(
					'add_components', 
					[AOverride], 
					[{name: 'e', type: macro : clay.Entity }, {name: 'idx', type: macro : Int }],
					macro: Void,
					[]
				);
			fields.push(add_field);
		}

		if(remove_field == null) {
			remove_field = MacroUtils.build_function(
					'remove_components', 
					[AOverride], 
					[{name: 'idx', type: macro : Int }],
					macro: Void,
					[]
				);
			fields.push(remove_field);
		}

		if(swap_field == null) {
			swap_field = MacroUtils.build_function(
					'swap_components', 
					[AOverride], 
					[{name: 'from', type: macro : Int }, {name: 'to', type: macro : Int }],
					macro: Void,
					[]
				);
			fields.push(swap_field);
		}

		var params = switch Context.getLocalType() {
			case TInst(_, t): t;
			default: null;
		}

		var include_comps = [];
		var exclude_comps = [];
		// var one_comps = [];

		for (param in params) {
			switch (param) {
				case TInst(_, _): 
					include_comps.push(param);
				case TType(i, j): 
					switch (i.get().name) {
					case 'Exclude': exclude_comps.push(j[0]);
					// case 'One': one_comps.push(j[0]);
					default: null;
				};
				default: null;
			};
		}

		types = include_comps;

        var len = types.length;
		var types_string = MacroUtils.create_string(types);
		var exclude_types_string:String = '';
		if(exclude_comps.length > 0) {
			exclude_types_string = '_EX_${MacroUtils.create_string(exclude_comps)}';
		}
		// var one_types_string:String = '';
		// if(one_comps.length > 0) {
		// 	one_types_string = '_ONE_${MacroUtils.create_string(one_comps)}';
		// }
		// var name = '${type_name}_${types_string}${exclude_types_string}${one_types_string}';
		var name = '${type_name}_${types_string}${exclude_types_string}';

		if(families.indexOf(name) == -1) {

			var array_names:Array<String> = [];
			var ctids:Array<String> = [];
			var ctypes = [];
			var excl_types = [];
			var one_types = [];

			if(exclude_comps.length > 0) {
				for (c in exclude_comps) {
					var info = MacroUtils.get_path_info(c);
					var ctn = info.pack.concat([info.module, info.name]).join(".");
					excl_types.push(ctn);
				}
			}

			// if(one_comps.length > 0) {
			// 	for (c in one_comps) {
			// 		var info = MacroUtils.get_path_info(c);
			// 		var ctn = info.pack.concat([info.module, info.name]).join(".");
			// 		one_types.push(ctn);
			// 	}
			// }

			for (i in 0...len) {

				var info = MacroUtils.get_path_info(types[i]);
				var comp_type = TPath({pack: info.pack, name: info.module, sub: info.name});
				// var comp_name = info.name.substr(0, 1).toLowerCase() + info.name.substr(1); // cameCase or lowercase?
				var comp_name = info.name.toLowerCase(); // cameCase or lowercase?
				var array_name = '${comp_name}_array';
				var comp_type_id = '${comp_name}_tid';

				array_names.push(array_name);
				ctids.push(comp_type_id);
				var ctn = info.pack.concat([info.module, info.name]).join(".");
				// var ctn = info.pack.concat([info.name]).join(".");
				ctypes.push(ctn);

				var ctype = TPath({pack: ['clay', 'types'], name: 'ComponentType'});

				fields.push(MacroUtils.build_var(comp_type_id, [], ctype));

				fields.push(MacroUtils.build_var(array_name, [], TPath({
					pack: [], name: 'Array',
					params: [TPType(macro : $comp_type)]
				})));

				fields.push(MacroUtils.build_function(
					'get_$comp_name', 
					[APublic, AInline], 
					[{ name: 'entity', type: macro:clay.Entity }],
					comp_type,
					[ macro return this.$array_name[this.comp_idx[entity.id]] ]
				));

			}
			if(array_names.length > 0) {

				switch(init_field.kind) {
					case FFun(f):{
						switch(f.expr.expr) {
							case EBlock(exprs):{
								for(i in 0...array_names.length) {
									var ctname = ctids[i];
									var tp = ctypes[i];
									var vn = array_names[i];
									var expr = Context.parse('${ctname} = cm.get_type(${tp})', init_field.pos);
									exprs.insert(i,expr);
									var expr = Context.parse('${vn} = []', init_field.pos);
									exprs.insert(0,expr);
								}
								var expr = Context.parse('include(${ctypes})', init_field.pos);
								exprs.insert(0,expr);
								if(excl_types.length > 0) {
									expr = Context.parse('exclude(${excl_types})', init_field.pos);
									exprs.insert(0,expr);
								}
								// if(one_types.length > 0) {
								// 	expr = Context.parse('one(${one_types})', init_field.pos);
								// 	exprs.insert(0,expr);
								// }
							}
							default:
						}
					}
					default:
				}
				
				switch(add_field.kind) {
					case FFun(f):{
						switch(f.expr.expr) {
							case EBlock(exprs):{
								for(i in 0...array_names.length) {
									var name = array_names[i];
									var ctname = ctids[i];
									var tp = ctypes[i];
									var expr = macro $i{name}[idx] = cm.get_tid(e, $i{ctname}.id);
									exprs.push(expr);
								}
							}
							default:
						}
					}
					default:
				}
				switch(remove_field.kind) {
					case FFun(f):{
						switch(f.expr.expr) {
							case EBlock(exprs):{
								for(an in array_names) {
									var expr = macro $i{an}[idx] = null;
									exprs.push(expr);
								}
							}
							default:
						}
					}
					default:
				}
				switch(swap_field.kind) {
					case FFun(f):{
						switch(f.expr.expr) {
							case EBlock(exprs):{
								for(an in array_names) {
									var expr = macro $i{an}[to] = $i{an}[from];
									exprs.push(expr);
								}
							}
							default:
						}
					}
					default:
				}
			}

			var uuid = ProcessorMacro.family_map.get(name);

			Context.defineType({
				pack: ['clay', 'families'],
				name: uuid,
				pos: pos,
				meta: [],
				kind: TDClass({
                    pack: [],
                    name: "Family",
                    sub: "FamilyData"
                }),
				fields: fields
			});

			families.push(name);

		}

		return Context.getType('clay.families.${ProcessorMacro.family_map.get(name)}');

	}

}


#end
