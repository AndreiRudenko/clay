package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Size;
import clay.graphics.particles.components.Scale;
import clay.graphics.particles.components.Rotation;
import clay.graphics.particles.components.Origin;
import clay.graphics.particles.components.Region;
import clay.utils.Mathf;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.render.Painter;
import clay.resources.Texture;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;


class SpriteRenderModule extends ParticleModule {


	public var texture(default, set):Texture;
	public var region(default, set):Rectangle;

	public var blendMode(default, set):BlendMode;
	public var premultipliedAlpha(get, set):Bool;

	var _blendSrc:BlendFactor;
	var _blendDst:BlendFactor;
	var _blendOp:BlendOperation;
	var _alphaBlendSrc:BlendFactor;
	var _alphaBlendDst:BlendFactor;
	var _alphaBlendOp:BlendOperation;

	var _premultipliedAlpha:Bool;

	var _matrix:Matrix;
	var _regionScaled:Rectangle;
	var _regionTmp:Rectangle;
	var _count:Int;

	var _size:Components<Size>;
	var _scale:Components<Scale>;
	var _color:Components<Color>;
	var _rotation:Components<Rotation>;
	var _origin:Components<Origin>;
	var _region:Components<Region>;

	var _sizeDefault:Size;
	var _scaleDefault:Scale;
	var _colorDefault:Color;
	var _rotationDefault:Rotation;
	var _originDefault:Origin;
	
	var _pSortTmp:haxe.ds.Vector<ParticleSprite>;
	var _particleSprites:haxe.ds.Vector<ParticleSprite>;


	public function new(options:SpriteRenderModuleOptions) {

		super({});

		_premultipliedAlpha = true;
		_count = 0;
		_matrix = new Matrix();
		_regionScaled = new Rectangle();
		_regionTmp = new Rectangle();

		region = options.region;
		texture = options.texture;

		_blendSrc = options.blendSrc != null ? options.blendSrc : BlendFactor.BlendOne;
		_blendDst = options.blendDst != null ? options.blendDst : BlendFactor.InverseSourceAlpha;
		_blendOp = options.blendOp != null ? options.blendOp : BlendOperation.Add;

		_alphaBlendSrc = options.alphaBlendSrc != null ? options.alphaBlendSrc : BlendFactor.BlendOne;
		_alphaBlendDst = options.alphaBlendDst != null ? options.alphaBlendDst : BlendFactor.InverseSourceAlpha;
		_alphaBlendOp = options.alphaBlendOp != null ? options.alphaBlendOp : BlendOperation.Add;

		blendMode = options.blendMode != null ? options.blendMode : BlendMode.NORMAL;

		if(options.premultipliedAlpha != null) {
			premultipliedAlpha = options.premultipliedAlpha;
		}

	}

	override function init() {

		_size = emitter.components.get(Size, false);
		_scale = emitter.components.get(Scale, false);
		_color = emitter.components.get(Color, false);
		_rotation = emitter.components.get(Rotation, false);
		_origin = emitter.components.get(Origin, false);
		_region = emitter.components.get(Region, false);

		_sizeDefault = new Size(32, 32);
		_scaleDefault = 1;
		_colorDefault = new Color(1,1,1,1);
		_rotationDefault = 0;
		_originDefault = new Origin(0.5, 0.5);

		if(_size != null) {
			for (i in 0...emitter.particles.capacity) {
				_size.get(i).copyFrom(_sizeDefault);
			}
		}

		if(_origin != null) {
			for (i in 0...emitter.particles.capacity) {
				_origin.get(i).copyFrom(_originDefault);
			}
		}

		if(_scale != null) {
			for (i in 0...emitter.particles.capacity) {
				_scale.set(i, _scaleDefault);
			}
		}

		if(_region != null) {
			for (i in 0...emitter.particles.capacity) {
				_region.get(i).set(0,0,1,1);
			}
		}

		_particleSprites = new haxe.ds.Vector(emitter.particles.capacity);
		_pSortTmp = new haxe.ds.Vector(emitter.particles.capacity);

		var p:Particle;
		for (i in 0...emitter.particles.capacity) {
			p = emitter.particles.get(i);
			_particleSprites[p.id] = new ParticleSprite();
		}

	}

	override function render(g:Painter) {

		g.setBlending(_blendSrc, _blendDst, _blendOp, _alphaBlendSrc, _alphaBlendDst, _alphaBlendOp);
		g.setTexture(texture);

		var sortMode = emitter.getSortModeFunc();

		if(sortMode != null) {
			var p:Particle;
			var ps:ParticleSprite;

			_count = emitter.particles.length;

			for (i in 0..._count) {
				p = emitter.particles.get(i);
				ps = _particleSprites[i];
				ps.particleData = p;
				ps.size = _size != null ? _size.get(p.id) : _sizeDefault;
				ps.origin = _origin != null ? _origin.get(p.id) : _originDefault;
				ps.rotation = _rotation != null ? _rotation.get(p.id) : _rotationDefault;
				ps.scale = _scale != null ? _scale.get(p.id) : _scaleDefault;
				ps.color = _color != null ? _color.get(p.id) : _colorDefault;
				ps.region = _region != null ? getRegionScaled(_region.get(p.id)) : _regionScaled;
			}

			_sort(_particleSprites, _pSortTmp, 0, _count-1, sortMode);

			for (i in 0..._count) {
				ps = _particleSprites[i];
				renderParticle(
					g, 
					emitter.system.transform.world.matrix,
					ps.particleData,
					ps.size,
					ps.origin,
					ps.rotation,
					ps.scale,
					ps.color,
					ps.region
				);
			}
		} else {
			for (p in emitter.particles) {
				renderParticle(
					g, 
					emitter.system.transform.world.matrix,
					p,
					_size != null ? _size.get(p.id) : _sizeDefault,
					_origin != null ? _origin.get(p.id) : _originDefault,
					_rotation != null ? _rotation.get(p.id) : _rotationDefault,
					_scale != null ? _scale.get(p.id) : _scaleDefault,
					_color != null ? _color.get(p.id) : _colorDefault,
					_region != null ? getRegionScaled(_region.get(p.id)) : _regionScaled
				);
			}
		}

	}

	inline function renderParticle(
		g:Painter, 
		emitterMatrix:Matrix, 
		particle:Particle, 
		size:Size, 
		origin:Origin, 
		rotation:Float, 
		scale:Float, 
		color:Color, 
		reg:Rectangle
	) {

		g.ensure(4, 6);

		_matrix.copy(emitterMatrix)
		.translate(particle.x, particle.y)
		.rotate(Mathf.radians(-rotation))
		.scale(scale, scale)
		.apply(-origin.x * size.x, -origin.y * size.y);

		g.addIndex(0);
		g.addIndex(1);
		g.addIndex(2);
		g.addIndex(0);
		g.addIndex(2);
		g.addIndex(3);

		g.addVertex(
			_matrix.tx, 
			_matrix.ty, 
			reg.x,
			reg.y,
			color
		);

		g.addVertex(
			_matrix.a * size.x + _matrix.tx, 
			_matrix.b * size.x + _matrix.ty, 
			reg.x + reg.w,
			reg.y,
			color
		);

		g.addVertex(
			_matrix.a * size.x + _matrix.c * size.y + _matrix.tx, 
			_matrix.b * size.x + _matrix.d * size.y + _matrix.ty, 
			reg.x + reg.w,
			reg.y + reg.h,
			color
		);

		g.addVertex(
			_matrix.c * size.y + _matrix.tx, 
			_matrix.d * size.y + _matrix.ty, 
			reg.x,
			reg.y + reg.h,
			color
		);
		
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

	// merge sort
	function _sort(a:haxe.ds.Vector<ParticleSprite>, aux:haxe.ds.Vector<ParticleSprite>, l:Int, r:Int, compare:(p1:Particle, p2:Particle)->Int) { 
		
		if (l < r) {
			var m = Std.int(l + (r - l) / 2);
			_sort(a, aux, l, m, compare);
			_sort(a, aux, m + 1, r, compare);
			_merge(a, aux, l, m, r, compare);
		}

	}

	inline function _merge(a:haxe.ds.Vector<ParticleSprite>, aux:haxe.ds.Vector<ParticleSprite>, l:Int, m:Int, r:Int, compare:(p1:Particle, p2:Particle)->Int) { 

		var k = l;
		while (k <= r) {
			aux[k] = a[k];
			k++;
		}

		k = l;
		var i = l;
		var j = m + 1;
		while (k <= r) {
			if (i > m) a[k] = aux[j++];
			else if (j > r) a[k] = aux[i++];
			else if (compare(aux[j].particleData, aux[i].particleData) < 0) a[k] = aux[j++];
			else a[k] = aux[i++];
			k++;
		}
		
	}

	inline function getRegionScaled(r:Rectangle) {
		
		_regionTmp.set(
			_regionScaled.x + r.x,
			_regionScaled.y + r.y,
			r.w, 
			r.h
		);

		return _regionTmp;

	}

	function updateRegionScaled() {
		
		if(region != null && texture != null) {
			_regionScaled.set(
				region.x / texture.widthActual,
				region.y / texture.heightActual,
				region.w / texture.widthActual,
				region.h / texture.heightActual
			);
		} else {
			_regionScaled.set(0, 0, 1, 1);
		}

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

	function set_texture(v:Texture):Texture {

		texture = v;

		updateRegionScaled();

		return texture;

	}

	function set_region(v:Rectangle):Rectangle {

		region = v;

		updateRegionScaled();

		return region;

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


}

private class ParticleSprite {


	public var particleData:Particle;

	public var size:Size;
	public var scale:Scale;
	public var origin:Origin;
	public var rotation:Float;
	public var color:Color;
	public var region:Region;


	public function new() {}


}


typedef SpriteRenderModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var texture:Texture;
	@:optional var region:Rectangle;

	@:optional var premultipliedAlpha:Bool;
	@:optional var blendMode:BlendMode;

	// custom blending
	@:optional var blendSrc:BlendFactor;
	@:optional var blendDst:BlendFactor;
	@:optional var blendOp:BlendOperation;
	@:optional var alphaBlendSrc:BlendFactor;
	@:optional var alphaBlendDst:BlendFactor;
	@:optional var alphaBlendOp:BlendOperation;

}

