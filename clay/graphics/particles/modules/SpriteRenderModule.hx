package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Size;
import clay.graphics.particles.components.Scale;
import clay.graphics.particles.components.Rotation;
import clay.graphics.particles.components.Origin;
import clay.graphics.particles.components.Region;
import clay.graphics.particles.ParticleEmitter;
import clay.graphics.Sprite;
import clay.graphics.shapes.Quad;
import clay.utils.Mathf;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.math.Rectangle;
import clay.math.Transform;
import clay.math.Matrix;
import clay.render.Painter;
import clay.resources.Texture;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;

// import haxe.ds.Vector;


class SpriteRenderModule extends ParticleModule {


	public var texture(default, set):Texture;
	public var region(default, set):Rectangle;

	public var blendSrc:BlendMode;
	public var blendDst:BlendMode;
	public var blendEq:BlendEquation;
	public var alphaBlendSrc:BlendMode;
	public var alphaBlendDst:BlendMode;
	public var alphaBlendEq:BlendEquation;

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

		_count = 0;
		_matrix = new Matrix();
		_regionScaled = new Rectangle();
		_regionTmp = new Rectangle();

		region = options.region;
		texture = options.texture;

		blendSrc = options.blendSrc != null ? options.blendSrc : BlendMode.BlendOne;
		blendDst = options.blendDst != null ? options.blendDst : BlendMode.InverseSourceAlpha;
		blendEq = options.blendEq != null ? options.blendEq : BlendEquation.Add;

		alphaBlendSrc = options.alphaBlendSrc != null ? options.alphaBlendSrc : BlendMode.BlendOne;
		alphaBlendDst = options.alphaBlendDst != null ? options.alphaBlendDst : BlendMode.InverseSourceAlpha;
		alphaBlendEq = options.alphaBlendEq != null ? options.alphaBlendEq : BlendEquation.Add;

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

		g.setBlendMode(blendSrc, blendDst, blendEq, alphaBlendSrc, alphaBlendDst, alphaBlendEq);
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
		// trace('render: ${particle.id}, region: ${reg}');
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

	@:optional var blendSrc:BlendMode;
	@:optional var blendDst:BlendMode;
	@:optional var blendEq:BlendEquation;
	@:optional var alphaBlendSrc:BlendMode;
	@:optional var alphaBlendDst:BlendMode;
	@:optional var alphaBlendEq:BlendEquation;

}

