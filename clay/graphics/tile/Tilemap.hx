package clay.graphics.tile;


import clay.resources.Texture;
import clay.math.Rectangle;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.render.RenderPath;
import clay.render.Camera;
import clay.render.GeometryType;
import clay.utils.Log.*;
import clay.utils.ArrayTools;


class Tilemap extends Mesh {


		/* The width of the tile */
	public var tile_width(default, null):Int;
		/* The height of the tile */
	public var tile_height(default, null):Int;
		/* The width of the map (in tiles) */
	public var width(default, null):Int;
		/* The height of the map (in tiles) */
	public var height(default, null):Int;

	public var map(default, null):Array<Tile>;
	public var tileset(default, null):Tileset;


	public function new(width:Int, height:Int, tile_width:Int, tile_height:Int) {

		this.tile_width = tile_width;
		this.tile_height = tile_height;
		this.width = width;
		this.height = height;

		map = [];

		super();

		sort_key.geomtype = GeometryType.quadpack;

	}

	override function render_geometry(r:RenderPath, c:Camera) {

		r.set_object_renderer(r.quadpack_renderer);
		r.quadpack_renderer.render(this);

	}

	public function set_tileset(texture:Texture, tile_width:Int, tile_height:Int, tile_margin:Int = 0, tile_spacing:Int = 0) {

		tileset = new Tileset('tileset', texture, tile_width, tile_height, tile_margin, tile_spacing);
		this.texture = texture; 
		
	}

	public function get_tile(x:Int, y:Int):Tile {
		
		return map[get_index(x, y)];

	}

	public function set_tile(x:Int, y:Int, index:Int):Tile {
		
		var idx = get_index(x, y);

		if(map[idx] != null) {
			remove_tile_geometry(map[idx]);
		}

		var tile = new Tile(index, x * tile_width, y * tile_height, tile_width, tile_height, color);
		map[idx] = tile;

		add_tile_geometry(tile);
		update_tile_tcoords(tile);

		return tile;
		
	}

	public function set_tile_color(x:Int, y:Int, color:Color):Tile {

		var idx = get_index(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.color = color;
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function set_tile_flipx(x:Int, y:Int, flip:Bool):Tile {

		var idx = get_index(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.flipx = flip;
			update_tile_tcoords(tile);
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function set_tile_flipy(x:Int, y:Int, flip:Bool):Tile {

		var idx = get_index(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.flipy = flip;
			update_tile_tcoords(tile);
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function set_tile_rotate(x:Int, y:Int, rotate:Int):Tile {

		var idx = get_index(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.rotate = rotate;
			update_tile_tcoords(tile);
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function set_tile_visible(x:Int, y:Int, visible:Bool):Tile {
		
		var idx = get_index(x, y);
		var tile = map[idx];

		if(tile != null) {
			if(tile.visible != visible) {
				tile.visible = visible;
				if(visible) {
					add_tile_geometry(tile);
				} else {
					remove_tile_geometry(tile);
				}
			}
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;
		
	}

	public function remove_tile(x:Int, y:Int):Tile {
		
		var idx = get_index(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			remove_tile_geometry(tile);
			map[idx] = null;
		} else {
			log('can`t remove tile at pos {$x, $y}');
		}

		return tile;

	}

	public function to_map_x(x:Float):Int {

		return Math.floor(x / tile_width);
		
	}

	public function to_map_y(y:Float):Int {

		return Math.floor(y / tile_height);
		
	}

	inline function get_index(x:Int, y:Int):Int { // i = x + w * y;  x = i % w; y = i / w;

		return Std.int(x + width * y);

	}

	inline function add_tile_geometry(tile:Tile) {

		for (v in tile.vertices) {
			add(v);
		}
		
	}

	inline function remove_tile_geometry(tile:Tile) {

		for (v in tile.vertices) {
			remove(v);
		}
		
	}

	function update_tile_tcoords(tile:Tile) {

		var tc = tileset.get_tile_coords(tile.index);

		if(tc == null) {
			log('can`t get tile texture coords for ${tile.index} index');
			return;
		}

		var flipx = tile.flipx;
		var flipy = tile.flipy;

		var sz_x = tileset.tile_width / tileset.texture.width_actual;
		var sz_y = tileset.tile_height / tileset.texture.height_actual;

		var tl_x = tc.x / tileset.texture.width_actual;
		var tl_y = tc.y / tileset.texture.height_actual;
		
		var tr_x = tl_x + sz_x;
		var tr_y = tl_y;

		var br_x = tl_x + sz_x;
		var br_y = tl_y + sz_y;

		var bl_x = tl_x;
		var bl_y = tl_y + sz_y;

		var tmp_x = 0.0;
		var tmp_y = 0.0;

		if(flipy) {
			tmp_y = bl_y;
			bl_y = tl_y;
			tl_y = tmp_y;

			tmp_y = br_y;
			br_y = tr_y;
			tr_y = tmp_y;
		}

		if(flipx) {
			tmp_x = tr_x;
			tr_x = tl_x;
			tl_x = tmp_x;

			tmp_x = br_x;
			br_x = bl_x;
			bl_x = tmp_x;
		}

		switch (tile.rotate) {
			case 1:
				tile.vertices[0].tcoord.set(bl_x, bl_y);
				tile.vertices[1].tcoord.set(tl_x, tl_y);
				tile.vertices[2].tcoord.set(tr_x, tr_y);
				tile.vertices[3].tcoord.set(br_x, br_y);
			case 2:
				tile.vertices[0].tcoord.set(br_x, br_y);
				tile.vertices[1].tcoord.set(bl_x, bl_y);
				tile.vertices[2].tcoord.set(tl_x, tl_y);
				tile.vertices[3].tcoord.set(tr_x, tr_y);
			case 3:
				tile.vertices[0].tcoord.set(tr_x, tr_y);
				tile.vertices[1].tcoord.set(br_x, br_y);
				tile.vertices[2].tcoord.set(bl_x, bl_y);
				tile.vertices[3].tcoord.set(tl_x, tl_y);
			case _:
				tile.vertices[0].tcoord.set(tl_x, tl_y);
				tile.vertices[1].tcoord.set(tr_x, tr_y);
				tile.vertices[2].tcoord.set(br_x, br_y);
				tile.vertices[3].tcoord.set(bl_x, bl_y);
		}

	}


}


class Tile {

		/* tileset index */
	public var index:Int;
		/* map pos x */
	public var x:Int;
		/* map pos y */
	public var y:Int;

	public var visible:Bool;
	public var flipx:Bool;
	public var flipy:Bool;
	public var rotate:Int;
	public var color(default, set):Color;

	public var vertices:Array<Vertex>;


	public function new(index:Int, x:Int, y:Int, w:Int, h:Int, color:Color) {

		this.index = index;
		this.x = x;
		this.y = y;

		vertices = [];

		vertices.push(new Vertex(new Vector(x, y)));
		vertices.push(new Vertex(new Vector(x + w, y)));
		vertices.push(new Vertex(new Vector(x + w, y + h)));
		vertices.push(new Vertex(new Vector(x, y + h)));

		this.color = color;

	}

	function set_color(v:Color):Color {

		color = v;

		for (v in vertices) {
			v.color = color;
		}
		
		return color;

	}


}
