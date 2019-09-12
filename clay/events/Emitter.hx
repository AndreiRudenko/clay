package clay.events;


class Emitter {


	@:noCompletion public var bindings:Map<EventType<Dynamic>, Array<EmitHandler<Dynamic>>>;

	var _to_remove:Array<EmitDef<Dynamic>>;
	var _to_add:Array<EmitHandler<Dynamic>>;
	var _processing:Bool;


	public function new() {

		bindings = new Map();

		_to_remove = [];
		_to_add = [];
		_processing = false;

	}

	public function emit<T>(event:EventType<T>, ?data:T) {

		var list = bindings.get(event);

		if(list != null) {
			_processing = true;
			for (e in list) {
				e.callback(data);
			}
			_processing = false;

			if(_to_remove.length > 0) {
				for (e in _to_remove) {
					_remove(e.event, e.handler);
				}
				_to_remove.splice(0, _to_remove.length);
			}
			if(_to_add.length > 0) {
				for (eh in _to_add) {
					_add(eh);
				}
				_to_add.splice(0, _to_add.length);
			}
		}
		
	}

	public function on<T>(event:EventType<T>, handler:(e:T)->Void, priority:Int = 0) {

		if(_has(event, handler)) {
			return;
		}

		if(_processing) {
			for (e in _to_add) {
				if(e.callback == handler) {
					return;
				} 
			}
			_to_add.push(new EmitHandler<T>(event, handler, priority));
		} else {
			_add(new EmitHandler<T>(event, handler, priority));
		}

	}

	public function off<T>(event:EventType<T>, handler:(e:T)->Void):Bool {

		if(!_has(event, handler)) {
			return false;
		}

		if(_processing) {
			for (e in _to_remove) {
				if(e.handler == handler) {
					return false;
				} 
			}
			_to_remove.push({event:event, handler:handler});
		} else {
			_remove(event, handler);
		}

		return true;

	}

	function _has<T>(event:EventType<T>, handler:(e:T)->Void):Bool {

		var list = bindings.get(event);

		if(list != null) {
			for (eh in list) {
				if(eh.callback == handler) {
					return true;
				}
			}
		}

		return false;
		
	}

	function _add<T>(emit_handler:EmitHandler<T>) {

		var list = bindings.get(emit_handler.event);
		if(list == null) {
			list = new Array<EmitHandler<T>>();
			list.push(emit_handler);
			bindings.set(emit_handler.event, list);
		} else {
			var at_pos:Int = list.length;
			for (i in 0...list.length) {
				if (emit_handler.priority < list[i].priority) {
					at_pos = i;
					break;
				}
			}
			list.insert(at_pos, emit_handler);
		}

	}

	function _remove<T>(event:EventType<T>, handler:(e:T)->Void) {
		
		var list = bindings.get(event);
		for (i in 0...list.length) {
			if(list[i].callback == handler) {
				list.splice(i, 1);
			}
		}

		if(list.length == 0) {
			bindings.remove(event);
		}

	}

	
}

private typedef EmitDef<T> = {event:T, handler:(e:T)->Void}

private class EmitHandler<T> {


	public var event:EventType<T>;
	public var callback:(e:T)->Void;
	public var priority:Int;


	public function new(event:EventType<T>, callback:(e:T)->Void, priority:Int) {

		this.event = event;
		this.callback = callback;
		this.priority = priority;

	}


}