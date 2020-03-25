package clay.graphics;

import kha.arrays.Float32Array;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import clay.utils.Color;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Vertex;
import clay.graphics.DisplayObject;
import clay.render.RenderContext;
import clay.render.Camera;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.render.types.Usage;
import clay.render.Blending;
import clay.render.TextureParameters;
import clay.resources.Texture;
import clay.utils.Log.*;
import clay.utils.BlendMode;

class Mesh extends DisplayObject {

	public var locked(default, set):Bool;

	public var color(default, set):Color;
	public var texture(get, set):Texture;
	public var textureParameters(default, null):TextureParameters;
	public var blending(default, null):Blending;
	public var region:Rectangle;

	public var vertices:Array<Vertex>;
	public var indices:Array<Int>;

	var _texture:Texture;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;
	var _regionScaled:Rectangle;


	public function new(?vertices:Array<Vertex>, ?indices:Array<Int>, ?texture:Texture) {
		super();

		locked = false;

    	this.vertices = vertices != null ? vertices : [];
		this.indices = indices != null ? indices : [];
		this.texture = texture;
		_regionScaled = new Rectangle();

		color = new Color();

		blending = new Blending();
		blending.mode = BlendMode.NORMAL;
		textureParameters = new TextureParameters();
	}

	public function add(v:Vertex) {
		vertices.push(v);
	}

	public function remove(v:Vertex):Bool {
		return vertices.remove(v);
	}

	override function render(ctx:RenderContext) {
		if(locked || ctx.canBatch(vertices.length, indices.length)) {
			ctx.ensure(vertices.length, indices.length);

			preRenderSetup(ctx);

			if(locked) {
				#if !noDebugConsole
				if(ctx.stats != null) {
					ctx.stats.locked++;
				}
				#end
				ctx.drawFromBuffers(_vertexBuffer, _indexBuffer);
			} else {
				updateRegionScaled();

				for (index in indices) {
					ctx.addIndex(index);
				}

				var m = transform.world.matrix;
				for (v in vertices) {
					ctx.setColor(v.color);
					ctx.addVertex(
						m.getTransformX(v.pos.x, v.pos.y), 
						m.getTransformY(v.pos.x, v.pos.y), 
						v.tcoord.x * _regionScaled.w + _regionScaled.x,
						v.tcoord.y * _regionScaled.h + _regionScaled.y
					);
				}
			}
		} else {
			log('WARNING: can`t batch a geometry, vertices: ${vertices.length} vs max ${ctx.verticesMax}, indices: ${indices.length} vs max ${ctx.indicesMax}');
		}
	}

	public function updateLocked() {
		if(locked) {
			if(_vertexBuffer.count() != vertices.length * 8) {
				clearBuffers();
				setupLockedBuffers();
			}

			updateLockedBuffer();
		}
	}

	override function destroy() {
		texture = null;
		color = null;
		textureParameters = null;
		blending = null;
		region = null;
		vertices = null;
		indices = null;
		_vertexBuffer = null;
		_indexBuffer = null;
		_regionScaled = null;
	    super.destroy();
	}

	function setupLockedBuffers() {
		var shader = getRenderShader();

		_vertexBuffer = new VertexBuffer(
			vertices.length,
			shader.pipeline.inputLayout[0],
			Usage.StaticUsage
		);

		_indexBuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);
	}

	function updateLockedBuffer() {
		updateRegionScaled();

		transform.update();

		var data = _vertexBuffer.lock();
		var m = transform.world.matrix;
		var n:Int = 0;
		for (v in vertices) {
			data.set(n++, m.getTransformX(v.pos.x, v.pos.y));
			data.set(n++, m.getTransformY(v.pos.x, v.pos.y));

			data.set(n++, v.color.r);
			data.set(n++, v.color.g);
			data.set(n++, v.color.b);
			data.set(n++, v.color.a);

			data.set(n++, v.tcoord.x * _regionScaled.w + _regionScaled.x);
			data.set(n++, v.tcoord.y * _regionScaled.h + _regionScaled.y);
		}
		_vertexBuffer.unlock();

		var idata = _indexBuffer.lock();
		for (i in 0...indices.length) {
			idata.set(i, indices[i]);
		}

		_indexBuffer.unlock();
	}

	function clearBuffers() {
		if(_vertexBuffer != null) {
			_vertexBuffer.delete();
			_vertexBuffer = null;
		}

		if(_indexBuffer != null) {
			_indexBuffer.delete();
			_indexBuffer = null;
		}
	}

	inline function preRenderSetup(ctx:RenderContext) {
		var shader = getRenderShader();
		ctx.setShader(shader);
		ctx.clip(clipRect);
		ctx.setTexture(texture);
		ctx.setTextureParameters(textureParameters);
		ctx.setBlending(blending);
	}

	inline function updateRegionScaled() {
		if(region == null || _texture == null) {
			_regionScaled.set(0, 0, 1, 1);
		} else {
			_regionScaled.set(
				region.x / _texture.widthActual,
				region.y / _texture.heightActual,
				region.w / _texture.widthActual,
				region.h / _texture.heightActual
			);
		}
	}

	inline function get_texture():Texture {
		return _texture;
	}

	function set_texture(v:Texture):Texture {
		if(_texture != null) {
			_texture.unref();
		}

		var tid:Int = Clay.renderer.sortOptions.textureMax; // for colored sorting

		if(v != null) {
			tid = v.tid;
			v.ref();
		}

		sortKey.texture = tid;

		dirtySort();

		return _texture = v;
	}

	function set_color(c:Color):Color {
		if(vertices != null) {
			for (v in vertices) {
				v.color = c;
			}
		}

		return color = c;
	}

	function set_locked(v:Bool):Bool {
		if(v) {
			setupLockedBuffers();
			updateLockedBuffer();
		} else {
			clearBuffers();
		}

		return locked = v;
	}

}
