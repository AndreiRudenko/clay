package clay.core.ecs;


import clay.World;


@:allow(clay.Processor)
class Processors {


		/** The list of processors */
	@:noCompletion public var _processors:Map<String, Processor>;

	var world:World;
	var inited:Bool = false;


	public function new(_world:World) {

		world = _world;

		_processors = new Map();

	}

	public function add<T:Processor>(_processor:T, _priority:Int = 0, _enabled:Bool = true):T {
		
		_processor.priority = _priority;

		_add(_processor, _enabled);

		return _processor;
		
	}

	public function remove<T:Processor>(_processor_class:Class<T>):T {

		var _class_name = Type.getClassName(_processor_class);
		var _processor:T = cast _processors.get(_class_name);

		if(_processor != null) {
			_remove(_processor);
		}

		return _processor;

	}

	public function get<T:Processor>(_processor_class:Class<T>):T {
		
		return cast _processors.get(Type.getClassName(_processor_class));

	}

	public function enable(_processor_class:Class<Dynamic>) {
		
		var _class_name = Type.getClassName(_processor_class);
		var _processor = _processors.get(_class_name);
		if(_processor != null && !_processor.active) {
			_enable(_processor);
		}

	}

	public function disable(_processor_class:Class<Dynamic>) {

		var _class_name = Type.getClassName(_processor_class);
		var _processor = _processors.get( _class_name );
		if(_processor != null && _processor.active) {
			_disable(_processor);
		}
		
	}

	public function empty() {

		for (p in _processors) {
			_remove(p);
		}

	}

	@:noCompletion public function init() {

		for (p in _processors) {
			p.init();
		}
		inited = true;

	}

	function _add(_processor:Processor, _enabled:Bool) {

		_processors.set(_processor.name, _processor);
		_processor.world = world;
		_processor.onadded();

		if(inited) {
			_processor.init();
		}

		if(_enabled) {
			_enable(_processor);
		}

	}

	function _remove(_processor:Processor) {

		if(_processor.active) {
			_disable(_processor);
		}

		_processor.onremoved();
		_processor.world = null;
		_processors.remove(_processor.name);

	}

	function _enable(_processor:Processor) {

		_processor.onenabled();
		_processor._active = true;
		_processor.__listen_emitter();

	}

	function _disable(_processor:Processor) {

		_processor.ondisabled();
		_processor._active = false;
		_processor.__unlisten_emitter();

	}

	@:noCompletion public function toString() {

		return _processors.toString();

	}
	
	@:noCompletion public inline function iterator():Iterator<Processor> {

		return _processors.iterator();

	}


}
