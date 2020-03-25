package clay.render;

import clay.render.types.TextureAddressing;
import clay.render.types.TextureFilter;
import clay.render.types.MipMapFilter;
import clay.utils.Bits;

class TextureParameters {

	static var textureFilterBits:Int = 2;
	static var mipMapFilterBits:Int = 2;
	static var textureAddressingBits:Int = 2;

	// flags for fast comparision
	// TextureFilter max 3, pow: 4 = 2bits
	// BlendingOperation max 3, pow: 4 = 2bits
	// Total 10 bits (2+2+2+2+2)
	public var flags(default, null):Int;

	public var filterMin(get, set):TextureFilter;
	public var filterMag(get, set):TextureFilter;
	public var mipmapFilter(get, set):MipMapFilter;
	public var uAddressing(get, set):TextureAddressing;
	public var vAddressing(get, set):TextureAddressing;

	var _filterMin:TextureFilter;
	var _filterMag:TextureFilter;
	var _mipmapFilter:MipMapFilter;
	var _uAddressing:TextureAddressing;
	var _vAddressing:TextureAddressing;

	public function new() {
		reset();
	}

	public inline function equals(other:TextureParameters) {
		return flags == other.flags;
	}

	public function copyFrom(other:TextureParameters) {
		_filterMin = other.filterMin;
		_filterMag = other.filterMag;
		_mipmapFilter = other.mipmapFilter;
		_uAddressing = other.uAddressing;
		_vAddressing = other.vAddressing;
	}

	public function reset() {
		flags = 0;
		_filterMin = TextureFilter.LinearFilter;
		_filterMag = TextureFilter.LinearFilter;
		_mipmapFilter = MipMapFilter.NoMipFilter;
		_uAddressing = TextureAddressing.Clamp;
		_vAddressing = TextureAddressing.Clamp;
		updateFlags();
	}

	inline function get_filterMin() {
		return _filterMin;
	}

	function set_filterMin(v:TextureFilter) {
		_filterMin = v;
		updateFlags();
		return _filterMin;
	}

	inline function get_filterMag() {
		return _filterMag;
	}

	function set_filterMag(v:TextureFilter) {
		_filterMag = v;
		updateFlags();
		return _filterMag;
	}

	inline function get_mipmapFilter() {
		return _mipmapFilter;
	}

	function set_mipmapFilter(v:MipMapFilter) {
		_mipmapFilter = v;
		updateFlags();
		return _mipmapFilter;
	}

	inline function get_uAddressing() {
		return _uAddressing;
	}

	function set_uAddressing(v:TextureAddressing) {
		_uAddressing = v;
		updateFlags();
		return _uAddressing;
	}

	inline function get_vAddressing() {
		return _vAddressing;
	}

	function set_vAddressing(v:TextureAddressing) {
		_vAddressing = v;
		updateFlags();
		return _vAddressing;
	}

	function updateFlags() {
		flags = 0;
		var offset = 0;
		flags = Bits.setToPos(flags, _filterMin, offset);
		offset += textureFilterBits;
		flags = Bits.setToPos(flags, _filterMag, offset);
		offset += textureFilterBits;
		flags = Bits.setToPos(flags, _mipmapFilter, offset);
		offset += mipMapFilterBits;
		flags = Bits.setToPos(flags, _uAddressing, offset);
		offset += textureAddressingBits;
		flags = Bits.setToPos(flags, _vAddressing, offset);
	}
	
}