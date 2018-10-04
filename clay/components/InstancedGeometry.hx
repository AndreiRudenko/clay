package clay.components;


import clay.math.Vector;
import clay.data.Color;
import clay.render.Shader;
import clay.components.Texture;
import clay.components.Geometry;
import clay.components.Transform;
import clay.utils.Log.*;

import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

using clay.render.utils.FastMatrix3Extender;


class InstancedGeometry extends Geometry {


	public var instances(default, null):Array<InstanceData>;
	public var instances_count(get, set):Int;
	var _instances_count:Int = 0;

	@:noCompletion public var vertexbuffers(default, null):Array<VertexBuffer>;
	@:noCompletion public var indexbuffer(default, null):IndexBuffer;


	public function new(_options:InstancedGeometryOptions) {

		super(_options);

		_instances_count = _options.instances;

		vertexbuffers = [];
		instances = [];

		geometry_type = GeometryType.instanced;

	}

	@:noCompletion public function update_instances(_mat:kha.math.FastMatrix3) {

		var inst:InstanceData;
		var mvp = kha.math.FastMatrix3.identity();
		var data = vertexbuffers[1].lock();
		var n:Int = 0;
		for (i in 0..._instances_count) {
			inst = instances[i];
			inst.transform.update();

			mvp.setFrom(_mat);
			mvp.append_matrix(inst.transform.world);

			// transform
			data.set(n++, mvp._00);		
			data.set(n++, mvp._01);		
			data.set(n++, 0);			
			data.set(n++, 0);		
			
			data.set(n++, mvp._10);		
			data.set(n++, mvp._11);		
			data.set(n++, 0);			
			data.set(n++, 0);		
			
			data.set(n++, 0);		
			data.set(n++, 0);		
			data.set(n++, 1);			
			data.set(n++, 0);		
			
			data.set(n++, mvp._20);		
			data.set(n++, mvp._21);		
			data.set(n++, 0);		
			data.set(n++, 1);	

			// color
			data.set(n++, inst.color.r);		
			data.set(n++, inst.color.g);		
			data.set(n++, inst.color.b);		
			data.set(n++, inst.color.a);

			if(texture != null) {
				data.set(n++, inst.texture_offset.x);		
				data.set(n++, inst.texture_offset.y);	
			}

		}
		vertexbuffers[1].unlock();

	}

	override function onadded() {

	    setup_buffers(_instances_count);

	}

	function setup_buffers(inst_count:Int) {

		instances.splice(0, instances.length);

		var inst:InstanceData;
		for (i in 0...inst_count) {
			inst = new InstanceData(this);
			instances.push(inst);
		}
		
		if(_texture != null) {
			setup_textured_buffers(inst_count);
		} else {
			setup_colored_buffers(inst_count);
		}

		indexbuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);
		
		var idata = indexbuffer.lock();
		for (i in 0...idata.length) {
			idata[i] = indices[i];
		}
		indexbuffer.unlock();

	}

	inline function setup_colored_buffers(inst_count:Int) {

		var sh = Clay.renderer.shader_instanced;
		
		// vertex pos
		vertexbuffers[0] = new VertexBuffer(
			vertices.length * 2,
			sh.inputLayout[0],
			Usage.StaticUsage
		);

		var data = vertexbuffers[0].lock();
		for (i in 0...vertices.length) {
			data.set(i * 2 + 0, vertices[i].pos.x);		
			data.set(i * 2 + 1, vertices[i].pos.y);		
		}		
		vertexbuffers[0].unlock();

		// color, transform
		vertexbuffers[1] = new VertexBuffer(
			inst_count,
			sh.inputLayout[1],
			Usage.StaticUsage,
			1
		);

	}

	inline function setup_textured_buffers(inst_count:Int) {

		var sh = Clay.renderer.shader_instanced_textured;

		// vertex pos, tcoord
		vertexbuffers[0] = new VertexBuffer(
			vertices.length * 2,
			sh.inputLayout[0],
			Usage.StaticUsage
		);

		var data = vertexbuffers[0].lock();
		for (i in 0...vertices.length) {
			data.set(i * 4 + 0, vertices[i].pos.x);		
			data.set(i * 4 + 1, vertices[i].pos.y);		
			data.set(i * 4 + 2, vertices[i].tcoord.x);		
			data.set(i * 4 + 3, vertices[i].tcoord.y);		
		}		
		vertexbuffers[0].unlock();

		// color, transform, texture_offset
		vertexbuffers[1] = new VertexBuffer(
			inst_count,
			sh.inputLayout[1],
			Usage.StaticUsage,
			1
		);

	}

	override function set_texture(v:Texture):Texture {

		super.set_texture(v);

		if(added) {
			setup_buffers(_instances_count);
		}

		return v;
	    
	}

	inline function get_instances_count():Int {
		
		return _instances_count;

	}

	function set_instances_count(v:Int):Int {

		if(v > _instances_count) {
			setup_buffers(v);
		}

		return _instances_count = v;
		
	}

	
}


class InstanceData {


	public var transform:Transform;
	public var color:Color;
	public var texture_offset:Vector; // todo: make this work

	var geom:InstancedGeometry;


	public function new(_geom:InstancedGeometry) {

		geom = _geom;

		transform = new Transform();
		color = new Color();
		texture_offset = new Vector();
		
	}

}


typedef InstancedGeometryOptions = {

	>GeometryOptions,

	var instances:Int;
	// @:optional var quad_size:Int;
	
}
