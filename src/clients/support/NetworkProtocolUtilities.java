/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.awt.*;
import common.NetworkProtocol;
import java.util.*;
import java_library.support.*;


// Utilities that aid in communicating with the server according to the
// network protocol specification
public class NetworkProtocolUtilities extends DateTimeServices
	implements NetworkProtocol {

	// The date-time range, formatted according to the protocol, for a
	// time-delimited data request starting at `start' and ending at `end'
	public static String date_time_range(Calendar start, Calendar end) {
		String result;
		String start_string, end_string;
		if (start == null) {
			start_string = "";
		} else {
			start_string = standard_formatted_date(start,
				Client_request_date_field_separator) +
				Client_request_date_time_separator + standard_formatted_time(
					start, Client_request_time_field_separator);
		}
		if (end == null) {
			end_string = "";
		} else {
			end_string = standard_formatted_date(end,
				Client_request_date_field_separator) +
				Client_request_date_time_separator + standard_formatted_time(
				end, Client_request_time_field_separator);
		}
		result = start_string + Client_request_date_time_range_separator +
			end_string;
		return result;
	}

	// A calander representing the date `d', where `d' is in the format
	// used for data sets: yyyymmdd (no field separator)
	// Precondition: d != null
	public static Calendar date_from_dataset_string(String d) {
		return date_from_string(d, "");
	}

	// A calander representing the time `t' (with the year, month, and day
	// set to 0), where `t' is in the format used for data sets: yyyymmdd
	// (no field separator)
	// Precondition: t != null
	public static Calendar time_from_dataset_string(String t) {
		return time_from_string(t, separator_from_time(t));
	}

	// A calander representing the date-time based on `d' and `t', where
	// `d' is in the date format used for data sets: yyyymmdd and `t' is
	// in the time format used for data sets: hhmmdd (no field separators)
	// Precondition: d != null && t != null
	public static Calendar date_time_from_dataset_strings(String d, String t) {
		Calendar date = date_from_string(d, "");
		Calendar time = time_from_string(t, separator_from_time(t));
		return date_time_from_date_and_time(date, time);
	}

	// A date-time one second later than `date'
	// Preconditiion: date != null
	public static Calendar one_second_later(Calendar date) {
		int y, m, d, h, min, s;
		y = date.get(date.YEAR);
		m = date.get(date.MONTH);
		d = date.get(date.DATE);
		h = date.get(date.HOUR_OF_DAY);
		min = date.get(date.MINUTE);
		s = date.get(date.SECOND) + 1;

		return new GregorianCalendar(y, m, d, h, min, s);
	}

	public static Calendar date_time_from_date_and_time(Calendar date,
			Calendar time) {

		int y, m, d, h, min, s;
		y = date.get(date.YEAR);
		m = date.get(date.MONTH);
		d = date.get(date.DATE);
		h = time.get(time.HOUR_OF_DAY);
		min = time.get(time.MINUTE);
		s = time.get(time.SECOND);

		return new GregorianCalendar(y, m, d, h, min, s);
	}

	// The component separator used in time `t' - empty string if no separator
	// Precondition: t != null
	public static String separator_from_time(String t) {
		String result = null;
		if (t.length() == 4 || t.length() == 6) {
			// Assume no separator - hhmm or hhmmss
			result = "";
		} else {
			for (int i = 0; result == null && i < t.length(); ++i) {
				char c = t.charAt(i);
				if (c < '0' || c > '9') {
					result = t.substring(i, i + 1);
				}
			}
			if (result == null) {
				throw new Error("Code defect encountered: time string '" +
					t + "' has the wrong number of digits");
			}
		}
		return result;
	}

	// The component separator used in date `d' (in yyyyxmmxdd) format -
	// empty string if no separator
	// Precondition: d != null
	public static String separator_from_date(String d) {
		String result = null;
		if (d.length() == 8) {
			// Assume no separator - yyyymmdd
			result = "";
		} else {
			for (int i = 0; i < d.length(); ++i) {
				char c = d.charAt(i);
				if (c < '0' || c > '9') {
					result = d.substring(i, i);
				}
			}
			if (result == null) {
				throw new Error("Code defect encountered: date string '" +
					d + "' has the wrong number of digits");
			}
		}
		return result;
	}
}
