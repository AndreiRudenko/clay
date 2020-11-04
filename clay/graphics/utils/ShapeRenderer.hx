package clay.graphics.utils;

import clay.math.Vector2;
import clay.math.FastMatrix3;
import clay.math.FastVector2;
import clay.Graphics;
import clay.graphics.Color;
import clay.graphics.Texture;
import clay.graphics.render.Pipeline;
import clay.graphics.render.VertexBuffer;
import clay.graphics.render.IndexBuffer;
import clay.graphics.utils.ImmediateColoredRenderer;
import clay.utils.StrokeAlign;
import clay.utils.Math;
import clay.utils.DynamicPool;
import clay.utils.FastFloat;
import clay.utils.Float32Array;


// TODO: render to texture then blit with opacity, to remove opacity overlap
class ShapeRenderer {

	static public var segmentSmooth(default, set):Float = 5;
	static function set_segmentSmooth(v:Float) {
		segmentSmooth = Math.max(1, v);
		return segmentSmooth;
	}

	static public var miterMinAngle(default, set):Float = 10; // degrees
	static function set_miterMinAngle(v:Float) {
		miterMinAngle = Math.clamp(v, 0.01, 180);
		_miterMinAngle = miterMinAngle / 180;
		return miterMinAngle;
	}

	static var _miterMinAngle:Float = 10/180;

	public var projection(get, set):FastMatrix3;
	inline function get_projection() return _renderer.projection; 
	inline function set_projection(v:FastMatrix3) return _renderer.projection = v; 

	public var transform:FastMatrix3 = new FastMatrix3();

	public var shapeType:ShapeType = ShapeType.LINE;
	public var color:Color = Color.WHITE;
	public var lineWidth:Int = 8;
	public var lineJoint:LineJoint = LineJoint.BEVEL;
	public var lineCap:LineCap = LineCap.BUTT;

	var _graphics:Graphics;
	var _polySegmentPool:DynamicPool<PolySegment>;
	var _renderer:ImmediateColoredRenderer;

	public function new(verticesMax:Int = 8192, indicesMax:Int = 16384) {
		_graphics = Clay.graphics;
		_renderer = new ImmediateColoredRenderer(verticesMax, indicesMax);
		_polySegmentPool = new DynamicPool<PolySegment>(32, 
			function() {
				return new PolySegment();
			}
		);
	}

	public function begin() {
		_renderer.begin();
	}

	public function end() {
		_renderer.end();
	}

	public inline function drawLine(x0:FastFloat, y0:FastFloat, x1:FastFloat, y1:FastFloat) {
		drawPolyLine([x0, y0, x1, y1], false);
	}

	public function drawTriangle(x0:FastFloat, y0:FastFloat, x1:FastFloat, y1:FastFloat, x2:FastFloat, y2:FastFloat) {
		drawPolygon([x0, y0, x1, y1, x2, y2], [0,1,2]);
	}

	public function drawRectangle(x:FastFloat, y:FastFloat, w:FastFloat, h:FastFloat) {
		drawPolygon([x, y, x+w, y, x+w, y+h, x, y+h], [0,1,2,0,2,3]);
	}

	public inline function drawCircle(x:FastFloat, y:FastFloat, r:FastFloat, segments:Int = -1) {
		drawEllipse(x, y, r, r, segments);
	}

	// http://slabode.exofire.net/circle_draw.shtml
	public function drawEllipse(x:FastFloat, y:FastFloat, rx:FastFloat, ry:FastFloat, segments:Int = -1) {
		if(segments <= 0) {
			var scale = Math.sqrt((transform.a * transform.a + transform.b * transform.b) * Math.max(rx, ry));
			segments = Std.int(scale * segmentSmooth);
		}

		if(segments < 3) {
			segments = 3;
		}

		var theta:FastFloat = Math.TAU / segments;
		
		var c:FastFloat = Math.cos(theta);
		var s:FastFloat = Math.sin(theta);

		var px:FastFloat = 1;
		var py:FastFloat = 0;
		var t:FastFloat = 0;

		var points = [];
		var indices = [];

		var i:Int = 0;
		while(i < segments) {
			points.push(x + px * rx);
			points.push(y + py * ry);

			t = px;
			px = c * px - s * py;
			py = s * t + c * py;

			if(shapeType == ShapeType.FILL) {
				indices.push(i);
				indices.push((i+1) % segments);
				indices.push(segments);
			}
			i++;
		}

		if(shapeType == ShapeType.FILL) {
			points.push(x);
			points.push(y);
			drawPolygon(points, indices);
		} else {
			drawPolyLine(points, true);
		}
	}

	public inline function drawArc(x:FastFloat, y:FastFloat, radius:FastFloat, angleStart:FastFloat, angle:FastFloat, segments:Int = -1) {
		drawArcType(ArcType.PIE, x, y, radius, angleStart, angle, segments);
	}

	// TODO: proper handling open arc ending angles
	public function drawArcType(type:ArcType, x:FastFloat, y:FastFloat, radius:FastFloat, angleStart:FastFloat, angle:FastFloat, segments:Int = -1) {
		if(radius == 0 || angle == 0) return;
		
		var absAngle:FastFloat = Math.abs(angle);

		if(segments <= 0) {
			if(absAngle > Math.TAU) absAngle = Math.TAU;
			var angleScale = absAngle / Math.TAU;
			var scale = Math.sqrt((transform.a * transform.a + transform.b * transform.b) * radius * angleScale);
			segments = Std.int(scale * segmentSmooth);
		}

		if(segments < 3) segments = 3;

		var theta:FastFloat = absAngle / segments;
		
		var c:FastFloat = Math.cos(theta);
		var s:FastFloat = Math.sin(theta);

		var px:FastFloat = Math.cos(angleStart);
		var py:FastFloat = Math.sin(angleStart);
		var t:FastFloat = 0;

		var segsAdd = 0;

		if(absAngle < Math.TAU) {
			segsAdd = 1;
		}

		var points = [];
		var indices = [];

		var i:Int = 0;
		while(i < segments) {
			points.push(x + px * radius);
			points.push(y + py * radius);
			t = px;
			if(angle > 0) {
				px = px * c - py * s;
				py = t * s + py * c;
			} else {
				px = px * c + py * s;
				py = -t * s + py * c;
			}

			if(shapeType == ShapeType.FILL) {
				indices.push(i);
				indices.push((i+1) % (segments + segsAdd));
				indices.push(segments + segsAdd);
			}

			i++;
		}

		if(absAngle < Math.TAU) {
			points.push(x + px * radius);
			points.push(y + py * radius);
		}

		if(shapeType == ShapeType.FILL) {
			points.push(x);
			points.push(y);
			if(type != ArcType.PIE) {
				indices.push(0);
				indices.push(segments);
				indices.push(segments + segsAdd);
			}
			drawPolygon(points, indices);
		} else {
			var closed = true;
			switch (type) {
				case ArcType.PIE:
					points.push(x);
					points.push(y);
				case ArcType.OPEN:
					closed = false;
				case ArcType.CLOSED:
			}
			drawPolyLine(points, closed);
		}
	}

	// https://github.com/Feirell/2d-bezier/blob/master/lib/cubic-bezier.js
	// start, control1, control2, end, ...
	// TODO: filled bezier
	public function drawCubicBezier(points:Array<FastFloat>, closed:Bool = false, segments:Int = 20) {
		var drawPoints:Array<FastFloat> = [];

		var ax:FastFloat;
		var ay:FastFloat;

		var bx:FastFloat;
		var by:FastFloat;

		var cx:FastFloat;
		var cy:FastFloat;

		var dx:FastFloat;
		var dy:FastFloat;

		var t:FastFloat;
		var omt:FastFloat;

		var x:FastFloat;
		var y:FastFloat;

		var i = 0;
		var j = 0;
		while(i < points.length) {
			ax = points[i++];
			ay = points[i++];

			bx = points[i++];
			by = points[i++];

			cx = points[i++];
			cy = points[i++];

			dx = points[i++];
			dy = points[i++];

			j = 0;
			while(j <= segments) {
				t = j / segments;
				omt = 1 - t;

				x = omt * omt * omt * ax +
					3 * t * omt * omt * bx +
					3 * t * t * omt * cx +
					t * t * t * dx;

				y = omt * omt * omt * ay +
					3 * t * omt * omt * by +
					3 * t * t * omt * cy +
					t * t * t * dy;

				drawPoints.push(x);
				drawPoints.push(y);
				j++;
			}
		}

		drawPolyLine(drawPoints, closed);
	}

	public function drawPolygon(points:Array<FastFloat>, indices:Array<Int>) {
		var vertsCount = Std.int(points.length / 2);
		beginGeometry(vertsCount, indices.length);

		var i:Int = 0;
		while(i < vertsCount) {
			addVertexExt(points[i*2], points[i*2+1], color);
			i++;
		}

		i = 0;
		while(i < indices.length) {
			addIndex(indices[i]);
			i++;
		}

		endGeometry();
	}

	// based on https://github.com/CrushedPixel/Polyline2D
	public function drawPolyLine(points:Array<FastFloat>, closed:Bool = false) {
		var thickness = lineWidth / 2;

		var tScale = Math.sqrt((transform.a * transform.a + transform.b * transform.b) * thickness);
		var s = Std.int(tScale * segmentSmooth);
		var roundMinAngle:FastFloat = Math.TAU / s;

		var segments:Array<PolySegment> = [];

		var p0x:FastFloat;
		var p0y:FastFloat;
		var p1x:FastFloat;
		var p1y:FastFloat;
		var seg:PolySegment;

		var i:Int = 0;
		while (i < points.length - 3) {
			p0x = points[i];
			p0y = points[i + 1];
			p1x = points[i + 2];
			p1y = points[i + 3];

			if(p0x != p1x || p0y != p1y) {
				seg = _polySegmentPool.get();
				seg.set(p0x, p0y, p1x, p1y, thickness);
				segments.push(seg);
			}
			i += 2;
		}

		if (closed) {
			// create a connecting segment from the last to the first point
			p0x = points[points.length - 2];
			p0y = points[points.length - 1];
			p1x = points[0];
			p1y = points[1];

			// to avoid division-by-zero errors,
			// only create a line segment for non-identical points
			if(p0x != p1x || p0y != p1y) {
				seg = _polySegmentPool.get();
				seg.set(p0x, p0y, p1x, p1y, thickness);
				segments.push(seg);
			}
		}

		if (segments.length == 0) {
			// handle the case of insufficient input points
			return;
		}

		// calculate the path's global start and end points
		var firstSegment = segments[0];
		var lastSegment = segments[segments.length - 1];

		var pathStart1 = firstSegment.edge1.a;
		var pathStart2 = firstSegment.edge2.a;
		var pathEnd1 = lastSegment.edge1.b;
		var pathEnd2 = lastSegment.edge2.b;

		// handle different end cap styles
		if (closed) {
			// join the last (connecting) segment and the first segment
			drawJoint(lastSegment, firstSegment, lineJoint, pathEnd1, pathEnd2, pathStart1, pathStart2, roundMinAngle);
		} else if (lineCap == LineCap.SQUARE) {
			// extend the start/end points by half the thickness
			pathStart1.subtract(FastVector2.MultiplyScalar(firstSegment.edge1.direction(), thickness));
			pathStart2.subtract(FastVector2.MultiplyScalar(firstSegment.edge2.direction(), thickness));
			pathEnd1.add(FastVector2.MultiplyScalar(lastSegment.edge1.direction(), thickness));
			pathEnd2.add(FastVector2.MultiplyScalar(lastSegment.edge2.direction(), thickness));
		} else if (lineCap == LineCap.ROUND) {
			// draw half circle end caps
			drawTriangleFan(firstSegment.center.a, firstSegment.center.a, firstSegment.edge1.a, firstSegment.edge2.a, false, roundMinAngle);
			drawTriangleFan(lastSegment.center.b, lastSegment.center.b, lastSegment.edge1.b, lastSegment.edge2.b, true, roundMinAngle);
		}

		// generate mesh data for path segments
		var start1 = pathStart1.clone();
		var start2 = pathStart2.clone();
		var nextStart1 = new FastVector2(0, 0);
		var nextStart2 = new FastVector2(0, 0);
		var end1 = new FastVector2(0, 0);
		var end2 = new FastVector2(0, 0);

		i = 0;
		while(i < segments.length) {
			var segment = segments[i];

			if (i + 1 == segments.length) {
				// this is the last segment
				end1.copyFrom(pathEnd1);
				end2.copyFrom(pathEnd2);
			} else {
				drawJoint(segment, segments[i + 1], lineJoint, end1, end2, nextStart1, nextStart2, roundMinAngle);
			}
			beginGeometry(4, 6);

			addVertexExt(start1.x, start1.y, color);
			addVertexExt(end1.x, end1.y, color);
			addVertexExt(end2.x, end2.y, color);
			addVertexExt(start2.x, start2.y, color);

			addIndex(0);
			addIndex(1);
			addIndex(2);

			addIndex(0);
			addIndex(2);
			addIndex(3);

			endGeometry();

			start1.copyFrom(nextStart1);
			start2.copyFrom(nextStart2);

			_polySegmentPool.put(segment);
			i++;
		}
	}

	inline function drawJoint(segment1:PolySegment, segment2:PolySegment, jointStyle:LineJoint, end1:FastVector2, end2:FastVector2, nextStart1:FastVector2, nextStart2:FastVector2, roundMinAngle:FastFloat) {
		// calculate the angle between the two line segments
		var dir1 = segment1.center.direction();
		var dir2 = segment2.center.direction();

		var dot = dir1.dot(dir2);

		if (jointStyle == LineJoint.MITER && dot < -1 + _miterMinAngle) {
			// the minimum angle for mitered joints wasn't exceeded.
			// to avoid the intersection point being extremely far out,
			// thus producing an enormous joint like a rasta on 4/20,
			// we render the joint beveled instead.
			jointStyle = LineJoint.BEVEL;
		}

		// find out which are the inner edges for this joint
		var clockwise = dir1.cross(dir2) < 0;

		var inner1:LineSegment = null; 
		var inner2:LineSegment = null; 
		var outer1:LineSegment = null; 
		var outer2:LineSegment = null;

		if (clockwise) {
			outer1 = segment1.edge1;
			outer2 = segment2.edge1;
			inner1 = segment1.edge2;
			inner2 = segment2.edge2;
		} else {
			outer1 = segment1.edge2;
			outer2 = segment2.edge2;
			inner1 = segment1.edge1;
			inner2 = segment2.edge1;
		}

		var iVec = segment1.center.b.clone();
		var innerSecOpt = LineSegment.intersection(inner1, inner2, false, iVec);
		var innerSec = innerSecOpt ? iVec : inner1.b;

		var innerStart:FastVector2 = null;
		if (innerSecOpt) {
			innerStart = innerSec;
		} else {
			innerStart = inner2.a;
		}

		if (clockwise) {
			end1.copyFrom(outer1.b);
			end2.copyFrom(innerSec);

			nextStart1.copyFrom(outer2.a);
			nextStart2.copyFrom(innerStart);
		} else {
			end1.copyFrom(innerSec);
			end2.copyFrom(outer1.b);

			nextStart1.copyFrom(innerStart);
			nextStart2.copyFrom(outer2.a);
		}

		if(jointStyle == LineJoint.MITER){
			var oVec = new FastVector2(0, 0);
			if(LineSegment.intersection(outer1, outer2, true, oVec)) {
				beginGeometry(4, 6);

				addVertexExt(outer1.b.x, outer1.b.y, color);
				addVertexExt(oVec.x, oVec.y, color);
				addVertexExt(outer2.a.x, outer2.a.y, color);
				addVertexExt(iVec.x, iVec.y, color);

				addIndex(0);
				addIndex(1);
				addIndex(2);

				addIndex(0);
				addIndex(2);
				addIndex(3);

				endGeometry();
			}
		} else if(jointStyle == LineJoint.BEVEL) {
			beginGeometry(3, 3);

			addVertexExt(outer1.b.x, outer1.b.y, color);
			addVertexExt(outer2.a.x, outer2.a.y, color);
			addVertexExt(iVec.x, iVec.y, color);

			addIndex(0);
			addIndex(1);
			addIndex(2);

			endGeometry();
		} else if(jointStyle == LineJoint.ROUND) {
			drawTriangleFan(iVec, segment1.center.b, outer1.b, outer2.a, clockwise, roundMinAngle);
		}
	}

	inline function drawTriangleFan(connectTo:FastVector2, origin:FastVector2, start:FastVector2, end:FastVector2, clockwise:Bool, roundMinAngle:FastFloat) {
		var p1x:FastFloat = start.x - origin.x;
		var p1y:FastFloat = start.y - origin.y;

		var p2x:FastFloat = end.x - origin.x;
		var p2y:FastFloat = end.y - origin.y;

		// calculate the angle between the two points
		var angle1 = Math.atan2(p1y, p1x);
		var angle2 = Math.atan2(p2y, p2x);

		// ensure the outer angle is calculated
		if (clockwise) {
			if (angle2 > angle1) {
				angle2 = angle2 - Math.TAU;
			}
		} else {
			if (angle1 > angle2) {
				angle1 = angle1 - Math.TAU;
			}
		}

		var jointAngle = angle2 - angle1;

		// calculate the amount of triangles to use for the joint
		var numTriangles = Std.int(Math.max(1, Math.abs(jointAngle) / roundMinAngle));
		var theta:FastFloat = jointAngle / numTriangles;
		
		var c:FastFloat = Math.cos(theta);
		var s:FastFloat = Math.sin(theta);

		var px:FastFloat = c * p1x - s * p1y;
		var py:FastFloat = s * p1x + c * p1y;
		var t:FastFloat = 0;
		var i:Int = 0;

		var startPoint:FastVector2 = start.clone();
		var endPoint:FastVector2 = new FastVector2(0,0);

		var lastIdx = numTriangles * 2;
		beginGeometry(numTriangles * 2 + 1, numTriangles * 3);
		while(i < numTriangles) {
			if (i + 1 == numTriangles) {
				// it's the last triangle - ensure it perfectly
				// connects to the next line
				endPoint.copyFrom(end);
			} else {
				// rotate the original point around the origin
				// re-add the rotation origin to the target point
				endPoint.set(origin.x + px, origin.y + py);

				t = px;
				px = c * px - s * py;
				py = s * t + c * py;
			}

			// emit the triangle
			addVertexExt(startPoint.x, startPoint.y, color);
			addVertexExt(endPoint.x, endPoint.y, color);

			addIndex(i * 2);
			addIndex(i * 2 + 1);
			addIndex(lastIdx);

			startPoint.copyFrom(endPoint);
			i++;
		}
		addVertexExt(connectTo.x, connectTo.y, color);
		endGeometry();
	}

	// helpers
	inline function beginGeometry(vertsCount:Int, indicesCount:Int) {
		_renderer.beginGeometry(vertsCount, indicesCount);
	}

	inline function endGeometry() {
		_renderer.endGeometry();
	}

	inline function addVertexExt(x:FastFloat, y:FastFloat, c:Color) {
		_renderer.addVertex(transform.getTransformX(x, y), transform.getTransformY(x, y), c);
	}

	inline function addIndex(i:Int) {
		_renderer.addIndex(i);
	}
	
}

private class LineSegment {

	public var a:FastVector2;
	public var b:FastVector2;

	public inline function new(a:FastVector2, b:FastVector2) {
		this.a = a;
		this.b = b;
	}

	/**
	 * @return The line segment's direction vector.
	 */
	public inline function direction(normalized:Bool = true):FastVector2 {
		var vec = new FastVector2(b.x - a.x, b.y - a.y);
		if(normalized) vec.normalize();
		return vec;
	}

	public static function intersection(segA:LineSegment, segB:LineSegment, infiniteLines:Bool, into:FastVector2):Bool {
		// calculate un-normalized direction vectors
		var r = segA.direction(false);
		var s = segB.direction(false);

		var originDist = FastVector2.Subtract(segB.a, segA.a);

		var uNumerator:FastFloat = originDist.cross(r);
		var denominator:FastFloat = r.cross(s);

		// if (Math.abs(denominator) < 0.0001) {
		if (Math.abs(denominator) <= 0) {
			// The lines are parallel
			return false;
		}

		// solve the intersection positions
		var u:FastFloat = uNumerator / denominator;
		var t:FastFloat = originDist.cross(s) / denominator;

		if (!infiniteLines && (t < 0 || t > 1 || u < 0 || u > 1)) {
			// the intersection lies outside of the line segments
			return false;
		}

		// calculate the intersection point
		into.x = segA.a.x + r.x * t;
		into.y = segA.a.y + r.y * t;

		return true;
	}

}

private class PolySegment {

	public var center:LineSegment;
	public var edge1:LineSegment;
	public var edge2:LineSegment;

	// public function new(center:LineSegment, thickness:Float) {
	public function new() {
		center = new LineSegment(new FastVector2(0,0), new FastVector2(0,0));
		edge1 = new LineSegment(new FastVector2(0,0), new FastVector2(0,0));
		edge2 = new LineSegment(new FastVector2(0,0), new FastVector2(0,0));
	}

	public function set(p0x:FastFloat, p0y:FastFloat, p1x:FastFloat, p1y:FastFloat, thickness:FastFloat) {
		center.a.set(p0x, p0y);
		center.b.set(p1x, p1y);

		// calculate the segment's outer edges by offsetting
		// the central line by the normal vector
		// multiplied with the thickness
		// center + center.normal() * thickness

		var dx:FastFloat = p1x - p0x;
		var dy:FastFloat = p1y - p0y;

		var len:FastFloat = Math.sqrt(dx * dx + dy * dy);
		var tmp:FastFloat = dx;

		dx = -(dy / len) * thickness;
		dy = (tmp / len) * thickness;

		edge1.a.set(p0x + dx, p0y + dy);
		edge1.b.set(p1x + dx, p1y + dy);

		edge2.a.set(p0x - dx, p0y - dy);
		edge2.b.set(p1x - dx, p1y - dy);
	}

}


enum abstract ShapeType(Int) {
	var FILL;
	var LINE;
}

enum abstract LineJoint(Int) from Int to Int {	
	/**
	 * Corners are drawn with sharp joints.
	 * If the joint's outer angle is too large,
	 * the joint is drawn as beveled instead,
	 * to avoid the miter extending too far out.
	 */
	var MITER = 0;

	/**
	 * Corners are flattened.
	 */
	var BEVEL = 1;

	/**
	 * Corners are rounded off.
	 */
	var ROUND = 2;
}

enum abstract LineCap(Int) from Int to Int {
	/**
	 * Path ends are drawn flat,
	 * and don't exceed the actual end point.
	 */
	var BUTT = 0;

	/**
	 * Path ends are drawn flat,
	 * but extended beyond the end point
	 * by half the line thickness.
	 */
	var SQUARE = 1;

	/**
	 * Path ends are rounded off.
	 */
	var ROUND = 2;

	/**
	 * Path ends are connected according to the JointStyle.
	 * When using this EndCapStyle, don't specify the common start/end point twice,
	 * as Polyline2D connects the first and last input point itself.
	 */
	// var JOINT = 3;
}

enum abstract ArcType(Int) from Int to Int {
	/**
	 * The arc is drawn like a slice of pie, 
	 * with the arc circle connected to the center at its end-points.
	 */
	var PIE = 0;

	/**
	 * The arc circle's two end-points are unconnected when the arc is drawn as a line. 
	 * Behaves like the "closed" arc type when the arc is drawn in filled shapeType.
	 */
	var OPEN = 1;

	/**
	 * The arc circle's two end-points are connected to each other.
	 */
	var CLOSED = 2;

}