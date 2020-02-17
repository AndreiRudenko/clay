package clay.graphics;



import kha.arrays.Float32Array;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import clay.render.Color;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Vertex;
import clay.graphics.DisplayObject;
import clay.render.Painter;
import clay.render.Camera;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
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

	public var blendMode(default, set):BlendMode;
	public var premultipliedAlpha(get, set):Bool;

	var _blendSrc:BlendFactor;
	var _blendDst:BlendFactor;
	var _blendOp:BlendOperation;

	var _alphaBlendDst:BlendFactor;
	var _alphaBlendSrc:BlendFactor;
	var _alphaBlendOp:BlendOperation;

	var _texture:Texture;
	var _vertexBuffer:VertexBuffer;
	var _indexBuffer:IndexBuffer;
	var _regionScaled:Rectangle;
	var _premultipliedAlpha:Bool;


	public function new(?vertices:Array<Vertex>, ?indices:Array<Int>, ?texture:Texture) {
		
		super();

		locked = false;
		_premultipliedAlpha = true;

    	this.vertices = vertices != null ? vertices : [];
		this.indices = indices != null ? indices : [];
		this.texture = texture;
		_regionScaled = new Rectangle();

		color = new Color();

		blendMode = BlendMode.NORMAL;

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
			p.setBlending(_blendSrc, _blendDst, _blendOp, _alphaBlendSrc, _alphaBlendDst, _alphaBlendOp);

			if(locked) {
				#if !noDebugConsole
				p.stats.locked++;
				#end
				p.drawFromBuffers(_vertexBuffer, _indexBuffer);
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
			if(_vertexBuffer.count() != vertices.length * 8) {
				clearBuffers();
				setupLockedBuffers();
			}

			updateLockedBuffer();
		}
		
	}

	public function setBlending(
		blendSrc:BlendFactor, 
		blendDst:BlendFactor, 
		?blendOp:BlendOperation, 
		?alphaBlendSrc:BlendFactor, 
		?alphaBlendDst:BlendFactor, 
		?alphaBlendOp:BlendOperation
	) {
		
		_blendSrc = blendSrc;
		_blendDst = blendDst;
		_blendOp = blendOp != null ? blendOp : BlendOperation.Add;	

		_alphaBlendSrc = alphaBlendSrc != null ? alphaBlendSrc : blendSrc;
		_alphaBlendDst = alphaBlendDst != null ? alphaBlendDst : blendDst;
		_alphaBlendOp = alphaBlendOp != null ? alphaBlendOp : blendOp;	

	}

	function setupLockedBuffers() {

		var sh = shader != null ? shader : shaderDefault;

		_vertexBuffer = new VertexBuffer(
			vertices.length,
			sh.pipeline.inputLayout[0],
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
			data.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
			data.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);

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

	function set_blendMode(v:BlendMode):BlendMode {

		blendMode = v;
		updateBlending();

		return blendMode;
		
	}

	inline function get_premultipliedAlpha():Bool {

		return _premultipliedAlpha;
		
	}

	function set_premultipliedAlpha(v:Bool):Bool {

		_premultipliedAlpha = v;
		updateBlending();

		return _premultipliedAlpha;
		
	}

	function updateBlending() {

		if(_premultipliedAlpha) {
			switch (blendMode) {
				case BlendMode.NONE: setBlending(BlendFactor.BlendOne, BlendFactor.BlendZero);
				case BlendMode.NORMAL: setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceAlpha);
				case BlendMode.ADD: setBlending(BlendFactor.BlendOne, BlendFactor.BlendOne);
				case BlendMode.MULTIPLY: setBlending(BlendFactor.DestinationColor, BlendFactor.InverseSourceAlpha);
				case BlendMode.SCREEN: setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceColor);
				case BlendMode.ERASE: setBlending(BlendFactor.BlendZero, BlendFactor.InverseSourceAlpha);
				case BlendMode.MASK: setBlending(BlendFactor.BlendZero, BlendFactor.SourceAlpha); //TODO: test this
				case BlendMode.BELOW: setBlending(BlendFactor.InverseDestinationAlpha, BlendFactor.DestinationAlpha); //TODO: test this
			}
		} else {
			switch (blendMode) {
				case BlendMode.NONE: setBlending(BlendFactor.BlendOne, BlendFactor.BlendZero);
				case BlendMode.NORMAL: setBlending(BlendFactor.SourceAlpha, BlendFactor.InverseSourceAlpha);
				case BlendMode.ADD: setBlending(BlendFactor.SourceAlpha, BlendFactor.DestinationAlpha);
				case BlendMode.MULTIPLY: setBlending(BlendFactor.DestinationColor, BlendFactor.InverseSourceAlpha);
				case BlendMode.SCREEN: setBlending(BlendFactor.SourceAlpha, BlendFactor.BlendOne);
				case BlendMode.ERASE: setBlending(BlendFactor.BlendZero, BlendFactor.InverseSourceAlpha);
				case BlendMode.MASK: setBlending(BlendFactor.BlendZero, BlendFactor.SourceAlpha); //TODO: test this
				case BlendMode.BELOW: setBlending(BlendFactor.InverseDestinationAlpha, BlendFactor.DestinationAlpha); //TODO: test this
			}
		}
		
	}

}
