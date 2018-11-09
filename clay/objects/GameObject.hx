package clay.objects;


import clay.Entity;
import clay.World;
import clay.components.common.Transform;
import clay.utils.Log.*;
import clay.math.Vector;


class GameObject {


	static var ID:Int = 0;

	public var name     	(default, null):String;
	public var entity   	(default, null):Entity;
	public var transform	(default, null):Transform;
	public var world    	(default, null):World;

    public var pos              (get,never):Vector;
    public var rotation         (get,  set):Float;
    public var scale            (get,never):Vector;
    public var origin           (get,never):Vector;

    public var parent           (default,set):GameObject;


	public function new(?_options:GameObjectOptions) {

		if(_options != null) {
			name = def(_options.name, 'gameobject.${ID++}');
			world = def(_options.world, Clay.world);
			entity = def(_options.entity, world.entities.create());
			transform = def(_options.transform, new Transform());
			if(_options.pos != null) {
				transform.pos.copy_from(_options.pos);
			}
			if(_options.scale != null) {
				transform.scale.copy_from(_options.scale);
			}
			if(_options.origin != null) {
				transform.origin.copy_from(_options.origin);
			}
			if(_options.rotation != null) {
				transform.rotation = _options.rotation;
			}
		} else {
			name = 'gameobject.${ID++}';
			world = Clay.world;
			entity = world.entities.create();
			transform = new Transform();
		}

		world.components.set_many(entity, [new GameObjectComponent(), transform]);
		
	}

	public function destroy() {

		world.entities.destroy(entity);

		entity = Entity.NULL;
		name = null;
		transform = null;
		world = null;
		
	}

	function set_parent(_parent:GameObject):GameObject {
		
		parent = _parent;

		if(parent != null) {
			transform.parent = parent.transform;
		}

		return parent;

	}

	inline function get_pos():Vector {
		
		return transform.pos;

	}
	
	inline function get_scale():Vector {

		return transform.scale;

	}

	inline function get_origin():Vector {

		return transform.origin;

	}

	inline function get_rotation():Float {

		return transform.rotation;

	}

	inline function set_rotation(v:Float):Float {

		return transform.rotation = v;

	}

	
}

class GameObjectComponent {

	public function new() {}

}



typedef GameObjectOptions = {

	@:optional var name:String;
	@:optional var entity:Entity;
	@:optional var world:World;
	@:optional var transform:Transform;
	@:optional var pos:Vector;
	@:optional var scale:Vector;
	@:optional var origin:Vector;
	@:optional var rotation:Float;

}