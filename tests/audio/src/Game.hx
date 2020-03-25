package;

import clay.Clay;
import clay.math.Vector;
import clay.utils.Color;
import clay.events.AppEvent;
// import clay.graphics.tile.Tileset;
import clay.graphics.tile.Tilemap;
import clay.events.MouseEvent;
import clay.events.KeyEvent;
import clay.input.Key;
import clay.audio.Sound;
import clay.audio.AudioGroup;
import clay.audio.effects.Reverb;

class Game {

	public function new() {
		Clay.resources.loadAll(
			[
				'space_sound.mp3',
				'G3_hard.mp3'
			], 
			ready
		);
	}

	var music:Sound;
	var audioGroup:AudioGroup;

	function ready() {
		Clay.on(MouseEvent.MOUSE_DOWN, onMouseDown);
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		music = Clay.audio.play(Clay.resources.audio('space_sound.mp3'));
		music.loop = true;

		audioGroup = new AudioGroup();
		Clay.audio.add(audioGroup);

		var reverb = new Reverb({
			damping: 1,
			roomSize: 0.7
		});
		audioGroup.addEffect(reverb);
	}

	function onMouseDown(e:MouseEvent) {
		var snd = Clay.audio.play(Clay.resources.audio('G3_hard.mp3'), audioGroup);
		snd.pan = e.x / Clay.screen.width * 2 - 1;
	}

	function onKeyDown(e:KeyEvent) {
		if(e.key == Key.SPACE) {
			if(music.paused) {
				music.unpause();
			} else {
				music.pause();
			}
		}
	}

}
