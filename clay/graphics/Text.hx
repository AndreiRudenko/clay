package clay.graphics;

import kha.Kravur;
import kha.Kravur.AlignedQuad;
import kha.Kravur.KravurImage;
import kha.graphics4.TextureFormat;

import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.utils.Color;
import clay.render.Shader;
import clay.render.Vertex;
import clay.render.Camera;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.render.RenderContext;
import clay.resources.FontResource;
import clay.resources.Texture;
import clay.graphics.Mesh;
import clay.utils.Log.*;
import clay.utils.ArrayTools;
import clay.utils.Align;

class Text extends Mesh {

	public var text(get, set):String;
	public var font(get, set):FontResource;
	public var fontSize(get, set):Int; // expensive
	public var align(get, set):Align;
	public var alignVertical(get, set):Align;

	public var width(get, set):Float;
	public var height(get, set):Float;
	public var lineSpacing(get, set):Float;
	public var letterSpacing(get, set):Float;
	public var asTexture(get, set):Bool;

	public var textWidth(default, null):Float;
	public var textHeight(default, null):Float;

	public var textColors:Array<Color>; // TODO: remove?

	var _font:FontResource;
	var _text:String;
	var _fontSize:Int;
	var _width:Float;
	var _height:Float;
	var _lineSpacing:Float;
	var _letterSpacing:Float;
	var _align:Align;
	var _alignVertical:Align;
	var _asTexture:Bool;

	var _kravur:KravurImage;
	var _lines:Array<String>;

	var _canUpdateAsTexture:Bool = true;
	var _isRenderTexture:Bool = false;

	public function new(font:FontResource) {
		assert(font != null, "cant create Text without FontResource");

		_lines = [];
		textColors = [];

		super();

		indices = [0, 1, 2, 0, 2, 3];

		shaderDefault = Clay.renderer.shaders.get("text");

		textWidth = 0;
		textHeight = 0;

		_fontSize = 12;
		_align = Align.LEFT;
		_alignVertical = Align.TOP;
		_width = 0;
		_height = 0;
		_lineSpacing = 0;
		_letterSpacing = 0;

		_asTexture = false;

		blending.premultipliedAlpha = false;

		_text = "";
		this.font = font;
	}

	public function addText(t:String, ?c:Color) {
		var start = _text.length;

		for (i in 0...t.length) {
			textColors[start + i] = c;
		}
		_text += t;
	}

	override function render(ctx:RenderContext) {
		if(_asTexture) {
			super.render(ctx);
		} else {
			_render(ctx);
		}
	}

	override function destroy() {
		_font.unref();
		_font = null;
		_kravur = null;
		_lines = null;
	    super.destroy();
	}

	function _render(ctx:RenderContext) {
		if(!textIsEmpty(_text)) {

			preRenderSetup(ctx);

			if(locked) {
				#if !noDebugConsole
				if(ctx.stats != null) {
					ctx.stats.locked++;
				}
				#end
				ctx.drawFromBuffers(_vertexBuffer, _indexBuffer);
			} else {
				var matrix = transform.world.matrix;
				var i = 0;
				while(i < vertices.length) {
					ctx.ensure(4, 6);
					addQuadToRenderContext(ctx, matrix, i);
					i += 4;
				}
			}
		}
	}

	inline function addQuadToRenderContext(ctx:RenderContext, matrix:Matrix, startIdx:Int) {
		ctx.addIndex(0);
		ctx.addIndex(1);
		ctx.addIndex(2);
		ctx.addIndex(0);
		ctx.addIndex(2);
		ctx.addIndex(3);

		ctx.setColor(vertices[startIdx].color);

		var vertex;
		var j = 0;
		while(j < 4) {
			vertex = vertices[startIdx+j];
			ctx.addVertex(
				matrix.getTransformX(vertex.pos.x, vertex.pos.y), 
				matrix.getTransformY(vertex.pos.x, vertex.pos.y), 
				vertex.tcoord.x,
				vertex.tcoord.y
			);
			j++;
		}
	}

	function findCharIndex(charCode:Int):Int {
		var blocks = KravurImage.charBlocks;
		var offset = 0;
		var start = 0;
		var end = 0;
		var i = 0;
		while(i < blocks.length) {
			start = blocks[i];
			end = blocks[i + 1];
			if (charCode >= start && charCode <= end) {
				return offset + charCode - start;
			}
			offset += end - start + 1;
			i += 2;
		}

		return 0;
	}

	// TODO: rework this
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
		_kravur = _font.font._get(_fontSize); // note: this is expensive if creating new font or font size
		texture = _font.get(_fontSize);
	}

	function updateText() {
		var charCount:Int = 0;

		if(!textIsEmpty(_text)) {

			var lines = splitInLines(_text, _kravur);

			var quadCache = new AlignedQuad();

			var lineWidth:Float = 0;
			var fontHeght:Float = _kravur.getHeight();

			var offsetX:Float = 0;
			var offsetY:Float = 0;

			var customColors = textColors.length > 0;
			var charColor = color;

			var image = texture.image;
			var texRatioX:Float = image.width / image.realWidth;
			var texRatioY:Float = image.height / image.realHeight;

			textWidth = 0;
			textHeight = (fontHeght + _lineSpacing) * lines.length;

			offsetY = getVerticalOffset(textHeight);

			for (line in lines) {
				if(line != null && line.length > 0) {
					lineWidth = _kravur.stringWidth(line) + (line.length * _letterSpacing);

					if(lineWidth > textWidth) {
						textWidth = lineWidth;
					}

					offsetX = getHorisontalOffset(lineWidth);

					var linePos:Float = 0;
					var charOffset:Float = 0;
					var charIndex:Int = 0;
					var charQuad:AlignedQuad;
					var j:Int = 0;
					while(j < line.length) {
						if(customColors) {
							charColor = getCharColor(charCount);
						}
						charIndex = findCharIndex(line.charCodeAt(j));
						charQuad = _kravur.getBakedQuad(quadCache, charIndex, linePos, 0);
						if (charQuad != null) {
							charOffset = charQuad.xadvance + _letterSpacing;
							if(charIndex > 0) { // skip space
								ensureQuadVertices(charCount * 4);
								setQuadVerticesFromIdx(
									charCount * 4, 
									charQuad.x0 + offsetX, charQuad.y0 + offsetY, charQuad.x1 + offsetX, charQuad.y1 + offsetY, 
									charQuad.s0 * texRatioX, charQuad.t0 * texRatioY, charQuad.s1 * texRatioX, charQuad.t1 * texRatioY,
									charColor
								);

								charCount++;
							}
							linePos += charOffset;
						}
						j++;
					}

				}
				offsetY += fontHeght + _lineSpacing;
			}
		}

		removeVerticesFrom(charCount * 4);

		if(_asTexture) {
			setupAsTexture();
		} else {
			_isRenderTexture = false;
		}
	}

	inline function removeVerticesFrom(vertsCount:Int) {
		if(vertices.length > vertsCount) {
			vertices.splice(vertsCount, vertices.length);
		}
	}

	inline function getVerticalOffset(textHeight:Float):Float {
		return switch (_alignVertical) {
			case Align.BOTTOM: _height - textHeight;
			case Align.CENTER: _height * 0.5 - textHeight / 2;
			default: 0;
		}
	}

	inline function getHorisontalOffset(textWidth:Float):Float {
		return switch (_align) {
			case Align.RIGHT: _width - textWidth;
			case Align.CENTER: _width * 0.5 - textWidth / 2;
			default: 0;
		}
	}

	inline function getCharColor(idx:Int):Color {
		return textColors[idx] != null ? textColors[idx] : color;
	}

	function setupAsTexture() {
		if(!_canUpdateAsTexture) {
			return;
		}

		_canUpdateAsTexture = false;

		var oversample:Int = 2;

		var prevFontSize = _fontSize;
		var prevWidth = _width;
		var prevHeight = _height;
		var prevTransform = transform;

		_fontSize *= oversample;
		_width *= oversample;
		_height *= oversample;

		updateFont();
		updateText();

		var maxTextureSize = Texture.maxSize;

		var textureWidth = Math.min(textWidth, maxTextureSize);
		var textureHeight = Math.min(textHeight, maxTextureSize);

		var textureWidthScaled = Math.floor(textureWidth * oversample);
		var textureHeightScaled = Math.floor(textureHeight * oversample);

		var fontTexture:Texture = getFontRenderTexture(textureWidthScaled, textureHeightScaled);

		transform = new clay.math.Transform(); //TODO: reuse

		Clay.renderer.ctx.renderToTexture(fontTexture, textureWidthScaled, textureHeightScaled, _render);

		_width = prevWidth;
		_height = prevHeight;
		_fontSize = prevFontSize;

		texture = fontTexture;
		transform = prevTransform;

		removeVerticesFrom(4);
		ensureQuadVertices(0);

		setQuadVerticesFromIdx(
			0, 
			0, 0, textureWidth, textureHeight, 
			0, 0, 1, 1, 
			color
		);

		_canUpdateAsTexture = true;
	}

	inline function getFontRenderTexture(width:Int, height:Int):Texture {
		var fontTexture:Texture = texture;
		if(!_isRenderTexture || fontTexture == null || fontTexture.widthActual != width || fontTexture.heightActual != height) {
			fontTexture = Texture.createRenderTarget(width, height);
			_isRenderTexture = true;
		}

		return fontTexture;
	}

	inline function ensureQuadVertices(idx:Int) {
		if(vertices[idx] == null) {
			for (i in 0...4) {
				vertices[idx+i] = new Vertex();
			}
		}
	}

	inline function setQuadVerticesFromIdx(
		idx:Int, 
		minX:Float, minY:Float, maxX:Float, maxY:Float, 
		tcoordMinX:Float, tcoordMinY:Float, tcoordMaxX:Float, tcoordMaxY:Float, 
		color:Color
	) {
		applyVertexSettings(vertices[idx], minX, minY, tcoordMinX, tcoordMinY, color);
		applyVertexSettings(vertices[idx+1], maxX, minY, tcoordMaxX, tcoordMinY, color);
		applyVertexSettings(vertices[idx+2], maxX, maxY, tcoordMaxX, tcoordMaxY, color);
		applyVertexSettings(vertices[idx+3], minX, maxY, tcoordMinX, tcoordMaxY, color);
	}

	inline function applyVertexSettings(vertex:Vertex, posX:Float, posY:Float, tcoordX:Float, tcoordY:Float, color:Color) {
		vertex.pos.set(posX, posY);
		vertex.tcoord.set(tcoordX, tcoordY);
		vertex.color = color;
	}
	
	inline function textIsEmpty(text:String) {
		return text == null || text == "" || text.length == 0;
	}

	inline function get_text() {
		return _text;
	}

	function set_text(v:String):String {
		if(_text != v) {
			_text = v;
			if(textColors.length > _text.length) {
				textColors.splice(_text.length, textColors.length - _text.length);
			}
			updateText();
		}

		return _text;
	}

	inline function get_font() {
		return _font;
	}

	function set_font(v:FontResource):FontResource {
		if(_font != null) {
			_font.unref();
		}
		_font = v;
		assert(_font != null, "can`t set font to null for Text");

		updateFont();
		updateText();

		_font.ref();

		return _font;
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

	inline function get_align():Align {
		return _align;
	}

	function set_align(v:Align):Align {
		_align = v;
		updateText();

		return _align;
	}

	function get_alignVertical():Align {
		return _alignVertical;
	}

	function set_alignVertical(v:Align):Align {
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
