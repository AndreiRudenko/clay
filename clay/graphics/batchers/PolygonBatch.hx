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

class PolygonBatch {

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

	/** The maximum number of vertices rendered in one batch so far. **/
	public var maxVerticesInBatch:Int = 0;

	var _pipelineDefault:Pipeline;

	var _textureIds:SparseSet;

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

		_pipelineDefault = Graphics.pipelineMultiTextured;
		_currentPipeline = _pipelineDefault;

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

		_vertexBuffer = new VertexBuffer(_maxVertices, _pipelineDefault.inputLayout[0], Usage.DynamicUsage);
		_vertices = _vertexBuffer.lock();

		if (Texture.renderTargetsInvertedY) {
			_projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			_projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}
		_textureIds = new SparseSet(Texture.maxTextures);
	}

	public function dispose() {
		_vertexBuffer.delete();
		_indexBuffer.delete();
	}

	public function begin() {
		Log.assert(!isDrawing, 'PolygonBatch.end must be called before begin');
		isDrawing = true;
		renderCalls = 0;	
		if(!_useIndices) _graphics.setIndexBuffer(_indexBuffer);
		setupMatrices();
	}

	public function end() {
		Log.assert(isDrawing, 'PolygonBatch.begin must be called before end');
		flush();
		isDrawing = false;
	}

	public function flush() {
		if(_vertPos == 0) return;

		renderCalls++;
		renderCallsTotal++;
		if(_vertPos > maxVerticesInBatch) maxVerticesInBatch = _vertPos;
		
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

		_textureIds.clear();
		_vertPos = 0;
		_indPos = 0;
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

	public function drawPolygon(
		polygon:Polygon, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(isDrawing, 'PolygonBatch.begin must be called before draw');
		if(scaleX == 0 || scaleY == 0) return;
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
		drawPolyInternal(
			polygon.texture, polygon.vertices, polygon.indices,
			_drawMatrix, 
			regionX, regionY, regionW, regionH, 
			offsetVerts, countVerts, offsetInds, countInds
		);
	}

	public function drawPolygonTransform(
		polygon:Polygon, 
		transform:FastMatrix3,
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(isDrawing, 'PolygonBatch.begin must be called before draw');
		drawPolyInternal(
			polygon.texture, polygon.vertices, polygon.indices, 
			transform, 
			regionX, regionY, regionW, regionH, 
			offsetVerts, countVerts, offsetInds, countInds
		);
	}

	public function drawVertices(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		x:Float = 0, y:Float = 0, 
		scaleX:Float = 1, scaleY:Float = 1, 
		angle:Float = 0, 
		originX:Float = 0, originY:Float = 0, 
		skewX:Float = 0, skewY:Float = 0, 
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(isDrawing, 'PolygonBatch.begin must be called before draw');
		if(scaleX == 0 || scaleY == 0) return;
		_drawMatrix.setTransform(x, y, angle, scaleX, scaleY, originX, originY, skewX, skewY);
		drawPolyInternal(
			texture, vertices, indices, 
			_drawMatrix, 
			regionX, regionY, regionW, regionH, 
			offsetVerts, countVerts, offsetInds, countInds
		);
	}

	public function drawVerticesTransform(
		texture:Texture,
		vertices:Array<Vertex>, 
		indices:Array<Int>, 
		transform:FastMatrix3,
		regionX:Int = 0, regionY:Int = 0, ?regionW:Int, ?regionH:Int,
		offsetVerts:Int = 0, countVerts:Int = 0, offsetInds:Int = 0, countInds:Int = 0
	) {
		Log.assert(isDrawing, 'PolygonBatch.begin must be called before draw');
		drawPolyInternal(
			texture, vertices, indices, 
			transform, 
			regionX, regionY, regionW, regionH, 
			offsetVerts, countVerts, offsetInds, countInds
		);
	}

	#if !clay_debug inline #end
	function drawPolyInternal(
		texture:Texture, 
		vertices:Array<Vertex>, indices:Array<Int>, 
		transform:FastMatrix3, 
		regionX:Int, regionY:Int, ?regionW:Int, ?regionH:Int,
		offsetVerts:Int, countVerts:Int, offsetInds:Int, countInds:Int
	) {
		var vertCount:Int = vertices.length;
		var indCount:Int = indices.length;
		if(_useIndices) {
			final geomCount = 0;
			Log.assert(vertices.length % _vertsPerGeom == 0, 'PolygonBatch.drawImageVertices with non 4 vertices per quad: (${vertices.length})');

			vertCount = Std.int(vertCount / _vertsPerGeom);
			indCount = _indicesPerGeom * geomCount;
		}
		var pipeline = _pipeline != null ? _pipeline : _pipelineDefault;

		if(vertCount >= _maxVertices || indCount >= _maxIndices) {
			throw('PolygonBatch can`t batch geometry with vertices(${vertCount}/$_maxVertices), indices($indCount/$_maxIndices)');
		} else if(_vertPos + vertCount >= _maxVertices || _indPos + indCount >= _maxIndices || pipeline != _currentPipeline ) {
			flush();
		}

		if(texture == null) texture = Graphics.textureDefault;

		if(regionW == null) regionW = texture.widthActual;
		if(regionH == null) regionH = texture.heightActual;

		var texId = _textureIds.getSparse(texture.id);
		if(texId < 0) {
			if(_textureIds.used >= Graphics.maxShaderTextures) flush();
			texId = _textureIds.used;
			bindTexture(texture, texId);
			_textureIds.insert(texture.id);
		}

		_currentPipeline = pipeline;

		final rsx = regionX / texture.widthActual;
		final rsy = regionY / texture.heightActual;
		final rsw = regionW / texture.widthActual;
		final rsh = regionH / texture.heightActual;

		// get last vertex and index idx
		countVerts = countVerts <= 0 ? vertCount : countVerts + offsetVerts;
		countInds = countInds <= 0 ? indCount : countInds + offsetInds;

		if(_useIndices) {
			while(offsetInds < countInds) {
				_indices[_indPos++] = _vertPos + indices[offsetInds++];
			}
		} else {
			_indPos += countInds - offsetInds;
		}

		var vertIdx = _vertPos * Graphics.vertexSizeMultiTextured;
		final m = transform;
		final opacity = this.opacity;
		final texFormat = texture.format;
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

			_vertPos++;
		}
	}

	inline function bindTexture(texture:Texture, slot:Int) {
		_currentPipeline.setTexture('tex[$slot]', texture);
		_currentPipeline.setTextureParameters('tex[$slot]', _textureAddressing, _textureAddressing, _textureFilter, _textureFilter, _textureMipFilter);
	}

	inline function setupMatrices() {
		combined.copyFrom(_projection).append(_transform);
		_currentPipeline.setMatrix3('projectionMatrix', combined);
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

}
