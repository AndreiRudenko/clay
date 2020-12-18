package;

import clay.Clay;

class Main {

	public static function main() {
		Clay.init(
			{
				title: 'empty',
				width: 800,
				height: 600,
				window: {
					resizable: false
				}
			}, 
			onReady
		);
	}

	static function onReady() {
		new Game();
	}

}
