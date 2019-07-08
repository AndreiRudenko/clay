package clay.graphics;


import kha.Kravur;
import kha.Kravur.AlignedQuad;
import kha.Kravur.KravurImage;

import clay.math.Vector;
import clay.math.Matrix;
import clay.render.Color;
import clay.render.Shader;
import clay.render.Vertex;
import clay.render.RenderPath;
import clay.render.GeometryType;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.resources.FontResource;
import clay.resources.Texture;
import clay.graphics.Mesh;
import clay.utils.Log.*;
import clay.utils.ArrayTools;


class Text extends Mesh {


	public var text          	(default, set):String;
	public var font          	(default, set):FontResource;
	public var size          	(default, set):Int; // expensive
	public var align         	(default, set):TextAlign;
	public var align_vertical	(default, set):TextAlign;

	public var width         	(default, set):Float;
	public var height        	(default, set):Float;
	public var line_spacing  	(default, set):Float;
	public var letter_spacing	(default, set):Float;

	public var text_width 		(default, null):Float = 0;
	public var text_height		(default, null):Float = 0;

	public var text_colors:Array<Color>;

	var _size_dirty:Bool = true;
	var _font_dirty:Bool = true;

	var _setup:Bool = true;
	var _kravur:KravurImage;
	var _lines:Array<String>;


	public function new(font:FontResource) {

		_lines = [];
		text_colors = [];

		super();

		shader_default = Clay.renderer.shaders.get('text');
		sort_key.geomtype = GeometryType.quadpack;

		this.font = font;

		text = '';
		size = 12;
		align = TextAlign.left;
		align_vertical = TextAlign.top;
		width = 0;
		height = 0;
		line_spacing = 0;
		letter_spacing = 0;

		_setup = false;

		set_blendmode(BlendMode.SourceAlpha, BlendMode.InverseSourceAlpha, BlendEquation.Add);
		update_text();

	}

	public function add_text(_text:String, ?_color:Color) {

		var start = text.length;

		for (i in 0..._text.length) {
			text_colors[start + i] = _color;
		}
		text += _text;
		
	}

	override function render_geometry(r:RenderPath, c:Camera) {

		r.set_object_renderer(r.quadpack_renderer);
		r.quadpack_renderer.render(this);

	}

	function find_index(charCode: Int):Int {

		var glyphs = kha.graphics2.Graphics.fontGlyphs;
		var blocks = KravurImage.charBlocks;
		var offset = 0;
		for (i in 0...Std.int(blocks.length / 2)) {
			var start = blocks[i * 2];
			var end = blocks[i * 2 + 1];
			if (charCode >= start && charCode <= end) {
				return offset + charCode - start;
			}
			offset += end - start + 1;
		}

		return 0;

	}

	function split_in_lines(text:String, kravur:KravurImage):Array<String> {

		ArrayTools.clear(_lines); 

		var space_code:Int = ' '.code;
		var newline_code:Int = '\n'.code;
		var char_code:Int;
		var rest_pos:Int = 0;

		if(width > 0 || height > 0) {

			var line_height:Float = kravur.getHeight() + line_spacing;
			var text_height:Float = 0;
			var stop:Bool = false;

			inline function check_height():Bool {

				text_height += line_height;
				return height > 0 && text_height > (height - line_spacing);

			}

			if(width > 0) {
			
				var char_width:Float;
				var line_width:Float = 0;
				var word_idx:Int = 0;
				var last_break_width:Float = 0;
				var space_char:Bool = false;
				var newline_char:Bool = false;

				var i:Int = 0;
				while(i < text.length) {
					char_code = text.charCodeAt(i);

					char_width = @:privateAccess kravur.getCharWidth(char_code) + letter_spacing;
					space_char = char_code == space_code;
					newline_char = char_code == newline_code;

					if(space_char) {
						line_width += char_width;
						last_break_width = line_width;
						word_idx = i;
					} else if(newline_char) {
						if(check_height()) {
							stop = true;
							break;
						}
						line_width = 0;
						_lines.push(text.substr(rest_pos, i - rest_pos));
						rest_pos = i + 1;
					} else if((line_width + char_width - letter_spacing) > width) {
						if(last_break_width > 0) {
							if(check_height()) {
								stop = true;
								break;
							}
							line_width += char_width;
							_lines.push(text.substr(rest_pos, word_idx - rest_pos));
							line_width = line_width - last_break_width;
							last_break_width = 0;
							rest_pos = word_idx + 1;
						} else {
							if(i == 0) {
								break;
							}
							i--;
							if(check_height()) {
								stop = true;
								break;
							}
							_lines.push(text.substr(rest_pos, i + 1 - rest_pos));
							line_width = 0;
							last_break_width = 0;
							rest_pos = i + 1;
						}
					} else {
						line_width += char_width;
					}
					
					i++;

				}

			} else {
				for (i in 0...text.length) {
					char_code = text.charCodeAt(i);
					if(char_code == newline_code) {
						if(check_height()) {
							stop = true;
							break;
						}
						_lines.push(text.substr(rest_pos, i - rest_pos));
						rest_pos = i + 1;
					}
				}
			}

			if(!stop && rest_pos < text.length) {
				if(!check_height()) {
					_lines.push(text.substr(rest_pos, text.length - rest_pos));
				}
			}

		} else {
			for (i in 0...text.length) {
				char_code = text.charCodeAt(i);
				if(char_code == newline_code) {
					_lines.push(text.substr(rest_pos, i - rest_pos));
					rest_pos = i + 1;
				}
			}
			if(rest_pos < text.length) {
				_lines.push(text.substr(rest_pos, text.length - rest_pos));
			}
		}

		return _lines;

	}

	@:noCompletion public function update_text() {

		if(_setup) {
			return;
		}

		if(_font_dirty || _size_dirty) {
			_kravur = font.font._get(size); // note: this is expensive if creating new font or font size
			texture = font.get(size);
			_font_dirty = false;
			_size_dirty = false;
		}

		var n:Int = 0;

		if(text.length > 0) {

			var lines = split_in_lines(text, _kravur);

			var quad_cache = new AlignedQuad();

			var _text_width:Float = 0;
			var font_heght:Float = _kravur.getHeight();
			text_width = 0;
			text_height = (font_heght + line_spacing) * lines.length;

			var xoffset:Float = 0;
			var yoffset:Float = 0;

			var img = texture.image;
			var custom_colors = text_colors.length != 0;
			var _color = color;

			var w_ratio:Float = img.width / img.realWidth;
			var h_ratio:Float = img.height / img.realHeight;

			switch (align_vertical) {
				case TextAlign.bottom:{
					yoffset = height - text_height;
				}
				case TextAlign.center:{
					yoffset = height*0.5 - text_height/2;
				}
				default:{
					yoffset = 0;
				}
			}

			for (l in lines) {
				
				if(l != null && l.length > 0) {

					_text_width = _kravur.stringWidth(l) + (l.length * letter_spacing);

					if(_text_width > text_width) {
						text_width = _text_width;
					}

					var xpos:Float = 0;

					switch (align) {
						case TextAlign.right:{
							xoffset = width-_text_width;
						}
						case TextAlign.center:{
							xoffset = width*0.5-_text_width/2;
						}
						default:{
							xoffset = 0;
						}
					}

					var lw:Float = 0;

					for (i in 0...l.length) {
						if(custom_colors) {
							_color = text_colors[n];
							if(_color == null) {
								_color = color;
							}
						}
						var cidx = find_index(l.charCodeAt(i));
						var q:AlignedQuad = _kravur.getBakedQuad(quad_cache, cidx, xpos, 0);
						if (q != null) {
							lw = q.xadvance + letter_spacing;

							if(cidx > 0) { // skip space

								if(vertices[n*4] == null) {
									vertices[n*4] = new Vertex();
									vertices[n*4+1] = new Vertex();
									vertices[n*4+2] = new Vertex();
									vertices[n*4+3] = new Vertex();
								}

								var t0x = q.s0 * w_ratio;
								var t0y = q.t0 * h_ratio;
								var t1x = q.s1 * w_ratio;
								var t1y = q.t1 * h_ratio;

								var v0 = vertices[n*4];
								var v1 = vertices[n*4+1];
								var v2 = vertices[n*4+2];
								var v3 = vertices[n*4+3];

								v0.pos.set(q.x0+xoffset, q.y1+yoffset);
								v0.tcoord.set(t0x, t1y);
								v0.color = _color;

								v1.pos.set(q.x0+xoffset, q.y0+yoffset);
								v1.tcoord.set(t0x, t0y);
								v1.color = _color;

								v2.pos.set(q.x1+xoffset, q.y0+yoffset);
								v2.tcoord.set(t1x, t0y);
								v2.color = _color;

								v3.pos.set(q.x1+xoffset, q.y1+yoffset);
								v3.tcoord.set(t1x, t1y);
								v3.color = _color;

								n++;
							}

							xpos += lw;
						}
					}
				}

				yoffset += font_heght + line_spacing;

			}
		}

		if(vertices.length > n*4) {
			vertices.splice(n*4, vertices.length);
		}

	}

	function set_text(v:String):String {

		if(text != v) {
			text = v;

			if(text_colors.length > text.length) {
				text_colors.splice(text.length, text_colors.length - text.length);
			}

			update_text();
		}

		return text;
		
	}

	function set_font(v:FontResource):FontResource {

		font = v;
		_font_dirty = true;

		update_text();

		return font;
		
	}

	function set_size(v:Int):Int {

		size = v;
		_size_dirty = true;

		update_text();

		return size;
		
	}

	function set_align(v:TextAlign):TextAlign {

		align = v;
		update_text();

		return align;
		
	}

	function set_align_vertical(v:TextAlign):TextAlign {

		align_vertical = v;
		update_text();

		return align_vertical;
		
	}

	function set_line_spacing(v:Float):Float {

		line_spacing = v;

		update_text();

		return line_spacing;
		
	}

	function set_width(v:Float):Float {


		if(width != v) {
			width = v;
			update_text();
		}

		return width;
		
	}

	function set_height(v:Float):Float {

		if(height != v) {
			height = v;
			update_text();
		}

		return height;
		
	}

	function set_letter_spacing(v:Float):Float {

		letter_spacing = v;

		update_text();

		return letter_spacing;
		

	}

	override function set_color(v:Color):Color {

		text_colors.splice(0, text_colors.length);

		super.set_color(v);

		return v;

	}
	

}

@:enum abstract TextAlign(Int) from Int to Int {

	var left = 0;
	var right = 1;
	var center = 2;
	var top = 3;
	var bottom = 4;

}
