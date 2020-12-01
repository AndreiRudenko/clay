package clay.utils;

class UUID {

	static public function get(?val:Null<Int>):String {
		// https://web.archive.org/web/20190318040344/http://www.anotherchris.net/csharp/friendly-unique-id-generation-part-2/#base62

		if(val == null) val = Std.random(0x7fffffff);

		function toChar(value:Int):String {
			if (value > 9) {
				var ascii = (65 + (value - 10));
				if (ascii > 90) { ascii += 6; }
				return String.fromCharCode(ascii);
			} else {
				return Std.string(value).charAt(0);
			}
		}

		var r = Std.int(val % 62);
		var q = Std.int(val / 62);
		return q > 0 ? get(q) + toChar(r) : Std.string(toChar(r));
	}
	
}
