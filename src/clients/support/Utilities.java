package support;

import java.util.*;
import java.io.*;

/** General utilities */
public class Utilities
{
	public Utilities() {}

	// Index of the element of `dates' whose date_time matches `d',
	// assuming that `dates' and `d' are in the format "yyyymmdd" for
	// lexicographical comparison.
	// If no element's date_time matches `d':
	//   search_spec < 0: Index of latest element whose date_time < `d'
	//   search_spec > 0: Index of earliest element whose date_time > `d'
	//   search_spec = 0: -1
	// If there is no element whose date_time is earlier than `d' for
	// search_spec < 0 or no element whose date_time is later than `d'
	// for search_spec > 0, result is 0.
	// Time efficiency is O(log2 n)
	// Precondition:
	//   d != null
	//   All elements of `dates' and `d' are in the format "yyyymmdd".
	public int index_at_date (String d, String dates[], int search_spec) {
		int top, bottom, i, comparison, result = 0;

		// Perform a binary search.
		bottom = 0;
		top = dates.length - 1;
		// invariant:
		//	must_be_in: in_range_or_not_in_array (d, dates, bottom, top)
		// variant:
		//	top_bottom_difference: top - bottom + 1
		while (result == 0 && top >= bottom) {
			i = (bottom + top) / 2;
			// assert: i > 0 and bottom <= i and i <= top
			switch (d.compareTo (dates[i])) {
				case 0:
					result = i;
					break;
				case 1:
					bottom = i + 1;
					break;
				case -1:
					top = i - 1;
					break;
			}
		}
		if (result == 0 && search_spec != 0) {
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
	// 	non_zero_implies_valid: result > 0 implies valid_index (dates, result)
	// 	non_zero_spec_negative_implies_result_le_d:
	// 		result > 0 and search_spec < 0 implies
	// 			i_th (result).date_time <= (d)
	// 	non_zero_spec_positive_implies_result_ge_d:
	// 		result > 0 and search_spec > 0 implies
	// 			i_th (result).date_time >= (d)
	// 	spec_negative_next_item_gt_d_if_valid:
	// 		search_spec < 0 and valid_index (dates, result + 1) implies
	// 			i_th (result + 1).date_time > d
	// 	spec_positive_previous_item_lt_d_if_valid:
	// 		search_spec > 0 and valid_index (dates, result - 1) implies
	// 			i_th (result - 1).date_time < d
	// 	dates_match_if_has_d:
	// 		has_date_time (d) implies i_th (result).date_time.is_equal (d)

		return result;
	}

	boolean valid_index (String dates[], int i) {
		return i >= 0 && i < dates.length;
	}
}
