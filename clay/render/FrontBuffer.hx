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

using clay.render.utils.FastMatrix3Extender;


class FrontBuffer {


	public var shader(default, set):Shader;

	var vertexbuffer:VertexBuffer;
	var indexbuffer:IndexBuffer;
	var texture_loc:TextureUnit;
	var projection_loc:ConstantLocation;

	var renderer:Renderer;
	var projection_matrix:FastMatrix3;


	public function new(_renderer:Renderer) {
		
		renderer = _renderer;
		shader = renderer.shader_textured;

    	vertexbuffer = new VertexBuffer(4, shader.inputLayout[0], Usage.StaticUsage);
		var vertices = vertexbuffer.lock();

		// colors
		var index:Int = 0;
		for (i in 0...4) {
			index = i * 8;
			vertices.set(index + 2, 1);
			vertices.set(index + 3, 1);
			vertices.set(index + 4, 1);
			vertices.set(index + 5, 1);
		}

		vertexbuffer.unlock();

		indexbuffer = new IndexBuffer(6, Usage.StaticUsage);
		var indices = indexbuffer.lock();

		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 0;
		indices[4] = 2;
		indices[5] = 3;
		
		indexbuffer.unlock();

	}

	function set_vertices(img:Image, transformation:FastMatrix3) {

		var vertices = vertexbuffer.lock();

		var x = 0;
		var y = 0;
		var w = x + img.width;
		var h = y + img.height;
		var wr = w / img.realWidth;
		var hr = h / img.realHeight;
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

		vertexbuffer.unlock();

	}

	public function render(source:Image, destination:Canvas, rotation:ScreenRotation) {

		var g = destination.g4;

		projection_matrix = FastMatrix3.identity().orto(0, Clay.screen.width, Clay.screen.height, 0);

		var transformation = Scaler.getScaledTransformation(source.width, source.height, destination.width, destination.height, rotation);
		set_vertices(source, transformation);

		g.begin();
		g.clear(kha.Color.Black);

		shader.reset_blendmodes();
		
		g.setPipeline(shader);
		g.setMatrix3(projection_loc, projection_matrix);
		g.setTexture(texture_loc, source);

		g.setVertexBuffer(vertexbuffer);
		g.setIndexBuffer(indexbuffer);

		g.drawIndexedVertices();

		g.setTexture(texture_loc, null);

		g.end();

	}

	function set_shader(v:Shader):Shader {

		shader = v;

		texture_loc = shader.getTextureUnit("tex");
		projection_loc = shader.getConstantLocation("mvpMatrix");
		
		return v;

	}
	

}