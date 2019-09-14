package;


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
			onready
		);

	}

	static function onready() {

		new Game();

	}

}
