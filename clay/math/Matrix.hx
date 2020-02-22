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


	public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0) {

		set(a, b, c, d, tx, ty);
		
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
	public inline function set(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float):Matrix {
		
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;

		return this;

	}

	/**
	 * Translates the matrix on the x and y.
	 *
	 * @param _x How much to translate x by
	 * @param _y How much to translate y by
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function translate(x:Float, y:Float):Matrix {
		
		tx += x;
		ty += y;

		return this;

	}    

	public inline function apply(x:Float, y:Float):Matrix {
		
		tx = a * x + c * y + tx;
		ty = b * x + d * y + ty;

		return this;

	}
	
	
	/**
	 * Applies a scale transformation to the matrix.
	 *
	 * @param _x The amount to scale horizontally
	 * @param _y The amount to scale vertically
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function scale(x:Float, y:Float):Matrix {
		
		a *= x;
		b *= x;
		c *= y;
		d *= y;

		return this;
		
	}
	
	/**
	 * Applies a rotation transformation to the matrix.
	 *
	 * @param angle The angle in radians.
	 * @return This matrix. Good for chaining method calls.
	 */
	public inline function rotate(angle:Float):Matrix {
		
		var sin:Float = Math.sin(angle);
		var cos:Float = Math.cos(angle);

		var a1:Float = a;
		var b1:Float = b;
		var c1:Float = c;
		var d1:Float = d;

		a = a1 *  cos + b1 * sin;
		b = a1 * -sin + b1 * cos;
		c = c1 *  cos + d1 * sin;
		d = c1 * -sin + d1 * cos;

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

	public inline function orto(left:Float, right:Float, bottom:Float, top:Float):Matrix {

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

	/**
	 * Get a new position x with the current transformation applied.
	 */
	public inline function getTransformX(x:Float, y:Float):Float {

		return a * x + c * y + tx;

	}

	/**
	 * Get a new position y with the current transformation applied.
	 */
	public inline function getTransformY(x:Float, y:Float):Float {

		return b * x + d * y + ty;
		
	}
	

}