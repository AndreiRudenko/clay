package clay.render;

import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.utils.BlendMode;
import clay.utils.Bits;


class Blending {

	static var blendingFactorBits:Int = 4;
	static var blendingOperationBits:Int = 3;

	// flags for fast comparision
	// BlendingFactor max 11, pow: 16 = 4bits
	// BlendingOperation max 5, pow: 8 = 3bits
	// Total 22 bits (4+4+3+4+4+3)
	public var flags(default, null):Int;

	public var mode(get, set):BlendMode;
	public var premultipliedAlpha(get, set):Bool;

	public var blendSrc(default, null):BlendFactor;
	public var blendDst(default, null):BlendFactor;
	public var blendOp(default, null):BlendOperation;
	public var alphaBlendDst(default, null):BlendFactor;
	public var alphaBlendSrc(default, null):BlendFactor;
	public var alphaBlendOp(default, null):BlendOperation;

	var _mode:BlendMode;
	var _premultipliedAlpha:Bool;

    public function new() {
    	flags = 0;
    	_premultipliedAlpha = true;
    	mode = BlendMode.UNDEFINED;
    }
    
	public function set(
		blendSrc:BlendFactor, blendDst:BlendFactor, ?blendOp:BlendOperation, 
		?alphaBlendSrc:BlendFactor, ?alphaBlendDst:BlendFactor, ?alphaBlendOp:BlendOperation
	) {
    	_mode = BlendMode.CUSTOM;

		blendOp = blendOp != null ? blendOp : BlendOperation.Add;
		setInternal(
			blendSrc, 
			blendDst, 
			blendOp, 
			alphaBlendSrc != null ? alphaBlendSrc : blendSrc, 
			alphaBlendDst != null ? alphaBlendDst : blendDst, 
			alphaBlendOp != null ? alphaBlendOp : blendOp
		);
	}

	public function copyFrom(blending:Blending) {
		_mode = blending.mode;
		setInternal(
			blending.blendSrc, blending.blendDst, blending.blendOp, 
			blending.alphaBlendSrc, blending.alphaBlendDst, blending.alphaBlendOp
		);
	}

	public inline function equals(blending:Blending):Bool {
		return flags == blending.flags;
	}

	inline function get_mode():BlendMode {
		return _mode;
	}

	function set_mode(v:BlendMode):BlendMode {
		_mode = v;
		updateBlending();
		return _mode;
	}

	inline function get_premultipliedAlpha():Bool {
		return _premultipliedAlpha;
	}

	function set_premultipliedAlpha(v:Bool):Bool {
		_premultipliedAlpha = v;
		updateBlending();
		return _premultipliedAlpha;
	}

	function updateBlending() {
		var m = _mode;
		if(_premultipliedAlpha) {
			switch (_mode) {
				case BlendMode.CUSTOM:
				case BlendMode.UNDEFINED: set(BlendFactor.Undefined, BlendFactor.Undefined);
				case BlendMode.NONE: set(BlendFactor.BlendOne, BlendFactor.BlendZero);
				case BlendMode.NORMAL: set(BlendFactor.BlendOne, BlendFactor.InverseSourceAlpha);
				case BlendMode.ADD: set(BlendFactor.BlendOne, BlendFactor.BlendOne);
				case BlendMode.MULTIPLY: set(BlendFactor.DestinationColor, BlendFactor.InverseSourceAlpha);
				case BlendMode.SCREEN: set(BlendFactor.BlendOne, BlendFactor.InverseSourceColor);
				case BlendMode.ERASE: set(BlendFactor.BlendZero, BlendFactor.InverseSourceAlpha);
				case BlendMode.MASK: set(BlendFactor.BlendZero, BlendFactor.SourceAlpha); //TODO: test this
				case BlendMode.BELOW: set(BlendFactor.InverseDestinationAlpha, BlendFactor.DestinationAlpha); //TODO: test this
			}
		} else {
			switch (_mode) {
				case BlendMode.CUSTOM:
				case BlendMode.UNDEFINED: set(BlendFactor.Undefined, BlendFactor.Undefined);
				case BlendMode.NONE: set(BlendFactor.BlendOne, BlendFactor.BlendZero);
				case BlendMode.NORMAL: set(BlendFactor.SourceAlpha, BlendFactor.InverseSourceAlpha);
				case BlendMode.ADD: set(BlendFactor.SourceAlpha, BlendFactor.DestinationAlpha);
				case BlendMode.MULTIPLY: set(BlendFactor.DestinationColor, BlendFactor.InverseSourceAlpha);
				case BlendMode.SCREEN: set(BlendFactor.SourceAlpha, BlendFactor.BlendOne);
				case BlendMode.ERASE: set(BlendFactor.BlendZero, BlendFactor.InverseSourceAlpha);
				case BlendMode.MASK: set(BlendFactor.BlendZero, BlendFactor.SourceAlpha); //TODO: test this
				case BlendMode.BELOW: set(BlendFactor.InverseDestinationAlpha, BlendFactor.DestinationAlpha); //TODO: test this
			}
		}
		_mode = m;
	}

	inline function setInternal(
		blendSrc:BlendFactor, blendDst:BlendFactor, blendOp:BlendOperation, 
		alphaBlendSrc:BlendFactor, alphaBlendDst:BlendFactor, alphaBlendOp:BlendOperation
	) {
		this.blendSrc = blendSrc;
		this.blendDst = blendDst;
		this.blendOp = blendOp;
		this.alphaBlendSrc = alphaBlendSrc;
		this.alphaBlendDst = alphaBlendDst;
		this.alphaBlendOp = alphaBlendOp;
		updateFlags();
	}

	function updateFlags() {
		flags = 0;
		var totalBits = blendingFactorBits * 4 + blendingOperationBits * 2;
		var offset = 0;
		flags = Bits.setToPos(flags, blendSrc, offset);
		offset += blendingFactorBits;
		flags = Bits.setToPos(flags, blendDst, offset);
		offset += blendingFactorBits;
		flags = Bits.setToPos(flags, blendOp, offset);
		offset += blendingOperationBits;

		flags = Bits.setToPos(flags, alphaBlendSrc, offset);
		offset += blendingFactorBits;
		flags = Bits.setToPos(flags, alphaBlendDst, offset);
		offset += blendingFactorBits;
		flags = Bits.setToPos(flags, alphaBlendOp, offset);
		// offset += blendingOperationBits;
/*
		// test
		offset = 0;
		var _blendSrc = Bits.extractRange(flags, offset+1, blendingFactorBits);
		offset += blendingFactorBits;
		var _blendDst = Bits.extractRange(flags, offset+1, blendingFactorBits);
		offset += blendingFactorBits;
		var _blendOp = Bits.extractRange(flags, offset+1, blendingOperationBits);
		offset += blendingOperationBits;

		var _alphaBlendSrc = Bits.extractRange(flags, offset+1, blendingFactorBits);
		offset += blendingFactorBits;
		var _alphaBlendDst = Bits.extractRange(flags, offset+1, blendingFactorBits);
		offset += blendingFactorBits;
		var _alphaBlendOp = Bits.extractRange(flags, offset+1, blendingOperationBits);
		// offset += blendingOperationBits;

		trace('blendSrc $blendSrc/$_blendSrc, blendDst $blendDst/$_blendDst, blendOp $blendOp/$_blendOp,
alphaBlendSrc $alphaBlendSrc/$_alphaBlendSrc, alphaBlendDst $alphaBlendDst/$_alphaBlendDst, alphaBlendOp $alphaBlendOp/$_alphaBlendOp');
*/
	}

}