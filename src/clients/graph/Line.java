/* Copyright 1998, 1999: Jim Cochrane - see file forum.txt */

package graph;

/**
 * Abstraction for a line
**/
class Line {

	public Line(double x1, double x2, double y1, double y2) {
		_x1 = x1;
		_x2 = x2;
		_y1 = y1;
		_y2 = y2;
	}

	// x coordinate of start point of line
	public double x1() {
		return _x1;
	}

	// x coordinate of end point of line
	public double x2() {
		return _x2;
	}

	// y coordinate of start point of line
	public double y1() {
		return _y1;
	}

	// y coordinate of end point of line
	public double y2() {
		return _y2;
	}

// Implementation

	double _x1, _x2, _y1, _y2;
}
