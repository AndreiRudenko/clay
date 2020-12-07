package;


class Command {


	public var name:String;
	public var usage:String;


	public function new(_name:String, _usage:String) {

		name = _name;
		usage = _usage;

	}


	public function execute(args:Array<String>) {
		
	}


}