package clay.emitters;

// based on Emitter by Sven Bergström https://github.com/underscorediscovery/luxe/blob/master/luxe/Emitter.hx

import haxe.ds.IntMap;
import clay.utils.Log._verbose;
import clay.utils.Log._verboser;


@:noCompletion private typedef EmitHandler = Dynamic->Void;
@:noCompletion private typedef HandlerList = Array<EmitHandler>;

@:noCompletion private typedef EmitNode<T> = { event:T, handler:EmitHandler #if clay_emitter_pos, ?pos:haxe.PosInfos #end }


class Emitter<ET:Int> {


	@:noCompletion public var bindings:IntMap<HandlerList>;

		//store the items to remove
	var _to_remove:List< EmitNode<ET> >;
	var _checking:Bool = false;

		/** create a new emitter instance, for binding functions easily to named events. similar to `Events` */
	public function new() {

		_to_remove = new List();
		bindings = new IntMap<HandlerList>();

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
		if(_list != null && _list.length > 0) {
			for(handler in _list) {
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
	public function on<T>(event:ET, handler: T->Void #if clay_emitter_pos, ?pos:haxe.PosInfos #end ) {

		_check();

		#if clay_emitter_pos _verbose('on / $event / ${pos.fileName}:${pos.lineNumber}@${pos.className}.${pos.methodName}'); #end

		if(!bindings.exists(event)) {
			bindings.set(event, [handler]);
		} else {
			var _list = bindings.get(event);
			if(_list.indexOf(handler) == -1) {
				_list.push(handler);
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
				var _list = bindings.get(_node.event);
				if(_list != null) {
					_list.remove( _node.handler );
					if(_list.length == 0) {
						bindings.remove(_node.event);
					}
				}
			}
			_to_remove.clear();
		}

		_checking = false;

	}

}
