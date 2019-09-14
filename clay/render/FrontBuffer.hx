package clay.render;


import kha.ScreenRotation;
import kha.Scaler;
import kha.Canvas;
import kha.graphics4.Graphics;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.FastVector2;

import clay.render.Shader;
import clay.resources.Texture;

using clay.render.utils.FastMatrix3Extender;


class FrontBuffer {


	// public var shader:Shader;

	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;
	var _textureLoc:TextureUnit;

	var _renderer:Renderer;
	var _projectionMatrix:FastMatrix3;


	public function new(renderer:Renderer) {
		
		_renderer = renderer;
		var shader = _renderer.shaderTextured;
		
		_projectionMatrix = FastMatrix3.identity();

    	_vertexbuffer = new VertexBuffer(4, shader.pipeline.inputLayout[0], Usage.StaticUsage);
		var vertices = _vertexbuffer.lock();

		// colors
		var index:Int = 0;
		for (i in 0...4) {
			index = i * 8;
			vertices.set(index + 2, 1);
			vertices.set(index + 3, 1);
			vertices.set(index + 4, 1);
			vertices.set(index + 5, 1);
		}

		_vertexbuffer.unlock();

		_indexbuffer = new IndexBuffer(6, Usage.StaticUsage);
		var indices = _indexbuffer.lock();

		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 0;
		indices[4] = 2;
		indices[5] = 3;
		
		_indexbuffer.unlock();

	}

	function setVertices(texture:Texture, transformation:FastMatrix3) {

		var vertices = _vertexbuffer.lock();

		var x = 0;
		var y = 0;
		var w = x + texture.width;
		var h = y + texture.height;
		var wr = w / texture.widthActual;
		var hr = h / texture.heightActual;
		var p1 = transformation.multvec(new FastVector2(x, y));
		var p2 = transformation.multvec(new FastVector2(w, y));
		var p3 = transformation.multvec(new FastVector2(w, h));
		var p4 = transformation.multvec(new FastVector2(x, h));

		var index:Int = 0;
		vertices.set(index + 0, p1.x);
		vertices.set(index + 1, p1.y);
		vertices.set(index + 6, 0);
		vertices.set(index + 7, 0);

		index += 8;
		vertices.set(index + 0, p2.x);
		vertices.set(index + 1, p2.y);
		vertices.set(index + 6, wr);
		vertices.set(index + 7, 0);

		index += 8;
		vertices.set(index + 0, p3.x);
		vertices.set(index + 1, p3.y);
		vertices.set(index + 6, wr);
		vertices.set(index + 7, hr);

		index += 8;
		vertices.set(index + 0, p4.x);
		vertices.set(index + 1, p4.y);
		vertices.set(index + 6, 0);
		vertices.set(index + 7, hr);

		_vertexbuffer.unlock();

	}

	public function render(source:Texture, destination:Canvas, shader:Shader, rotation:ScreenRotation) {

		var g = destination.g4;

		_projectionMatrix.identity().orto(0, Clay.screen.width, Clay.screen.height, 0);

		var transformation = Scaler.getScaledTransformation(source.width, source.height, destination.width, destination.height, rotation);
		setVertices(source, transformation);

		_textureLoc = shader.setTexture('tex', source).location;
		shader.setMatrix3('mvpMatrix', _projectionMatrix);

		shader.resetBlendModes();
		shader.use(g);
		shader.apply(g);

		g.setVertexBuffer(_vertexbuffer);
		g.setIndexBuffer(_indexbuffer);

		g.drawIndexedVertices();

		g.setTexture(_textureLoc, null);

	}
	

}