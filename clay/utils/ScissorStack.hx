package clay.utils;

import clay.math.Rectangle;
import clay.utils.DynamicPool;
import clay.utils.Log;

class ScissorStack {

	static public var scissor(get, never):Rectangle;
	static inline function get_scissor() return _scissors[_scissors.length-1]; 

	static var _scissors:Array<Rectangle> = [];
	static var _scissorPool:DynamicPool<Rectangle> = new DynamicPool<Rectangle>(16, function() {return new Rectangle();});

	public function pushScissor(rect:Rectangle, clipFromLast:Bool = false) {
		var s = _scissorPool.get().copyFrom(rect);
		if(clipFromLast) {
			var lastScissor = scissor;
			if(lastScissor != null) {
				s.clamp(lastScissor);
			}
		}
		_scissors.push(s);
		Clay.graphics.scissor(s.x, s.y, s.w, s.h);
	}

	public function popScissor() {
		if(_scissors.length > 0) {
			_scissorPool.put(_scissors.pop());
			var s = scissor;
			Clay.graphics.scissor(s.x, s.y, s.w, s.h);
		} else {
			Log.warning('pop scissor with no scissors left in stack');
		}
	}
    
}