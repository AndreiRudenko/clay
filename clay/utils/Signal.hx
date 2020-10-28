package clay.utils;

#if macro
import haxe.macro.Expr;
#else

@:multiType
abstract Signal<T>(SignalBase<T>){

	public var emit(get, never):T;
	public var handlers(get, never):Array<SignalHandler<T>>;
	public var processing(get, never):Bool;
	public var count(get, never):Int;

	public function new();

	public inline function add(listener:T, order:Int = 0) {
		this.add(listener, order);
	}

	public inline function addOnce(listener:T, order:Int = 0) {
		this.addOnce(listener, order);
	}

	// public inline function queue(listener:T, order:Int = 0) {

	// 	// this.addOnce(listener, order);

	// }

	public inline function remove(listener:T) {
		this.remove(listener);
	}
	
	// public inline function dequeue(listener:T) {

	// 	// this.remove(listener);

	// }

	public inline function has(listener:T):Bool {
		return this.has(listener);
	}

	public inline function destroy() {
		this.destroy();
	}

	public inline function clear() {
		this.clear();
	}

	inline function get_emit():T {
		return this.emit;
	}

	inline function get_handlers():Array<SignalHandler<T>> {
		return this.handlers;
	}

	inline function get_processing():Bool {
		return this.processing;
	}

	inline function get_count():Int {
		return this.handlers.length;
	}

	@:to 
	static inline function toSignal0(signal:SignalBase<()->Void>):Signal0 {
		return new Signal0();
	}
	
	@:to 
	static inline function toSignal1<T1>(signal:SignalBase<(t1:T1)->Void>):Signal1<T1> {
		return new Signal1();
	}
	
	@:to 
	static inline function toSignal2<T1, T2>(signal:SignalBase<(t1:T1, t2:T2)->Void>):Signal2<T1, T2> {
		return new Signal2();
	}
	
	@:to 
	static inline function toSignal3<T1, T2, T3>(signal:SignalBase<(t1:T1, t2:T2, t3:T3)->Void>):Signal3<T1, T2, T3> {
		return new Signal3();
	}
	
	@:to 
	static inline function toSignal4<T1, T2, T3, T4>(signal:SignalBase<(t1:T1, t2:T2, t3:T3, t4:T4)->Void>):Signal4<T1, T2, T3, T4> {
		return new Signal4();
	}

}

class Signal0 extends SignalBase<()->Void> {
	
	public function new(){
		super();
		this.emit = emit0;
	}

	public function emit0() {
		SignalMacro.buildemit();
	}

}

class Signal1<T1> extends SignalBase<(t1:T1)->Void> {

	public function new(){
		super();
		this.emit = emit1;
	}

	public function emit1(v1:T1) {
		SignalMacro.buildemit(v1);
	}

}

class Signal2<T1, T2> extends SignalBase<(t1:T1, t2:T2)->Void> {

	public function new(){
		super();
		this.emit = emit2;
	}

	public function emit2(v1:T1, v2:T2) {
		SignalMacro.buildemit(v1, v2);
	}

}

class Signal3<T1, T2, T3> extends SignalBase<(t1:T1, t2:T2, t3:T3)->Void> {
	
	public function new(){
		super();
		this.emit = emit3;
	}

	public function emit3(v1:T1, v2:T2, v3:T3) {
		SignalMacro.buildemit(v1, v2, v3);
	}


}

class Signal4<T1, T2, T3, T4> extends SignalBase<(t1:T1, t2:T2, t3:T3, t4:T4)->Void> {

	public function new(){
		super();
		this.emit = emit4;
	}

	public function emit4(v1:T1, v2:T2, v3:T3, v4:T4) {
		SignalMacro.buildemit(v1, v2, v3, v4);
	}


}

class SignalBase<T> {

	public var emit:T;
	public var handlers:Array<SignalHandler<T>>;
	public var processing:Bool;
	var _toRemove:Array<T>;
	var _toAdd:Array<SignalHandler<T>>;

	public function new() {
		handlers = [];
		_toRemove = [];
		_toAdd = [];
		processing = false;
	}

	public function addOnce(listener:T, order:Int = 0) {
		_tryAdd(listener, true, order);
	}

	public function add(listener:T, order:Int = 0) {
		_tryAdd(listener, false, order);
	}

	public function remove(listener:T) {
		if(has(listener)) {
			if(processing) {
				if(_toRemove.indexOf(listener) == -1) {
					_toRemove.push(listener);
				}
			} else {
				_remove(listener);
			}
		}
	}

	public inline function has(listener:T):Bool {
		return getHandler(listener) != null;
	}

	public function getHandler(listener:T):SignalHandler<T> {
		for (h in handlers) {
			if(h.listener == listener) {
				return h;
			}
		}

		return null;
	}

	public inline function clear() {
		handlers = null;
		_toRemove = null;
		_toAdd = null;

		handlers = [];
		_toRemove = [];
		_toAdd = [];
	}

	public inline function destroy() {
		emit = null;
		handlers = null;
		_toRemove = null;
		_toAdd = null;
	}

	inline function _tryAdd(listener:T, once:Bool, order:Int) {
		if(!has(listener)) {

			var handler = new SignalHandler<T>(listener, once, order);

			if(processing) {
				var has = false;
				for (s in _toAdd) {
					if(s.listener == listener) {
						has = true;
						break;
					}
				}
				if(has) {
					_toAdd.push(handler);
				}
			} else {
				_add(handler);
			}
		}
	}

	function _add(handler:SignalHandler<T>) {
		var atPos:Int = handlers.length;

		for (i in 0...handlers.length) {
			if (handler.order < handlers[i].order) {
				atPos = i;
				break;
			}
		}

		handlers.insert(atPos, handler);
	}

	function _remove(listener:T) {
		for (i in 0...handlers.length) {
			if(handlers[i].listener == listener) {
				handlers.splice(i, 1);
				break;
			}
		}
	}

}


class SignalHandler<T> {

	public var listener:T;
	public var once:Bool;
	public var order:Int;

	public function new(listener:T, once:Bool, order:Int) {
		this.listener = listener;
		this.once = once;
		this.order = order;
	}

}

#end

private class SignalMacro {

	public static macro function buildemit(exprs:Array<Expr>):Expr {
		return macro { 
			processing = true;

			for (h in handlers){
				h.listener($a{exprs});
				if(h.once) {
					_toRemove.push(h.listener);
				}
			}
			
			processing = false;
			
			if (_toRemove.length > 0){
				for (l in _toRemove){
					_remove(l);
				}
				_toRemove.splice(0, _toRemove.length);
			}

			if (_toAdd.length > 0){
				for (h in _toAdd){
					_add(h);
				}
				_toAdd.splice(0, _toAdd.length);
			}
		}
	}

}
