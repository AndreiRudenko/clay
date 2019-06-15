package clay.types.macro;


import haxe.macro.Context;
import haxe.macro.Expr;


#if macro
class EventMacro {


	public static var event_id:Int = 0;
	public static var event_map:Map<String, Int> = new Map();


	public static function build():Array<Field> {

		var fields = Context.getBuildFields();

		function get_event_name(field:Field):String {

			var name:String;

			switch (field.kind) {
				case FVar(t,_): 
					switch (t) {
						case TPath(p): 
							switch (p.params[0]) {
								case TPType(t1): 
									switch (t1) {
										case TPath(p1): 
											name = '${p1.name}_${field.name}';
										case _:
									}
								case _:
							}
						case _:
					}
				case _:
			}

			return name;
			
		}

		for(field in fields) {
			switch (field.kind) {
				case FVar(t,e):
					switch (t) {
						case TPath(p): 
							if(p.name == 'EventType') {
								if(e != null) {
									Context.error("Remove initializer, EventType id will be created at compile-time", field.pos);
								}
								var name = get_event_name(field);
								var id:Int = 0;
								if(event_map.exists(name)) {
									id = event_map.get(name);
								} else {
									id = event_id++;
								}
								field.kind = FVar(t,macro $v{id});
							}
						case _:
					}
				case _:
			}
		}

		return fields;

	}

}
#end
