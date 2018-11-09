package clay.types;


@:enum abstract TextAlign(Int) from Int to Int {

	var left = 0;
	var right = 1;
	var center = 2;
	var top = 3;
	var bottom = 4;

}