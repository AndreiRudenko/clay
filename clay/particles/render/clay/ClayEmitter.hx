package clay.particles.render.clay;


// import luxe.Sprite;
import clay.Entity;
import clay.components.graphics.QuadGeometry;
import clay.components.graphics.Texture;
import clay.render.Layer;
import clay.render.types.BlendMode;
import clay.particles.ParticleEmitter;
import clay.particles.core.ParticleData;
import clay.particles.core.Particle;
import clay.data.Color;


class ClayEmitter extends EmitterRenderer {


	var texture:Texture;
	var layer:Layer;


	public function new(_renderer:ClayRenderer, _emitter:ParticleEmitter) {

		super(_emitter);

		layer = Clay.renderer.layers.get(emitter.layer);

	}

	override function init() {

		texture = Clay.resources.texture(emitter.image_path);

	}

	override function destroy() {

		texture = null;
		layer = null;

	}
	
	override function onspritecreate(p:Particle):ParticleData {

		var q = new QuadGeometry({texture: texture, layer: emitter.layer, order: Std.int(emitter.depth)});
		q.color = new Color();

		return new ParticleData(q);

	}

	override function onspritedestroy(pd:ParticleData) {

		var geom:QuadGeometry = pd.sprite;
		layer.remove(geom);
		geom.destroy();

	}

	override function onspriteshow(pd:ParticleData) {

		var geom:QuadGeometry = pd.sprite;

		if(geom != null && !geom.added) {
			layer.add(geom);
		}

	}

	override function onspritehide(pd:ParticleData) {

		var geom:QuadGeometry = pd.sprite;

		if(geom != null && geom.added) {
			layer.remove(geom);
		}

	}

	override function onspriteupdate(pd:ParticleData) {

		var geom:QuadGeometry = pd.sprite;
		var color:Color = pd.color;

		geom.transform_matrix.identity()
		.translate(pd.x, pd.y)
		.rotate(pd.r) // todo: check radians ?
		.scale(pd.s, pd.s);

		if(pd.centered) {
			geom.transform_matrix.apply(-pd.w*0.5, -pd.h*0.5);
		} else {
			geom.transform_matrix.apply(-pd.ox, -pd.oy);
		}
		
		if(pd.w != geom.size.x || pd.h != geom.size.y) {
			geom.size.set(pd.w, pd.h);
		}

		geom.color.copy_from(pd.color);

	}

	override function onspritedepth(pd:ParticleData, depth:Float) {

		var geom:QuadGeometry = pd.sprite;
		geom.order = Std.int(depth);

	}

	override function onspritetexture(pd:ParticleData, path:String) {

		var geom:QuadGeometry = pd.sprite;
		var tex = Clay.resources.texture(path);
		geom.texture = tex;

	}

	override function onblendsrc(v:clay.particles.data.BlendMode) {

		// var sprite:Sprite;
		// for (pd in emitter.particles_data) {
		// 	sprite = pd.sprite;
		// 	sprite.blend_src = blend_convert(v);
		// }

	}

	override function onblenddest(v:clay.particles.data.BlendMode) {

		// var sprite:Sprite;
		// for (pd in emitter.particles_data) {
		// 	sprite = pd.sprite;
		// 	sprite.blend_dest = blend_convert(v);
		// }

	}

	override function onlayerchanged(v:Int) {

		for (pd in emitter.particles_data) {
			pd.sprite.layer = v;
		}

	}

	function blend_convert(v:clay.particles.data.BlendMode):BlendMode {

		switch (v) {
			case clay.particles.data.BlendMode.zero :{
				return BlendMode.BlendZero;
			}
			case clay.particles.data.BlendMode.one :{
				return BlendMode.BlendOne;
			}
			case clay.particles.data.BlendMode.src_color :{
				return BlendMode.SourceColor;
			}
			case clay.particles.data.BlendMode.one_minus_src_color :{
				return BlendMode.InverseSourceColor;
			}
			case clay.particles.data.BlendMode.src_alpha :{
				return BlendMode.SourceAlpha;
			}
			case clay.particles.data.BlendMode.one_minus_src_alpha :{
				return BlendMode.InverseSourceAlpha;
			}
			case clay.particles.data.BlendMode.dst_alpha :{
				return BlendMode.DestinationAlpha;
			}
			case clay.particles.data.BlendMode.one_minus_dst_alpha :{
				return BlendMode.InverseDestinationAlpha;
			}
			case clay.particles.data.BlendMode.dst_color :{
				return BlendMode.DestinationColor;
			}
			case clay.particles.data.BlendMode.one_minus_dst_color :{
				return BlendMode.InverseDestinationColor;
			}
			case clay.particles.data.BlendMode.src_alpha_saturate :{
				return BlendMode.BlendZero; // not implemented
			}
		}
		
	}

}
