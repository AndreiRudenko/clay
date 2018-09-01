package;


class Main {

	public static function main() {

		Clay.init(
			{
				title: 'empty',
				width: 800,
				height: 600,
				antialiasing: 0,
				vsync: false,
				window_mode: clay.types.WindowMode.Window,
				resizable: false
			}, 
			onready
		);

	}

	static function onready() {

		new Game();

	}

}
