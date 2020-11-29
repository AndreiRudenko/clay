package clay.graphics.batchers;

import kha.Kravur;
import clay.Clay;
import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.Font;
import clay.graphics.Vertex;
import clay.graphics.render.VertexBuffer;
import clay.graphics.render.IndexBuffer;
import clay.graphics.render.Pipeline;
import clay.graphics.render.VertexStructure;
import clay.graphics.render.Shaders;
import clay.math.FastMatrix3;
import clay.math.Matrix;
import clay.utils.FastFloat;
import clay.utils.Log;
import clay.utils.Math;
import clay.utils.Float32Array;
import clay.utils.SparseSet;
using StringTools;

class SpriteBatch {

	public var projection(get, set):FastMatrix3;
	final _projection:FastMatrix3 = new FastMatrix3();
	inline function get_projection() return _projection;
	function set_projection(v:FastMatrix3) {
		if(isDrawing) flush();
		_projection.copyFrom(v);
		if(isDrawing) setupMatrices();
		return v;
	}

	public var transform(get, set):FastMatrix3;
	final _transform:FastMatrix3 = new FastMatrix3();
	inline function get_transform() return _transform;
	function set_transform(v:FastMatrix3) {
		if(isDrawing) flush();
		_transform.copyFrom(v);
		if(isDrawing) setupMatrices();
		return v;
	}
	
	public final combined:FastMatrix3 = new FastMatrix3();

	public var color:Color = Color.WHITE;

	public var opacity(get, set):Float;
	inline function get_opacity() return _opacityStack[_opacityStack.length-1];
	inline function set_opacity(v:Float) return _opacityStack[_opacityStack.length-1] = v;

	public var pipeline(get, set):Pipeline;
	var _pipeline:Pipeline;
	inline function get_pipeline() return _pipeline;
	function set_pipeline(v:Pipeline) {
		if(isDrawing) flush();
		return _pipeline = v;
	}

	public var textureFilter(get, set):TextureFilter;
	var _textureFilter:TextureFilter = TextureFilter.LinearFilter;
	inline function get_textureFilter() return _textureFilter; 
	function set_textureFilter(v:TextureFilter) {
		if(isDrawing) flush();
		return _textureFilter = v;
	}

	public var textureMipFilter(get, set):MipMapFilter;
	var _textureMipFilter:MipMapFilter = MipMapFilter.NoMipFilter;
	inline function get_textureMipFilter() return _textureMipFilter; 
	function set_textureMipFilter(v:MipMapFilter) {
		if(isDrawing) flush();
		return _textureMipFilter = v;
	}

	public var textureAddressing(get, set):TextureAddressing;
	var _textureAddressing:TextureAddressing = TextureAddressing.Clamp;
	inline function get_textureAddressing() return _textureAddressing; 
	function set_textureAddressing(v:TextureAddressing) {
		if(isDrawing) flush();
		return _textureAddressing = v;
	}

	/** true if currently between begin and end. */
	public var isDrawing(default, null):Bool = false;

	/** Number of render calls since the last {@link #begin()}. **/
	public var renderCalls(default, null):Int = 0;

	/** Number of rendering calls, ever. Will not be reset unless set manually. **/
	public var renderCallsTotal:Int = 0;

	/** The maximum number of sprites rendered in one batch so far. **/
	public var maxSpritesInBatch:Int = 0;

	var _pipelineDefault:Pipeline;

	var _textureIds:SparseSet;

	var _currentPipeline:Pipeline;
	var _vertices:Float32Array;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;

	var _drawMatrix:FastMatrix3;
	var _bakedQuadCache:AlignedQuad;
	var _opacityStack:Array<Float>;

	var _bufferIdx:Int = 0;
	var _bufferSize:Int = 0;

	var _graphics:Graphics;

	public function new(size:Int = 1024) {
		_graphics = Clay.graphics;
		_bufferSize = size;

		_pipelineDefault = Graphics.pipelineMultiTextured;

		_currentPipeline = _pipelineDefault;

		_drawMatrix = new FastMatrix3();
		_bakedQuadCache = new AlignedQuad();

		_opacityStack = [1];

		_vertexBuffer = new VertexBuffer(_bufferSize * 4, _pipelineDefault.inputLayout[0], Usage.DynamicUsage);
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
			_projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			_projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}

		_textureIds = new SparseSet(Texture.maxTextures);
	}

	public function begin() {
		Log.assert(!isDrawing, 'SpriteBatch.end must be called before begin');
		isDrawing = true;
		renderCalls = 0;
		_graphics.setIndexBuffer(_indexBuffer);
		setupMatrices();
	}

	public function end() {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before end');
		flush();
		isDrawing = false;
	}

	public function flush() {
		if(_bufferIdx == 0) return;
		
		renderCalls++;
		renderCallsTotal++;
		if(_bufferIdx > maxSpritesInBatch) maxSpritesInBatch = _bufferIdx;

		_vertexBuffer.unlock(_bufferIdx * 4);
		_vertices = _vertexBuffer.lock();

		_graphics.setPipeline(_currentPipeline);
		_graphics.applyUniforms(_currentPipeline);
		_graphics.setVertexBuffer(_vertexBuffer);

		_graphics.draw(0, _bufferIdx * 6);

		_textureIds.clear();
		_bufferIdx = 0;
	}

	public function dispose() {
		_vertexBuffer.delete();
		_indexBuffer.delete();
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

	public function drawImage(
		texture:Texture, 
		x:Float = 0, y:Float = 0, 
		?width:Float, ?height:Float, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		if(width == 0 || height == 0) return;
		if(texture == null) texture = Graphics.textureDefault;
		if(width == null) width = texture.widthActual;
		if(height == null) height = texture.heightActual;
		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;
		_drawMatrix.setTransform(x, y, angle, 1, 1, originX, originY, skewX, skewY);
		drawImageInternal(texture, _drawMatrix, width, height, regionX, regionY, regionW, regionH);
	}

	public function drawImageTransform(
		texture:Texture, 
		transform:FastMatrix3,
		width:Float = 0, height:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		if(width == 0 || height == 0) return;
		if(texture == null) texture = Graphics.textureDefault;
		if(width == null) width = texture.widthActual;
		if(height == null) height = texture.heightActual;
		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;
		drawImageInternal(texture, transform, width, height, regionX, regionY, regionW, regionH);
	}

	public function drawImageVertices(
		texture:Texture,
		vertices:Array<Vertex>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetImg:Int = 0, ?countImg:Int
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		Log.assert(vertices.length % 4 == 0, 'SpriteBatch.drawImageVertices with non 4 vertices per image: (${vertices.length})');
		if(scaleX == 0 || scaleY == 0) return;
		if(texture == null) texture = Graphics.textureDefault;
		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;
		if(countImg == null) countImg = Math.floor(vertices.length / 4);
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
		drawImageVerticesInternal(texture, vertices, _drawMatrix, regionX, regionY, regionW, regionH, offsetImg, countImg);
	}

	public function drawImageVerticesTransform(
		texture:Texture,
		vertices:Array<Vertex>, 
		transform:FastMatrix3,
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetImg:Int = 0, ?countImg:Int
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		Log.assert(vertices.length % 4 == 0, 'SpriteBatch.drawImageVertices with non 4 vertices per image: (${vertices.length})');
		if(texture == null) texture = Graphics.textureDefault;
		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;
		if(countImg == null) countImg = Math.floor(vertices.length / 4);
		drawImageVerticesInternal(texture, vertices, transform, regionX, regionY, regionW, regionH, offsetImg, countImg);
	}

	public function drawString(
		text:String, 
		x:Float, y:Float, 
		size:Int = 16, ?font:Font, spacing:Int = 0,
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0
	) {		
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		if(text.length == 0) return;
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
		drawStringInternal(text, size, font, spacing, _drawMatrix);
	}

	public function drawStringTransform(
		text:String, 
		transform:FastMatrix3,
		size:Int = 16, ?font:Font, spacing:Int = 0
	) {		
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		if(text.length == 0) return;
		drawStringInternal(text, size, font, spacing, transform);
	}

	#if !clay_debug inline #end
	function drawImageInternal(texture:Texture, transform:FastMatrix3, width:Float, height:Float, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		final pipeline = getPipeline();
		if(pipeline != _currentPipeline) switchPipeline(pipeline);

		if(_bufferIdx + 1 >= _bufferSize) flush();

		var texId = _textureIds.getSparse(texture.id);
		if(texId < 0) {
			if(_textureIds.used >= Graphics.maxShaderTextures) flush();
			texId = _textureIds.used;
			bindTexture(texture, texId);
			_textureIds.insert(texture.id);
		}

		final texWidth = texture.widthActual;
		final texHeight = texture.heightActual;

		final left = regionX / texWidth;
		final top = regionY / texHeight;
		final right = (regionX + regionW) / texWidth;
		final bottom = (regionY + regionH) / texHeight;

		final texFormat = texture.format;
		final m = transform;

		addQuadVertices(
			texId,
			texFormat,
			m.getTransformX(0, 0), m.getTransformY(0, 0), color, left, top,
			m.getTransformX(width, 0), m.getTransformY(width, 0), color, right, top,
			m.getTransformX(width, height), m.getTransformY(width, height), color, right, bottom,
			m.getTransformX(0, height), m.getTransformY(0, height), color, left, bottom
		);

		_bufferIdx++;
	}

	#if !clay_debug inline #end
	function drawImageVerticesInternal(
		texture:Texture, 
		vertices:Array<Vertex>, 
		transform:FastMatrix3,  
		regionX:Int, regionY:Int, regionW:Int, regionH:Int,
		offsetImg:Int, countImg:Int
	) {
		final pipeline = getPipeline();
		if(pipeline != _currentPipeline) switchPipeline(pipeline);

		final texWidth = texture.widthActual;
		final texHeight = texture.heightActual;

		final rsx = regionX / texWidth;
		final rsy = regionY / texHeight;
		final rsw = regionW / texWidth;
		final rsh = regionH / texHeight;

		final m = transform;

		var v1:Vertex;
		var v2:Vertex;
		var v3:Vertex;
		var v4:Vertex;

		var texId:Int = _textureIds.getSparse(texture.id);
		final texFormat = texture.format;
		
		var start:Int = offsetImg * 4;
		var end:Int = (offsetImg + countImg) * 4;

		while(start < end) {

			v1 = vertices[start++];
			v2 = vertices[start++];
			v3 = vertices[start++];
			v4 = vertices[start++];

			if(_bufferIdx + 1 >= _bufferSize) {
				flush();
				texId = -1;
			}

			if(texId < 0) {
				if(_textureIds.used >= Graphics.maxShaderTextures) flush();
				texId = _textureIds.used;
				bindTexture(texture, texId);
				_textureIds.insert(texture.id);
			}

			addQuadVertices(
				texId,
				texFormat,
				m.getTransformX(v1.x, v1.y), m.getTransformY(v1.x, v1.y), v1.color, v1.u * rsw + rsx, v1.v * rsh + rsy,
				m.getTransformX(v2.x, v2.y), m.getTransformY(v2.x, v2.y), v2.color, v2.u * rsw + rsx, v2.v * rsh + rsy,
				m.getTransformX(v3.x, v3.y), m.getTransformY(v3.x, v3.y), v3.color, v3.u * rsw + rsx, v3.v * rsh + rsy,
				m.getTransformX(v4.x, v4.y), m.getTransformY(v4.x, v4.y), v4.color, v4.u * rsw + rsx, v4.v * rsh + rsy
			);

			_bufferIdx++;
		}
	}

	#if !clay_debug inline #end
	function drawStringInternal(text:String, size:Int, font:Font, spacing:Int, transform:FastMatrix3) {
		if(font == null) font = Graphics.fontDefault;

		final pipeline = getPipeline();
		if(pipeline != _currentPipeline) switchPipeline(pipeline);

		final texture = font.getTexture(size);
		final kravur = @:privateAccess font.font._get(size);

		final image = texture.image;
		final texRatioX:FastFloat = image.width / image.realWidth;
		final texRatioY:FastFloat = image.height / image.realHeight;

		var linePos:Float = 0;
		var charIndex:Int = 0;
		var charQuad:AlignedQuad;

		var x0:FastFloat;
		var y0:FastFloat;
		var x1:FastFloat;
		var y1:FastFloat;

		var left:FastFloat;
		var top:FastFloat;
		var right:FastFloat;
		var bottom:FastFloat;

		var i:Int = 0;
		var texId:Int = _textureIds.getSparse(texture.id);
		final texFormat = texture.format;

		final m = transform;

		while(i < text.length) {
			charIndex = findCharIndex(text.fastCodeAt(i));
			charQuad = kravur.getBakedQuad(_bakedQuadCache, charIndex, linePos, 0);
			if (charQuad != null) {
				if(charIndex > 0) { // skip space

					x0 = charQuad.x0;
					y0 = charQuad.y0;
					x1 = charQuad.x1;
					y1 = charQuad.y1;

					left = charQuad.s0 * texRatioX;
					top = charQuad.t0 * texRatioY;
					right = charQuad.s1 * texRatioX;
					bottom = charQuad.t1 * texRatioY;

					if(_bufferIdx + 1 >= _bufferSize) {
						flush();
						texId = -1;
					}

					if(texId < 0) {
						if(_textureIds.used >= Graphics.maxShaderTextures) flush();
						texId = _textureIds.used;
						bindTexture(texture, texId);
						_textureIds.insert(texture.id);
					}

					addQuadVertices(
						texId,
						texFormat,
						m.getTransformX(x0, y0), m.getTransformY(x0, y0), color, left, top,
						m.getTransformX(x1, y0), m.getTransformY(x1, y0), color, right, top,
						m.getTransformX(x1, y1), m.getTransformY(x1, y1), color, right, bottom,
						m.getTransformX(x0, y1), m.getTransformY(x0, y1), color, left, bottom
					);

					_bufferIdx++;
				}
				linePos += charQuad.xadvance + spacing; // TODO: + tracking
			}
			i++;
		}
	}

	inline function findCharIndex(charCode:Int):Int {
		var blocks = KravurImage.charBlocks;
		var offset = 0;
		var start = 0;
		var end = 0;
		var i = 0;
		var idx = 0;
		while(i < blocks.length) {
			start = blocks[i];
			end = blocks[i + 1];
			if (charCode >= start && charCode <= end) {
				idx = offset + charCode - start;
				break;
			}
			offset += end - start + 1;
			i += 2;
		}

		return idx;
	}

	inline function getPipeline():Pipeline {
		return _pipeline != null ? _pipeline : _pipelineDefault;		
	}

	inline function switchPipeline(pipeline:Pipeline) {
		flush();
		_currentPipeline = pipeline;
	}

	inline function bindTexture(texture:Texture, slot:Int) {
		_currentPipeline.setTexture('tex[$slot]', texture);
		_currentPipeline.setTextureParameters('tex[$slot]', _textureAddressing, _textureAddressing, _textureFilter, _textureFilter, _textureMipFilter);
	}

	inline function setupMatrices() {
		combined.copyFrom(_projection).append(_transform);
		_currentPipeline.setMatrix3('projectionMatrix', combined);
	}

	inline function addQuadVertices(
		texId:Int, texFormat:Int,
		v1x:FastFloat, v1y:FastFloat, v1c:Color, v1u:FastFloat, v1v:FastFloat,
		v2x:FastFloat, v2y:FastFloat, v2c:Color, v2u:FastFloat, v2v:FastFloat,
		v3x:FastFloat, v3y:FastFloat, v3c:Color, v3u:FastFloat, v3v:FastFloat,
		v4x:FastFloat, v4y:FastFloat, v4c:Color, v4u:FastFloat, v4v:FastFloat
	) {
		var i = _bufferIdx * Graphics.vertexSizeMultiTextured * 4;
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
