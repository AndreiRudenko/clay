package clay.utils;

import haxe.macro.Context;
import haxe.macro.Expr;

class Common {

	macro static public function def(value:Expr, def:Expr):Expr {
		return macro @:pos(Context.currentPos()) {
			if($value == null) $value = $def;
			$value;
		}
	}

}
