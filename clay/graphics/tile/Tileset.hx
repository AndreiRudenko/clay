package clay.graphics.tile;


import clay.resources.Texture;
import clay.math.Rectangle;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.utils.Log.*;
import clay.utils.ArrayTools;


class Tileset {


	public var name:String;

	public var texture(default, null):Texture;

	public var tile_width(default, null):Int;
	public var tile_height(default, null):Int;
	public var tile_margin(default, null):Int;
	public var tile_spacing(default, null):Int;

	public var gid:Int;
	public var rows(default, null):Int;
	public var columns(default, null):Int;
	public var total(default, null):Int;
	public var tcoords(default, null):Array<Vector>;
	public var tdata(default, null):Array<Dynamic>;
	public var tprops(default, null):Array<Dynamic>;


	public function new(name:String, texture:Texture, tile_width:Int, tile_height:Int, tile_margin:Int = 0, tile_spacing:Int = 0) {
		
		this.name = name;
		this.texture = texture;
		this.tile_width = tile_width;
		this.tile_height = tile_height;
		this.tile_margin = tile_margin;
		this.tile_spacing = tile_spacing;

		gid = 0;
		rows = 0;
		columns = 0;
		total = 0;
		tcoords = [];
		tdata = [];
		tprops = [];

		update_tile_data(texture.width_actual, texture.height_actual);

	}

	public function set_texture(t:Texture) {

		texture = t;
		update_tile_data(texture.width_actual, texture.height_actual);
		
	}

	public function set_tile_size(w:Int, h:Int) {
		
		tile_width = w;
		tile_height = h;

		if(texture != null) {
			update_tile_data(texture.width_actual, texture.height_actual);
		}

	}

	public function set_tile_spacing(?margin:Int, ?spacing:Int) {

		if(margin != null) {
			tile_margin = margin;
		}

		if(spacing != null) {
			tile_spacing = spacing;
		}

		if(texture != null) {
			update_tile_data(texture.width_actual, texture.height_actual);
		}

	}

	public function get_tile_data(tile:Int) {

		return tdata[tile - gid];
		
	}

	public function get_tile_props(tile:Int) {

		return tprops[tile - gid];
		
	}

	public function get_tile_coords(tile:Int):Vector {
		
		return tcoords[tile - gid];

	}

	function update_tile_data(texture_width:Int, texture_height:Int) {
		
		var row_count = (texture_height - tile_margin * 2 + tile_spacing) / (tile_height + tile_spacing);
		var col_count = (texture_width - tile_margin * 2 + tile_spacing) / (tile_height + tile_spacing);
		
		if (row_count % 1 != 0 || col_count % 1 != 0) {
			log('Image tile area not tile size multiple in: ' + name);
		}

		// In Tiled a tileset image that is not an even multiple of the tile dimensions is truncated
		// - hence the floor when calculating the rows/columns.
		rows = Math.floor(row_count);
		columns = Math.floor(col_count);

		// In Tiled, "empty" spaces in a tileset count as tiles and hence count towards the gid
		total = rows * columns;

		ArrayTools.clear(tcoords);

		var tx = tile_margin;
		var ty = tile_margin;

		for (y in 0...rows) {
			for (x in 0...columns) {
				tcoords.push(new Vector(tx, ty));
				tx += tile_width + tile_spacing;
			}
			tx = tile_margin;
			ty += tile_height + tile_spacing;
		}

	}



}
