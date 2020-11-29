package clay.utils;

class FPSCounter {

	public static var fps:Int = 0;

	static var deltaTime:Float = 0;
	static var totalFrames:Int = 0;
	static var elapsedTime:Float = 0;
	static var previousTime:Float = 0;
	static var currentTime:Float = 0;

	public static function update() {
		previousTime = currentTime;

	    currentTime = kha.Scheduler.realTime();
		deltaTime = (currentTime - previousTime);

		elapsedTime += deltaTime;
		if (elapsedTime >= 1.0) {
			fps = totalFrames;
			totalFrames = 0;
			elapsedTime = 0;
		}
		totalFrames++;
	}
	
}