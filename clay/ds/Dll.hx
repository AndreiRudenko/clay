package clay.ds;

// doubly linked list

class Dll<T> {


	public var head (default, null) : DllNode<T>;
	public var tail (default, null) : DllNode<T>;

	public var pool_size (default, null) : Int = 0;
	public var length(default, null):Int = 0;

	var head_pool : DllNode<T>;
	var tail_pool : DllNode<T>;

	var reserved_size : Int = 0;


	public function new(_reserved_size:Null<Int> = 0) {

		if(_reserved_size > 0){
			reserved_size = _reserved_size;
			while(pool_size < reserved_size) {
				put_node_to_pool(new DllNode<T>(cast null));
			}
		}

	}

	public inline function add_first(_value:T) : DllNode<T> {

		var node = get_node_from_pool(_value);

		node.next = head;
		if (head != null){
			head.prev = node;
		} else {
			tail = node;
		}

		head = node;
		
		length++;

		return node;

	}

	public inline function add_last(_value:T) : DllNode<T> {

		var node = get_node_from_pool(_value);

		if (tail != null) {
			tail.next = node;
			node.prev = tail;
		} else{
			head = node;
		}

		tail = node;
		
		length++;

		return node;

	}

	public inline function get_first() : T {

		if(head != null){
			return head.value;
		}

		return null;

	}

	public inline function get_last() : T {

		if(tail != null){
			return tail.value;
		}

		return null;

	}

	public inline function get_node(_value:T) : DllNode<T> {

		var _ret:DllNode<T> = null;

		var len = length;

		var nodeHead = head;
		var nodeTail = tail;

		while(len > 0) {

			if(nodeHead.value == _value){
				_ret = nodeHead;
				break;
			} else if(nodeTail.value == _value){
				_ret = nodeTail;
				break;
			}

			nodeHead = nodeHead.next;
			nodeTail = nodeTail.prev;

			len -= 2;
		}

		return _ret;

	}

	public function rem_first() : T {

		if(length == 0) {
			return null;
		}
		
		var node = head;
		if (head == tail){
			head = tail = null;
		} else {
			head = head.next;
			node.next = null;
			head.prev = null;
		}

		length--;

		return put_node_to_pool(node);

	}

	public function rem_last() : T {
		
		if(length == 0) {
			return null;
		}

		var node = tail;
		if (head == tail){
			head = tail = null;
		} else {
			tail = tail.prev;
			node.prev = null;
			tail.next = null;
		}
		
		length--;

		return put_node_to_pool(node);

	}

	public inline function remove(_value:T):Bool{

		if(length == 0) {
			return false;
		}
		
		var node = get_node(_value);
		if(node != null){
			remove_node(node);
			return true;
		}
		
		return false;

	}

	public inline function remove_node(node:DllNode<T>) {
		
		if (node == head){
			head = head.next;
			
			if (head == null) {
				tail = null;
			}
		} else if (node == tail) {
			tail = tail.prev;
				
			if (tail == null) {
				head = null;
			}
		}

		if (node.prev != null) {
			node.prev.next = node.next;
		}

		if (node.next != null) {
			node.next.prev = node.prev;
		}

		node.next = node.prev = null;


		put_node_to_pool(node);
		length--;

	}

	public inline function exists(_value:T) : Bool {

		return get_node(_value) != null;

	}

	public inline function clear(gc:Bool = true){

		if (gc || reserved_size > 0) {
			var node = head;
			var next = null;
			for (i in 0...length) {

				next = node.next;

				node.prev = null;
				node.next = null;

				put_node_to_pool(node);

				node = next;
			}
		}
		
		head = tail = null;
		length = 0;
		
	}

	public inline function toArray():Array<T>{

		var ret:Array<T> = [];

		var node = head;
		while (node != null){
			ret.push(node.value);
			node = node.next;
		}
		
		return ret;

	}
	
	inline function get_node_from_pool(_value:T):DllNode<T> {

		var node:DllNode<T> = null;

		if(reserved_size == 0 || pool_size == 0){
			node = new DllNode(_value);
		} else {
			node = head_pool;

			head_pool = head_pool.next;

			if(head_pool == null){
				tail_pool = null;
			}

			pool_size--;

			node.next = null;
			node.value = _value;
		}

		return node;

	}

	inline function put_node_to_pool(node:DllNode<T>):T {

		var _value = node.value;

		if(reserved_size > 0 && pool_size < reserved_size){

			if(head_pool == null){
				head_pool = tail_pool = node;
			} else {
				tail_pool = tail_pool.next = node;
			}

			node.value = cast null; // clear node value

			pool_size++;
		} else {
			node.value = cast null;
			node.prev = null;
			node.next = null;
		}

		return _value;

	}

	public inline function print_pool(){

	    var _list = []; 

		var node = head_pool;
		while (node != null){
			_list.push(node.value);
			node = node.next;
		}

		return 'pool: [${_list.join(", ")}]';

	}

	inline function toString() {

		var _list = []; 

		var node = head;
		while (node != null){
			_list.push(node.value);
			node = node.next;
		}

		return 'node: [${_list.join(", ")}]';

	}
	
	public inline function iterator():Iterator<T> {

		return new DLLIterator<T>(head);

	}


}


private class DllNode<T> {

	public var value : T;
	public var next : DllNode<T>;
	public var prev : DllNode<T>;


	public function new(_value:T){
		
		value = _value;

	}

}


private class DLLIterator<T> {


	var node:DllNode<T>;
	

	public inline function new(head:DllNode<T>){

		node = head;

	}

	public inline function hasNext():Bool {

		return node != null;

	}
	
	public inline function next():T {

		var _value = node.value;
		node = node.next;
		return _value;

	}
	
}
