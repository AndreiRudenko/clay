package clay.utils;

// https://github.com/underscorediscovery/luxe/blob/master/luxe/Log.hx

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

private enum LogError {
	RequireString(detail:String);
}

class Log {

		//default to `log`
	static var _level : Int = 1;
	static var _filter : Array<String>;
	static var _exclude : Array<String>;
	static var _logWidth : Int = 16;

	macro public static function getLevel() : haxe.macro.Expr {
		return macro $v{ ${clay.utils.Log._level} };
	}
	macro public static function getFilter() : haxe.macro.Expr {
		return macro $v{ ${clay.utils.Log._filter} };
	}
	macro public static function getExclude() : haxe.macro.Expr {
		return macro $v{ ${clay.utils.Log._exclude} };
	}

	macro static function level( __level:Int ) : haxe.macro.Expr {

		_level = __level;

		return macro null;

	}

	macro static function filter( __filter:String ) : haxe.macro.Expr {

		_filter = __filter.split(',');

		var _index = 0;
		for(_f in _filter) {
			_filter[_index] = StringTools.trim(_f);
			_index++;
		}

		return macro null;

	}

	macro static function exclude( __exclude:String ) : haxe.macro.Expr {

		_exclude = __exclude.split(',');

		var _index = 0;
		for(_e in _exclude) {
			_exclude[_index] = StringTools.trim(_e);
			_index++;
		}

		return macro null;

	}

	macro static function width( _width:Int ) : haxe.macro.Expr {

		_logWidth = _width;

		return macro null;

	}

		//This macro uses the defined log level value to reject code that
		//shouldn't even exist at runtime , like low level debug information
		//and logging by injecting or not injecting code
	macro public static function log( value:Dynamic ) : Expr {

		var _file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var _context = Path.withoutExtension(_file).toLowerCase();
		var _spaces = _getSpacing(_file);

		for(meta in Context.getLocalClass().get().meta.get()) {
			if(meta.name == ':log_as') {
				var _str = switch(meta.params[0].expr) {
					case EConst(CString(str)): _context = str;
					default: throw LogError.RequireString('log_as meta requires a string constant like "name"');
				}
			}
		}

		var _log = (_level > 0);

			if(_filter != null && (_filter.indexOf(_context) == -1)) {
				_log = false;
			}

			if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
				_log = false;
			}

		if(_log) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}i / $_context / ' + $value);
		}

		return macro null;

	}

	macro public static function _debug( value:Dynamic ) : Expr { // TODO: rename to debug?

		var _file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var _context = Path.withoutExtension(_file).toLowerCase();
		var _spaces = _getSpacing(_file);

		for(meta in Context.getLocalClass().get().meta.get()) {
			if(meta.name == ':log_as') {
				var _str = switch(meta.params[0].expr) {
					case EConst(CString(str)): _context = str;
					default: throw LogError.RequireString('log_as meta requires a string constant like "name"');
				}
			}
		} //for each meta

		var _log = (_level > 1);

			if(_filter != null && (_filter.indexOf(_context) == -1)) {
				_log = false;
			}

			if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
				_log = false;
			}

		if(_log) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}d / $_context / ' + $value);
		}

		return macro null;

	}

	macro public static function _verbose( value:Dynamic ) : Expr { // TODO: rename to verbose?

		var _file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var _context = Path.withoutExtension(_file).toLowerCase();
		var _spaces = _getSpacing(_file);

		for(meta in Context.getLocalClass().get().meta.get()) {
			if(meta.name == ':log_as') {
				var _str = switch(meta.params[0].expr) {
					case EConst(CString(str)): _context = str;
					default: throw LogError.RequireString('log_as meta requires a string constant like "name"');
				}
			}
		} //for each meta

		var _log = (_level > 2);

			if(_filter != null && (_filter.indexOf(_context) == -1)) {
				_log = false;
			}

			if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
				_log = false;
			}

		if(_log) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}v / $_context / ' + $value);
		}

		return macro null;

	}

	macro public static function _verboser( value:Dynamic ) : Expr { // TODO: rename to verboser?

		var _file = Path.withoutDirectory(Context.getPosInfos(Context.currentPos()).file);
		var _context = Path.withoutExtension(_file).toLowerCase();
		var _spaces = _getSpacing(_file);

		for(meta in Context.getLocalClass().get().meta.get()) {
			if(meta.name == ':log_as') {
				var _str = switch(meta.params[0].expr) {
					case EConst(CString(str)): _context = str;
					default: throw LogError.RequireString('log_as meta requires a string constant like "name"');
				}
			}
		}

		var _log = (_level > 3);

			if(_filter != null && (_filter.indexOf(_context) == -1)) {
				_log = false;
			}

			if(_exclude != null && (_exclude.indexOf(_context) != -1)) {
				_log = false;
			}

		if(_log) {
			return macro @:pos(Context.currentPos()) trace('${_spaces}V / $_context / ' + $value);
		}

		return macro null;

	}

	macro public static function assert(expr:Expr, ?reason:ExprOf<String>) {

		#if !clay_no_assertions
			var _str = haxe.macro.ExprTools.toString(expr);

			reason = switch(reason) {
				case macro null: macro '';
				case _: macro ' ( ' + $reason + ' )';
			}

			return macro @:pos(Context.currentPos()) {
				if(!$expr) throw clay.utils.Log.DebugError.assertion( '$_str' + $reason);
			}
		#end
		return macro null;

	}

	macro public static function assertNull(value:Expr, ?reason:ExprOf<String>) {

		#if !clay_no_assertions
			var _str = haxe.macro.ExprTools.toString(value);

			reason = switch(reason) {
				case macro null: macro '';
				case _: macro ' ( ' + $reason + ' )';
			}
			return macro @:pos(Context.currentPos()) {
				if($value == null) throw clay.utils.Log.DebugError.nullAssertion('$_str was null' + $reason);
			}
		#end
		return macro null;

	}

	macro public static function def(value:Expr, def:Expr):Expr {

		return macro @:pos(Context.currentPos()) {
			if($value == null) $value = $def;
			$value;
		}

	}


//Internal Helpers


	static function _getSpacing(_file:String ) {

		var _spaces = '';

			//the magic number here is File.hx[:1234] for the trace listener log spacing
		var _traceLength = _file.length + 4;
		var _diff : Int = _logWidth - _traceLength;
		if(_diff > 0) {
			for(i in 0 ... _diff) {
				_spaces += ' ';
			}
		}

		return _spaces;

	}

} // Debug

enum DebugError {
	assertion(expr:String);
	nullAssertion(expr:String);
}