/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

/** A pair of ints */
public class IntPair {
	public IntPair() {}

	public IntPair(int l, int r) {
		_left = l;
		_right = r;
	}

	public int left() {
		return _left;
	}

	public int right() {
		return _right;
	}

	public void set_left(int l) {
		_left = l;
	}

	public void set_right(int r) {
		_right = r;
	}

	private int _left;
	private int _right;
}
