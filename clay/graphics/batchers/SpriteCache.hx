package clay.graphics.batchers;

import kha.Kravur;
import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.Font;
import clay.graphics.Vertex;
import clay.graphics.render.VertexBuffer;
import clay.graphics.render.IndexBuffer;
import clay.graphics.render.Pipeline;
import clay.math.FastMatrix3;
import clay.math.Matrix;
import clay.utils.FastFloat;
import clay.utils.Log;
import clay.utils.Math;
import clay.utils.Float32Array;
import clay.utils.SparseSet;
using clay.utils.ArrayTools;

class SpriteCache {

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

	public var color:Color = Color.WHITE;

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
	var _caches:Array<Cache>;
	var _currentCache:Cache;

	var _vertices:Float32Array;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;

	var _drawMatrix:FastMatrix3;
	var _opacityStack:Array<Float>;

	var _bufferSize:Int = 0;

	var _textureIds:SparseSet;

	var _graphics:Graphics;

	public function new(size:Int = 4096) {
		_graphics = Clay.graphics;
		_bufferSize = size;

		_pipelineDefault = Graphics.pipelineMultiTextured;

		_drawMatrix = new FastMatrix3();

		_opacityStack = [1];
		_caches = [];

		_vertexBuffer = new VertexBuffer(_bufferSize * 4, _pipelineDefault.inputLayout[0], Usage.StaticUsage);
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
		_textureIds = new SparseSet(Texture.maxTextures);
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

			_currentCache.reset();
			if (cacheID == _caches.length - 1) _currentCache.size = _bufferSize - _currentCache.offset;
		}
	}

	public function endCache():Int {
		Log.assert(!isDrawing, 'SpriteCache.end must be called before beginCache');
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before endCache');
		if(_currentCache == _caches[_caches.length-1]) _currentCache.size = _currentCache.used;
		var id = _currentCache.id;
		_currentCache = null;
		_textureIds.clear();
		return id;
	}

	public function clearCache(cacheID:Int) {
		Log.assert(!isDrawing, 'SpriteCache.end must be called before clearCache');
		var cache = _caches[cacheID];
		var start = cache.offset;
		var end = start + cache.size;
		while(start < end) {
			_vertices[start++] = 0;
		}
		cache.reset();
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
		Log.assert(isDrawing, 'PolyCache.begin must be called before draw');

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

	public function addImage(
		texture:Texture, 
		x:Float = 0, y:Float = 0, 
		width:Float = 0, height:Float = 0, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used + 1 >= _currentCache.size) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			if(width == 0 || height == 0) return;
			_drawMatrix.setTransform(x, y, angle, 1, 1, originX, originY, skewX, skewY);
			addInternal(texture, _drawMatrix, width, height, regionX, regionY, regionW, regionH);
		}
	}

	public function addImageTransform(
		texture:Texture, 
		transform:FastMatrix3,
		width:Float = 0, height:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used + 1 >= _currentCache.size) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			if(width == 0 || height == 0) return;
			addInternal(texture, transform, width, height, regionX, regionY, regionW, regionH);
		}
	}

	public function addImageVertices(
		texture:Texture,
		vertices:Array<Vertex>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 0, scaleY:Float = 0, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetImg:Int = 0, countImg:Int = 0
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used * 4 + vertices.length >= _currentCache.size * 4) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			if(scaleX == 0 || scaleY == 0) return;
			_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
			addVerticesInternal(texture, vertices, _drawMatrix, regionX, regionY, regionW, regionH, offsetImg, countImg);
		}
	}

	public function addImageVerticesTransform(
		texture:Texture,
		vertices:Array<Vertex>, 
		transform:FastMatrix3,
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetImg:Int = 0, countImg:Int = 0
	) {
		Log.assert(_currentCache != null, 'SpriteCache.beginCache must be called before add');
		if(_currentCache.used * 4 + vertices.length >= _currentCache.size * 4) {
			Log.warning('cant add more than currentCache.size: ${_currentCache.size} sprites');
		} else {
			addVerticesInternal(texture, vertices, transform, regionX, regionY, regionW, regionH, offsetImg, countImg);
		}
	}

	#if !clay_debug inline #end
	function addInternal(
		texture:Texture, 
		transform:FastMatrix3, 
		?width:Float, ?height:Float, 
		regionX:Int, regionY:Int, ?regionW:Int, ?regionH:Int
	) {
		if(texture == null) texture = Graphics.textureDefault;

		if(width == null) width = texture.widthActual;
		if(height == null) height = texture.heightActual;

		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;

		var lastCommand = _currentCache.getLastCommand();
		final lastTextureIndex = lastCommand.texturesUsed-1;

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

		final left = regionX / texture.widthActual;
		final top = regionY / texture.heightActual;
		final right = (regionX + regionW) / texture.widthActual;
		final bottom = (regionY + regionH) / texture.heightActual;

		final m = transform;
		final texId = _textureIds.getSparse(texture.id);
		final texFormat = texture.format;

		addVerticesToBuffer(
			texId,
			texFormat,
			m.getTransformX(0, 0), m.getTransformY(0, 0), color, left, top,
			m.getTransformX(width, 0), m.getTransformY(width, 0), color, right, top,
			m.getTransformX(width, height), m.getTransformY(width, height), color, right, bottom,
			m.getTransformX(0, height), m.getTransformY(0, height), color, left, bottom
		);

		_currentCache.used++;
		lastCommand.count += 6;
	}

	#if !clay_debug inline #end
	function addVerticesInternal(
		texture:Texture, 
		vertices:Array<Vertex>, 
		transform:FastMatrix3, 
		regionX:Int, regionY:Int, ?regionW:Int, ?regionH:Int, 
		offsetImg:Int, ?countImg:Int
	) {
		Log.assert(vertices.length % 4 == 0, 'SpriteCache.addImageVertices with non 4 vertices per image: (${vertices.length})');

		if(texture == null) texture = Graphics.textureDefault;

		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;

		if(countImg == null) countImg = Math.floor(vertices.length / 4);

		var lastCommand = _currentCache.getLastCommand();
		final lastTextureIndex = lastCommand.texturesUsed-1;

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

		final rsx = regionX / texture.widthActual;
		final rsy = regionY / texture.heightActual;
		final rsw = regionW / texture.widthActual;
		final rsh = regionH / texture.heightActual;

		final m = transform;
		final texId = _textureIds.getSparse(texture.id);
		final texFormat = texture.format;

		var start:Int = offsetImg * 4;
		var end:Int = (offsetImg + countImg) * 4;

		var v1:Vertex;
		var v2:Vertex;
		var v3:Vertex;
		var v4:Vertex;

		while(start < end) {
			v1 = vertices[start++];
			v2 = vertices[start++];
			v3 = vertices[start++];
			v4 = vertices[start++];

			addVerticesToBuffer(
				texId,
				texFormat,
				m.getTransformX(v1.x, v1.y), m.getTransformY(v1.x, v1.y), v1.color, v1.u * rsw + rsx, v1.v * rsh + rsy,
				m.getTransformX(v2.x, v2.y), m.getTransformY(v2.x, v2.y), v2.color, v2.u * rsw + rsx, v2.v * rsh + rsy,
				m.getTransformX(v3.x, v3.y), m.getTransformY(v3.x, v3.y), v3.color, v3.u * rsw + rsx, v3.v * rsh + rsy,
				m.getTransformX(v4.x, v4.y), m.getTransformY(v4.x, v4.y), v4.color, v4.u * rsw + rsx, v4.v * rsh + rsy
			);

			_currentCache.used++;
			lastCommand.count += 6;
		}
	}

	inline function addVerticesToBuffer(
		texId:Int, texFormat:Int,
		v1x:FastFloat, v1y:FastFloat, v1c:Color, v1u:FastFloat, v1v:FastFloat,
		v2x:FastFloat, v2y:FastFloat, v2c:Color, v2u:FastFloat, v2v:FastFloat,
		v3x:FastFloat, v3y:FastFloat, v3c:Color, v3u:FastFloat, v3v:FastFloat,
		v4x:FastFloat, v4y:FastFloat, v4c:Color, v4u:FastFloat, v4v:FastFloat
	) {
		var i = (_currentCache.offset + _currentCache.used) * Graphics.vertexSizeMultiTextured * 4;
		final opacity = this.opacity;

		_vertices[i++] = v1x;
		_vertices[i++] = v1y;

		_vertices[i++] = v1c.r;
		_vertices[i++] = v1c.g;
		_vertices[i++] = v1c.b;
		_vertices[i++] = v1c.a * opacity;

		_vertices[i++] = v1u;
		_vertices[i++] = v1v;

		_vertices[i++] = texId;
		_vertices[i++] = texFormat;

		_vertices[i++] = v2x;
		_vertices[i++] = v2y;

		_vertices[i++] = v2c.r;
		_vertices[i++] = v2c.g;
		_vertices[i++] = v2c.b;
		_vertices[i++] = v2c.a * opacity;

		_vertices[i++] = v2u;
		_vertices[i++] = v2v;

		_vertices[i++] = texId;
		_vertices[i++] = texFormat;

		_vertices[i++] = v3x;
		_vertices[i++] = v3y;

		_vertices[i++] = v3c.r;
		_vertices[i++] = v3c.g;
		_vertices[i++] = v3c.b;
		_vertices[i++] = v3c.a * opacity;

		_vertices[i++] = v3u;
		_vertices[i++] = v3v;

		_vertices[i++] = texId;
		_vertices[i++] = texFormat;

		_vertices[i++] = v4x;
		_vertices[i++] = v4y;	

		_vertices[i++] = v4c.r;
		_vertices[i++] = v4c.g;
		_vertices[i++] = v4c.b;
		_vertices[i++] = v4c.a * opacity;

		_vertices[i++] = v4u;
		_vertices[i++] = v4v;

		_vertices[i++] = texId;
		_vertices[i++] = texFormat;

	}

}

private class Cache {

	public var id:Int;

	public var commands:Array<DrawCommand>;

	public var offset:Int;
	public var size:Int;
	public var used:Int = 0;

	public function new(id:Int, offset:Int, size:Int) {
		commands = [];
		this.id = id;
		this.offset = offset;
		this.size = size;

		var cmd = new DrawCommand();
		cmd.offset = offset * 6;
		commands.push(cmd);
	}

	public function reset() {
		while(commands.length > 1) {
			commands.pop();
		}

		final cmd = commands[0];
		cmd.clear();
		cmd.offset = offset * 6;

		used = 0;
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
