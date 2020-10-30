package clay;

import kha.Framebuffer;
import clay.Clay;
import clay.graphics.VertexBuffer;
import clay.graphics.IndexBuffer;
import clay.graphics.Pipeline;
import clay.graphics.Texture;
import clay.graphics.Font;
import clay.graphics.VertexStructure;
import clay.graphics.Shaders;
import clay.math.FastMatrix3;
import clay.graphics.Color;
import clay.utils.Log;

class Graphics {

	static public var fontDefault:Font;

	static public inline var vertexSize:Int = 8;

	static public var pipelineTextured:Pipeline;
	static public var pipelineTexturedPremultAlpha:Pipeline;
	static public var pipelineColored:Pipeline;

	static var frameBuffer:Framebuffer;
	static var vertexBuffer:VertexBuffer;
	static var indexBuffer:IndexBuffer;
	static var projection:FastMatrix3;

	static public function setup() {
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		structure.add("texPosition", VertexData.Float2);

		// textured
		pipelineTexturedPremultAlpha = new Pipeline([structure], Shaders.textured_vert, Shaders.textured_frag);
		pipelineTexturedPremultAlpha.setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceAlpha, BlendOperation.Add);
		pipelineTexturedPremultAlpha.compile();

		// text
		pipelineTextured = new Pipeline([structure], Shaders.textured_vert, Shaders.text_frag);
		pipelineTextured.setBlending(BlendFactor.SourceAlpha, BlendFactor.InverseSourceAlpha, BlendOperation.Add);
		pipelineTextured.compile();

		// colored
		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);

		pipelineColored = new Pipeline([structure], Shaders.colored_vert, Shaders.colored_frag);
		pipelineColored.setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceAlpha, BlendOperation.Add);
		pipelineColored.compile();

		#if !no_default_font
		fontDefault = Clay.resources.font("Muli-Regular.ttf");
		#end
		projection = new FastMatrix3();
		initBuffers();
	}

	static public function blit(src:Texture, ?dst:Texture, ?pipeline:Pipeline, 
		clearDst:Bool = true, bilinear:Bool = true,
		scaleX:Float = 1, scaleY:Float = 1, offsetX:Float = 0, offsetY:Float = 0
	) {
		var g:kha.graphics4.Graphics;
		if(dst != null) {
			Log.assert(dst.isRenderTarget, 'Graphics.blit with non renderTarget destination texture');
			g = dst.image.g4;

			if (Texture.renderTargetsInvertedY) {
				projection.orto(0, Clay.window.width, 0, Clay.window.height);
			} else {
				projection.orto(0, Clay.window.width, Clay.window.height, 0);
			}
		} else {
			g = frameBuffer.g4;	
			
			projection.orto(0, Clay.window.width, Clay.window.height, 0);
		}

		if(pipeline == null) pipeline = Graphics.pipelineTexturedPremultAlpha;
		
		setBlitVertices(offsetX, offsetY, src.widthActual * scaleX, src.heightActual * scaleY);

		g.begin();
		if(clearDst) g.clear(Color.BLACK);

		var textureUniform = pipeline.setTexture('tex', src);
		pipeline.setTextureParameters('tex', 
			TextureAddressing.Clamp, TextureAddressing.Clamp, 
			bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter,
			MipMapFilter.NoMipFilter
		);
		pipeline.setMatrix3('projectionMatrix', projection);
		pipeline.use(g);
		pipeline.apply(g);

		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		g.drawIndexedVertices(0, 6);

		g.setTexture(textureUniform.location, null);
		g.end();
	}

	@:allow(clay.App)
	static function render(f:Array<Framebuffer>) {
		frameBuffer = f[0];
	}

	static function initBuffers() {
		var pipeline = Graphics.pipelineTexturedPremultAlpha;
		vertexBuffer = new VertexBuffer(
			4, 
			pipeline.inputLayout[0], 
			Usage.StaticUsage
		);

		var vertices = vertexBuffer.lock();

		vertices[2] = 1; vertices[3] = 1; vertices[4] = 1; vertices[5] = 1;
		vertices[10] = 1; vertices[11] = 1; vertices[12] = 1; vertices[13] = 1;
		vertices[18] = 1; vertices[19] = 1; vertices[20] = 1; vertices[21] = 1;
		vertices[26] = 1; vertices[27] = 1; vertices[28] = 1; vertices[29] = 1;

		vertices[6] = 0; vertices[7] = 0;
		vertices[14] = 1; vertices[15] = 0;
		vertices[22] = 1; vertices[23] = 1;
		vertices[30] = 0; vertices[31] = 1;

		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(
			6, 
			Usage.StaticUsage
		);

		var indices = indexBuffer.lock();
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 0;
		indices[4] = 2;
		indices[5] = 3;
		indexBuffer.unlock();
	}

	static function setBlitVertices(x:Float, y:Float, w:Float, h:Float) {		
		var vertices = vertexBuffer.lock();
		vertices[0] = x;
		vertices[1] = y;

		vertices[8] = x + w;
		vertices[9] = y;

		vertices[16] = x + w;
		vertices[17] = y + h;

		vertices[24] = x;
		vertices[25] = y + h;
		vertexBuffer.unlock();
	}

	public var target(default, null):Texture;
	var _g4:kha.graphics4.Graphics;

	public function new() {}

	public function begin(?target:Texture) {
		if(target == null) target = Clay.window.buffer;
		
		Log.assert(target.isRenderTarget, 'Graphics: begin with non renderTarget texture');
		this.target = target;
		_g4 = target.image.g4;
		_g4.begin();
	}

	public function clear(?clearColor:Color) {
		Log.assert(target != null, 'Graphics: no active target, begin before you clear');
		_g4.clear(clearColor != null ? clearColor : Color.BLACK);
	}

	public function end() {
		Log.assert(target != null, 'Graphics: no active target, begin before you end');
		_g4.end();
		target = null;
		_g4 = null;
	}

	public function viewport(x:Float, y:Float, w:Float, h:Float) {
		Log.assert(target != null, 'Graphics: no active target, begin before you set viewport');
		_g4.viewport(Std.int(x), Std.int(y), Std.int(w), Std.int(h));
	}

	public function scissor(x:Float, y:Float, w:Float, h:Float) {
		Log.assert(target != null, 'Graphics: no active target, begin before you set scissor');
		_g4.scissor(Std.int(x), Std.int(y), Std.int(w), Std.int(h));
	}

	public function disableScissor() {
		_g4.disableScissor();
	}

	public function setVertexBuffer(vertexBuffer:VertexBuffer) {
		Log.assert(target != null, 'Graphics: no active target, begin before you setVertexBuffer');
		_g4.setVertexBuffer(vertexBuffer);
	}

	public function setVertexBuffers(vertexBuffers:Array<VertexBuffer>) {
		Log.assert(target != null, 'Graphics: no active target, begin before you setVertexBuffers');
		_g4.setVertexBuffers(vertexBuffers);
	}

	public function setIndexBuffer(indexBuffer:IndexBuffer) {
		Log.assert(target != null, 'Graphics: no active target, begin before you setIndexBuffer');
		_g4.setIndexBuffer(indexBuffer);
	}

	public function setPipeline(pipeline:Pipeline) {
		Log.assert(target != null, 'Graphics: no active target, begin before you usePipeline');
		pipeline.use(_g4);
	}

	public function applyUniforms(pipeline:Pipeline) {
		Log.assert(target != null, 'Graphics: no active target, begin before you applyUniforms');
		pipeline.apply(_g4);
	}

	public function draw(start:Int = 0, count:Int = -1) {
		Log.assert(target != null, 'Graphics: no active target, begin before you draw');
		_g4.drawIndexedVertices(start, count);
	}

	public function drawInstanced(instances:Int, start:Int = 0, count:Int = -1) {
		Log.assert(target != null, 'Graphics: no active target, begin before you draw');
		_g4.drawIndexedVerticesInstanced(instances, start, count);
	}
	
}
