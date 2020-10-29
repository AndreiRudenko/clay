package clay.graphics;

import kha.Kravur;
import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.Font;
import clay.graphics.Vertex;
import clay.graphics.VertexBuffer;
import clay.graphics.IndexBuffer;
import clay.math.FastMatrix3;
import clay.math.Matrix;
import clay.utils.FastFloat;
import clay.utils.Log;
import clay.utils.Math;
import clay.utils.Float32Array;

using clay.utils.ArrayTools;

class SpriteCache {

	public var projection:FastMatrix3 = new FastMatrix3();
	public var transform:FastMatrix3 = new FastMatrix3();

	public var color:Color = Color.WHITE;

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
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;

	var _drawMatrix:FastMatrix3;
	var _opacityStack:Array<Float>;

	var _bufferSize:Int = 0;

	var _invTexWidth:Float = 0;
	var _invTexHeight:Float = 0;

	var _graphics:Graphics;

	public function new(size:Int = 4096) {
		_graphics = Clay.graphics;
		_bufferSize = size;

		_pipelineAlpha = Graphics.pipelineTextured;
		_pipelinePremultAlpha = Graphics.pipelineTexturedPremultAlpha;

		_drawMatrix = new FastMatrix3();

		_opacityStack = [1];
		_caches = [];

		_vertexBuffer = new VertexBuffer(_bufferSize * 4, _pipelineAlpha.inputLayout[0], Usage.StaticUsage);
		_vertices = _vertexBuffer.lock();

		_indexBuffer = new IndexBuffer(_bufferSize * 3 * 2, Usage.StaticUsage);
		var indices = _indexBuffer.lock();
		for (i in 0..._bufferSize) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		_indexBuffer.unlock();

		if (Texture.renderTargetsInvertedY) {
			projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}
	}

	public function beginCache(cacheID:Int = -1) {
		Log.assert(!isDrawing, 'SpriteCache.end must be called before beginCache');
		Log.assert(_currentCache == null, 'SpriteCache.endCache must be called before begin');
		if(cacheID < 0) {
			var offset:Int = 0;
			var size:Int = _bufferSize;
			var lastCache = _caches.length > 0 ? _caches[_caches.length-1] : null;
			if(lastCache != null) {
				offset = lastCache.offset + lastCache.size;
				size -= offset;
			}

			if(size > 0) {
				_currentCache = new Cache(_caches.length, offset, size);
				_caches.push(_currentCache);
				cacheCount++;
			} else {
				Log.warning("can't create cache, no buffer space is left");
			}
		} else {
			_currentCache = _caches[cacheID];
			Log.assert(_currentCache != null, 'SpriteCache.beginCache can`t find cache ${cacheID} to redefine it');

			_currentCache.textures.clear();
			_currentCache.counts.clear();
			_currentCache.used = 0;
			if (cacheID == _caches.length - 1) _currentCache.size = _bufferSize - _currentCache.offset;
		}
	}

	public function endCache():Int {
		Log.assert(!isDrawing, 'SpriteCache.end must be called before beginCache');
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before endCache');
		if(_currentCache == _caches[_caches.length-1]) _currentCache.size = _currentCache.used;
		var id = _currentCache.id;
		_currentCache = null;
		return id;
	}

	public function clearCache(cacheID:Int) {
		Log.assert(!isDrawing, 'SpriteCache.end must be called before clearCache');
		var cache = _caches[cacheID];
		cache.textures.clear();
		cache.counts.clear();
		var start = cache.offset;
		var end = start + cache.size;
		while(start < end) {
			_vertices[start++] = 0;
		}
	}

	public function begin() {
		Log.assert(!isDrawing, 'SpriteCache.end must be called before begin');
		Log.assert(_currentCache == null, 'SpriteCache.endCache must be called before begin');
		isDrawing = true;
		renderCalls = 0;
		if(_caches.length > 0) {
			var lastCache = _caches[_caches.length-1];
			_vertexBuffer.unlock((lastCache.offset + lastCache.size) * 4);
			_graphics.setVertexBuffer(_vertexBuffer);
			_graphics.setIndexBuffer(_indexBuffer);
		}
	}

	public function end() {
		Log.assert(isDrawing, 'SpriteCache.begin must be called before end');
		isDrawing = false;
		if(_caches.length > 0) {
			_vertices = _vertexBuffer.lock();
		}
	}

	public function draw(cacheID:Int) {
		Log.assert(isDrawing, 'SpriteCache.begin must be called before draw');
		var cache = _caches[cacheID];
		if(cache.textures.length == 0) {
			Log.warning('Nothing to draw in cache:${cacheID}');
			return;
		}

		var textures = cache.textures;
		var counts = cache.counts;
		var offset = cache.offset;

		var count:Int;

		var currentPipeline = getPipeline();

		_graphics.setPipeline(currentPipeline);
		currentPipeline.setMatrix3('projectionMatrix', projection);

		var i:Int = 0;
		while(i < textures.length) {
			count = counts[i];
			currentPipeline.setTexture('tex', textures[i]);
			currentPipeline.setTextureParameters('tex', textureAddressing, textureAddressing, textureFilter, textureFilter, textureMipFilter);

			_graphics.applyUniforms(currentPipeline);
			_graphics.draw(offset * 6, count * 6);

			offset += count;
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
		texture:Texture, 
		x:Float = 0, y:Float = 0, 
		width:Float = 0, height:Float = 0, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used + 1 >= _currentCache.size) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			_drawMatrix.setTransform(x, y, angle, 1, 1, originX, originY, skewX, skewY).append(transform);
			addInternal(texture, _drawMatrix, width, height, regionX, regionY, regionW, regionH);
		}
	}

	public function addT(
		texture:Texture, 
		transform:Matrix,
		width:Float = 0, height:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used + 1 >= _currentCache.size) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			_drawMatrix.fromMatrix(transform).append(this.transform);
			addInternal(texture, _drawMatrix, width, height, regionX, regionY, regionW, regionH);
		}
	}

	public function addV(
		texture:Texture,
		vertices:Array<Vertex>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 0, scaleY:Float = 0, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used * 4 + vertices.length >= _currentCache.size * 4) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).append(transform);
			addVerticesInternal(texture, vertices, _drawMatrix, regionX, regionY, regionW, regionH);
		}
	}

	public function addVT(
		texture:Texture,
		vertices:Array<Vertex>, 
		transform:Matrix,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used * 4 + vertices.length >= _currentCache.size * 4) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			_drawMatrix.fromMatrix(transform).append(this.transform);
			addVerticesInternal(texture, vertices, _drawMatrix, regionX, regionY, regionW, regionH);
		}
	}

	inline function addInternal(texture:Texture, transform:FastMatrix3, width:Float, height:Float, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		var lastIndex = _currentCache.textures.length - 1;

		if(lastIndex < 0 || texture != _currentCache.textures[lastIndex]) {
			_currentCache.textures.push(texture);
			_currentCache.counts.push(1);
		} else {
			_currentCache.counts[lastIndex] = _currentCache.counts[lastIndex] + 1;
		}

		if(width == 0 && height == 0) {
			width = texture.widthActual;
			height = texture.heightActual;
		}

		if(regionW == 0 && regionH == 0) {
			regionW = texture.widthActual;
			regionH = texture.heightActual;
		}

		var left = regionX / texture.widthActual;
		var top = regionY / texture.heightActual;
		var right = (regionX + regionW) / texture.widthActual;
		var bottom = (regionY + regionH) / texture.heightActual;

		var m = transform;

		addVertices(
			m.getTransformX(0, 0), m.getTransformY(0, 0), color, left, top,
			m.getTransformX(width, 0), m.getTransformY(width, 0), color, right, top,
			m.getTransformX(width, height), m.getTransformY(width, height), color, right, bottom,
			m.getTransformX(0, height), m.getTransformY(0, height), color, left, bottom
		);

		_currentCache.used++;
	}

	inline function addVerticesInternal(texture:Texture, vertices:Array<Vertex>, transform:FastMatrix3, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		var lastIndex = _currentCache.textures.length - 1;

		if(lastIndex < 0 || texture != _currentCache.textures[lastIndex]) {
			_currentCache.textures.push(texture);
			_currentCache.counts.push(1);
		} else {
			_currentCache.counts[lastIndex] = _currentCache.counts[lastIndex] + 1;
		}

		if(regionW == 0 && regionH == 0) {
			regionW = texture.widthActual;
			regionH = texture.heightActual;
		}

		var m = transform;

		var v1:Vertex;
		var v2:Vertex;
		var v3:Vertex;
		var v4:Vertex;

		var i:Int = 0;

		while(i < vertices.length) {
			v1 = vertices[i++];
			v2 = vertices[i++];
			v3 = vertices[i++];
			v4 = vertices[i++];

			addVertices(
				m.getTransformX(v1.x, v1.y), m.getTransformY(v1.x, v1.y), v1.color, v1.u, v1.v,
				m.getTransformX(v2.x, v2.y), m.getTransformY(v2.x, v2.y), v2.color, v2.u, v2.v,
				m.getTransformX(v3.x, v3.y), m.getTransformY(v3.x, v3.y), v3.color, v3.u, v3.v,
				m.getTransformX(v4.x, v4.y), m.getTransformY(v4.x, v4.y), v4.color, v4.u, v4.v
			);

			_currentCache.used++;
		}
	}

	inline function getPipeline():Pipeline {
		return pipeline != null ? pipeline : (premultipliedAlpha ? _pipelinePremultAlpha : _pipelineAlpha);		
	}

	inline function addVertices(
		v1x:FastFloat, v1y:FastFloat, v1c:Color, v1u:FastFloat, v1v:FastFloat,
		v2x:FastFloat, v2y:FastFloat, v2c:Color, v2u:FastFloat, v2v:FastFloat,
		v3x:FastFloat, v3y:FastFloat, v3c:Color, v3u:FastFloat, v3v:FastFloat,
		v4x:FastFloat, v4y:FastFloat, v4c:Color, v4u:FastFloat, v4v:FastFloat
	) {
		var idx = (_currentCache.offset + _currentCache.used) * Graphics.vertexSize * 4;
		var opacity = this.opacity;

		_vertices[idx+0] = v1x;
		_vertices[idx+1] = v1y;

		_vertices[idx+2] = v1c.r;
		_vertices[idx+3] = v1c.g;
		_vertices[idx+4] = v1c.b;
		_vertices[idx+5] = v1c.a * opacity;

		_vertices[idx+6] = v1u;
		_vertices[idx+7] = v1v;

		_vertices[idx+8] = v2x;
		_vertices[idx+9] = v2y;

		_vertices[idx+10] = v2c.r;
		_vertices[idx+11] = v2c.g;
		_vertices[idx+12] = v2c.b;
		_vertices[idx+13] = v2c.a * opacity;

		_vertices[idx+14] = v2u;
		_vertices[idx+15] = v2v;

		_vertices[idx+16] = v3x;
		_vertices[idx+17] = v3y;

		_vertices[idx+18] = v3c.r;
		_vertices[idx+19] = v3c.g;
		_vertices[idx+20] = v3c.b;
		_vertices[idx+21] = v3c.a * opacity;

		_vertices[idx+22] = v3u;
		_vertices[idx+23] = v3v;

		_vertices[idx+24] = v4x;
		_vertices[idx+25] = v4y;	

		_vertices[idx+26] = v4c.r;
		_vertices[idx+27] = v4c.g;
		_vertices[idx+28] = v4c.b;
		_vertices[idx+29] = v4c.a * opacity;

		_vertices[idx+30] = v4u;
		_vertices[idx+31] = v4v;
	}

}

private class Cache {

	public var id:Int;
	public var offset:Int;
	public var size:Int;
	public var used:Int = 0;
	public var textures:Array<Texture>;
	public var counts:Array<Int>;

	public function new(id:Int, offset:Int, size:Int) {
		this.id = id;
		this.offset = offset;
		this.size = size;
		textures = [];
		counts = [];
	}

}
