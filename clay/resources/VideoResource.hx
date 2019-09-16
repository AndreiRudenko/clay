package clay.resources;

import clay.system.ResourceManager;


class VideoResource extends Resource {


	@:noCompletion public var video:kha.Video;


	public function new(video:kha.Video) {

		this.video = video;
		resourceType = ResourceType.video;
		
	}

	override function unload() {

		video.unload();
		
	}
	

}
