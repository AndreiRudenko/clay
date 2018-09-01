package clay.math;


// import snow.api.buffers.Float32Array;


class Matrix {


	public var elements:Array<Float>;


	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;
	

	// var matrix:Float32Array;


	public function new(_a:Float = 1, _b:Float = 0, _c:Float = 0, _d:Float = 1, _tx:Float = 0, _ty:Float = 0) {

		set(_a, _b, _c, _d, _tx, _ty);
		
	}

	/**
	 * Sets the matrix properties
	 * 
	 * @param  _a   Matrix component
	 * @param  _b   Matrix component
	 * @param  _c   Matrix component
	 * @param  _d   Matrix component
	 * @param  _tx  Matrix component
	 * @param  _ty  Matrix component
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function set(_a:Float, _b:Float, _c:Float, _d:Float, _tx:Float, _ty:Float):Matrix {
		
		a = _a;
		b = _b;
		c = _c;
		d = _d;
		tx = _tx;
		ty = _ty;

		return this;

	}

	/**
	 * Translates the matrix on the x and y.
	 *
	 * @param _x How much to translate x by
	 * @param _y How much to translate y by
	 * @return This matrix. Good for chaining method calls.
	 */
	public function translate(_x:Float, _y:Float):Matrix {
		
		tx += _x;
		ty += _y;

		return this;

	}    

	public function apply(_x:Float, _y:Float):Matrix {
		
		tx = a * _x + c * _y + tx;
		ty = b * _x + d * _y + ty;

		return this;

	}
	
	
	/**
	 * Applies a scale transformation to the matrix.
	 *
	 * @param _x The amount to scale horizontally
	 * @param _y The amount to scale vertically
	 * @return This matrix. Good for chaining method calls.
	 */
	public function scale(_x:Float, _y:Float):Matrix {
		
		a *= _x;
		b *= _x;
		c *= _y;
		d *= _y;

		return this;
		
	}
	
	/**
	 * Applies a rotation transformation to the matrix.
	 *
	 * @param _angle The angle in radians.
	 * @return This matrix. Good for chaining method calls.
	 */
	public function rotate(_angle:Float):Matrix {
		
		var _sin:Float = Math.sin(_angle);
		var _cos:Float = Math.cos(_angle);

		var _a:Float = a;
		var _b:Float = b;
		var _c:Float = c;
		var _d:Float = d;

		a = _a *  _cos + _b * _sin;
		b = _a * -_sin + _b * _cos;
		c = _c *  _cos + _d * _sin;
		d = _c * -_sin + _d * _cos;

		return this;
		
	}	

	public function append(m:Matrix):Matrix {
		
        var a1 = a;
        var b1 = b;
        var c1 = c;
        var d1 = d;

        a = (m.a * a1) + (m.b * c1);
        b = (m.a * b1) + (m.b * d1);
        c = (m.c * a1) + (m.d * c1);
        d = (m.c * b1) + (m.d * d1);

        tx = (m.tx * a1) + (m.ty * c1) + tx;
        ty = (m.tx * b1) + (m.ty * d1) + ty;

		return this;

	}

	public function projection(_w:Float, _h:Float):Matrix {

		set(
			2/_w, 0,
			0, -2/_h,
			-1, 1
		);

		return this;

	}

	public function orto(left:Float, right:Float,  bottom:Float, top:Float):Matrix {

		var sx:Float = 1.0 / (right - left);
		var sy:Float = 1.0 / (top - bottom);

		set(
			2.0*sx,      0,
			0,           2.0*sy,
			-(right+left)*sx, -(top+bottom)*sy
		);

		return this;

	}

	public function identity():Matrix {

		set(
			1, 0,
			0, 1,
			0, 0
		);

		return  this;
	}

	public function multiply(m:Matrix):Matrix {

		a = a * m.a + b * m.c;
		b = a * m.b + b * m.d;
		c = c * m.a + d * m.c;
		d = c * m.b + d * m.d;
		tx = tx * m.a + ty * m.c + m.tx;
		ty = tx * m.b + ty * m.d + m.ty;

		return this;

	}

	public function copy(other:Matrix):Matrix {

		set(
			other.a,  other.b,
			other.c,  other.d,
			other.tx, other.ty
		);

		return this;

	}

	// public function tofloat32array(?into:Float32Array):Float32Array {

	// 	if(into == null) {
	// 		into = new Float32Array(9);
	// 	}

	// 	into[0] = a;
	// 	into[1] = b;
	// 	into[2] = 0;
	// 	into[3] = c;
	// 	into[4] = d;
	// 	into[5] = 0;
	// 	into[6] = tx;
	// 	into[7] = ty;
	// 	into[8] = 1;

	// 	return into;

	// }

}