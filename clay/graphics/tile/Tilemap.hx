package clay.graphics.tile;


import clay.resources.Texture;
import clay.math.Rectangle;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.render.Camera;
import clay.utils.Log.*;
import clay.utils.ArrayTools;


class Tilemap extends Mesh {


		/* The width of the tile */
	public var tileWidth(default, null):Int;
		/* The height of the tile */
	public var tileHeight(default, null):Int;
		/* The width of the map (in tiles) */
	public var width(default, null):Int;
		/* The height of the map (in tiles) */
	public var height(default, null):Int;

	public var map(default, null):Array<Tile>;
	public var tileset(default, null):Tileset;

	public var tilesCount(default, null):Int;


	public function new(width:Int, height:Int, tileWidth:Int, tileHeight:Int) {

		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.width = width;
		this.height = height;

		map = [];

		super();

		tilesCount = 0;

	}

	public function empty() {
		
		ArrayTools.clear(map);
		ArrayTools.clear(vertices);
		ArrayTools.clear(indices);

		tilesCount = 0;

	}
	
	public function setTileset(texture:Texture, tileWidth:Int, tileHeight:Int, tileMargin:Int = 0, tileSpacing:Int = 0) {

		tileset = new Tileset('tileset', texture, tileWidth, tileHeight, tileMargin, tileSpacing);
		this.texture = texture; 
		
	}

	public function getTile(x:Int, y:Int):Tile {
		
		return map[getIndex(x, y)];

	}

	public function setTile(x:Int, y:Int, index:Int):Tile {
		
		var idx = getIndex(x, y);

		if(map[idx] != null) {
			removeTileGeometry(map[idx]);
		}

		var tile = new Tile(index, x * tileWidth, y * tileHeight, tileWidth, tileHeight, color);
		map[idx] = tile;

		addTileGeometry(tile);
		updateTileTcoords(tile);

		return tile;
		
	}

	public function setTileColor(x:Int, y:Int, color:Color):Tile {

		var idx = getIndex(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.color = color;
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function setTileFlipX(x:Int, y:Int, flip:Bool):Tile {

		var idx = getIndex(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.flipX = flip;
			updateTileTcoords(tile);
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function setTileFlipY(x:Int, y:Int, flip:Bool):Tile {

		var idx = getIndex(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.flipY = flip;
			updateTileTcoords(tile);
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function setTileRotate(x:Int, y:Int, rotate:Int):Tile {

		var idx = getIndex(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			tile.rotate = rotate;
			updateTileTcoords(tile);
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;

	}

	public function setTileVisible(x:Int, y:Int, visible:Bool):Tile {
		
		var idx = getIndex(x, y);
		var tile = map[idx];

		if(tile != null) {
			if(tile.visible != visible) {
				tile.visible = visible;
				if(visible) {
					addTileGeometry(tile);
				} else {
					removeTileGeometry(tile);
				}
			}
		} else {
			log('can`t get tile at pos {$x, $y}');
		}

		return tile;
		
	}

	public function removeTile(x:Int, y:Int):Tile {
		
		var idx = getIndex(x, y);
		var tile = map[idx];
		
		if(tile != null) {
			removeTileGeometry(tile);
			map[idx] = null;
		} else {
			log('can`t remove tile at pos {$x, $y}');
		}

		return tile;

	}

	public function toMapX(x:Float):Int {

		return Math.floor(x / tileWidth);
		
	}

	public function toMapY(y:Float):Int {

		return Math.floor(y / tileHeight);
		
	}

	inline function getIndex(x:Int, y:Int):Int { // i = x + w * y;  x = i % w; y = i / w;

		return Std.int(x + width * y);

	}

	inline function addTileGeometry(tile:Tile) {

		var offset = vertices.length;

		indices.push(offset);
		indices.push(offset + 1);
		indices.push(offset + 2);
		indices.push(offset + 0);
		indices.push(offset + 2);
		indices.push(offset + 3);

		for (v in tile.vertices) {
			add(v);
		}

		tilesCount++;

	}

	inline function removeTileGeometry(tile:Tile) {

		var found = false;
		for (v in tile.vertices) {
			if(remove(v)) {
				found = true;
			}
		}

		if(found) {
			for (i in 0...6) {
				indices.pop();
			}
			tilesCount--;
		}
		
	}

	function updateTileTcoords(tile:Tile) {

		var tc = tileset.getTileCoords(tile.index);

		if(tc == null) {
			log('can`t get tile texture coords for ${tile.index} index');
			return;
		}

		var flipX = tile.flipX;
		var flipY = tile.flipY;

		var szX = tileset.tileWidth / tileset.texture.widthActual;
		var szY = tileset.tileHeight / tileset.texture.heightActual;

		var tlX = tc.x / tileset.texture.widthActual;
		var tlY = tc.y / tileset.texture.heightActual;
		
		var trX = tlX + szX;
		var trY = tlY;

		var brX = tlX + szX;
		var brY = tlY + szY;

		var blX = tlX;
		var blY = tlY + szY;

		var tmpX = 0.0;
		var tmpY = 0.0;

		if(flipY) {
			tmpY = blY;
			blY = tlY;
			tlY = tmpY;

			tmpY = brY;
			brY = trY;
			trY = tmpY;
		}

		if(flipX) {
			tmpX = trX;
			trX = tlX;
			tlX = tmpX;

			tmpX = brX;
			brX = blX;
			blX = tmpX;
		}

		switch (tile.rotate) {
			case 1:
				tile.vertices[0].tcoord.set(blX, blY);
				tile.vertices[1].tcoord.set(tlX, tlY);
				tile.vertices[2].tcoord.set(trX, trY);
				tile.vertices[3].tcoord.set(brX, brY);
			case 2:
				tile.vertices[0].tcoord.set(brX, brY);
				tile.vertices[1].tcoord.set(blX, blY);
				tile.vertices[2].tcoord.set(tlX, tlY);
				tile.vertices[3].tcoord.set(trX, trY);
			case 3:
				tile.vertices[0].tcoord.set(trX, trY);
				tile.vertices[1].tcoord.set(brX, brY);
				tile.vertices[2].tcoord.set(blX, blY);
				tile.vertices[3].tcoord.set(tlX, tlY);
			case _:
				tile.vertices[0].tcoord.set(tlX, tlY);
				tile.vertices[1].tcoord.set(trX, trY);
				tile.vertices[2].tcoord.set(brX, brY);
				tile.vertices[3].tcoord.set(blX, blY);
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
	public var flipX:Bool;
	public var flipY:Bool;
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
