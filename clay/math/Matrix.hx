package clay.math;


import clay.math.Transform;

/*

| a | c | tx |
| b | d | ty |
| 0 | 0 | 1  |

 */
 
class Matrix {


	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;


	public function new(_a:Float = 1, _b:Float = 0, _c:Float = 0, _d:Float = 1, _tx:Float = 0, _ty:Float = 0) {

		set(_a, _b, _c, _d, _tx, _ty);
		
	}

	/**
	 * Set the matrix to the identity matrix - when appending or prepending this matrix to another there will be no change in the resulting matrix
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function identity():Matrix {

		set(
			1, 0,
			0, 1,
			0, 0
		);

		return  this;
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
	public inline function translate(_x:Float, _y:Float):Matrix {
		
		tx += _x;
		ty += _y;

		return this;

	}    

	public inline function apply(_x:Float, _y:Float):Matrix {
		
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
	public inline function scale(_x:Float, _y:Float):Matrix {
		
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
	public inline function rotate(_angle:Float):Matrix {
		
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

	/**
	 * Append a matrix to this matrix.
	 * 
	 * @param m The matrix to append.
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function append(m:Matrix):Matrix {
		
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

	public inline function orto(left:Float, right:Float,  bottom:Float, top:Float):Matrix {

		var sx:Float = 1.0 / (right - left);
		var sy:Float = 1.0 / (top - bottom);

		set(
			2.0*sx,      0,
			0,           2.0*sy,
			-(right+left)*sx, -(top+bottom)*sy
		);

		return this;

	}

	public inline function multiply(m:Matrix):Matrix {

		a = a * m.a + b * m.c;
		b = a * m.b + b * m.d;
		c = c * m.a + d * m.c;
		d = c * m.b + d * m.d;
		tx = tx * m.a + ty * m.c + m.tx;
		ty = tx * m.b + ty * m.d + m.ty;

		return this;

	}
	/**
	 * Invert this matrix so that it represents the opposite of its orginal tranformation.
	 * 
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function invert():Matrix {

		var a1:Float = a;
		var b1:Float = b;
		var c1:Float = c;
		var d1:Float = d;
		var tx1:Float = tx;
		var n:Float = a1 * d1 - b1 * c1;

		a = d1 / n;
		b = -b1 / n;
		c = -c1 / n;
		d = a1 / n;
		tx = (c1 * ty - d1 * tx1) / n;
		ty = -(a1 * ty - b1 * tx1) / n;

		return this;

	}

	public inline function copy(other:Matrix):Matrix {

		set(
			other.a,  other.b,
			other.c,  other.d,
			other.tx, other.ty
		);

		return this;

	}

	public inline function decompose(into:Spatial) {

		var determ = a * d - b * c;

		into.pos.set(tx, ty);

		if(a != 0 || b != 0) {
			var r = Math.sqrt(a * a + b * b);
			into.rotation = (b > 0) ? Math.acos(a / r) : -Math.acos(a / r);
			into.scale.set(r, determ / r);
		} else if(c != 0 || d != 0) {
			var s = Math.sqrt(c * c + d * d);
			into.rotation = Math.PI * 0.5 - (d > 0 ? Math.acos(-c / s) : -Math.acos(c / s));
			into.scale.set(determ / s, s);
		} else {
			into.rotation = 0;
			into.scale.set(0,0);
		}

	}
	

}