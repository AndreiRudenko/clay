package clay.render;


import clay.components.Geometry;


@:access(clay.components.Geometry)
class GeometryList {


	public var head (default, null):Geometry;
	public var tail (default, null):Geometry;

	public var length(default, null):Int = 0;
	

	public function new() {}

	public function add(geom:Geometry):GeometryList {

		if (head == null) {
			head = tail = geom;
			geom.next = geom.prev = null;
		} else {
			var node:Geometry = tail;
			while (node != null) {
				if (node.sort_key <= geom.sort_key){
					break;
				}

				node = node.prev;
			}

			if (node == tail) {
				tail.next = geom;
				geom.prev = tail;
				geom.next = null;
				tail = geom;
			} else if (node == null) {
				geom.next = head;
				geom.prev = null;
				head.prev = geom;
				head = geom;
			} else {
				geom.next = node.next;
				geom.prev = node;
				node.next.prev = geom;
				node.next = geom;
			}
		}

		length++;

		return this;

	}

	public inline function add_first(geom:Geometry):GeometryList {

		geom.next = head;
		if (head != null){
			head.prev = geom;
		} else {
			tail = geom;
		}

		head = geom;
		
		length++;

		return this;

	}

	public function remove(geom:Geometry):GeometryList {

		if (geom == head){
			head = head.next;
			
			if (head == null) {
				tail = null;
			}
		} else if (geom == tail) {
			tail = tail.prev;
				
			if (tail == null) {
				head = null;
			}
		}

		if (geom.prev != null){
			geom.prev.next = geom.next;
		}

		if (geom.next != null){
			geom.next.prev = geom.prev;
		}

		geom.next = geom.prev = null;

		length--;

		return this;

	}

	public function clear():GeometryList {

		var geom:Geometry = null;
		while (head != null) {
			geom = head;
			head = head.next;
			geom.prev = null;
			geom.next = null;
		}

		tail = null;
		
		length = 0;

		return this;

	}

	public function toArray():Array<Geometry> {

		var _arr:Array<Geometry> = []; 

		var node:Geometry = head;
		while (node != null){
			_arr.push(node);
			node = node.next;
		}

		return _arr;

	}

	@:noCompletion public function toString() {

		var _list:Array<String> = []; 

		var cn:String;
		var node:Geometry = head;
		while (node != null){
			cn = Type.getClassName(Type.getClass(node));
			_list.push('$cn / order: ${node.order}/ sort_key: ${node.sort_key}');
			node = node.next;
		}

		return '[${_list.join(", ")}]';

	}

	public inline function iterator():GeometryListIterator {

		return new GeometryListIterator(head);

	}
	

}

@:final @:unreflective @:dce
@:access(clay.components.Geometry)
private class GeometryListIterator {


	public var node:Geometry;


	public inline function new(head:Geometry) {

		node = head;

	}

	public inline function hasNext():Bool {

		return node != null;

	}

	public inline function next():Geometry {

		var n = node;
		node = node.next;
		return n;

	}


}

