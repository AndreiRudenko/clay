package clay.components;


import kha.Kravur.AlignedQuad;
import kha.Kravur.KravurImage;

import clay.math.Vector;
import clay.math.Matrix;
import clay.data.Color;
import clay.render.Vertex;
import clay.resources.FontResource;
import clay.components.Texture;
import clay.components.Geometry;
import clay.utils.Log.*;


class Text extends Geometry {


	public var text(default, set):String;
	public var font(default, set):FontResource;
	public var size(default, set):Int; // expensive
	public var align(default, set):TextAlign;
	public var align_vertical(default, set):TextAlign;

	public var width(default, set):Float;
	public var height(default, set):Float;
	public var line_spacing(default, set):Float;
	public var letter_spacing(default, set):Float;
	public var tab_width(default, set):Int;

	var split_regex:EReg = ~/(?:\r\n|\r|\n)/g;
	var tab_regex:EReg = ~/\t/gim;
	var tab_string:String = '';

	var _setup:Bool = true;


	public function new(_options:TextOptions) {

		super(_options);

		geometry_type = GeometryType.text;

		font = _options.font;
		size = def(_options.size, 12);
		text = def(_options.text, '');
		align = def(_options.align, TextAlign.left);
		align_vertical = def(_options.align_vertical, TextAlign.top);
		width = def(_options.width, 0);
		height = def(_options.height, 0);
		line_spacing = def(_options.line_spacing, 0);
		letter_spacing = def(_options.letter_spacing, 0);
		tab_width = def(_options.tab_width, 4);

		_setup = false;
		update_text();

	}

	override function destroy() {}

	function set_text(v:String):String {

		text = v;
		update_text();

		return text;
		
	}

	function set_font(v:FontResource):FontResource {

		font = v;
		update_text();

		return font;
		
	}

	function set_size(v:Int):Int {

		size = v;
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

	//todo: Make this fast
	function find_index(charcode: Int, font_glyphs: Array<Int>):Int {

		for (i in 0...font_glyphs.length) {
			if (font_glyphs[i] == charcode) return i;
		}
		return 0;

	}

	// based on https://github.com/Nazariglez/Gecko2D/blob/master/Sources/gecko/components/draw/TextComponent.hx
	function split_in_lines(_text:String, _font:KravurImage):Array<String> {

		var txt = tab_regex.replace(_text, tab_string);
		var lines = split_regex.split(txt);

		if(width == 0 && height == 0) {
			return lines;
		}

        var parsed_lines:Array<String> = [];

		var text_heght:Float = _font.getHeight() + line_spacing;
		var space_width:Float = _font.stringWidth(' ') + letter_spacing;
		var _stop:Bool = false;
		var th:Float = 0;
		for (line in lines) {
			var i:Int = 0;
			var lw:Float = 0;
			var result:String = '';
			var words = line.split(" ");
			th += text_heght;

			for (word in words) {

				if(height > 0 && height <= th-line_spacing) {
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
					th += text_heght;
					if(height > 0 && height <= th-line_spacing) { // todo: i know...
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

	@:noCompletion public function update_text() {

		if(_setup) {
			return;
		}

		var tex_name:String = '${font.id}_$size';

		var t = Clay.resources.texture(tex_name);
		var font_glyphs = kha.graphics2.Graphics.fontGlyphs;

		var _font = font.font._get(size, font_glyphs); // note: this is expensive if creating new font or font size
		if(t == null) {
			var img = _font.getTexture();
			t = new Texture(img, true);
			t.id = tex_name;
		}

		if(t != texture) {
			texture = t;
		}

		var lines = split_in_lines(text, _font);

		var quad_cache = new AlignedQuad();

		vertices = [];

		var text_heght:Float = _font.getHeight();
		var text_width:Float = 0;
		var text_heigth_sum:Float = 0;

		var xoffset:Float = 0;
		var yoffset:Float = 0;

		var img = texture.image;

		var w_ratio:Float = img.width / img.realWidth;
		var h_ratio:Float = img.height / img.realHeight;

		for (l in lines) {
			
			if(l == null || l.length == 0) {
				yoffset += text_heght + line_spacing;
				continue;
			}

			text_width = _font.stringWidth(l) + (l.length*letter_spacing);

			var xpos:Float = 0;

			switch (align) {
				case TextAlign.right:{
					xoffset = -text_width;
				}
				case TextAlign.center:{
					xoffset = -text_width/2;
				}
				default:{
					xoffset = 0;
				}
			}

			var lw:Float = 0;

			for (i in 0...l.length) {
				var q:AlignedQuad = _font.getBakedQuad(quad_cache, find_index(l.charCodeAt(i), font_glyphs), xpos, 0);
				if (q != null) {

					lw = q.xadvance + letter_spacing;

					var t0x = q.s0 * w_ratio;
					var t0y = q.t0 * h_ratio;
					var t1x = q.s1 * w_ratio;
					var t1y = q.t1 * h_ratio;

					add(new Vertex(new Vector(q.x0+xoffset, q.y1+yoffset), new Color(), new Vector(t0x, t1y)));
					add(new Vertex(new Vector(q.x0+xoffset, q.y0+yoffset), new Color(), new Vector(t0x, t0y)));
					add(new Vertex(new Vector(q.x1+xoffset, q.y0+yoffset), new Color(), new Vector(t1x, t0y)));
					add(new Vertex(new Vector(q.x1+xoffset, q.y1+yoffset), new Color(), new Vector(t1x, t1y)));

					xpos += lw;
				}
			}

			yoffset += text_heght + line_spacing;

		}

		var th = yoffset - line_spacing;

		switch (align_vertical) {
			case TextAlign.bottom:{
				for (v in vertices) {
					v.pos.y -= th;
				}
			}
			case TextAlign.center:{
				for (v in vertices) {
					v.pos.y -= th*0.5;
				}
			}
			default:
		}


	}

	function set_line_spacing(v:Float):Float {

		line_spacing = v;

		update_text();

		return line_spacing;
		
	}

	function set_width(v:Float):Float {

		width = v;

		update_text();

		return width;
		
	}

	function set_height(v:Float):Float {

		height = v;

		update_text();

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

}

typedef TextOptions = {

	>GeometryOptions,

	var font:FontResource;
	@:optional var text:String;
	@:optional var size:Int;
	@:optional var align:TextAlign;
	@:optional var align_vertical:TextAlign;
	@:optional var width:Float;
	@:optional var height:Float;
	@:optional var line_spacing:Float;
	@:optional var letter_spacing:Float;
	@:optional var tab_width:Int;

}

@:enum abstract TextAlign(Int) from Int to Int {

	var left = 0;
	var right = 1;
	var center = 2;
	var top = 3;
	var bottom = 4;

}