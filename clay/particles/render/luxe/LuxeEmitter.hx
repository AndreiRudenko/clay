package sparkler.render.luxe;


import luxe.Sprite;
import phoenix.Texture;
import phoenix.Batcher;
import sparkler.ParticleEmitter;
import sparkler.core.ParticleData;
import sparkler.core.Particle;
import sparkler.data.Color;


class LuxeEmitter extends EmitterRenderer {


	var texture:Texture;
	var batcher:Batcher;


	public function new(_renderer:LuxeRenderer, _emitter:ParticleEmitter) {

		super(_emitter);

		batcher = _renderer.batcher;

	}

	override function init() {

		texture = Luxe.resources.texture(emitter.image_path);

	}

	override function destroy() {

		texture = null;
		batcher = null;

	}
	
	override function onspritecreate(p:Particle):ParticleData {

		var sprite = new Sprite({
			name: 'particle_'+p.id,
			depth: emitter.depth,
			texture: texture,
			no_scene: true,
			no_batcher_add: true
		});

		return new ParticleData(sprite);

	}

	override function onspritedestroy(pd:ParticleData) {

		var sprite:Sprite = pd.sprite;
		sprite.destroy();

	}

	override function onspriteshow(pd:ParticleData) {

		var sprite:Sprite = pd.sprite;

		var geom = sprite.geometry;
		if(geom != null && !geom.added) {
			batcher.add(geom);
		}

	}

	override function onspritehide(pd:ParticleData) {

		var sprite:Sprite = pd.sprite;

		var geom = sprite.geometry;
		if(geom != null && geom.added) {
			batcher.remove(geom);
		}

	}

	override function onspriteupdate(pd:ParticleData) {

		var sprite:Sprite = pd.sprite;
		var color:Color = pd.color;

		// position
		if(pd.x != sprite.pos.x) {
			sprite.pos.x = pd.x;
		}
		
		if(pd.y != sprite.pos.y) {
			sprite.pos.y = pd.y;
		}

		// size
		if(pd.w != sprite.size.x) {
			sprite.size.x = pd.w;
		}
		
		if(pd.h != sprite.size.y) {
			sprite.size.y = pd.h;
		}

		// rotation
		if(pd.r != sprite.rotation_z) {
			sprite.rotation_z = pd.r;
		}

		// scale
		if(pd.s != sprite.scale.x) {
			sprite.scale.set_xy(pd.s,pd.s);
		}

		// color
		if(color.r != sprite.color.r) {
			sprite.color.r = color.r;
		}

		if(color.g != sprite.color.g) {
			sprite.color.g = color.g;
		}

		if(color.b != sprite.color.b) {
			sprite.color.b = color.b;
		}

		if(color.a != sprite.color.a) {
			sprite.color.a = color.a;
		}

	}

	override function onspritedepth(pd:ParticleData, depth:Float) {

		var sprite:Sprite = pd.sprite;
		sprite.depth = depth;

	}

	override function onspritetexture(pd:ParticleData, path:String) {

		var sprite:Sprite = pd.sprite;
		var tex = Luxe.resources.texture(path);
		sprite.texture = tex;

	}

	override function onblendsrc(v:sparkler.data.BlendMode) {

		var sprite:Sprite;
		for (pd in emitter.particles_data) {
			sprite = pd.sprite;
			sprite.blend_src = blend_convert(v);
		}

	}

	override function onblenddest(v:sparkler.data.BlendMode) {

		var sprite:Sprite;
		for (pd in emitter.particles_data) {
			sprite = pd.sprite;
			sprite.blend_dest = blend_convert(v);
		}

	}

	function blend_convert(v:sparkler.data.BlendMode):BlendMode {

		switch (v) {
			case sparkler.data.BlendMode.zero :{
				return BlendMode.zero;
			}
			case sparkler.data.BlendMode.one :{
				return BlendMode.one;
			}
			case sparkler.data.BlendMode.src_color :{
				return BlendMode.src_color;
			}
			case sparkler.data.BlendMode.one_minus_src_color :{
				return BlendMode.one_minus_src_color;
			}
			case sparkler.data.BlendMode.src_alpha :{
				return BlendMode.src_alpha;
			}
			case sparkler.data.BlendMode.one_minus_src_alpha :{
				return BlendMode.one_minus_src_alpha;
			}
			case sparkler.data.BlendMode.dst_alpha :{
				return BlendMode.dst_alpha;
			}
			case sparkler.data.BlendMode.one_minus_dst_alpha :{
				return BlendMode.one_minus_dst_alpha;
			}
			case sparkler.data.BlendMode.dst_color :{
				return BlendMode.dst_color;
			}
			case sparkler.data.BlendMode.one_minus_dst_color :{
				return BlendMode.one_minus_dst_color;
			}
			case sparkler.data.BlendMode.src_alpha_saturate :{
				return BlendMode.src_alpha_saturate;
			}
		}
		
	}

}
