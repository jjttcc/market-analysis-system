/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.text.*;
import java.io.*;

/** General utilities */
public class Utilities
{
	public Utilities() {}

	// Do Vectors `l1' and `l2' have the same contents, compared by object
	// (not by reference)?
	public static boolean lists_match(Vector l1, Vector l2) {
		boolean result = l1 == l2;
		if (! result && l1 != null && l2 != null && l1.size() == l2.size()) {
			result = true;
			for (int i = 0; result && i < l1.size(); ++i) {
				if (! l1.elementAt(i).equals(l1.elementAt(i))) result = false;
			}
		}
		return result;
	}

	// The month `m' as a string
	// Precondition:
	//   m >= 1 && m <= 12
	public static String month_at(int m) {
		return months[m-1];
	}

	// Index of the element of `dates[bottom..top]' whose date/time matches
	// `d', assuming that `dates' and `d' are dates in the format "yyyymmdd"
	// or times in the format "hhmmss" for lexicographical comparison.
	// If no element's date_time matches `d':
	//   search_spec < 0: Index of latest element whose date_time < `d'
	//   search_spec > 0: Index of earliest element whose date_time > `d'
	//   search_spec = 0: -1
	// If there is no element whose date_time is earlier than `d' for
	// search_spec < 0 or no element whose date_time is later than `d'
	// for search_spec > 0, result is -1.
	// Time efficiency is O(log2 n)
	// Precondition:
	//   d != null
	//   All elements of `dates' and `d' are in the format "yyyymmdd".
	//	bottom >= 0;
	//	top <= dates.length - 1;
	//   `dates' is sorted in ascending order.
	static public int index_at_date (String d, String dates[],
			int search_spec, int bottom, int top) {
		int i, comparison, result = -1;

		// Perform a binary search.
		// invariant:
		//	must_be_in: in_range_or_not_in_array (d, dates, bottom, top)
		// variant:
		//	top_bottom_difference: top - bottom + 1
		while (result == -1 && top >= bottom) {
			i = (bottom + top) / 2;
			// assert: i >= 0 and bottom <= i and i <= top
			comparison = d.compareTo(dates[i]);
			if (comparison == 0) result = i;
			else if (comparison > 0) bottom = i + 1;
			else if (comparison < 0) top = i - 1;
		}
		if (result == -1 && search_spec != 0) {
			if (search_spec < 0 && valid_index (dates, top)) {
				// top is now the index of the first element whose
				// date/time is earlier than `d', unless there is no
				// element whose date/time is earlier than `d'
				result = top;
			}
			else if (search_spec > 0 && valid_index (dates, bottom)) {
				// bottom is now the index of the first element whose
				// date/time is later than `d', unless there is no element
				// whose date/time is later than `d'
				result = bottom;
			}
		}
	// ensure:
	// 	non_zero_implies_valid: result > -1 implies valid_index (dates, result)
	// 	non_zero_spec_negative_implies_result_le_d:
	// 		result > -1 and search_spec < 0 implies
	// 			dates[result] <= (d)
	// 	non_zero_spec_positive_implies_result_ge_d:
	// 		result > -1 and search_spec > 0 implies
	// 			dates[result] >= (d)
	// 	spec_negative_next_item_gt_d_if_valid:
	// 		search_spec < 0 and valid_index (dates, result + 1) implies
	// 			dates[result + 1] > d
	// 	spec_positive_previous_item_lt_d_if_valid:
	// 		search_spec > 0 and valid_index (dates, result - 1) implies
	// 			dates[result - 1] < d
	// 	dates_match_if_has_d:
	// 		dates.has(d) implies dates[result].is_equal (d)

		return result;
	}

	// Does `v' contain string `s'?
	static public boolean vector_has(Vector v, String s) {
		boolean result = false;
		for (int i = 0; i < v.size() && ! result; ++i) {
			if (((String) v.elementAt(i)).equals(s)) {
				result = true;
			}
		}
		return result;
	}

	private static String[] months = new String[12];

	static {
		months[0] = "Jan";
		months[1] = "Feb";
		months[2] = "Mar";
		months[3] = "Apr";
		months[4] = "May";
		months[5] = "Jun";
		months[6] = "Jul";
		months[7] = "Aug";
		months[8] = "Sep";
		months[9] = "Oct";
		months[10] = "Nov";
		months[11] = "Dec";
	}

	static protected boolean valid_index (String dates[], int i) {
		return i >= 0 && i < dates.length;
	}

	// double values formatted for display
	static public String[] formatted_doubles(Vector values,
			boolean right_justify) {
		String[] result = new String[values.size()];
		final double billion = 1000000000.0;
		final double million = 1000000.0;
		final double thousand = 1000.0;
		double d;
		int size, longest_length = 0;

		for (int i = 0; i < values.size(); ++i) {
			d = ((Double) values.elementAt(i)).doubleValue();
			if (d >= billion) {
				result[i] = formatter.format(d / billion);
				result[i] += "b";
			} else if (d >= million) {
				result[i] = formatter.format(d / million);
				result[i] += "m";
			} else if (d >= thousand) {
				result[i] = formatter.format(d / thousand);
				result[i] += "k";
			} else {
				result[i] = formatter.format(d);
			}
			size = result[i].length();
			if (size > longest_length) {
				longest_length = size;
			}
		}

		if (right_justify) {
			// Ensure that all elements of `result' are right-justified
			// according to the size of the longest element.
			for (int i = 0; i < result.length; ++i) {
				size = result[i].length();
				if (size < longest_length) {
					for (int j = size; j < longest_length; ++j) {
						result[i] = " " + result[i];
					}
				}
			}
		}

		return result;
	}

	static public boolean isdigit(byte c) {
		byte zero = '0', nine = '9';
		return c >= zero && c <= nine;
	}

	// b at offset of length `length' as a positive integer.  -1 if
	// length <= 0 or the specified partition does not start with a digit.
	// Sets Last_int_length to the number of digits in the result or to
	// 0 if the result is -1.
	static public int int_from_bytes(byte b[], int offset, int length) {
		int result = -1;
		Last_int_length = 0;
		String buffer = null;
		if (length > 0 && isdigit(b[offset])) {
			int i;
			for (i = offset + 1; i < length + offset && isdigit(b[i]); ++i) {
			}
			Last_int_length = i - offset;
			buffer = new String(b, offset, Last_int_length);
			result = Integer.parseInt(buffer);
		}
		return result;
	}

	public static int Last_int_length;
	static NumberFormat formatter = NumberFormat.getInstance();
}
