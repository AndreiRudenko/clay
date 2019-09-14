package clay.events;


class Emitter {


	@:noCompletion public var bindings:Map<EventType<Dynamic>, Array<EmitHandler<Dynamic>>>;

	var _toRemove:Array<EmitDef<Dynamic>>;
	var _toAdd:Array<EmitHandler<Dynamic>>;
	var _processing:Bool;


	public function new() {

		bindings = new Map();

		_toRemove = [];
		_toAdd = [];
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

			if(_toRemove.length > 0) {
				for (e in _toRemove) {
					_remove(e.event, e.handler);
				}
				_toRemove.splice(0, _toRemove.length);
			}
			if(_toAdd.length > 0) {
				for (eh in _toAdd) {
					_add(eh);
				}
				_toAdd.splice(0, _toAdd.length);
			}
		}
		
	}

	public function on<T>(event:EventType<T>, handler:(e:T)->Void, priority:Int = 0) {

		if(_has(event, handler)) {
			return;
		}

		if(_processing) {
			for (e in _toAdd) {
				if(e.callback == handler) {
					return;
				} 
			}
			_toAdd.push(new EmitHandler<T>(event, handler, priority));
		} else {
			_add(new EmitHandler<T>(event, handler, priority));
		}

	}

	public function off<T>(event:EventType<T>, handler:(e:T)->Void):Bool {

		if(!_has(event, handler)) {
			return false;
		}

		if(_processing) {
			for (e in _toRemove) {
				if(e.handler == handler) {
					return false;
				} 
			}
			_toRemove.push({event:event, handler:handler});
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

	function _add<T>(emitHandler:EmitHandler<T>) {

		var list = bindings.get(emitHandler.event);
		if(list == null) {
			list = new Array<EmitHandler<T>>();
			list.push(emitHandler);
			bindings.set(emitHandler.event, list);
		} else {
			var atPos:Int = list.length;
			for (i in 0...list.length) {
				if (emitHandler.priority < list[i].priority) {
					atPos = i;
					break;
				}
			}
			list.insert(atPos, emitHandler);
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