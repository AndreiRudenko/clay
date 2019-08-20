package clay.render.renderers;


import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;


import clay.graphics.Mesh;
import clay.render.Camera;
import clay.resources.Texture;
import clay.utils.Log.*;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.math.Vector;


class StaticRenderer extends ObjectRenderer {


	var g:Graphics;


	override function start() {
		
		g = renderpath.g;

	}

	public function render(geom:Mesh) {

		if(geom.vertexbuffer.count() == 0) {
			return;
		}

		#if !no_debug_console
		renderpath.stats.vertices += geom.vertexbuffer.count();
		renderpath.stats.indices += geom.indexbuffer.count();
		renderpath.stats.locked++;
		#end
		
		var shader = geom.shader != null ? geom.shader : geom.shader_default;
		var texture = geom.texture;

		renderpath.clip(geom.clip_rect);

		if(texture == null) {
			texture = renderpath.texture_blank;
		}

		var texture_loc = shader.set_texture('tex', texture).location;
		shader.set_matrix3('mvpMatrix', renderpath.camera.projection_matrix);

		shader.set_blendmode(
			geom.blend_src, geom.blend_dst, geom.blend_op, 
			geom.alpha_blend_src, geom.alpha_blend_dst, geom.alpha_blend_op
		);

		shader.use(g);
		shader.apply(g);

		g.setVertexBuffer(geom.vertexbuffer);
		g.setIndexBuffer(geom.indexbuffer);

		g.drawIndexedVertices(0, geom.indexbuffer.count());

		g.setTexture(texture_loc, null);

		#if !no_debug_console
		renderpath.stats.draw_calls++;
		#end

	}


}