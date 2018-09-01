package clay.types.macro;


import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;


class MacroUtils {
	

	public static function create_string(types:Array<Type>, delimiter:String = '_', sort:Bool = true):String {

		var len = types.length;
		var types_strings = [];
		
		for (i in 0...len) {
			
			var type_name = switch (types[i]) {
				case TInst(ref, types): ref.get().name;
				default:
					throw false;
			}
			var type_pack = switch (types[i]) {
				case TInst(ref, types): ref.get().pack;
				default:
					throw false;
			}
			
			type_pack.push(type_name);
			var full_type = type_pack.join(delimiter);
			types_strings.push(full_type);
			// types_strings.push(type_name);

		}

		if(sort) {
			types_strings.sort(function(a:String, b:String):Int {

				a = a.toUpperCase();
				b = b.toUpperCase();

				if (a < b) {
					return -1;
				} else if (a > b) {
					return 1;
				} else {
					return 0;
				}

			});
		}

		return types_strings.join(delimiter);

	}

	
	public static function build_type_expr(pack:Array<String>, module:String, name:String):Expr {
		var pack_module = pack.concat([module, name]);
		
		var type_expr = macro $i{pack_module[0]};
		for (idx in 1...pack_module.length){
			var field = $i{pack_module[idx]};
			type_expr = macro $type_expr.$field;
		}
		
		return macro $type_expr;
	}
	
	public static inline function camelCase(name:String):String {

		return name.substr(0, 1).toLowerCase() + name.substr(1);

	}
	
	public static function build_var(name:String, access:Array<Access>, type:ComplexType, e:Expr = null, m:Metadata = null):Field {

		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FVar(type, e),
			meta: m == null ? [] : m
		};

	}
	
	public static function build_prop(name:String, access:Array<Access>, get:String, set:String, type:ComplexType, e:Expr = null, m:Metadata = null):Field {

		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FProp(get, set, type, e),
			meta: m == null ? [] : m
		};

	}
	
	public static function build_function(name:String, access:Array<Access>, args:Array<FunctionArg>, ret:ComplexType, exprs:Array<Expr>, m:Metadata = null):Field {

		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FFun({
				args: args,
				ret: ret,
				expr: macro $b{exprs}
			}),
			meta: m == null ? [] : m
		};

	}
	
	public static function get_path_info(type:Type):PathInfo {

		var data:PathInfo = {
			pack: null,
			module: null,
			name: null
		}

		switch (type) {
			case TInst(ref, types):
				data.pack = ref.get().pack;
				data.module = ref.get().module.split('.').pop();
				data.name = ref.get().name;
			default:
				throw false;
		}
		
		return data;

	}

	public static function subclasses(type:ClassType, root:String):Bool {

		var name = type.module + '.' + type.name;
		return (name.substr(0, root.length) == root || type.superClass != null && subclasses(type.superClass.t.get(), root));

	}

	
}


typedef PathInfo = {
	var pack:Array<String>;
	var module:String;
	var name:String;
}