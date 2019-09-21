package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Size;
import clay.graphics.particles.components.Scale;
import clay.graphics.particles.components.Rotation;
import clay.graphics.particles.components.Origin;
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


	public var texture:Texture;
	public var region:Rectangle;

	public var blendSrc:BlendMode;
	public var blendDst:BlendMode;
	public var blendEq:BlendEquation;
	public var alphaBlendSrc:BlendMode;
	public var alphaBlendDst:BlendMode;
	public var alphaBlendEq:BlendEquation;

	var _matrix:Matrix;
	var _regionScaled:Rectangle;
	var _count:Int;

	var _size:Components<Size>;
	var _scale:Components<Scale>;
	var _color:Components<Color>;
	var _rotation:Components<Rotation>;
	var _origin:Components<Origin>;
	
	var _pSortTmp:haxe.ds.Vector<ParticleSprite>;
	var _particleSprites:haxe.ds.Vector<ParticleSprite>;


	public function new(options:SpriteRenderModuleOptions) {

		super({});

		texture = options.texture;
		region = options.region;

		blendSrc = options.blendSrc != null ? options.blendSrc : BlendMode.BlendOne;
		blendDst = options.blendDst != null ? options.blendDst : BlendMode.InverseSourceAlpha;
		blendEq = options.blendEq != null ? options.blendEq : BlendEquation.Add;

		alphaBlendSrc = options.alphaBlendSrc != null ? options.alphaBlendSrc : BlendMode.BlendOne;
		alphaBlendDst = options.alphaBlendDst != null ? options.alphaBlendDst : BlendMode.InverseSourceAlpha;
		alphaBlendEq = options.alphaBlendEq != null ? options.alphaBlendEq : BlendEquation.Add;

		_count = 0;
		_matrix = new Matrix();
		_regionScaled = new Rectangle();

		
	}

	override function init() {

		_size = emitter.components.get(Size);
		_scale = emitter.components.get(Scale);
		_color = emitter.components.get(Color);
		_rotation = emitter.components.get(Rotation);
		_origin = emitter.components.get(Origin);

		for (i in 0...emitter.particles.capacity) {
			_size.get(i).set(32,32);
			_origin.get(i).set(0.5,0.5);
			_scale.set(i, 1);
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
		updateRegionScaled();

		var sortMode = emitter.getSortModeFunc();

		if(sortMode != null) {
			var p:Particle;
			var ps:ParticleSprite;

			_count = emitter.particles.length;

			for (i in 0..._count) {
				p = emitter.particles.get(i);
				ps = _particleSprites[i];
				ps.particleData = p;
				ps.size = _size.get(p.id);
				ps.origin = _origin.get(p.id);
				ps.rotation = _rotation.get(p.id);
				ps.scale = _scale.get(p.id);
				ps.color = _color.get(p.id);
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
					ps.color
				);
			}
		} else {
			for (p in emitter.particles) {
				renderParticle(
					g, 
					emitter.system.transform.world.matrix,
					p,
					_size.get(p.id),
					_origin.get(p.id),
					_rotation.get(p.id),
					_scale.get(p.id),
					_color.get(p.id)
				);
			}
		}

	}

	inline function renderParticle(g:Painter, emitterMatrix:Matrix, particle:Particle, size:Size, origin:Origin, rotation:Float, scale:Float, color:Color):Void {

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
			_regionScaled.x,
			_regionScaled.y,
			color
		);

		g.addVertex(
			_matrix.a * size.x + _matrix.tx, 
			_matrix.b * size.x + _matrix.ty, 
			_regionScaled.x + _regionScaled.w,
			_regionScaled.y,
			color
		);

		g.addVertex(
			_matrix.a * size.x + _matrix.c * size.y + _matrix.tx, 
			_matrix.b * size.x + _matrix.d * size.y + _matrix.ty, 
			_regionScaled.x + _regionScaled.w,
			_regionScaled.y + _regionScaled.h,
			color
		);

		g.addVertex(
			_matrix.c * size.y + _matrix.tx, 
			_matrix.d * size.y + _matrix.ty, 
			_regionScaled.x,
			_regionScaled.y + _regionScaled.h,
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

	inline function updateRegionScaled() {
		
		if(region == null || texture == null) {
			_regionScaled.set(0, 0, 1, 1);
		} else {
			_regionScaled.set(
				_regionScaled.x = region.x / texture.widthActual,
				_regionScaled.y = region.y / texture.heightActual,
				_regionScaled.w = region.w / texture.widthActual,
				_regionScaled.h = region.h / texture.heightActual
			);
		}

	}


}

private class ParticleSprite {


	public var particleData:Particle;

	public var size:Size;
	public var scale:Scale;
	public var origin:Origin;
	public var rotation:Float;
	public var color:Color;


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

