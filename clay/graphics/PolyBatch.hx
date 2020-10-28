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

class PolyBatch {

	public var projection:FastMatrix3 = new FastMatrix3();
	public var transform:FastMatrix3 = new FastMatrix3();

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

	/** The maximum number of vertices rendered in one batch so far. **/
	public var maxVerticesInBatch:Int = 0;

	var _pipelineAlpha:Pipeline;
	var _pipelinePremultAlpha:Pipeline;
	var _pipelineColored:Pipeline;

	var _texture:Texture;
	var _currentPipeline:Pipeline;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;
	var _vertices:Float32Array;
	var _indices:Uint32Array;

	var _drawMatrix:FastMatrix3;
	var _opacityStack:Array<Float>;

	var _vertPos:Int = 0;
	var _indPos:Int = 0;
	var _bufferSize:Int = 0;
	var _maxVertices:Int = 0;
	var _maxIndices:Int = 0;

	var _invTexWidth:Float = 0;
	var _invTexHeight:Float = 0;

	var _vertsPerGeom:Int;
	var _indicesPerGeom:Int;
	var _useIndices:Bool;

	var _graphics:Graphics;

	public function new(size:Int = 1000, vertsPerGeom:Int = 0, ?geomIndices:Array<Int>) {
		_graphics = Clay.graphics;
		_bufferSize = size;
		_vertsPerGeom = vertsPerGeom;

		_pipelineAlpha = Graphics.pipelineTextured;
		_pipelinePremultAlpha = Graphics.pipelineTexturedPremultAlpha;
		_pipelineColored = Graphics.pipelineColored;

		_currentPipeline = _pipelinePremultAlpha;

		_drawMatrix = new FastMatrix3();

		_opacityStack = [1];

		if(vertsPerGeom > 0 && geomIndices != null && geomIndices.length > 0) {
			_useIndices = false;
			_maxVertices = size * vertsPerGeom;
			_indexBuffer = createStaticIndexBuffer(size, vertsPerGeom, geomIndices);
			_maxIndices = _indexBuffer.count();
			_indicesPerGeom = geomIndices.length;
		} else {
			_useIndices = true;
			_maxVertices = size;
			_maxIndices = size * 4;
			_indexBuffer = new IndexBuffer(_maxIndices, Usage.DynamicUsage);
			_indices = _indexBuffer.lock();
			_indicesPerGeom = 0;
		}

		_vertexBuffer = new VertexBuffer(_maxVertices, _pipelineAlpha.inputLayout[0], Usage.DynamicUsage);
		_vertices = _vertexBuffer.lock();

		if (Texture.renderTargetsInvertedY) {
			projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}
	}

	public function begin() {
		Log.assert(!isDrawing, 'PolyBatch.end must be called before begin');
		isDrawing = true;
		renderCalls = 0;	
		if(!_useIndices) _graphics.setIndexBuffer(_indexBuffer);
	}

	public function end() {
		Log.assert(isDrawing, 'PolyBatch.begin must be called before end');
		flush();
		isDrawing = false;
		_texture = null;
	}

	public function flush() {
		if(_vertPos == 0) return;

		renderCalls++;
		renderCallsTotal++;
		if(_vertPos > maxVerticesInBatch) maxVerticesInBatch = _vertPos;

		_currentPipeline.setMatrix3('projectionMatrix', projection);
		_currentPipeline.setTexture('tex', _texture);
		_currentPipeline.setTextureParameters('tex', _textureAddressing, _textureAddressing, _textureFilter, _textureFilter, _textureMipFilter);
		
		_graphics.setPipeline(_currentPipeline);
		_graphics.applyUniforms(_currentPipeline);

		_vertexBuffer.unlock(_vertPos);
		_vertices = _vertexBuffer.lock();
		_graphics.setVertexBuffer(_vertexBuffer);

		if(_useIndices) {
			_indexBuffer.unlock(_indPos);
			_indices = _indexBuffer.lock();
			_graphics.setIndexBuffer(_indexBuffer);
		}

		_graphics.draw(0, _indPos);

		_vertPos = 0;
		_indPos = 0;
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

	public function drawPoly(
		polygon:Polygon, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'PolyBatch.begin must be called before draw');
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).multiply(transform);
		drawPolyInternal(polygon.texture, polygon.vertices, polygon.indices, _drawMatrix, regionX, regionY, regionW, regionH);
	}

	public function drawPolyT(
		polygon:Polygon, 
		transform:Matrix,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'PolyBatch.begin must be called before draw');
		_drawMatrix.fromMatrix(transform).multiply(this.transform);
		drawPolyInternal(polygon.texture, polygon.vertices, polygon.indices, _drawMatrix, regionX, regionY, regionW, regionH);
	}

	public function drawPolyV(
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
		Log.assert(isDrawing, 'PolyBatch.begin must be called before draw');
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY).multiply(transform);
		drawPolyInternal(texture, vertices, indices, _drawMatrix, regionX, regionY, regionW, regionH);
	}

	public function drawPolyVT(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		transform:Matrix,
		regionX:Int = 0, regionY:Int = 0, regionW:Int = 0, regionH:Int = 0
	) {
		Log.assert(isDrawing, 'PolyBatch.begin must be called before draw');
		_drawMatrix.fromMatrix(transform).multiply(this.transform);
		drawPolyInternal(texture, vertices, indices, _drawMatrix, regionX, regionY, regionW, regionH);
	}

	inline function drawPolyInternal(texture:Texture, vertices:Array<Vertex>, indices:Array<Int>, transform:FastMatrix3, regionX:Int, regionY:Int, regionW:Int, regionH:Int) {
		var indCount = _useIndices ? indices.length : _indicesPerGeom;

		if(vertices.length >= _maxVertices || indCount >= _maxIndices) {
			throw('can`t batch geometry with vertices(${vertices.length}/$_maxVertices), indices($indCount/$_maxIndices)');
		} else if(_vertPos + vertices.length >= _maxVertices || _indPos + indCount >= _maxIndices) {
			flush();
		}

		var pipeline = getPipeline(_premultipliedAlpha);
		if(pipeline != _currentPipeline) {
			switchPipeline(pipeline);
		}

		if(regionW == 0 && regionH == 0) {
			regionW = texture.widthActual;
			regionH = texture.heightActual;
		}

		if(texture != _texture) switchTexture(texture);
		
		var rsx = regionX / texture.widthActual;
		var rsy = regionY / texture.heightActual;
		var rsw = regionW / texture.widthActual;
		var rsh = regionH / texture.heightActual;

		var i:Int = 0;
		if(_useIndices) {
			while(i < indices.length) {
				_indices[_indPos++] = _vertPos + indices[i++];
			}
		} else {
			_indPos += _indicesPerGeom;
		}

		var vertIdx = _vertPos * Graphics.vertexSize;
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

			_vertPos++;
		}
	}

	function createStaticIndexBuffer(geomCount:Int, vertsPerGeom:Int, geomIndices:Array<Int>) {
		var indCount = geomIndices.length;
		var bufferSize = geomCount * indCount;
		var buffer = new IndexBuffer(bufferSize, Usage.StaticUsage);

		var ind = buffer.lock();
		var i = 0;
		var j = 0;
		while(i < geomCount) {
			j = 0;
			while(j < indCount) {
				ind[i*indCount+j] = geomIndices[j] + i * vertsPerGeom;
				j++;
			}
			i++;
		}
		buffer.unlock();

		return buffer;
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

}
