package;


import clay.Clay;


class Main {

	public static function main() {

		Clay.init(
			{
				title: 'clay_animation',
				width: 960,
				height: 640,
				window: {
					resizable: false
				}
			}, 
			onready
		);

	}

	static function onready() {

		new Game();

	}

}
