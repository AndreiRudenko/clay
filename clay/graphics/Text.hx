package clay.graphics;


import kha.Kravur;
import kha.Kravur.AlignedQuad;
import kha.Kravur.KravurImage;
import kha.graphics4.TextureFormat;

import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.render.Color;
import clay.render.Shader;
import clay.render.Vertex;
import clay.render.Camera;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.render.Painter;
import clay.resources.FontResource;
import clay.resources.Texture;
import clay.graphics.Mesh;
import clay.utils.Log.*;
import clay.utils.ArrayTools;


class Text extends Mesh {


	public var text(default, set):String;
	public var font(default, set):FontResource;
	public var fontSize(get, set):Int; // expensive
	public var align(get, set):TextAlign;
	public var alignVertical(get, set):TextAlign;

	public var width(get, set):Float;
	public var height(get, set):Float;
	public var lineSpacing(get, set):Float;
	public var letterSpacing(get, set):Float;
	public var asTexture(get, set):Bool;

	public var textWidth(default, null):Float;
	public var textHeight(default, null):Float;

	public var textColors:Array<Color>; // TODO: remove?

	var _fontSize:Int;
	var _width:Float;
	var _height:Float;
	var _lineSpacing:Float;
	var _letterSpacing:Float;
	var _align:TextAlign;
	var _alignVertical:TextAlign;
	var _asTexture:Bool;

	var _kravur:KravurImage;
	var _lines:Array<String>;


	public function new(font:FontResource) {

		_lines = [];
		textColors = [];

		super();

		shaderDefault = Clay.renderer.shaders.get("text");

		textWidth = 0;
		textHeight = 0;

		_fontSize = 12;
		_align = TextAlign.LEFT;
		_alignVertical = TextAlign.TOP;
		_width = 0;
		_height = 0;
		_lineSpacing = 0;
		_letterSpacing = 0;

		_asTexture = false;

		premultipliedAlpha = false;

		this.font = font;
		text = "";

		// updateText();

	}

	public function addText(t:String, ?c:Color) {

		var start = text.length;

		for (i in 0...t.length) {
			textColors[start + i] = c;
		}
		text += t;
		
	}

	override function render(p:Painter) {

		if(_asTexture) {
			super.render(p);
		} else {
			_render(p);
		}

	}

	function _render(p:Painter) {
		
		if(!textIsEmpty(text)) {
			p.setShader(shader != null ? shader : shaderDefault);
			p.clip(clipRect);
			p.setTexture(texture);
			p.setBlending(_blendSrc, _blendDst, _blendOp, _alphaBlendSrc, _alphaBlendDst, _alphaBlendOp);

			if(locked) {
				#if !noDebugConsole
				p.stats.locked++;
				#end
				p.drawFromBuffers(_vertexBuffer, _indexBuffer); //TODO: render to texture instead?
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

	function splitInLines(txt:String, kravur:KravurImage):Array<String> {

		ArrayTools.clear(_lines); 

		var spaceCode:Int = " ".code;
		var newlineCode:Int = "\n".code;
		var charCode:Int;
		var restPos:Int = 0;

		if(_width > 0 || _height > 0) {

			var lineHeight:Float = kravur.getHeight() + _lineSpacing;
			var textHeight:Float = 0;
			var stop:Bool = false;

			inline function checkHeight():Bool {

				textHeight += lineHeight;
				return _height > 0 && textHeight > (_height - _lineSpacing);

			}

			if(_width > 0) {
			
				var charWidth:Float;
				var lineWidth:Float = 0;
				var wordIdx:Int = 0;
				var lastBreakWidth:Float = 0;
				var spaceChar:Bool = false;
				var newlineChar:Bool = false;

				var i:Int = 0;
				while(i < txt.length) {
					charCode = txt.charCodeAt(i);

					charWidth = @:privateAccess kravur.getCharWidth(charCode) + _letterSpacing;
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
						_lines.push(txt.substr(restPos, i - restPos));

						restPos = i + 1;
					} else if((lineWidth + charWidth - _letterSpacing) > _width) {
						if(lastBreakWidth > 0) {
							if(checkHeight()) {
								stop = true;
								break;
							}
							lineWidth += charWidth;
							_lines.push(txt.substr(restPos, wordIdx - restPos));
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
							_lines.push(txt.substr(restPos, i + 1 - restPos));

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
				for (i in 0...txt.length) {
					charCode = txt.charCodeAt(i);
					if(charCode == newlineCode) {
						if(checkHeight()) {
							stop = true;
							break;
						}
						_lines.push(txt.substr(restPos, i - restPos));
						restPos = i + 1;
					}
				}
			}

			if(!stop && restPos < txt.length) {
				if(!checkHeight()) {
					_lines.push(txt.substr(restPos, txt.length - restPos));
				}
			}

		} else {
			for (i in 0...txt.length) {
				charCode = txt.charCodeAt(i);
				if(charCode == newlineCode) {
					_lines.push(txt.substr(restPos, i - restPos));
					restPos = i + 1;
				}
			}
			if(restPos < txt.length) {
				_lines.push(txt.substr(restPos, txt.length - restPos));
			}
		}

		return _lines;

	}

	function updateFont() {
		
		_kravur = font.font._get(_fontSize); // note: this is expensive if creating new font or font size
		texture = font.get(_fontSize);

	}

	function updateText() {

		var n:Int = 0;

		if(!textIsEmpty(text)) {

			var lines = splitInLines(text, _kravur);

			var quadCache = new AlignedQuad();

			var tWidth:Float = 0;
			var fontHeght:Float = _kravur.getHeight();
			textWidth = 0;
			textHeight = (fontHeght + _lineSpacing) * lines.length;

			var xoffset:Float = 0;
			var yoffset:Float = 0;

			var img = texture.image;
			var customColors = textColors.length != 0;
			var _color = color;

			var wRatio:Float = img.width / img.realWidth;
			var hRatio:Float = img.height / img.realHeight;

			switch (_alignVertical) {
				case TextAlign.BOTTOM:{
					yoffset = _height - textHeight;
				}
				case TextAlign.CENTER:{
					yoffset = _height*0.5 - textHeight/2;
				}
				default:{
					yoffset = 0;
				}
			}

			var l:String;
			for (i in 0...lines.length) {

				l = lines[i];

				if(l != null && l.length > 0) {

					tWidth = _kravur.stringWidth(l) + (l.length * _letterSpacing);

					if(tWidth > textWidth) {
						textWidth = tWidth;
					}

					var xpos:Float = 0;

					switch (_align) {
						case TextAlign.RIGHT:{
							xoffset = _width - tWidth;
						}
						case TextAlign.CENTER:{
							xoffset = _width * 0.5 - tWidth / 2;
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
							lw = q.xadvance + _letterSpacing;

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

				yoffset += fontHeght + _lineSpacing;

			}
		}

		if(vertices.length > n*4) {
			vertices.splice(n*4, vertices.length);
		}

		if(indices.length > n*6) {
			indices.splice(n*6, indices.length);
		}

		if(_asTexture) {
			setupAsTexture();
		}

	}

	var _canUpdateAsTexture:Bool = true;

	function setupAsTexture() {

		if(!_canUpdateAsTexture) {
			return;
		}

		_canUpdateAsTexture = false;

		var oversample:Int = 2;

		var fs = _fontSize;
		var tw = _width;
		var th = _height;

		_fontSize = fs * oversample;
		_width *= oversample;
		_height *= oversample;

		updateFont();
		updateText();

		var ttw = textWidth;
		var tth = textHeight;

		if(ttw > 4096) {
			ttw = 4096;
		}

		if(tth > 4096) {
			tth = 4096;
		}

		var ttwo = ttw * oversample;
		var ttho = tth * oversample;

		var tex = Texture.createRenderTarget(Math.floor(ttwo), Math.floor(ttho), null, null, true);
		var g = tex.image.g4;
		var p = Clay.renderer.painter;
		var tr = transform;

		transform = new clay.math.Transform();

		// TODO: separate this to renderToTexture method in renderer
		g.begin();
		g.clear(kha.Color.Black);

		p.begin(g, new Rectangle(0, 0, ttwo, ttho));

		var mtrx = new Matrix();
		if (kha.Image.renderTargetsInvertedY()) {
			mtrx.orto(0, ttwo, 0, ttho);
		} else {
			mtrx.orto(0, ttwo, ttho, 0);
		}

		p.setProjection(mtrx);
		_render(p);
		p.end();

		g.end();

		_width = tw;
		_height = th;
		_fontSize = fs;

		texture = tex;
		transform = tr;

		vertices = [
			new Vertex(new Vector(0, 0), new Vector(0, 0)),
			new Vertex(new Vector(ttw, 0), new Vector(1, 0)),
			new Vertex(new Vector(ttw, tth), new Vector(1, 1)),
			new Vertex(new Vector(0, tth), new Vector(0, 1))
		];

		indices = [0, 1, 2, 0, 2, 3];

		_canUpdateAsTexture = true;
		
	}

	inline function textIsEmpty(text:String) {
		
		return text == null || text == "" || text.length == 0;

	}

	function set_text(v:String):String {

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
		updateFont();
		updateText();

		return font;
		
	}

	inline function get_fontSize():Int {

		return _fontSize;
		
	}

	function set_fontSize(v:Int):Int {

		_fontSize = v;
		updateFont();
		updateText();

		return _fontSize;
		
	}

	inline function get_align():TextAlign {

		return _align;
		
	}

	function set_align(v:TextAlign):TextAlign {

		_align = v;
		updateText();

		return _align;
		
	}

	function get_alignVertical():TextAlign {

		return _alignVertical;
		
	}

	function set_alignVertical(v:TextAlign):TextAlign {

		_alignVertical = v;
		updateText();

		return _alignVertical;
		
	}

	inline function get_lineSpacing():Float {

		return _lineSpacing;
		
	}

	function set_lineSpacing(v:Float):Float {

		_lineSpacing = v;
		updateText();

		return _lineSpacing;
		
	}

	inline function get_width():Float {

		return _width;
		
	}

	function set_width(v:Float):Float {

		if(_width != v) {
			_width = v;
			updateText();
		}

		return _width;
		
	}

	inline function get_height():Float {

		return _height;
		
	}

	function set_height(v:Float):Float {

		if(_height != v) {
			_height = v;
			updateText();
		}

		return _height;
		
	}

	inline function get_letterSpacing():Float {

		return _letterSpacing;
		
	}

	function set_letterSpacing(v:Float):Float {

		_letterSpacing = v;
		updateText();

		return _letterSpacing;
		

	}

	inline function get_asTexture():Bool {

		return _asTexture;
		
	}

	function set_asTexture(v:Bool):Bool {

		_asTexture = v;
		updateFont();
		updateText();

		return v;
		
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
