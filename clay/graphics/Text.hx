package clay.graphics;


import kha.Kravur;
import kha.Kravur.AlignedQuad;
import kha.Kravur.KravurImage;

import clay.math.Vector;
import clay.math.Matrix;
import clay.render.Color;
import clay.render.Shader;
import clay.render.Vertex;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.render.Painter;
import clay.resources.FontResource;
import clay.resources.Texture;
import clay.graphics.Mesh;
import clay.utils.Log.*;
import clay.utils.ArrayTools;


class Text extends Mesh {


	public var text(default, set):String;
	public var font(default, set):FontResource;
	public var size(default, set):Int; // expensive
	public var align(default, set):TextAlign;
	public var alignVertical(default, set):TextAlign;

	public var width(default, set):Float;
	public var height(default, set):Float;
	public var lineSpacing(default, set):Float;
	public var letterSpacing(default, set):Float;

	public var textWidth(default, null):Float = 0;
	public var textHeight(default, null):Float = 0;

	public var textColors:Array<Color>;

	var _sizeDirty:Bool = true;
	var _fontDirty:Bool = true;

	var _setup:Bool = true;
	var _kravur:KravurImage;
	var _lines:Array<String>;


	public function new(font:FontResource) {

		_lines = [];
		textColors = [];

		super();

		shaderDefault = Clay.renderer.shaders.get("text");

		this.font = font;

		text = "";
		size = 12;
		align = TextAlign.LEFT;
		alignVertical = TextAlign.TOP;
		width = 0;
		height = 0;
		lineSpacing = 0;
		letterSpacing = 0;

		_setup = false;

		setBlendMode(BlendMode.SourceAlpha, BlendMode.InverseSourceAlpha, BlendEquation.Add);
		updateText();

	}

	public function addText(t:String, ?c:Color) {

		var start = text.length;

		for (i in 0...t.length) {
			textColors[start + i] = c;
		}
		text += t;
		
	}

	override function render(p:Painter) {

		if(!textIsEmpty(text)) {
			p.setShader(shader != null ? shader : shaderDefault);
			p.clip(clipRect);
			p.setTexture(texture);

			if(blendDisabled) {
				var sh = shader != null ? shader : shaderDefault;
				p.setBlendMode(
					sh._blendSrcDefault, sh._blendDstDefault, sh._blendOpDefault, 
					sh._alphaBlendSrcDefault, sh._alphaBlendDstDefault, sh._alphaBlendOpDefault
				);
			} else {
				p.setBlendMode(blendSrc, blendDst, blendOp, alphaBlendSrc, alphaBlendDst, alphaBlendOp);
			}

			if(locked) {
				#if !noDebugConsole
				p.stats.locked++;
				#end
				p.drawFromBuffers(_vertexBuffer, _indexBuffer); // render to texture instead
			} else {

				var v:Vertex;
				var quads = Math.floor(vertices.length / 4);
				var m = transform.world.matrix;

				for (i in 0...quads) {
					p.ensure(4, 6);
					p.addIndex(0);
					p.addIndex(1);
					p.addIndex(2);
					p.addIndex(0);
					p.addIndex(2);
					p.addIndex(3);

					v = vertices[i*4];
					p.addVertex(
						m.a * v.pos.x + m.c * v.pos.y + m.tx, 
						m.b * v.pos.x + m.d * v.pos.y + m.ty, 
						v.tcoord.x,
						v.tcoord.y,
						v.color
					);
					
					v = vertices[i*4+1];
					p.addVertex(
						m.a * v.pos.x + m.c * v.pos.y + m.tx, 
						m.b * v.pos.x + m.d * v.pos.y + m.ty, 
						v.tcoord.x,
						v.tcoord.y,
						v.color
					);
					
					v = vertices[i*4+2];
					p.addVertex(
						m.a * v.pos.x + m.c * v.pos.y + m.tx, 
						m.b * v.pos.x + m.d * v.pos.y + m.ty, 
						v.tcoord.x,
						v.tcoord.y,
						v.color
					);

					v = vertices[i*4+3];
					p.addVertex(
						m.a * v.pos.x + m.c * v.pos.y + m.tx, 
						m.b * v.pos.x + m.d * v.pos.y + m.ty, 
						v.tcoord.x,
						v.tcoord.y,
						v.color
					);

				}

			}
		}

	}

	function findIndex(charCode:Int):Int {

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

	function splitInLines(text:String, kravur:KravurImage):Array<String> {

		ArrayTools.clear(_lines); 

		var spaceCode:Int = " ".code;
		var newlineCode:Int = "\n".code;
		var charCode:Int;
		var restPos:Int = 0;

		if(width > 0 || height > 0) {

			var lineHeight:Float = kravur.getHeight() + lineSpacing;
			var textHeight:Float = 0;
			var stop:Bool = false;

			inline function checkHeight():Bool {

				textHeight += lineHeight;
				return height > 0 && textHeight > (height - lineSpacing);

			}

			if(width > 0) {
			
				var charWidth:Float;
				var lineWidth:Float = 0;
				var wordIdx:Int = 0;
				var lastBreakWidth:Float = 0;
				var spaceChar:Bool = false;
				var newlineChar:Bool = false;

				var i:Int = 0;
				while(i < text.length) {
					charCode = text.charCodeAt(i);

					charWidth = @:privateAccess kravur.getCharWidth(charCode) + letterSpacing;
					spaceChar = charCode == spaceCode;
					newlineChar = charCode == newlineCode;

					if(spaceChar) {
						lineWidth += charWidth;
						lastBreakWidth = lineWidth;
						wordIdx = i;
					} else if(newlineChar) {
						if(checkHeight()) {
							stop = true;
							break;
						}
						lineWidth = 0;
						_lines.push(text.substr(restPos, i - restPos));

						restPos = i + 1;
					} else if((lineWidth + charWidth - letterSpacing) > width) {
						if(lastBreakWidth > 0) {
							if(checkHeight()) {
								stop = true;
								break;
							}
							lineWidth += charWidth;
							_lines.push(text.substr(restPos, wordIdx - restPos));
							lineWidth = lineWidth - lastBreakWidth;
							lastBreakWidth = 0;
							restPos = wordIdx + 1;
						} else {
							if(i == 0) {
								break;
							}
							i--;
							if(checkHeight()) {
								stop = true;
								break;
							}
							_lines.push(text.substr(restPos, i + 1 - restPos));

							lineWidth = 0;
							lastBreakWidth = 0;
							restPos = i + 1;
						}
					} else {
						lineWidth += charWidth;
					}
					
					i++;

				}

			} else {
				for (i in 0...text.length) {
					charCode = text.charCodeAt(i);
					if(charCode == newlineCode) {
						if(checkHeight()) {
							stop = true;
							break;
						}
						_lines.push(text.substr(restPos, i - restPos));
						restPos = i + 1;
					}
				}
			}

			if(!stop && restPos < text.length) {
				if(!checkHeight()) {
					_lines.push(text.substr(restPos, text.length - restPos));
				}
			}

		} else {
			for (i in 0...text.length) {
				charCode = text.charCodeAt(i);
				if(charCode == newlineCode) {
					_lines.push(text.substr(restPos, i - restPos));
					restPos = i + 1;
				}
			}
			if(restPos < text.length) {
				_lines.push(text.substr(restPos, text.length - restPos));
			}
		}

		return _lines;

	}

	@:noCompletion public function updateText() {

		if(_setup) {
			return;
		}

		if(_fontDirty || _sizeDirty) {
			_kravur = font.font._get(size); // note: this is expensive if creating new font or font size
			texture = font.get(size);
			_fontDirty = false;
			_sizeDirty = false;
		}

		var n:Int = 0;

		if(!textIsEmpty(text)) {

			var lines = splitInLines(text, _kravur);

			var quadCache = new AlignedQuad();

			var _textWidth:Float = 0;
			var fontHeght:Float = _kravur.getHeight();
			textWidth = 0;
			textHeight = (fontHeght + lineSpacing) * lines.length;

			var xoffset:Float = 0;
			var yoffset:Float = 0;

			var img = texture.image;
			var customColors = textColors.length != 0;
			var _color = color;

			var wRatio:Float = img.width / img.realWidth;
			var hRatio:Float = img.height / img.realHeight;

			switch (alignVertical) {
				case TextAlign.BOTTOM:{
					yoffset = height - textHeight;
				}
				case TextAlign.CENTER:{
					yoffset = height*0.5 - textHeight/2;
				}
				default:{
					yoffset = 0;
				}
			}

			var l:String;
			for (i in 0...lines.length) {

				l = lines[i];

				if(l != null && l.length > 0) {

					_textWidth = _kravur.stringWidth(l) + (l.length * letterSpacing);

					if(_textWidth > textWidth) {
						textWidth = _textWidth;
					}

					var xpos:Float = 0;

					switch (align) {
						case TextAlign.RIGHT:{
							xoffset = width-_textWidth;
						}
						case TextAlign.CENTER:{
							xoffset = width*0.5-_textWidth/2;
						}
						default:{
							xoffset = 0;
						}
					}

					var lw:Float = 0;

					for (i in 0...l.length) {
						if(customColors) {
							_color = textColors[n];
							if(_color == null) {
								_color = color;
							}
						}
						var cidx = findIndex(l.charCodeAt(i));
						var q:AlignedQuad = _kravur.getBakedQuad(quadCache, cidx, xpos, 0);
						if (q != null) {
							lw = q.xadvance + letterSpacing;

							if(cidx > 0) { // skip space

								if(vertices[n*4] == null) {
									vertices[n*4] = new Vertex();
									vertices[n*4+1] = new Vertex();
									vertices[n*4+2] = new Vertex();
									vertices[n*4+3] = new Vertex();
								}

								// if(indices.length <= n*6) {
								// 	var offset = n*4;
								// 	indices[n*6] = offset;
								// 	indices[n*6+1] = offset + 1;
								// 	indices[n*6+2] = offset + 2;
								// 	indices[n*6+3] = offset + 0;
								// 	indices[n*6+4] = offset + 2;
								// 	indices[n*6+5] = offset + 3;
								// }

								var t0x = q.s0 * wRatio;
								var t0y = q.t0 * hRatio;
								var t1x = q.s1 * wRatio;
								var t1y = q.t1 * hRatio;

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

				yoffset += fontHeght + lineSpacing;

			}
		}

		if(vertices.length > n*4) {
			vertices.splice(n*4, vertices.length);
		}

		if(indices.length > n*6) {
			indices.splice(n*6, indices.length);
		}

	}

	inline function textIsEmpty(text:String) {
		
		return text == "" || text.length == 0;

	}

	function set_text(v:String):String {

		if(v == null) {
			v = "";
		}

		if(text != v) {
			text = v;

			if(textColors.length > text.length) {
				textColors.splice(text.length, textColors.length - text.length);
			}

			updateText();
		}

		return text;
		
	}

	function set_font(v:FontResource):FontResource {

		font = v;
		_fontDirty = true;

		updateText();

		return font;
		
	}

	function set_size(v:Int):Int {

		size = v;
		_sizeDirty = true;

		updateText();

		return size;
		
	}

	function set_align(v:TextAlign):TextAlign {

		align = v;
		updateText();

		return align;
		
	}

	function set_alignVertical(v:TextAlign):TextAlign {

		alignVertical = v;
		updateText();

		return alignVertical;
		
	}

	function set_lineSpacing(v:Float):Float {

		lineSpacing = v;

		updateText();

		return lineSpacing;
		
	}

	function set_width(v:Float):Float {

		if(width != v) {
			width = v;
			updateText();
		}

		return width;
		
	}

	function set_height(v:Float):Float {

		if(height != v) {
			height = v;
			updateText();
		}

		return height;
		
	}

	function set_letterSpacing(v:Float):Float {

		letterSpacing = v;

		updateText();

		return letterSpacing;
		

	}

	override function set_color(v:Color):Color {

		ArrayTools.clear(textColors);

		super.set_color(v);

		return v;

	}
	

}

@:enum abstract TextAlign(Int) from Int to Int {

	var LEFT = 0;
	var RIGHT = 1;
	var CENTER = 2;
	var TOP = 3;
	var BOTTOM = 4;

}
