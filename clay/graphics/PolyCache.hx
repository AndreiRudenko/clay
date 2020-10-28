package clay.graphics;

import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.Polygon;
import clay.graphics.Vertex;
import clay.graphics.VertexBuffer;
import clay.graphics.IndexBuffer;
import clay.math.FastMatrix3;
import clay.math.Matrix;
import clay.utils.Log;
import clay.utils.Math;
import clay.utils.Float32Array;
import clay.utils.Uint32Array;
using clay.utils.ArrayTools;

class PolyCache {

	public var projection:FastMatrix3 = new FastMatrix3();
	public var transform:FastMatrix3 = new FastMatrix3();

	public var opacity(get, set):Float;
	inline function get_opacity() return _opacityStack[_opacityStack.length-1];
	inline function set_opacity(v:Float) return _opacityStack[_opacityStack.length-1] = v;

	public var pipeline:Pipeline;
	public var premultipliedAlpha:Bool = true;

	public var textureFilter:TextureFilter = TextureFilter.PointFilter;
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

	var _pipelineAlpha:Pipeline;
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

	var _invTexWidth:Float = 0;
	var _invTexHeight:Float = 0;

	var _graphics:Graphics;

	public function new(verticesMax:Int = 8192, indicesMax:Int = 16384) {
		_graphics = Clay.graphics;
		_verticesMax = verticesMax;
		_indicesMax = indicesMax;

		_pipelineAlpha = Graphics.pipelineTextured;
		_pipelinePremultAlpha = Graphics.pipelineTexturedPremultAlpha;

		_drawMatrix = new FastMatrix3();

		_opacityStack = [1];
		_caches = [];

		_vertexBuffer = new VertexBuffer(_verticesMax, _pipelineAlpha.inputLayout[0], Usage.StaticUsage);
		_vertices = _vertexBuffer.lock();

		_indexBuffer = new IndexBuffer(_indicesMax, Usage.StaticUsage);
		_indices = _indexBuffer.lock();

		if (Texture.renderTargetsInvertedY) {
			projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}
	}

	public function beginCache(cacheID:Int = -1) {
		Log.assert(!isDrawing, 'PolyCache.end must be called before beginCache');
		Log.assert(_currentCache == null, 'PolyCache.endCache must be called before begin');
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
			Log.assert(_currentCache != null, 'PolyCache.beginCache can`t find cache ${cacheID} to redefine it');

			_currentCache.textures.clear();
			_currentCache.countsI.clear();
			_currentCache.usedV = 0;
			_currentCache.usedI = 0;
			if (cacheID == _caches.length - 1) {
				_currentCache.sizeV = _verticesMax - _currentCache.offsetV;
				_currentCache.sizeI = _indicesMax - _currentCache.offsetI;
			}
		}
	}

	public function endCache():Int {
		Log.assert(!isDrawing, 'PolyCache.end must be called before beginCache');
		Log.assert(_currentCache != null, 'PolyCache.beginCache must be called before endCache');
		if(_currentCache == _caches[_caches.length-1]) {
			_currentCache.sizeV = _currentCache.usedV;
			_currentCache.sizeI = _currentCache.usedI;
		}
		var id = _currentCache.id;
		_currentCache = null;
		return id;
	}

	public function clearCache(cacheID:Int) {
		Log.assert(!isDrawing, 'PolyCache.end must be called before clearCache');
		var cache = _caches[cacheID];
		cache.textures.clear();
		cache.countsI.clear();
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
	}

	public function begin() {
		Log.assert(!isDrawing, 'PolyCache.end must be called before begin');
		Log.assert(_currentCache == null, 'PolyCache.endCache must be called before begin');
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
		Log.assert(isDrawing, 'PolyCache.begin must be called before end');
		isDrawing = false;
		if(_caches.length > 0) {
			_vertices = _vertexBuffer.lock();
			_indices = _indexBuffer.lock();
		}
	}

	public function draw(cacheID:Int) {
		Log.assert(isDrawing, 'PolyCache.begin must be called before draw');
		var cache = _caches[cacheID];
		if(cache.textures.length == 0) {
			Log.warning('Nothing to draw in cache:${cacheID}');
			return;
		}

		var textures = cache.textures;
		var countsI = cache.countsI;
		var offsetI = cache.offsetI;

		var countI:Int;

		var currentPipeline = getPipeline();

		_graphics.setPipeline(currentPipeline);
		currentPipeline.setMatrix3('projectionMatrix', projection);

		var i:Int = 0;
		while(i < textures.length) {
			countI = countsI[i];
			currentPipeline.setTexture('tex', textures[i]);
			currentPipeline.setTextureParameters('tex', textureAddressing, textureAddressing, textureFilter, textureFilter, textureMipFilter);

			_graphics.applyUniforms(currentPipeline);
			_graphics.draw(offsetI, countI);

			offsetI += countI;
			renderCalls++;
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

	public function add(
		polygon:Polygon, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolyCache.beginCache must be called before add');
		if(_currentCache.usedV + polygon.vertices.length >= _currentCache.sizeV || _currentCache.usedI + polygon.indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${polygon.vertices.length} vertices and ${polygon.indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).multiply(transform);
			addPolyInternal(polygon.texture, polygon.vertices, polygon.indices, _drawMatrix, regionX, regionY, regionW, regionH);
		}
	}

	public function addT(
		polygon:Polygon, 
		transform:Matrix,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolyCache.beginCache must be called before add');
		if(_currentCache.usedV + polygon.vertices.length >= _currentCache.sizeV || _currentCache.usedI + polygon.indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${polygon.vertices.length} vertices and ${polygon.indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			_drawMatrix.fromMatrix(transform).multiply(this.transform);
			addPolyInternal(polygon.texture, polygon.vertices, polygon.indices, _drawMatrix, regionX, regionY, regionW, regionH);
		}
	}

	public function addV(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolyCache.beginCache must be called before add');
		if(_currentCache.usedV + vertices.length >= _currentCache.sizeV || _currentCache.usedI + indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${vertices.length} vertices and ${indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).multiply(transform);
			addPolyInternal(texture, vertices, indices, _drawMatrix, regionX, regionY, regionW, regionH);
		}
	}

	public function addVT(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		transform:Matrix,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'PolyCache.beginCache must be called before add');
		if(_currentCache.usedV + vertices.length >= _currentCache.sizeV || _currentCache.usedI + indices.length >= _currentCache.sizeI) {
			Log.warning('cant add polygon with ${vertices.length} vertices and ${indices.length} indices, to cache with (${_currentCache.usedV}/${_currentCache.sizeV}) vertices and (${_currentCache.usedI}/${_currentCache.sizeI}) indices');
		} else {
			_drawMatrix.fromMatrix(transform).multiply(this.transform);
			addPolyInternal(texture, vertices, indices, _drawMatrix, regionX, regionY, regionW, regionH);
		}
	}

	inline function addPolyInternal(texture:Texture, vertices:Array<Vertex>, indices:Array<Int>, transform:FastMatrix3, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		var lastIndex = _currentCache.textures.length - 1;

		if(lastIndex < 0 || texture != _currentCache.textures[lastIndex]) {
			_currentCache.textures.push(texture);
			_currentCache.countsI.push(indices.length);
		} else {
			_currentCache.countsI[lastIndex] = _currentCache.countsI[lastIndex] + indices.length;
		}

		if(regionW == 0 && regionH == 0) {
			regionW = texture.widthActual;
			regionH = texture.heightActual;
		}
		
		var rsx = regionX / texture.widthActual;
		var rsy = regionY / texture.heightActual;
		var rsw = regionW / texture.widthActual;
		var rsh = regionH / texture.heightActual;

		var vertPos = _currentCache.usedV;
		var indPos = _currentCache.usedI;

		var i:Int = 0;
		while(i < indices.length) {
			_indices[indPos++] = vertPos + indices[i++];
		}
		_currentCache.usedI = indPos;


		var vertIdx = vertPos * Graphics.vertexSize;
		var m = transform;
		var opacity = this.opacity;
		var v:Vertex;

		i = 0;
		while(i < vertices.length) {
			v = vertices[i++];

			_vertices[vertIdx++] = m.getTransformX(v.x, v.y);
			_vertices[vertIdx++] = m.getTransformY(v.x, v.y);

			_vertices[vertIdx++] = v.color.r;
			_vertices[vertIdx++] = v.color.g;
			_vertices[vertIdx++] = v.color.b;
			_vertices[vertIdx++] = v.color.a * opacity;

			_vertices[vertIdx++] = v.u * rsw + rsx;
			_vertices[vertIdx++] = v.v * rsh + rsy;

			vertPos++;
		}
		_currentCache.usedV = vertPos;
	}

	inline function getPipeline():Pipeline {
		return pipeline != null ? pipeline : (premultipliedAlpha ? _pipelinePremultAlpha : _pipelineAlpha);		
	}

}

private class Cache {

	public var id:Int;

	public var textures:Array<Texture>;

	public var offsetV:Int;
	public var offsetI:Int;

	public var sizeV:Int;
	public var sizeI:Int;

	public var usedV:Int = 0;
	public var usedI:Int = 0;

	public var countsI:Array<Int>;

	public function new(id:Int, offsetV:Int, sizeV:Int, offsetI:Int, sizeI:Int) {
		this.id = id;
		this.offsetV = offsetV;
		this.sizeV = sizeV;
		this.offsetI = offsetI;
		this.sizeI = sizeI;
		textures = [];
		countsI = [];
	}

}
