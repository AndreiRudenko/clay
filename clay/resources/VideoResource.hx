package clay.resources;


class VideoResource extends Resource {


	@:noCompletion public var video:kha.Video;


	public function new(_video:kha.Video) {

		video = _video;
		
	}


}
