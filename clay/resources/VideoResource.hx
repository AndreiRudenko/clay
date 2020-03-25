package clay.resources;

import clay.resources.ResourceManager;

class VideoResource extends Resource {

	@:noCompletion public var video:kha.Video;

	public function new(video:kha.Video) {
		this.video = video;
		resourceType = ResourceType.VIDEO;
	}

	override function unload() {
		video.unload();
	}
	
}
