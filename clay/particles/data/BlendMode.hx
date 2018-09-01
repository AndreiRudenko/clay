package clay.particles.data;



@:enum abstract BlendMode(Int) from Int to Int {

	var zero                    = 0;
	var one                     = 1;
	var src_color               = 2;
	var one_minus_src_color     = 3;
	var src_alpha               = 4;
	var one_minus_src_alpha     = 5;
	var dst_alpha               = 6;
	var one_minus_dst_alpha     = 7;
	var dst_color               = 8;
	var one_minus_dst_color     = 9;
	var src_alpha_saturate      = 10;

}

