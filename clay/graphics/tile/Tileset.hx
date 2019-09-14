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

	public var tileWidth(default, null):Int;
	public var tileHeight(default, null):Int;
	public var tileMargin(default, null):Int;
	public var tileSpacing(default, null):Int;

	public var gid:Int;
	public var rows(default, null):Int;
	public var columns(default, null):Int;
	public var total(default, null):Int;
	public var tcoords(default, null):Array<Vector>;
	public var tdata(default, null):Array<Dynamic>;
	public var tprops(default, null):Array<Dynamic>;


	public function new(name:String, texture:Texture, tileWidth:Int, tileHeight:Int, tileMargin:Int = 0, tileSpacing:Int = 0) {
		
		this.name = name;
		this.texture = texture;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.tileMargin = tileMargin;
		this.tileSpacing = tileSpacing;

		gid = 0;
		rows = 0;
		columns = 0;
		total = 0;
		tcoords = [];
		tdata = [];
		tprops = [];

		updateTileData(texture.widthActual, texture.heightActual);

	}

	public function setTexture(t:Texture) {

		texture = t;
		updateTileData(texture.widthActual, texture.heightActual);
		
	}

	public function setTileSize(w:Int, h:Int) {
		
		tileWidth = w;
		tileHeight = h;

		if(texture != null) {
			updateTileData(texture.widthActual, texture.heightActual);
		}

	}

	public function setTileSpacing(?margin:Int, ?spacing:Int) {

		if(margin != null) {
			tileMargin = margin;
		}

		if(spacing != null) {
			tileSpacing = spacing;
		}

		if(texture != null) {
			updateTileData(texture.widthActual, texture.heightActual);
		}

	}

	public function getTileData(tile:Int) {

		return tdata[tile - gid];
		
	}

	public function getTileProps(tile:Int) {

		return tprops[tile - gid];
		
	}

	public function getTileCoords(tile:Int):Vector {
		
		return tcoords[tile - gid];

	}

	function updateTileData(textureWidth:Int, textureHeight:Int) {
		
		var rowCount = (textureHeight - tileMargin * 2 + tileSpacing) / (tileHeight + tileSpacing);
		var colCount = (textureWidth - tileMargin * 2 + tileSpacing) / (tileHeight + tileSpacing);
		
		if (rowCount % 1 != 0 || colCount % 1 != 0) {
			log('Image tile area not tile size multiple in: ' + name);
		}

		// In Tiled a tileset image that is not an even multiple of the tile dimensions is truncated
		// - hence the floor when calculating the rows/columns.
		rows = Math.floor(rowCount);
		columns = Math.floor(colCount);

		// In Tiled, "empty" spaces in a tileset count as tiles and hence count towards the gid
		total = rows * columns;

		ArrayTools.clear(tcoords);

		var tx = tileMargin;
		var ty = tileMargin;

		for (y in 0...rows) {
			for (x in 0...columns) {
				tcoords.push(new Vector(tx, ty));
				tx += tileWidth + tileSpacing;
			}
			tx = tileMargin;
			ty += tileHeight + tileSpacing;
		}

	}



}
