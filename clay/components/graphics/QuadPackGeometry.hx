package clay.components.graphics;

// based on https://github.com/underscorediscovery/luxe

import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.data.Color;
import clay.ds.Int32RingBuffer;
import clay.render.Vertex;
import clay.resources.FontResource;
import clay.components.graphics.Texture;
import clay.components.graphics.Geometry;
import clay.utils.Log.*;
import clay.utils.PowerOfTwo;

@:keep
class QuadPackGeometry extends Geometry {


	public var quads(default, null):Map<Int, PackedQuad>;

	var _quad_ids:Int32RingBuffer;
	var _quads_used:Int;
	var _quads_max:Int;


	public function new(_options:QuadPackGeometryOptions) {

		super(_options);

		_quads_max = _options.quads_max != null ? PowerOfTwo.next(_options.quads_max) : 4096;
		_quads_used = 0;
		_quad_ids = new Int32RingBuffer(_quads_max);

		quads = new Map();

		geometry_type = GeometryType.quad;

	}
	
	public function quad_add( _options:PackedQuadOptions ):Int {

		def(_options.visible, true);
		def(_options.flipx, false);
		def(_options.flipy, false);

		if(_quads_used >= _quads_max) {
			throw('Out of quads, max allowed ${_quads_max}');
		}

		++_quads_used;
		var _id = _quad_ids.pop();

		var vert0 = new Vertex( new Vector( _options.x, _options.y ), _options.color);
		var vert1 = new Vertex( new Vector( _options.x+_options.w, _options.y ), _options.color);
		var vert2 = new Vertex( new Vector( _options.x+_options.w, _options.y+_options.h ), _options.color);
		var vert3 = new Vertex( new Vector( _options.x, _options.y+_options.h ), _options.color);

		add( vert0 );
		add( vert1 );
		add( vert2 );
		add( vert3 );

		var _quad:PackedQuad = new PackedQuad();

		_quad.uid = _id;
		_quad.verts = [];
		_quad.flipx = _options.flipx;
		_quad.flipy = _options.flipx;
		_quad.visible = _options.visible;
		_quad._uv_cache = new Rectangle(0,0,1,1);

		_quad.verts.push( vert0 );
		_quad.verts.push( vert1 );
		_quad.verts.push( vert2 );
		_quad.verts.push( vert3 );

		quads.set(_id, _quad);

		if(_options.uv != null) {
			quad_uv(_id, _options.uv);
		}

		return _id;

	}

	public function quad_remove( _quad_id:Int ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {

			remove( _quad.verts[0] );
			remove( _quad.verts[1] );
			remove( _quad.verts[2] );
			remove( _quad.verts[3] );

			quads.remove( _quad_id );

			--_quads_used;
			_quad_ids.push(_quad_id);

		}

	}

	public function quad_visible( _quad_id:Int, visible:Bool ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {

				//add only if not already added
			if(visible && !_quad.visible) {

				_quad.visible = false;

				add( _quad.verts[0] );
				add( _quad.verts[1] );
				add( _quad.verts[2] );
				add( _quad.verts[3] );

			} else if(!visible && _quad.visible) {

				_quad.visible = false;

				remove( _quad.verts[0] );
				remove( _quad.verts[1] );
				remove( _quad.verts[2] );
				remove( _quad.verts[3] );

			}

		}

	}

	public function quad_resize( _quad_id:Int, _size : Rectangle ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {

			_quad.verts[0].pos = new Vector( _size.x,         _size.y );
			_quad.verts[1].pos = new Vector( _size.x+_size.w, _size.y );
			_quad.verts[2].pos = new Vector( _size.x+_size.w, _size.y+_size.h );
			_quad.verts[3].pos = new Vector( _size.x,         _size.y+_size.h );

		}

	}

	public function quad_pos( _quad_id:Int, _p:Vector ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {

			var _diffx = _p.x - _quad.verts[0].pos.x;
			var _diffy = _p.y - _quad.verts[0].pos.y;

			_quad.verts[0].pos.x += _diffx;
			_quad.verts[0].pos.y += _diffy;

			_quad.verts[1].pos.x += _diffx;
			_quad.verts[1].pos.y += _diffy;

			_quad.verts[2].pos.x += _diffx;
			_quad.verts[2].pos.y += _diffy;

			_quad.verts[3].pos.x += _diffx;
			_quad.verts[3].pos.y += _diffy;

		}

	}

	public function quad_color( _quad_id:Int, _c:Color ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {
			_quad.verts[0].color = _c;
			_quad.verts[1].color = _c;
			_quad.verts[2].color = _c;
			_quad.verts[3].color = _c;
		}

	}

	public function quad_alpha( _quad_id:Int, _a:Float ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {
			_quad.verts[0].color.a = _a;
			_quad.verts[1].color.a = _a;
			_quad.verts[2].color.a = _a;
			_quad.verts[3].color.a = _a;
		}

	}

	public function quad_uv_space( _quad_id:Int, _uv : Rectangle ) {

		var _quad = quads.get( _quad_id );

		if(_quad != null) {

			var flipx = _quad.flipx;
			var flipy = _quad.flipy;

				//the uv width and height
			var sz_x = _uv.w;
			var sz_y = _uv.h;

				//tl
			var tl_x = _uv.x;
			var tl_y = _uv.y;

				//Keep for later, before changing the values for flipping
			_quad._uv_cache.set( tl_x, tl_y, sz_x, sz_y );

				//tr
			var tr_x = tl_x + sz_x;
			var tr_y = tl_y;
				//br
			var br_x = tl_x + sz_x;
			var br_y = tl_y + sz_y;
				//bl
			var bl_x = tl_x;
			var bl_y = tl_y + sz_y;

			var tmp_x = 0.0;
			var tmp_y = 0.0;

					//flipped y swaps tl and tr with bl and br, only on y
				if(flipy) {

						//swap tl and bl
					tmp_y = bl_y;
						bl_y = tl_y;
						tl_y = tmp_y;

						//swap tr and br
					tmp_y = br_y;
						br_y = tr_y;
						tr_y = tmp_y;

				} //flipy

					//flipped x swaps tl and bl with tr and br, only on x
				if(flipx) {

						//swap tl and tr
					tmp_x = tr_x;
						tr_x = tl_x;
						tl_x = tmp_x;

						//swap bl and br
					tmp_x = br_x;
						br_x = bl_x;
						bl_x = tmp_x;

				} //flipx

			_quad.verts[0].tcoord.set( tl_x , tl_y );
			_quad.verts[1].tcoord.set( tr_x , tr_y );
			_quad.verts[2].tcoord.set( br_x , br_y );
			_quad.verts[3].tcoord.set( bl_x , bl_y );

		}

	}

    public function quad_uv( _quad_id:Int, _uv : Rectangle ) {

        if( texture == null ) {
            log("Warning : calling UV on a PackedQuad Geometry with null texture.");
            return;
        }

        var tlx = _uv.x/texture.width_actual;
        var tly = _uv.y/texture.height_actual;
        var szx = _uv.w/texture.width_actual;
        var szy = _uv.h/texture.height_actual;

        quad_uv_space( _quad_id, new Rectangle( tlx, tly, szx, szy ) );

    }

    public function quad_flipx( _quad_id:Int, _flip:Bool ) {

        var _quad = quads.get( _quad_id );

        if(_quad != null) {
            _quad.flipx = _flip;
            quad_uv_space( _quad_id, _quad._uv_cache );
        }

    }

    public function quad_flipy( _quad_id:Int, _flip:Bool ) {

        var _quad = quads.get( _quad_id );

        if(_quad != null) {
            _quad.flipy = _flip;
            quad_uv_space( _quad_id, _quad._uv_cache );
        }

    }

}

class PackedQuad {


	public var uid:UInt;
	public var verts:Array<Vertex>;
	public var flipx:Bool;
	public var flipy:Bool;
	public var visible:Bool;
	public var _uv_cache:Rectangle;


	public function new() {}


}


typedef PackedQuadOptions = {
	x : Float,
	y : Float,
	w : Float,
	h : Float,

	?color : Color,
	?uv : Rectangle,
	?flipx : Bool,
	?flipy : Bool,
	?visible : Bool
}

typedef QuadPackGeometryOptions = {

	>GeometryOptions,

	@:optional var quads_max:Int;

}
