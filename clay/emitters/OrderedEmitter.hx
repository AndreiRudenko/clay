package clay.emitters;

// based on Emitter by Sven Bergström https://github.com/underscorediscovery/luxe/blob/master/luxe/Emitter.hx

import haxe.ds.IntMap;
import clay.utils.Log._verbose;
import clay.utils.Log._verboser;


@:noCompletion private typedef EmitHandler = Dynamic->Void;
@:noCompletion private typedef HandlerList = Array<EmitHandler>;

@:noCompletion private typedef EmitNode<T> = { event:T, handler:EmitHandler #if clay_emitter_pos, ?pos:haxe.PosInfos #end }


private class OrderedHandler {


	public var order:Array<Int>;
	public var handlers:HandlerList;


	public function new() {

		order = [];
		handlers = [];

	}

}

class OrderedEmitter<ET:Int> {


	@:noCompletion public var bindings:IntMap<OrderedHandler>;

	var _to_remove:List<EmitNode<ET>>;
	var _checking:Bool = false;

		/** create a new emitter instance, for binding functions easily to named events. similar to `Events` */
	public function new() {

		_to_remove = new List();
		bindings = new IntMap<OrderedHandler>();

	}

	public function destroy() {

		while(!_to_remove.isEmpty()) {
			var _node = _to_remove.pop();
			_node.event = null;
			_node.handler = null;
			_node = null;
		}

		_to_remove = null;
		bindings = null;
		
	}

		/** Emit a named event */
	// @:generic
	public function emit<T>( event:ET, ?data:T #if clay_emitter_pos, ?pos:haxe.PosInfos #end ) {

		_check();

		_checking = true;

		var _list = bindings.get(event);
		if(_list != null && _list.handlers.length > 0) {
			for(handler in _list.handlers) {
				#if clay_emitter_pos _verboser('emit / $event / ${pos.fileName}:${pos.lineNumber}@${pos.className}.${pos.methodName}'); #end
				handler(data);
			}
		}

		_checking = false;

			//needed because handlers
			//might disconnect listeners
		_check();

	}

		/** connect a named event to a handler */
	// @:generic
	public function on<T>(event:ET, handler: T->Void, order:Int #if clay_emitter_pos, ?pos:haxe.PosInfos #end ) {

		_check();

		#if clay_emitter_pos _verbose('on / $event / ${pos.fileName}:${pos.lineNumber}@${pos.className}.${pos.methodName}'); #end
		
		if(!bindings.exists(event)) {
			var oh:OrderedHandler = new OrderedHandler();
			oh.handlers.push(handler);
			oh.order.push(order);
			bindings.set(event, oh);
		} else {
			var oh = bindings.get(event);
			if(oh.handlers.indexOf(handler) == -1) {
				var added:Bool = false;
				var o:Int = 0;
				for (i in 0...oh.order.length) {
					o = oh.order[i];
					if (order <= o) {
						oh.handlers.insert(i, handler);
						oh.order.insert(i, order);
						added = true;
						break;
					}
				}
				if(!added) {
					oh.handlers.push(handler);
					oh.order.push(order);
				}
			}
		}

	}

		/** disconnect a named event and handler. returns true on success, or false if event or handler not found */
	// @:generic
	public function off<T>(event:ET, handler: T->Void #if clay_emitter_pos, ?pos:haxe.PosInfos #end ):Bool {

		_check();

		var _success = false;

		if(bindings.exists(event)) {
			#if clay_emitter_pos _verbose('off / $event / ${pos.fileName}:${pos.lineNumber}@${pos.className}.${pos.methodName}'); #end
			_to_remove.push({ event:event, handler:handler });
			_success = true;
		}

		return _success;

	}

	function _check() {

		if(_checking) {
			return;
		}

		_checking = true;

		if(!_to_remove.isEmpty()) {
			for(_node in _to_remove) {
				var oh:OrderedHandler = bindings.get(_node.event);
				if(oh != null) {
					for (i in 0...oh.handlers.length) {
						if(oh.handlers[i] == _node.handler) {
							oh.handlers.splice(i,1);
							oh.order.splice(i,1);
							break;
						}
					}
					if(oh.handlers.length == 0) {
						bindings.remove(_node.event);
					}
				}
			}
			_to_remove.clear();
		}

		_checking = false;

	}

}
