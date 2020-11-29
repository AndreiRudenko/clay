package clay.graphics;

import clay.Resources;
import clay.resources.Resource;

class Video extends Resource {

	public var video:kha.Video;

	public function new(video:kha.Video) {
		this.video = video;
		resourceType = ResourceType.VIDEO;
	}

	override function unload() {
		video.unload();
	}
	
}
