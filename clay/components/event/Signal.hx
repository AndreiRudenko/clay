package clay.components.event;

#if macro
import haxe.macro.Expr;
#else

@:multiType
abstract Signal<T>(SignalBase<T>){


	public var emit(get, never):T;


	public function new();

	public inline function add(listener:T, order:Int = 0) {

		this.add(listener, order);

	}

	public inline function add_once(listener:T, order:Int = 0) {

		this.add_once(listener, order);

	}

	// public inline function queue(listener:T, order:Int = 0) {

	// 	// this.add_once(listener, order);

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

	@:to 
	static inline function toSignal0(signal:SignalBase<Void->Void>):Signal0 {

		return new Signal0();

	}
	
	@:to 
	static inline function toSignal1<T1>(signal:SignalBase<T1->Void>):Signal1<T1> {

		return new Signal1();

	}
	
	@:to 
	static inline function toSignal2<T1, T2>(signal:SignalBase<T1->T2->Void>):Signal2<T1, T2> {

		return new Signal2();

	}
	
	@:to 
	static inline function toSignal3<T1, T2, T3>(signal:SignalBase<T1->T2->T3->Void>):Signal3<T1, T2, T3> {

		return new Signal3();

	}
	
	@:to 
	static inline function toSignal4<T1, T2, T3, T4>(signal:SignalBase<T1->T2->T3->T4->Void>):Signal4<T1, T2, T3, T4> {

		return new Signal4();

	}

}


class Signal0 extends SignalBase<Void->Void> {
	

	public function new(){

		super();
		this.emit = emit0;

	}

	public function emit0() {

		SignalMacro.buildemit();

	}


}


class Signal1<T1> extends SignalBase<T1->Void> {
	

	public function new(){

		super();
		this.emit = emit1;

	}

	public function emit1(v1:T1) {

		SignalMacro.buildemit(v1);

	}


}

class Signal2<T1, T2> extends SignalBase<T1->T2->Void> {
	

	public function new(){

		super();
		this.emit = emit2;

	}

	public function emit2(v1:T1, v2:T2) {

		SignalMacro.buildemit(v1, v2);

	}


}

class Signal3<T1, T2, T3> extends SignalBase<T1->T2->T3->Void> {
	

	public function new(){

		super();
		this.emit = emit3;

	}

	public function emit3(v1:T1, v2:T2, v3:T3) {

		SignalMacro.buildemit(v1, v2, v3);

	}


}

class Signal4<T1, T2, T3, T4> extends SignalBase<T1->T2->T3->T4->Void> {
	

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
	var to_remove:Array<SignalHandler<T>>;
	var to_add:Array<SignalOptions<T>>;
	var processing:Bool;


	public function new() {
		
		handlers = [];
		to_remove = [];
		to_add = [];
		processing= false;

	}

	public function add_once(listener:T, ?order:Null<Int>) {

		_try_add(listener, true, order);

	}

	public function add(listener:T, ?order:Null<Int>) {

		_try_add(listener, false, order);
		
	}

	public function remove(listener:T) {

		for (i in 0...handlers.length) {
			if(handlers[i].listener == listener) {
				if(processing) {
					to_remove.push(handlers[i]);
				} else {
					handlers.splice(i, 1);
				}
				break;
			}
		}

	}

	public inline function has(listener:T):Bool {

		return get_handler(listener) != null;
		
	}

	public function get_handler(listener:T):SignalHandler<T> {
		
		for (h in handlers) {
			if(h.listener == listener) {
				return h;
			}
		}

		return null;

	}

	public inline function clear() {
		
		handlers = null;
		to_remove = null;
		to_add = null;
		handlers = [];
		to_remove = [];
		to_add = [];

	}

	public inline function destroy() {
		
		emit = null;
		handlers = null;
		to_remove = null;
		to_add = null;

	}

	inline function _try_add(listener:T, once:Bool, order:Null<Int>) {

		if(has(listener)) {
			throw("clay / signal / add / attempted to add the same listener twice");
		}

		if(processing) {
			to_add.push({listener: listener, once: once, order: order});
		} else {
			_add(listener, once, order);
		}

	}

	function _add(listener:T, once:Bool, order:Null<Int>) {

		var handler = new SignalHandler<T>(listener, once, order);

		if(order != null) {
			var added:Bool = false;
			for (i in 0...handlers.length) {
				if (order < handlers[i].order) {
					handlers.insert(i, handler);
					added = true;
					break;
				}
			}
			if(!added) {
				handlers.push(handler);
			}
		} else {
			handlers.push(handler);
		}
		
	}


}


class SignalHandler<T> {


	public var listener:T;
	public var once:Bool;
	public var order:Int;


	public function new(_listener:T, _once:Bool, _order:Int = 0) {

		listener = _listener;
		once = _once;
		order = _order;

	}


}

private typedef SignalOptions<T> = {

	var listener:T;
	var once:Bool;
	@:optional var order:Int;

}

#end


private class SignalMacro {

	public static macro function buildemit(exprs:Array<Expr>):Expr {

		return macro { 
			processing = true;

			for (h in handlers){
				h.listener($a{exprs});
				if(h.once) {
					to_remove.push(h);
				}
			}
			
			processing = false;
			
			if (to_remove.length > 0){
				for (h in to_remove){
					remove(h.listener);
				}
				to_remove.splice(0, to_remove.length);
			}

			if (to_add.length > 0){
				for (o in to_add){
					_add(o.listener, o.once, o.order);
				}
				to_add.splice(0, to_add.length);
			}
		}

	}

}
