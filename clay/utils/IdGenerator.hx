package clay.utils;

class IdGenerator {

	var _id:Int;
	var _removedIds:Array<Int>;

	public function new() {
		reset();
	}

	public function get():Int {
		if(_removedIds.length > 0) {
			return _removedIds.shift();
		}
		return _id++;
	}

	public function put(id:Int) {
		_removedIds.push(id);
	}

	public function reset() {
		_id = 0;
		_removedIds = [];
	}

}