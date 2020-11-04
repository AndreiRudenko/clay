package clay.utils;

import clay.math.Vector2;
import clay.graphics.Camera;
class Viewport {

	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;
	public var camera:Camera;
	public var scaleMode:ScaleMode;

	var _scaledWidth:Float = 0;
	var _scaledHeight:Float = 0;

	public function new(camera:Camera, x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0) {
		this.camera = camera;
		this.x = x;
		this.y = y;
		this.width = width > 0 ? width : Std.int(camera.width);
		this.height = height > 0 ? height : Std.int(camera.height);
		_scaledWidth = this.width;
		_scaledHeight = this.height;
		scaleMode = ScaleMode.NONE;
	}

	public function screenToWorld(v:Vector2, ?into:Vector2):Vector2 {
		if(into == null) into = new Vector2();
		
		into.x = (v.x - x) * (camera.width / _scaledWidth);
		into.y = (v.y - y) * (camera.height / _scaledHeight);
		into.set(camera.view.getTransformX(into.x, into.y), camera.view.getTransformY(into.x, into.y));

		return into;
	}

	public function worldToScreen(v:Vector2, ?into:Vector2):Vector2 {
		if(into == null) into = new Vector2();
		
		into.copyFrom(v);
		into.set(camera.invProjectionView.getTransformX(into.x, into.y), camera.invProjectionView.getTransformY(into.x, into.y));
		into.x = (_scaledWidth / camera.width) * into.x + x;
		into.y = (_scaledHeight / camera.height) * into.y + y;

		return into;
	}
	
	public function apply() {
		applyScaledViewport();
		camera.update();
	}

	inline function applyScaledViewport() {
		_scaledWidth = width;
		_scaledHeight = height;
		switch (scaleMode) {
			case ScaleMode.FIT: {
				var targetRatio = camera.height / camera.width;
				var sourceRatio = height / width;
				var scale = targetRatio > sourceRatio ? camera.width / width : camera.height / height;
				_scaledWidth = width * scale;
				_scaledHeight = height * scale;
			}
			case ScaleMode.FILL: {
				var targetRatio = camera.height / camera.width;
				var sourceRatio = height / width;
				var scale = targetRatio < sourceRatio ? camera.width / width : camera.height / height;
				_scaledWidth = width * scale;
				_scaledHeight = height * scale;
			}
			case ScaleMode.STRETCH: {
				_scaledWidth = camera.width;
				_scaledHeight = camera.height;
			}
			default: 
		}
		Clay.graphics.viewport(x, y, _scaledWidth, _scaledHeight);
	}
	
	inline function setScissor(x:Float, y:Float, w:Float, h:Float) {
		Clay.graphics.scissor(x, y, w, h);
	}

}

enum abstract ScaleMode(Int){
	// Scales the source to fit the target while keeping the same aspect ratio. 
	// This may cause the source to be smaller than thetarget in one direction.
	var FIT;
	// Scales the source to fill the target while keeping the same aspect ratio. 
	// This may cause the source to be larger than the target in one direction.
	var FILL;
	// Scales the source to fill the target. This may cause the source to not keep the same aspect ratio.
	var STRETCH;
	// The source is not scaled. 
	var NONE;
}