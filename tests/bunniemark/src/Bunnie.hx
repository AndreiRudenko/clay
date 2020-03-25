package;


import clay.Clay;
import clay.graphics.Sprite;
import clay.utils.Color;


class Bunnie {

	public var x(get, set):Float;
	public var y(get, set):Float;

	public var w(get, set):Float;
	public var h(get, set):Float;

	public var vx:Float;
	public var vy:Float;

	public var graphics:Sprite;

	public function new(x:Float, y:Float, w:Float, h:Float) {
		graphics = new Sprite(Clay.resources.texture("bunnie.png"));
		Clay.layers.add(graphics);
		
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;

		vx = 50 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
		vy = 50 * ((Math.random() * 5) - 2.5) * (Math.random() < 0.5 ? 1 : -1);
	}
	
	inline function get_x() return graphics.transform.pos.x; 
	inline function set_x(v:Float) return graphics.transform.pos.x = v;
	
	inline function get_y() return graphics.transform.pos.y; 
	inline function set_y(v:Float) return graphics.transform.pos.y = v;
	
	inline function get_w() return graphics.size.x; 
	inline function set_w(v:Float) return graphics.size.x = v;

	inline function get_h() return graphics.size.y; 
	inline function set_h(v:Float) return graphics.size.y = v;
	
}


