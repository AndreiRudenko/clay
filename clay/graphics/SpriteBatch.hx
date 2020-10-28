package clay.graphics;

import kha.Kravur;
import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.Font;
import clay.graphics.Vertex;
import clay.graphics.VertexBuffer;
import clay.graphics.IndexBuffer;
import clay.graphics.Pipeline;
import clay.math.FastMatrix3;
import clay.math.Matrix;
import clay.utils.FastFloat;
import clay.utils.Log;
import clay.utils.Math;
import clay.utils.Float32Array;
using StringTools;

class SpriteBatch {

	public var projection:FastMatrix3 = new FastMatrix3();
	public var transform:FastMatrix3 = new FastMatrix3();

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

	public var premultipliedAlpha(get, set):Bool;
	var _premultipliedAlpha:Bool = true;
	inline function get_premultipliedAlpha() return _premultipliedAlpha; 
	function set_premultipliedAlpha(v:Bool) {
		if(isDrawing && _pipeline == null && _premultipliedAlpha != v) flush();
		return _premultipliedAlpha = v;
	}

	public var textureFilter(get, set):TextureFilter;
	var _textureFilter:TextureFilter = TextureFilter.PointFilter;
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

	var _pipelineAlpha:Pipeline;
	var _pipelinePremultAlpha:Pipeline;

	var _texture:Texture;
	var _currentPipeline:Pipeline;
	var _vertices:Float32Array;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;

	var _drawMatrix:FastMatrix3;
	var _bakedQuadCache:AlignedQuad;
	var _opacityStack:Array<Float>;

	var _bufferIdx:Int = 0;
	var _bufferSize:Int = 0;

	var _invTexWidth:Float = 0;
	var _invTexHeight:Float = 0;

	var _graphics:Graphics;

	public function new(size:Int = 1024) {
		_graphics = Clay.graphics;
		_bufferSize = size;

		_pipelineAlpha = Graphics.pipelineTextured;
		_pipelinePremultAlpha = Graphics.pipelineTexturedPremultAlpha;

		_currentPipeline = _pipelinePremultAlpha;

		_drawMatrix = new FastMatrix3();
		_bakedQuadCache = new AlignedQuad();

		_opacityStack = [1];

		_vertexBuffer = new VertexBuffer(_bufferSize * 4, _pipelineAlpha.inputLayout[0], Usage.DynamicUsage);
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

	public function begin() {
		Log.assert(!isDrawing, 'SpriteBatch.end must be called before begin');
		isDrawing = true;
		renderCalls = 0;
		_graphics.setIndexBuffer(_indexBuffer);
	}

	public function end() {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before end');
		flush();
		isDrawing = false;
		_texture = null;
	}

	public function flush() {
		if(_bufferIdx == 0) return;
		
		renderCalls++;
		renderCallsTotal++;
		if(_bufferIdx > maxSpritesInBatch) maxSpritesInBatch = _bufferIdx;

		_currentPipeline.setMatrix3('projectionMatrix', projection);
		_currentPipeline.setTexture('tex', _texture);
		_currentPipeline.setTextureParameters('tex', _textureAddressing, _textureAddressing, _textureFilter, _textureFilter, _textureMipFilter);

		_vertexBuffer.unlock(_bufferIdx * 4);
		_vertices = _vertexBuffer.lock();

		_graphics.setPipeline(_currentPipeline);
		_graphics.applyUniforms(_currentPipeline);
		_graphics.setVertexBuffer(_vertexBuffer);
		_graphics.draw(0, _bufferIdx * 6);

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
		width:Float = 0, height:Float = 0, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		_drawMatrix.setTransform(x, y, angle, 1, 1, originX, originY, skewX, skewY).multiply(transform);
		drawImageInternal(texture, _drawMatrix, width, height, regionX, regionY, regionW, regionH);
	}

	public function drawImageT(
		texture:Texture, 
		transform:Matrix,
		width:Float = 0, height:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		_drawMatrix.fromMatrix(transform).multiply(this.transform);
		drawImageInternal(texture, _drawMatrix, width, height, regionX, regionY, regionW, regionH);
	}

	public function drawImageV(
		texture:Texture,
		vertices:Array<Vertex>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 0, scaleY:Float = 0, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).multiply(transform);
		drawImageVerticesInternal(texture, vertices, _drawMatrix, regionX, regionY, regionW, regionH);
	}

	public function drawImageVT(
		texture:Texture,
		vertices:Array<Vertex>, 
		transform:Matrix,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');
		_drawMatrix.fromMatrix(transform).multiply(this.transform);
		drawImageVerticesInternal(texture, vertices, _drawMatrix, regionX, regionY, regionW, regionH);
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
		if(font == null) font = Graphics.fontDefault;

		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).multiply(transform);
		drawStringInternal(text, size, font, spacing, _drawMatrix);
	}

	public function drawStringT(
		text:String, 
		transform:Matrix,
		size:Int = 16, ?font:Font, spacing:Int = 0
	) {		
		Log.assert(isDrawing, 'SpriteBatch.begin must be called before draw');

		if(text.length == 0) return;
		if(font == null) font = Graphics.fontDefault;

		_drawMatrix.fromMatrix(transform).multiply(this.transform);
		drawStringInternal(text, size, font, spacing, _drawMatrix);
	}

	inline function drawImageInternal(texture:Texture, transform:FastMatrix3, width:Float, height:Float, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		var pipeline = getPipeline(_premultipliedAlpha);
		if(pipeline != _currentPipeline) {
			switchPipeline(pipeline);
		}

		if(texture != _texture) {
			switchTexture(texture);
		} else if(_bufferIdx + 1 >= _bufferSize) {
			flush();
		}

		if(width == 0 && height == 0) {
			width = texture.widthActual;
			height = texture.heightActual;
		}

		if(regionW == 0 && regionH == 0) {
			regionW = texture.widthActual;
			regionH = texture.heightActual;
		}

		var left = regionX * _invTexWidth;
		var top = regionY * _invTexHeight;
		var right = (regionX + regionW) * _invTexWidth;
		var bottom = (regionY + regionH) * _invTexHeight;

		var m = transform;

		addVertices(
			m.getTransformX(0, 0), m.getTransformY(0, 0), color, left, top,
			m.getTransformX(width, 0), m.getTransformY(width, 0), color, right, top,
			m.getTransformX(width, height), m.getTransformY(width, height), color, right, bottom,
			m.getTransformX(0, height), m.getTransformY(0, height), color, left, bottom
		);

		_bufferIdx++;
	}

	inline function drawImageVerticesInternal(texture:Texture, vertices:Array<Vertex>, transform:FastMatrix3, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		var pipeline = getPipeline(_premultipliedAlpha);
		if(pipeline != _currentPipeline) {
			switchPipeline(pipeline);
		}

		if(texture != _texture) {
			switchTexture(texture);
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
			if(_bufferIdx + 1 >= _bufferSize) flush();

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

			_bufferIdx++;
		}
	}

	inline function drawStringInternal(text:String, size:Int, font:Font, spacing:Int, transform:FastMatrix3) {
		var pipeline = getPipeline(false);
		if(pipeline != _currentPipeline) {
			switchPipeline(pipeline);
		}

		var texture = font.getTexture(size);
		if(texture != _texture) {
			switchTexture(texture);
		}
	
		var kravur = @:privateAccess font.font._get(size);

		var image = texture.image;
		var texRatioX:FastFloat = image.width / image.realWidth;
		var texRatioY:FastFloat = image.height / image.realHeight;

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

		var m = transform;

		while(i < text.length) {
			charIndex = findCharIndex(text.fastCodeAt(i));
			charQuad = kravur.getBakedQuad(_bakedQuadCache, charIndex, linePos, 0);
			if (charQuad != null) {
				if(charIndex > 0) { // skip space
					if(_bufferIdx + 1 >= _bufferSize) flush();

					x0 = charQuad.x0;
					y0 = charQuad.y0;
					x1 = charQuad.x1;
					y1 = charQuad.y1;

					left = charQuad.s0 * texRatioX;
					top = charQuad.t0 * texRatioY;
					right = charQuad.s1 * texRatioX;
					bottom = charQuad.t1 * texRatioY;

					addVertices(
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

	inline function getPipeline(premultAlpha:Bool):Pipeline {
		return _pipeline != null ? _pipeline : (premultAlpha ? _pipelinePremultAlpha : _pipelineAlpha);		
	}

	inline function switchPipeline(pipeline:Pipeline) {
		flush();
		_currentPipeline = pipeline;
	}

	inline function switchTexture(texture:Texture) {
		flush();
		_texture = texture;
		_invTexWidth = 1 / _texture.widthActual;
		_invTexHeight = 1 / _texture.heightActual;
	}

	inline function addVertices(
		v1x:FastFloat, v1y:FastFloat, v1c:Color, v1u:FastFloat, v1v:FastFloat,
		v2x:FastFloat, v2y:FastFloat, v2c:Color, v2u:FastFloat, v2v:FastFloat,
		v3x:FastFloat, v3y:FastFloat, v3c:Color, v3u:FastFloat, v3v:FastFloat,
		v4x:FastFloat, v4y:FastFloat, v4c:Color, v4u:FastFloat, v4v:FastFloat
	) {
		var idx = _bufferIdx * Graphics.vertexSize * 4;
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
