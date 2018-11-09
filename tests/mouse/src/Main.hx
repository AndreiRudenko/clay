package;


class Main {

	public static function main() {

		Clay.init(
			{
				title: 'mouse',
				width: 800,
				height: 600,
				antialiasing: 0,
				vsync: false,
				window: {
					mode: clay.types.WindowMode.Window,
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
