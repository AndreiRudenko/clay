package clay.graphics.batchers;

import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.Polygon;
import clay.graphics.Vertex;
import clay.graphics.render.VertexBuffer;
import clay.graphics.render.IndexBuffer;
import clay.graphics.render.Pipeline;
import clay.math.FastMatrix3;
import clay.math.Matrix;
import clay.utils.Log;
import clay.utils.Math;
import clay.utils.Float32Array;
import clay.utils.Uint32Array;
import clay.utils.SparseSet;
using clay.utils.ArrayTools;

class PolygonCache {

	public var projection(get, set):FastMatrix3;
	final _projection:FastMatrix3 = new FastMatrix3();
	inline function get_projection() return _projection;
	function set_projection(v:FastMatrix3) {
		_projection.copyFrom(v);
		return v;
	}

	public var transform(get, set):FastMatrix3;
	final _transform:FastMatrix3 = new FastMatrix3();
	inline function get_transform() return _transform;
	function set_transform(v:FastMatrix3) {
		_transform.copyFrom(v);
		return v;
	}

	public final combined:FastMatrix3 = new FastMatrix3();

	public var opacity(get, set):Float;
	inline function get_opacity() return _opacityStack[_opacityStack.length-1];
	inline function set_opacity(v:Float) return _opacityStack[_opacityStack.length-1] = v;

	public var pipeline:Pipeline;

	public var textureFilter:TextureFilter = TextureFilter.LinearFilter;
	public var textureMipFilter:MipMapFilter = MipMapFilter.NoMipFilter;
	public var textureAddressing:TextureAddressing = TextureAddressing.Clamp;

	/** true if currently between begin and end. */
	public var isDrawing(default, null):Bool = false;

	/** Number of render calls since the last {@link #begin()}. **/
	public var renderCalls(default, null):Int = 0;

	/** Number of rendering calls, ever. Will not be reset unless set manually. **/
	public var renderCallsTotal:Int = 0;

	/** The maximum number of sprites rendered in one batch so far. **/
	public var maxSpritesInBatch:Int = 0;

	public var cacheCount(default, null):Int = 0;

	var _pipelineDefault:Pipeline;
	var _pipelinePremultAlpha:Pipeline;
	var _caches:Array<Cache>;
	var _currentCache:Cache;

	var _vertices:Float32Array;
	var _indices:Uint32Array;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;

	var _drawMatrix:FastMatrix3;
	var _opacityStack:Array<Float>;

	var _verticesMax:Int = 0;
	var _indicesMax:Int = 0;

	var _textureIds:SparseSet;

	var _graphics:Graphics;

	public function new(verticesMax:Int = 8192, indicesMax:Int = 16384) {
		_graphics = Clay.graphics;
		_verticesMax = verticesMax;
		_indicesMax = indicesMax;

		_pipelineDefault = Graphics.pipelineMultiTextured;

		_drawMatrix = new FastMatrix3();

		_opacityStack = [1];
		_caches = [];

		_vertexBuffer = new VertexBuffer(_verticesMax, _pipelineDefault.inputLayout[0], Usage.StaticUsage);
		_vertices = _vertexBuffer.lock();

		_indexBuffer = new IndexBuffer(_indicesMax, Usage.StaticUsage);
		_indices = _indexBuffer.lock();

		if (Texture.renderTargetsInvertedY) {
			projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}
		_textureIds = new SparseSet(Texture.maxTextures);
	}

	public function dispose() {
		_vertexBuffer.delete();
		_indexBuffer.delete();
	}
	
	public function beginCache(cacheID:Int = -1) {
		Log.assert(!isDrawing, 'PolygonCache.end must be called before beginCache');
		Log.assert(_currentCache == null, 'PolygonCache.endCache must be called before begin');
		if(cacheID < 0) {
			var offsetV:Int = 0;
			var offsetI:Int = 0;
			var sizeV:Int = _verticesMax;
			var sizeI:Int = _indicesMax;
			var lastCache = _caches.length > 0 ? _caches[_caches.length-1] : null;
			if(lastCache != null) {
				offsetV = lastCache.offsetV + lastCache.sizeV;
				offsetI = lastCache.offsetI + lastCache.sizeI;
				sizeV -= offsetV;
				sizeI -= offsetI;
			}

			if(sizeV > 0 && sizeI > 0) {
				_currentCache = new Cache(_caches.length, offsetV, sizeV, offsetI, sizeI);
				_caches.push(_currentCache);
				cacheCount++;
			} else {
				Log.warning("can't create cache, no buffer space is left");
			}
		} else {
			_currentCache = _caches[cacheID];
			Log.assert(_currentCache != null, 'PolygonCache.beginCache can`t find cache ${cacheID} to redefine it');

			_currentCache.reset();
			if (cacheID == _caches.length - 1) {
				_currentCache.sizeV = _verticesMax - _currentCache.offsetV;
				_currentCache.sizeI = _indicesMax - _currentCache.offsetI;
			}
		}
	}

	public function endCache():Int {
		Log.assert(!isDrawing, 'PolygonCache.end must be called before beginCache');
		Log.assert(_currentCache != null, 'PolygonCache.beginCache must be called before endCache');
		if(_currentCache == _caches[_caches.length-1]) {
			_currentCache.sizeV = _currentCache.usedV;
			_currentCache.sizeI = _currentCache.usedI;
		}
		var id = _currentCache.id;
		_currentCache = null;
		_textureIds.clear();
		return id;
	}

	public function clearCache(cacheID:Int) {
		Log.assert(!isDrawing, 'PolygonCache.end must be called before clearCache');
		var cache = _caches[cacheID];
		var start = cache.offsetV;
		var end = start + cache.sizeV;
		while(start < end) {
			_vertices[start++] = 0;
		}
		start = cache.offsetI;
		end = start + cache.sizeI;
		while(start < end) {
			_indices[start++] = 0;
		}
		cache.reset();
	}

	public function begin() {
		Log.assert(!isDrawing, 'PolygonCache.end must be called before begin');
		Log.assert(_currentCache == null, 'PolygonCache.endCache must be called before begin');
		isDrawing = true;
		renderCalls = 0;
		if(_caches.length > 0) {
			var lastCache = _caches[_caches.length-1];
			_vertexBuffer.unlock(lastCache.offsetV + lastCache.sizeV);
			_indexBuffer.unlock(lastCache.offsetI + lastCache.sizeI);
			_graphics.setVertexBuffer(_vertexBuffer);
			_graphics.setIndexBuffer(_indexBuffer);
		}
	}

	public function end() {
		Log.assert(isDrawing, 'PolygonCache.begin must be called before end');
		isDrawing = false;
		if(_caches.length > 0) {
			_vertices = _vertexBuffer.lock();
			_indices = _indexBuffer.lock();
		}
	}

	public function draw(cacheID:Int) {
		Log.assert(isDrawing, 'PolygonCache.begin must be called before draw');

		final commands = _caches[cacheID].commands;
		final currentPipeline = pipeline != null ? pipeline : _pipelineDefault;

		_graphics.setPipeline(currentPipeline);
		combined.copyFrom(_projection).append(_transform);
		currentPipeline.setMatrix3('projectionMatrix', combined);

		var cmd:DrawCommand;
		var i:Int = 0;
		var tIdx:Int = 0;
		while(i < commands.length) {
			cmd = commands[i];
			if(cmd.texturesUsed > 0) {
				tIdx = 0;
				while(tIdx < cmd.texturesUsed) {
					currentPipeline.setTexture('tex[$tIdx]', cmd.textures[tIdx]);
					currentPipeline.setTextureParameters('tex[$tIdx]', textureAddressing, textureAddressing, textureFilter, textureFilter, textureMipFilter);
					tIdx++;
				}
				_graphics.applyUniforms(currentPipeline);
				_graphics.draw(cmd.offset, cmd.count);
				renderCalls++;
			} else {
				Log.warning('Nothing to draw in cache:${cacheID}, with command: ${i}');
			}
			i++;
		}
	}

	public function clear() {
		_caches.clear();
		cacheCount = 0;
	}

	public function pushOpacity(opacity:Float) {
		_opacityStack.push(opacity);
	}

	public function popOpacity() {
		if(_opacityStack.length > 1) {
			_opacityStack.pop();
		} else {
			Log.warning('pop opacity with no opacity left in stack');
		}
	}

	public function addPolygon(
		polygon:Polygon, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolygonCache.beginCache must be called before add');
		if(_currentCache.usedV + polygon.vertices.length >= _currentCache.sizeV || _currentCache.usedI + polygon.indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${polygon.vertices.length} vertices and ${polygon.indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			if(scaleX == 0 || scaleY == 0) return;
			_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
			addPolygonInternal(
				polygon.texture, polygon.vertices, polygon.indices, 
				_drawMatrix, 
				regionX, regionY, regionW, regionH,
				offsetVerts, countVerts, offsetInds, countInds
			);
		}
	}

	public function addPolygonTransform(
		polygon:Polygon, 
		transform:FastMatrix3,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolygonCache.beginCache must be called before add');
		if(_currentCache.usedV + polygon.vertices.length >= _currentCache.sizeV || _currentCache.usedI + polygon.indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${polygon.vertices.length} vertices and ${polygon.indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			addPolygonInternal(
				polygon.texture, polygon.vertices, polygon.indices, 
				transform, 
				regionX, regionY, regionW, regionH,
				offsetVerts, countVerts, offsetInds, countInds
			);
		}
	}

	public function addVertices(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolygonCache.beginCache must be called before add');
		if(_currentCache.usedV + vertices.length >= _currentCache.sizeV || _currentCache.usedI + indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${vertices.length} vertices and ${indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			if(scaleX == 0 || scaleY == 0) return;
			_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
			addPolygonInternal(
				texture, vertices, indices, 
				_drawMatrix, 
				regionX, regionY, regionW, regionH,
				offsetVerts, countVerts, offsetInds, countInds
			);
		}
	}

	public function addVerticesTransform(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		transform:FastMatrix3,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolygonCache.beginCache must be called before add');
		if(_currentCache.usedV + vertices.length >= _currentCache.sizeV || _currentCache.usedI + indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${vertices.length} vertices and ${indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			addPolygonInternal(
				texture, vertices, indices, 
				transform, 
				regionX, regionY, regionW, regionH,
				offsetVerts, countVerts, offsetInds, countInds
			);
		}
	}

	#if !clay_debug inline #end
	function addPolygonInternal(
		texture:Texture, vertices:Array<Vertex>, indices:Array<Int>, 
		transform:FastMatrix3, 
		regionX:Int, regionY:Int, ?regionW:Int, ?regionH:Int,
		offsetVerts:Int, countVerts:Int, offsetInds:Int, countInds:Int
	) {
		if(texture == null) texture = Graphics.textureDefault;

		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;
		
		var lastCommand = _currentCache.getLastCommand();
		var lastTextureIndex = lastCommand.texturesUsed-1;

		if(lastTextureIndex < 0 || texture != lastCommand.textures[lastTextureIndex]) {
			if(lastCommand.texturesUsed >= Graphics.maxShaderTextures) {
				final cmd = new DrawCommand();
				cmd.offset = lastCommand.offset + lastCommand.count;
				lastCommand = cmd;
				_currentCache.commands.push(cmd);
				_textureIds.clear();
			}

			if(!_textureIds.has(texture.id)) {
				lastCommand.textures[lastCommand.texturesUsed] = texture;
				lastCommand.texturesUsed++;
				_textureIds.insert(texture.id);
			}
		}
		
		var rsx = regionX / texture.widthActual;
		var rsy = regionY / texture.heightActual;
		var rsw = regionW / texture.widthActual;
		var rsh = regionH / texture.heightActual;

		// get last vertex and index idx
		countVerts = countVerts <= 0 ? vertices.length : countVerts + offsetVerts;
		countInds = countInds <= 0 ? indices.length : countInds + offsetInds;

		var vertPos = _currentCache.usedV;
		var indPos = _currentCache.usedI;
		// var indPos = lastCommand.offset + lastCommand.count;

		while(offsetInds < countInds) {
			_indices[indPos++] = vertPos + indices[offsetInds++];
		}
		
		_currentCache.usedI = indPos;
		lastCommand.count += countInds - offsetInds;

		final m = transform;
		final texId = _textureIds.getSparse(texture.id);
		final opacity = this.opacity;
		final texFormat = texture.format;
		var vertIdx = vertPos * Graphics.vertexSizeMultiTextured;
		var v:Vertex;

		while(offsetVerts < countVerts) {
			v = vertices[offsetVerts++];

			_vertices[vertIdx++] = m.getTransformX(v.x, v.y);
			_vertices[vertIdx++] = m.getTransformY(v.x, v.y);

			_vertices[vertIdx++] = v.color.r;
			_vertices[vertIdx++] = v.color.g;
			_vertices[vertIdx++] = v.color.b;
			_vertices[vertIdx++] = v.color.a * opacity;

			_vertices[vertIdx++] = v.u * rsw + rsx;
			_vertices[vertIdx++] = v.v * rsh + rsy;

			_vertices[vertIdx++] = texId;
			_vertices[vertIdx++] = texFormat;

			vertPos++;
		}
		_currentCache.usedV = vertPos;
	}

}

private class Cache {

	public var id:Int;

	public var commands:Array<DrawCommand>;

	public var offsetV:Int;
	public var offsetI:Int;

	public var sizeV:Int;
	public var sizeI:Int;

	public var usedV:Int = 0;
	public var usedI:Int = 0;

	public function new(id:Int, offsetV:Int, sizeV:Int, offsetI:Int, sizeI:Int) {
		commands = [];
		this.id = id;
		this.offsetV = offsetV;
		this.sizeV = sizeV;
		this.offsetI = offsetI;
		this.sizeI = sizeI;

		var cmd = new DrawCommand();
		cmd.offset = offsetI;
		commands.push(cmd);
	}

	public function reset() {
		while(commands.length > 1) {
			commands.pop();
		}

		final cmd = commands[0];
		cmd.clear();
		cmd.offset = offsetI;

		usedV = 0;
		usedI = 0;
	}

	public inline function getLastCommand():DrawCommand {
		return commands[commands.length-1];
	}

}

private class DrawCommand {

	public var textures:haxe.ds.Vector<Texture>;
	public var texturesUsed:Int = 0;
	public var offset:Int = 0;
	public var count:Int = 0;

	public function new() {
		textures = new haxe.ds.Vector(Graphics.maxShaderTextures);
	}

	public function clear() {
		while(texturesUsed > 0) {
			texturesUsed--;
			textures[texturesUsed] = null;
		}
		offset = 0;
		count = 0;
	}

}
