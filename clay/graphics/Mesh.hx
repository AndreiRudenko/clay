package clay.graphics;



import kha.arrays.Float32Array;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import clay.render.Color;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Vertex;
import clay.render.DisplayObject;
import clay.render.Painter;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.render.types.Usage;
import clay.resources.Texture;
import clay.utils.Log.*;


class Mesh extends DisplayObject {


	public var locked(default, set):Bool;

	public var color(default, set):Color;
	public var texture(get, set):Texture;
	public var region:Rectangle;

	public var vertices:Array<Vertex>;
	public var indices:Array<Int>;

	public var blendDisabled:Bool = false;

	public var blendSrc:BlendMode;
	public var blendDst:BlendMode;
	public var blendOp:BlendEquation;

	public var alphaBlendDst:BlendMode;
	public var alphaBlendSrc:BlendMode;
	public var alphaBlendOp:BlendEquation;

	var _texture:Texture;
	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;
	var _regionScaled:Rectangle;


	public function new(?vertices:Array<Vertex>, ?indices:Array<Int>, ?texture:Texture) {
		
		super();

		locked = false;

    	this.vertices = vertices != null ? vertices : [];
		this.indices = indices != null ? indices : [];
		this.texture = texture;
		_regionScaled = new Rectangle();

		color = new Color();

		setBlendMode(BlendMode.BlendOne, BlendMode.InverseSourceAlpha, BlendEquation.Add);

	}

	public function add(v:Vertex) {

		vertices.push(v);

	}

	public function remove(v:Vertex):Bool {

		return vertices.remove(v);

	}

	override function render(p:Painter) {

		if(locked || p.canBatch(vertices.length, indices.length)) {
			p.ensure(vertices.length, indices.length);
			
			p.setShader(shader != null ? shader : shaderDefault);
			p.clip(clipRect);
			p.setTexture(texture);

			if(blendDisabled) {
				var sh = shader != null ? shader : shaderDefault;
				p.setBlendMode(
					sh._blendSrcDefault, sh._blendDstDefault, sh._blendOpDefault, 
					sh._alphaBlendSrcDefault, sh._alphaBlendDstDefault, sh._alphaBlendOpDefault
				);
			} else {
				p.setBlendMode(blendSrc, blendDst, blendOp, alphaBlendSrc, alphaBlendDst, alphaBlendOp);
			}

			if(locked) {
				#if !noDebugConsole
				p.stats.locked++;
				#end
				p.drawFromBuffers(_vertexbuffer, _indexbuffer);
			} else {
				updateRegionScaled();

				for (index in indices) {
					p.addIndex(index);
				}

				var m = transform.world.matrix;
				for (v in vertices) {
					p.addVertex(
						m.a * v.pos.x + m.c * v.pos.y + m.tx, 
						m.b * v.pos.x + m.d * v.pos.y + m.ty, 
						v.tcoord.x * _regionScaled.w + _regionScaled.x,
						v.tcoord.y * _regionScaled.h + _regionScaled.y,
						v.color
					);
				}
			}

		} else {
			log('WARNING: can`t batch a geometry, vertices: ${vertices.length} vs max ${p.verticesMax}, indices: ${indices.length} vs max ${p.indicesMax}');
		}

	}

	public function updateLocked() {

		if(locked) {
			if(_vertexbuffer.count() != vertices.length * 8) {
				clearBuffers();
				setupLockedBuffers();
			}

			updateLockedBuffer();
		}
		
	}

	public function setBlendMode(blendSrc:BlendMode, blendDst:BlendMode, ?blendOp:BlendEquation, ?alphaBlendSrc:BlendMode, ?alphaBlendDst:BlendMode, ?alphaBlendOp:BlendEquation) {
		
		this.blendSrc = blendSrc;
		this.blendDst = blendDst;
		this.blendOp = blendOp != null ? blendOp : BlendEquation.Add;	

		this.alphaBlendSrc = alphaBlendSrc != null ? alphaBlendSrc : blendSrc;
		this.alphaBlendDst = alphaBlendDst != null ? alphaBlendDst : blendDst;
		this.alphaBlendOp = alphaBlendOp != null ? alphaBlendOp : blendOp;	

	}

	function setupLockedBuffers() {

		var sh = shader != null ? shader : shaderDefault;

		_vertexbuffer = new VertexBuffer(
			vertices.length,
			sh.pipeline.inputLayout[0],
			Usage.StaticUsage
		);

		_indexbuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);

	}

	function updateLockedBuffer() {

		updateRegionScaled();

		transform.update();

		var data = _vertexbuffer.lock();
		var m = transform.world.matrix;
		var n:Int = 0;
		for (v in vertices) {
			data.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
			data.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);

			data.set(n++, v.color.r);
			data.set(n++, v.color.g);
			data.set(n++, v.color.b);
			data.set(n++, v.color.a);

			data.set(n++, v.tcoord.x * _regionScaled.w + _regionScaled.x);
			data.set(n++, v.tcoord.y * _regionScaled.h + _regionScaled.y);
		}
		_vertexbuffer.unlock();

		var idata = _indexbuffer.lock();
		for (i in 0...indices.length) {
			idata.set(i, indices[i]);
		}

		_indexbuffer.unlock();

	}

	function clearBuffers() {

		if(_vertexbuffer != null) {
			_vertexbuffer.delete();
			_vertexbuffer = null;
		}

		if(_indexbuffer != null) {
			_indexbuffer.delete();
			_indexbuffer = null;
		}

	}

	inline function updateRegionScaled() {
		
		if(region == null || _texture == null) {
			_regionScaled.set(0, 0, 1, 1);
		} else {
			_regionScaled.set(
				_regionScaled.x = region.x / _texture.widthActual,
				_regionScaled.y = region.y / _texture.heightActual,
				_regionScaled.w = region.w / _texture.widthActual,
				_regionScaled.h = region.h / _texture.heightActual
			);
		}

	}

	inline function get_texture():Texture {

		return _texture;

	}

	function set_texture(v:Texture):Texture {

		var tid:Int = Clay.renderer.sortOptions.textureMax; // for colored sorting

		if(v != null) {
			tid = v.tid;
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
