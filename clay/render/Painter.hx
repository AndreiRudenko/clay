package clay.render;



import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.TextureFormat;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;
import kha.math.FastMatrix3;
import kha.Image;

import clay.math.Vector;
import clay.graphics.Mesh;
import clay.render.Color;
import clay.render.Camera;
import clay.render.RenderStats;
import clay.resources.Texture;
import clay.render.Shader;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.utils.Mathf;
import clay.utils.ArrayTools;
import clay.utils.Log.*;

using clay.render.utils.FastMatrix3Extender;


class Painter {


	public var stats(default, null):RenderStats;
	public var verticesMax(default, null):Int = 0;
	public var indicesMax(default, null):Int = 0;

	var g:Graphics;

	var _renderer:Renderer;

	var _vertsDraw:Int = 0;
	var _indicesDraw:Int = 0;
	var _vertexIdx:Int = 0;

	var _shader:Shader;
	var _texture:Texture;
    var _textureBlank:Texture;
	var _clipRect:Rectangle;
	var _clipRectDefault:Rectangle;

	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;

	var _vertices:Float32Array;
	var _indices:Uint32Array;

	var _blendSrc:BlendMode;
	var _blendDst:BlendMode;
	var _blendOp:BlendEquation;

	var _alphaBlendDst:BlendMode;
	var _alphaBlendSrc:BlendMode;
	var _alphaBlendOp:BlendEquation;

	var _projectionMatrix:FastMatrix3;


	public function new(renderer:Renderer, batchSize:Int) {

		_renderer = renderer;

		verticesMax = batchSize;
		indicesMax = Std.int(verticesMax / 4) * 6; // adjusted for quads

		var shader = _renderer.shaders.get('textured');
		_vertexbuffer = new VertexBuffer(
			verticesMax,
			shader.pipeline.inputLayout[0],
			Usage.DynamicUsage
		);

		_indexbuffer = new IndexBuffer(
			indicesMax,
			Usage.DynamicUsage
		);
		
		_vertices = _vertexbuffer.lock();
		_indices = _indexbuffer.lock();

		_clipRectDefault = new Rectangle(0, 0, Clay.screen.width, Clay.screen.height);
		_projectionMatrix = FastMatrix3.identity();

		_textureBlank = Texture.create(1, 1, TextureFormat.RGBA32, Usage.StaticUsage, true);
		var pixels = _textureBlank.lock();
		pixels.setInt32(0, 0xffffffff);
		_textureBlank.unlock();

		#if !no_debug_console
		stats = new RenderStats();
		#end

	}

	public function begin(graphics:Graphics, clipRect:Rectangle) {
		
		g = graphics;
		_clipRectDefault = clipRect;
		
		#if !no_debug_console
		stats.reset();
		#end

	}

	public inline function end() {
		
		flush();

	}

	public function setProjection(matrix:Matrix) {
		
		_projectionMatrix.fromMatrix(matrix);

	}

	public function clip(rect:Rectangle) {

		// if(_clipRect != rect && !_clipRect.equals(rect)) { // check for null
		if(_clipRect != rect) {
			flush();
		}
		_clipRect = rect;

	}

	public function setShader(shader:Shader) {

		if(_shader != shader) {
			flush();
			_shader = shader;
		}
		
	}

	public function setTexture(texture:Texture) {
		
		if(_texture != texture) {
			flush();
			_texture = texture;
		}

	}

	public function setBlendMode(
		blendSrc:BlendMode, blendDst:BlendMode, ?blendOp:BlendEquation, 
		?alphaBlendSrc:BlendMode, ?alphaBlendDst:BlendMode, ?alphaBlendOp:BlendEquation
	) {

		if(_blendSrc != blendSrc 
			|| _blendDst != blendDst 
			|| _blendOp != blendOp
			|| _alphaBlendSrc != alphaBlendSrc
			|| _alphaBlendDst != alphaBlendDst
			|| _alphaBlendOp != alphaBlendOp
		) {
			flush();
			_blendSrc = blendSrc;
			_blendDst = blendDst;
			_blendOp = blendOp;
			_alphaBlendSrc = alphaBlendSrc;
			_alphaBlendDst = alphaBlendDst;
			_alphaBlendOp = alphaBlendOp;
		}

	}

	public function canBatch(vertsCount:Int, indicesCount:Int):Bool {
		
		return vertsCount < verticesMax && indicesCount < indicesMax;

	}

	public function ensure(vertsCount:Int, indicesCount:Int) {

		if(_vertsDraw + vertsCount >= verticesMax || _indicesDraw + indicesCount >= indicesMax) {
			flush();
		}
		
	}

		// adding indices must be before adding vertices
	public inline function addIndex(i:Int) {

		_indices[_indicesDraw++] = _vertsDraw + i;

		#if !no_debug_console
		stats.indices++;
		#end

	}

	public inline function addVertex(x:Float, y:Float, uvx:Float, uvy:Float, c:Color) {
		
		_vertices.set(_vertexIdx++, x);
		_vertices.set(_vertexIdx++, y);

		_vertices.set(_vertexIdx++, c.r);
		_vertices.set(_vertexIdx++, c.g);
		_vertices.set(_vertexIdx++, c.b);
		_vertices.set(_vertexIdx++, c.a);

		_vertices.set(_vertexIdx++, uvx);
		_vertices.set(_vertexIdx++, uvy);

		_vertsDraw++;

		#if !no_debug_console
		stats.vertices++;
		#end

	}

	public function drawFromBuffers(vertexbuffer:VertexBuffer, indexbuffer:IndexBuffer, count:Int = 0) {

		flush();

		if(count <= 0) {
			count = indexbuffer.count();
		}

		#if !no_debug_console
		stats.vertices += Math.floor(vertexbuffer.count() / 8);
		stats.indices += count;
		#end
		
		draw(vertexbuffer, indexbuffer, count);

	}

	public function flush() {
		
		if(_vertsDraw == 0) {
			_verboser('nothing to draw, vertices == 0');
			return;
		}

		_vertexbuffer.unlock(_vertsDraw);
		_indexbuffer.unlock(_indicesDraw);
		// _indexbuffer.unlock();

		draw(_vertexbuffer, _indexbuffer, _indicesDraw);

		_vertices = _vertexbuffer.lock();
		_indices = _indexbuffer.lock();

		_vertexIdx = 0;

		_vertsDraw = 0;
		_indicesDraw = 0;

	}

	inline function draw(vertexbuffer:VertexBuffer, indexbuffer:IndexBuffer, count:Int) {

		if(_clipRect != null) {
			g.scissor(Std.int(_clipRect.x), Std.int(_clipRect.y), Std.int(_clipRect.w), Std.int(_clipRect.h));
		} else {
			g.scissor(Std.int(_clipRectDefault.x), Std.int(_clipRectDefault.y), Std.int(_clipRectDefault.w), Std.int(_clipRectDefault.h));
		}

		if(_texture == null) {
			_texture = _textureBlank;
		}

		var textureLoc = _shader.setTexture('tex', _texture).location;
		_shader.setMatrix3('mvpMatrix', _projectionMatrix);

		_shader.setBlendMode(
			_blendSrc, _blendDst, _blendOp, 
			_alphaBlendSrc, _alphaBlendDst, _alphaBlendOp
		);

		_shader.use(g);
		_shader.apply(g);

		g.setVertexBuffer(vertexbuffer);
		g.setIndexBuffer(indexbuffer);

		g.drawIndexedVertices(0, count);

		g.setTexture(textureLoc, null);

		#if !no_debug_console
		stats.drawCalls++;
		#end

	}


}