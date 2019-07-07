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
	public var tab_width     	(default, set):Int;
	public var wrap          	(default, set):Bool;

    public var text_width 		(default, null):Float = 0;
    public var text_height		(default, null):Float = 0;

	public var text_colors:Array<Color>;


	// var split_regex:EReg;
	// var tab_regex:EReg;

	// var tab_string:String;

	var size_dirty:Bool = true;
	var font_dirty:Bool = true;

	var _setup:Bool = true;
	var _kravur:KravurImage;


	public function new(options:TextOptions) {

		text_colors = [];

		super();

		// tab_string = '';
		// split_regex = new EReg('(?:\r\n|\r|\n)', 'g');
		// tab_regex = new EReg('\t', 'gim');

		shader_default = Clay.renderer.shaders.get('text');
		sort_key.geomtype = GeometryType.quadpack;

		font = def(options.font, Clay.renderer.font);
		size = def(options.size, 12);
		text = def(options.text, '');
		align = def(options.align, TextAlign.left);
		align_vertical = def(options.align_vertical, TextAlign.top);
		width = def(options.width, 0);
		height = def(options.height, 0);
		line_spacing = def(options.line_spacing, 0);
		letter_spacing = def(options.letter_spacing, 0);
		tab_width = def(options.tab_width, 4);
		wrap = def(options.wrap, false);

		if(options.text_colors != null) {
			text_colors = options.text_colors;
		}

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

	// see heaps h2d.Text
/*
	function split_in_lines(_text:String, _font:KravurImage):Array<String> {

		var txt = tab_regex.replace(_text, tab_string);
		var lines = split_regex.split(txt);

		if(!wrap || (width == 0 && height == 0)) {
			return lines;
		}

		inline function in_hb(th:Float) return height > 0 && height <= th-line_spacing;

        var parsed_lines:Array<String> = [];

		var _text_height:Float = _font.getHeight() + line_spacing;
		var space_width:Float = _font.stringWidth(' ') + letter_spacing;
		var _stop:Bool = false;
		var th:Float = 0;
		for (line in lines) {
			var i:Int = 0;
			var lw:Float = 0;
			var result:String = '';
			var words = line.split(" ");
			th += _text_height;

			for (word in words) {

				if(in_hb(th)) {
					_stop = true;
					break;
				}

				var ww = _font.stringWidth(word) + (word.length*letter_spacing);

				if(i < words.length-1){
					ww += space_width;
				}

				lw += ww;
				if(width == 0 || lw <= width + letter_spacing) {
					if(i == 0) {
						result += word;
					} else {
						result += " " + word;
					}
				} else {
					th += _text_height;
					if(in_hb(th)) {
						_stop = true;
						break;
					}
					result += "\n" + word;
					lw = ww;
				}

				i++;
			}

			parsed_lines.push(result);

			if(_stop) {
				break;
			}
		}
		
        return parsed_lines.join("\n").split("\n");

	}
*/
	@:noCompletion public function update_text() {

		if(_setup) {
			return;
		}

		if(font_dirty || size_dirty) {
			_kravur = font.font._get(size); // note: this is expensive if creating new font or font size
			texture = font.get(size);
			font_dirty = false;
			size_dirty = false;
		}

		var n:Int = 0;

		if(text.length > 0) {

			// var lines = split_in_lines(text, _kravur);
			var lines = [text];

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

		text = v;

		if(text_colors.length > text.length) {
			text_colors.splice(text.length, text_colors.length - text.length);
		}

		update_text();

		return text;
		
	}

	function set_font(v:FontResource):FontResource {

		font = v;
		font_dirty = true;

		update_text();

		return font;
		
	}

	function set_size(v:Int):Int {

		size = v;
		size_dirty = true;

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

	function set_tab_width(v:Int):Int {

		tab_width = v;

		tab_string = '';
		for (i in 0...tab_width) {
			tab_string += ' ';
		}

		update_text();

		return tab_width;
		
	}

	override function set_color(v:Color):Color {

		text_colors.splice(0, text_colors.length);

		super.set_color(v);

		return v;

	}

	function set_wrap(v:Bool):Bool {

		wrap = v;

		update_text();

		return wrap;
		
	}

}

@:enum abstract TextAlign(Int) from Int to Int {

	var left = 0;
	var right = 1;
	var center = 2;
	var top = 3;
	var bottom = 4;

}

typedef TextOptions = {

	// >GeometryOptions,

	@:optional var font:FontResource;
	@:optional var text:String;
	@:optional var text_colors:Array<Color>;
	@:optional var size:Int;
	@:optional var align:TextAlign;
	@:optional var align_vertical:TextAlign;
	@:optional var width:Float;
	@:optional var height:Float;
	@:optional var line_spacing:Float;
	@:optional var letter_spacing:Float;
	@:optional var tab_width:Int;
	@:optional var wrap:Bool;

}
