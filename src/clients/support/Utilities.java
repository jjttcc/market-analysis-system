/* Copyright 1998, 1999: Jim Cochrane - see file forum.txt */

package support;

import java.util.*;
import java.io.*;

/** General utilities */
public class Utilities
{
	public Utilities() {}

	// The month `m' as a string
	// Precondition:
	//   m >= 1 && m <= 12
	public static String month_at(int m) {
		return months[m-1];
	}

	// Index of the element of `dates' whose date_time matches `d',
	// assuming that `dates' and `d' are in the format "yyyymmdd" for
	// lexicographical comparison.
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
	static public int index_at_date (String d, String dates[],
			int search_spec) {
		int top, bottom, i, comparison, result = -1;

		// Perform a binary search.
		bottom = 0;
		top = dates.length - 1;
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
}
