package graph;

// A pair of double values
public class DoublePair {
	public DoublePair(double l, double r) {
		_left = l; _right = r;
	}

	double left() { return _left; }
	double right() { return _right; }
	double _left;
	double _right;
}
