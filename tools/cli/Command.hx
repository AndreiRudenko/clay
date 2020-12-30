package;


class Command {

	public var name:String;
	public var usage:String;

	public function new(name:String, usage:String) {
		this.name = name;
		this.usage = usage;
	}


	public function execute(args:Array<String>) {}

}