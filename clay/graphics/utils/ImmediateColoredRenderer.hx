package clay.graphics.utils;

import clay.math.Vector2;
import clay.math.FastMatrix3;
import clay.math.FastVector2;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.render.Pipeline;
import clay.graphics.render.VertexBuffer;
import clay.graphics.render.IndexBuffer;
import clay.utils.StrokeAlign;
import clay.utils.Math;
import clay.utils.DynamicPool;
import clay.utils.FastFloat;
import clay.utils.Float32Array;
import clay.utils.Uint32Array;
import clay.utils.Log;
import clay.Graphics;

class ImmediateColoredRenderer {

	public var projection(get, set):FastMatrix3;
	var _projection:FastMatrix3 = new FastMatrix3();
	inline function get_projection() return _projection;
	function set_projection(v:FastMatrix3) {
		Log.assert(!_inGeometryMode, 'ImmediateColoredRenderer.endGeometry must be called before changing projection');
		if(isDrawing) flush();
		return _projection = v;
	}

	public var pipeline(get, set):Pipeline;
	var _pipeline:Pipeline;
	inline function get_pipeline() return _pipeline;
	function set_pipeline(v:Pipeline) {
		Log.assert(!_inGeometryMode, 'ImmediateColoredRenderer.endGeometry must be called before changing pipeline');
		if(isDrawing) flush();
		_pipeline = v;
		_currentPipeline = _pipeline != null ? _pipeline : _pipelineColored;
		return _pipeline;
	}

	/** true if currently between begin and end. */
	public var isDrawing(default, null):Bool = false;

	/** Number of render calls since the last {@link #begin()}. **/
	public var renderCalls(default, null):Int = 0;

	/** Number of rendering calls, ever. Will not be reset unless set manually. **/
	public var renderCallsTotal:Int = 0;

	/** The maximum number of vertices rendered in one batch so far. **/
	public var maxVerticesInBatch:Int = 0;

	var _currentPipeline:Pipeline;
	var _pipelineColored:Pipeline;

	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;
	var _vertices:Float32Array;
	var _indices:Uint32Array;

	var _verticesMax:Int = 0;
	var _indicesMax:Int = 0;

	var _vertsDraw:Int = 0;
	var _indicesDraw:Int = 0;

	var _vertStartPos:Int = 0;
	var _vertexIdx:Int = 0;
	var _vertPos:Int = 0;
	var _indPos:Int = 0;

	var _inGeometryMode:Bool = false;

	var _graphics:Graphics;

	public function new(verticesMax:Int = 8192, indicesMax:Int = 16384) {
		_graphics = Clay.graphics;
		_verticesMax = verticesMax;
		_indicesMax = indicesMax;

		_pipelineColored = Graphics.pipelineColored;
		_currentPipeline = _pipelineColored;

		_vertexBuffer = new VertexBuffer(_verticesMax, _pipelineColored.inputLayout[0], Usage.DynamicUsage);
		_vertices = _vertexBuffer.lock();

		_indexBuffer = new IndexBuffer(_indicesMax, Usage.DynamicUsage);
		_indices = _indexBuffer.lock();

		if(Texture.renderTargetsInvertedY) {
			_projection.orto(0, Clay.window.width, 0, Clay.window.height);
		} else {
			_projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}
	}

	public function dispose() {
		_vertexBuffer.delete();
		_indexBuffer.delete();
		_vertices = null;
		_indices = null;
	}

	public function begin() {
		Log.assert(!isDrawing, 'ImmediateColoredRenderer.end must be called before begin');
		isDrawing = true;
		renderCalls = 0;
	}

	public function end() {
		Log.assert(isDrawing, 'ImmediateColoredRenderer.begin must be called before end');
		flush();
		isDrawing = false;
	}

	public function flush() {
		if(_vertsDraw == 0) return;

		renderCalls++;
		renderCallsTotal++;
		if(_vertsDraw > maxVerticesInBatch) maxVerticesInBatch = _vertsDraw;

		_currentPipeline.setMatrix3('projectionMatrix', _projection);
		
		_graphics.setPipeline(_currentPipeline);
		_graphics.applyUniforms(_currentPipeline);

		_vertexBuffer.unlock(_vertsDraw);
		_vertices = _vertexBuffer.lock();
		_graphics.setVertexBuffer(_vertexBuffer);

		_indexBuffer.unlock(_indicesDraw);
		_indices = _indexBuffer.lock();
		_graphics.setIndexBuffer(_indexBuffer);

		_graphics.draw(0, _indicesDraw);

		_vertsDraw = 0;
		_indicesDraw = 0;
	}

	public function beginGeometry(verticesCount:Int, indicesCount:Int) {
		Log.assert(isDrawing, 'ImmediateColoredRenderer.begin must be called before beginGeometry');
		Log.assert(!_inGeometryMode, 'ImmediateColoredRenderer.endGeometry must be called before beginGeometry');
		_inGeometryMode = true;

		if(verticesCount >= _verticesMax || indicesCount >= _indicesMax) {
			throw('can`t batch geometry with vertices(${verticesCount}/$_verticesMax), indices($indicesCount/$_indicesMax)');
		} else if(_vertPos + verticesCount >= _verticesMax || _indPos + indicesCount >= _indicesMax) {
			flush();
		}

		_vertStartPos = _vertsDraw;
		_vertPos = _vertsDraw;
		_indPos = _indicesDraw;

		_vertsDraw += verticesCount;
		_indicesDraw += indicesCount;
	}

	public function endGeometry() {
		Log.assert(_inGeometryMode, 'ImmediateColoredRenderer.beginGeometry must be called before endGeometry');
		Log.assert(_vertPos == _vertsDraw, 'ImmediateColoredRenderer: added vertices($_vertPos) not equals of requested($_vertsDraw) in beginGeometry');
		Log.assert(_indPos == _indicesDraw, 'ImmediateColoredRenderer: added indicies($_indPos) is not equals of requested($_indicesDraw) in beginGeometry');
		_inGeometryMode = false;
	}

	public function addVertex(x:FastFloat, y:FastFloat, c:Color) {
		_vertexIdx = _vertPos * Graphics.vertexSizeColored;

		_vertices[_vertexIdx + 0] = x;
		_vertices[_vertexIdx + 1] = y;

		var a = c.a;
		_vertices[_vertexIdx + 2] = c.r * a;
		_vertices[_vertexIdx + 3] = c.g * a;
		_vertices[_vertexIdx + 4] = c.b * a;
		_vertices[_vertexIdx + 5] = a;

		_vertPos++;
	}

	public function addIndex(i:Int) {
		_indices[_indPos++] = _vertStartPos + i;
	}

}
