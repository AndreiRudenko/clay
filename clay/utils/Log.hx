package clay.utils;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

@:enum
private abstract LogLevel(Int) from Int to Int {
	var VERBOSE = 0;
	var DEBUG = 1;
	var INFO = 2;
	var WARNING = 3;
	var ERROR = 4;
	var CRITICAL = 5;
}

class Log {

	static inline var _spaces:String = '  ';
	static inline var _minLevel = 
		#if (clay_loglevel == 'info') LogLevel.INFO
		#elseif (clay_loglevel == 'verbose') LogLevel.VERBOSE
		#elseif (clay_loglevel == 'debug') LogLevel.DEBUG
		#elseif (clay_loglevel == 'error') LogLevel.ERROR
		#elseif (clay_loglevel == 'critical') LogLevel.CRITICAL
		#elseif (clay_loglevel == 'verbose') LogLevel.VERBOSE
		#else LogLevel.WARNING
		#end;

	macro static public function verbose(value:Dynamic):Expr {
		#if (clay_debug && !(clay_no_log))
		var file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var context = Path.withoutExtension(file);
		if(Std.int(LogLevel.VERBOSE) >= Std.int(_minLevel)) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}V / $context / ' + $value);
		}
		#end
		return macro null;
	}

	macro static public function debug(value:Dynamic):Expr {
		#if (clay_debug && !(clay_no_log))
		var file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var context = Path.withoutExtension(file);
		if(Std.int(LogLevel.DEBUG) >= Std.int(_minLevel)) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}D / $context / ' + $value);
		}
		#end
		return macro null;
	}

	macro static public function info(value:Dynamic):Expr {
		#if (clay_debug && !(clay_no_log))
		var file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var context = Path.withoutExtension(file);
		if(Std.int(LogLevel.INFO) >= Std.int(_minLevel)) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}I / $context / ' + $value);
		}
		#end
		return macro null;
	}

	macro static public function warning(value:Dynamic):Expr {
		#if (clay_debug && !(clay_no_log))
		var file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var context = Path.withoutExtension(file);
		if(Std.int(LogLevel.WARNING) >= Std.int(_minLevel)) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}W / $context / ' + $value);
		}
		#end
		return macro null;
	}

	macro static public function error(value:Dynamic):Expr {
		#if (clay_debug && !(clay_no_log))
		var file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var context = Path.withoutExtension(file);
		if(Std.int(LogLevel.ERROR) >= Std.int(_minLevel)) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}E / $context / ' + $value);
		}
		#end
		return macro null;
	}

	macro static public function critical(value:Dynamic):Expr {
		#if (clay_debug && !(clay_no_log))
		var file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var context = Path.withoutExtension(file);
		if(Std.int(LogLevel.ERROR) >= Std.int(_minLevel)) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}! / $context / ' + $value);
		}
		#end
		return macro null;
	}

	macro static public function assert(expr:Expr, ?reason:ExprOf<String>) {
		#if !clay_no_assert
			var str = haxe.macro.ExprTools.toString(expr);

			reason = switch(reason) {
				case macro null: macro '';
				case _: macro ' ( ' + $reason + ' )';
			}

			return macro @:pos(Context.currentPos()) {
				if(!$expr) throw('$str' + $reason);
			}
		#end
		return macro null;
	}

}
