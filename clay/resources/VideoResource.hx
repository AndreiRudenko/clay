package clay.resources;

import clay.system.ResourceManager;


class VideoResource extends Resource {


	@:noCompletion public var video:kha.Video;


	public function new(_video:kha.Video) {

		video = _video;
		resource_type = ResourceType.video;
		
	}

	override function unload() {

		video.unload();
		
	}
	

}
