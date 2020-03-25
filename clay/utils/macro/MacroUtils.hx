package clay.utils.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroUtils {
	
	public static function createString(types:Array<Type>, delimiter:String = '_', sort:Bool = true):String {
		var len = types.length;
		var typesStrings = [];
		
		for (i in 0...len) {
			var typeName = switch (types[i]) {
				case TInst(ref, types): ref.get().name;
				default:
					throw false;
			}
			var typePack = switch (types[i]) {
				case TInst(ref, types): ref.get().pack;
				default:
					throw false;
			}
			
			typePack.push(typeName);
			var fullType = typePack.join(delimiter);
			typesStrings.push(fullType);
			// typesStrings.push(typeName);
		}

		if(sort) {
			typesStrings.sort(function(a:String, b:String):Int {
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

		return typesStrings.join(delimiter);
	}
	
	public static function buildTypeExpr(pack:Array<String>, module:String, name:String):Expr {
		var packModule = pack.concat([module, name]);
		
		var typeExpr = macro $i{packModule[0]};
		for (idx in 1...packModule.length){
			var field = $i{packModule[idx]};
			typeExpr = macro $typeExpr.$field;
		}
		
		return macro $typeExpr;
	}
	
	public static inline function camelCase(name:String):String {
		return name.substr(0, 1).toLowerCase() + name.substr(1);
	}

	#if macro
	public static function buildVar(name:String, access:Array<Access>, type:ComplexType, e:Expr = null, m:Metadata = null):Field {
		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FVar(type, e),
			meta: m == null ? [] : m
		};
	}
	
	public static function buildProp(name:String, access:Array<Access>, get:String, set:String, type:ComplexType, e:Expr = null, m:Metadata = null):Field {
		return {
			pos: Context.currentPos(),
			name: name,
			access: access,
			kind: FProp(get, set, type, e),
			meta: m == null ? [] : m
		};
	}
	
	public static function buildFunction(name:String, access:Array<Access>, args:Array<FunctionArg>, ret:ComplexType, exprs:Array<Expr>, m:Metadata = null):Field {
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

	public static function buildConstructor(name:String, pack:Array<String>, params:Array<TypeParam>, exprs:Array<Expr>):Expr {
		return {
			pos: Context.currentPos(),
			expr: ENew(
				{
					name: name, 
					pack: pack, 
					params: params
				}, 
				exprs
			)
		}
	}
	#end
	
	public static function getPathInfo(type:Type):PathInfo {
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
			case TType(ref, types):
				data.pack = ref.get().pack;
				data.module = ref.get().module.split('.').pop();
				data.name = ref.get().name;
			default:
				throw false;
		}
		
		return data;
	}

	public static function getClassTypePath(type:haxe.macro.Type) {
		switch (type) {
			case TType(ref, types):
				var name = ref.get().name;
				if(!StringTools.startsWith(name, 'Class')) throw '$name must be Class<T>';
				var pack = name.substring(6, name.length-1).split('.');
				name = pack.pop();
				return {pack: pack, name: name, sub: null, params: []};
			default:
				throw 'Invalid type';
		}
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