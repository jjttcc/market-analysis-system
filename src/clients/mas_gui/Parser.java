/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.lang.*;
import java.util.*;
import graph.*;

/** Market Analysis Parser - parses market and indicator data sent from
the Market Analysis server */
class Parser {
	public static final int Date = 1, Open = 2, High = 3, Low = 4, Close = 5,
		Volume = 6, Open_interest = 7, Not_set = 0;

	// Constructor - fieldspecs specifies the fields format of each tuple -
	// e.g., date, high, low, close, volume.
	Parser(int fieldspecs[], String record_sep, String field_sep) {
		parsetype = fieldspecs;
		_record_separator = record_sep;
		_field_separator = field_sep;

		dates = new Vector();
		times = new Vector();
		float_field_count = float_fields(fieldspecs);
	}

	// Set the tuple field specifications.
	// Precondition: fs != null
	// Postcondition: field_specifications() == fs
	void set_field_specifications(int[] fs) {
		parsetype = fs;
	}

	// Set the drawer for drawing volume.
	void set_volume_drawer(BasicDrawer d) {
		volume_drawer = d;
	}

	// Set the drawer for open interest.
	void set_open_interest_drawer(BasicDrawer d) {
		open_interest_drawer = d;
	}

	// Specifications of the type (date, open, etc.) and order of each field
	// in a tuple.
	int[] field_specifications() {
		return parsetype;
	}

	// Parse `s' into a DataSet according to record_separator and
	// field_separator.  `drawer' is the tuple drawer to use for the
	// DataSet.  result() gives the new DataSet.
	public void parse(String s, BasicDrawer drawer) throws Exception {
		int rec_count;
		volumes = null;
		open_interests = null;
		is_intraday = contains_time_field(s);
		StringTokenizer recs = new StringTokenizer(s, _record_separator, false);
		rec_count = recs.countTokens();
		clear_vectors();
		if (has_field_type(Volume)) {
			volumes = new double[rec_count];
		}
		if (has_field_type(Open_interest)) {
			open_interests = new double[rec_count];
		}
		// If there is no open field
		if (! has_field_type(Open) && has_field_type(High) &&
				has_field_type(Low)) {
			// Add 1 to make room for the "fake" open field.
			value_data = new double[rec_count * (float_field_count + 1)];
			parse_with_no_open(recs);
		} else {
			value_data = new double[rec_count * float_field_count];
			parse_default(recs);
		}
		process_data(drawer);
	}

	// Parse fields - default routine
	private void parse_default(StringTokenizer recs) throws Exception {
		int float_index = 0, volume_index = 0, oi_index = 0;
		while (recs.hasMoreTokens()) {
			String s = recs.nextToken();
			StringTokenizer fields = new StringTokenizer(s,
				_field_separator, false);
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				try {
				switch (parsetype[j]) {
					case Date:
						dates.addElement(fields.nextToken());
						if (is_intraday) {
							times.addElement(fields.nextToken());
						}
						break;
					case Open:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case High:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Low:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Close:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Volume:
						volumes[volume_index++] =
							parse_double(fields.nextToken());
						break;
					case Open_interest:
						open_interests[oi_index++] =
							parse_double(fields.nextToken());
						break;
				}
				}
				catch (Exception e) {
					System.err.println("Last record processed was dated " +
						dates.elementAt(dates.size() - 1));
					throw e;
				}
			}
		}
	}

	// Parse fields - expecting high, low, and close fields (in that order),
	// but NO open field.
	private void parse_with_no_open(StringTokenizer recs) throws Exception {
		int float_index = 0, volume_index = 0, oi_index = 0;
		while (recs.hasMoreTokens()) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
													_field_separator, false);
			int open_field_index = -1;
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				try {
				switch (parsetype[j]) {
					case Date:
						dates.addElement(fields.nextToken());
						if (is_intraday) {
							times.addElement(fields.nextToken());
						}
						// Save a place for the open field:
						value_data[float_index] = 0;
						open_field_index = float_index;
						++float_index;
						break;
					case High:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Low:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Close:
						value_data[float_index++] =
							parse_double(fields.nextToken());
						if (open_field_index != -1) {
							// Store the close value into the open field.
							value_data[open_field_index] =
								value_data[float_index - 1];
						}
						break;
					case Volume:
						volumes[volume_index++] =
							parse_double(fields.nextToken());
						break;
					case Open_interest:
						open_interests[oi_index++] =
							parse_double(fields.nextToken());
						break;
				}
				}
				catch (Exception e) {
					System.err.println("Last record processed was dated " +
						dates.elementAt(dates.size() - 1));
					throw e;
				}
			}
		}
	}

	// Parsed data set result
	DataSet result() {
		return processed_data;
	}

	// Parsed volume
	DataSet volume_result() {
		return volume_data;
	}

	// Parsed open interest
	DataSet open_interest_result() {
		return oi_data;
	}

	public String record_separator() {
		return _record_separator;
	}

	public String field_separator() {
		return _field_separator;
	}

// Implementation

	double parse_double(String s) throws Exception {
		double result;
		try {
			result = Float.valueOf(s).floatValue();
		}
		catch (Exception e) {
			if (s.equals("NaN") || s.equals("nan")) {
				System.err.println("NaN encountered - substituting 0.");
				result = 0;
			}
			else {
				System.err.println("Error occurred in formatting value " + s +
					" (" + e + ")");
				throw e;
			}
		}
		return result;
	}

	Integer parse_int(String s) {
		return Integer.valueOf(s);
	}

	// Put the parsed data into a data set.
	// Postcondition: result() != null && result().drawer() == drawer
	private void process_data(BasicDrawer drawer) throws Exception {
		String[] date_array = null;
		String[] time_array = null;
		boolean has_dates = false;
		boolean has_times = false;

		volume_data = null;
		oi_data = null;

		try {
			has_dates = dates != null && ! dates.isEmpty();
			has_times = times != null && ! times.isEmpty();
			int length = value_data.length / float_field_count;
			if (length > 0) {
				processed_data = new DataSet(value_data, length, drawer);
			}
			else {
				processed_data = new DataSet(drawer);
			}
			if (has_dates) {
				date_array = new String[dates.size()];
				dates.copyInto(date_array);
				processed_data.set_dates(date_array);
			}
			if (has_times) {
				time_array = new String[times.size()];
				times.copyInto(time_array);
				processed_data.set_times(time_array);
			}
			if (volume_drawer != null && volumes != null &&
					volumes.length > 0) {
				volume_data = new DataSet(volumes, volumes.length,
											volume_drawer);
				if (has_dates) volume_data.set_dates(date_array);
				if (has_times) volume_data.set_times(time_array);
			}
			if (open_interest_drawer != null && open_interests != null &&
					open_interests.length > 0) {
				oi_data = new DataSet(open_interests,
					open_interests.length, open_interest_drawer);
				if (has_dates) oi_data.set_dates(date_array);
				if (has_times) oi_data.set_times(time_array);
			}
		}
		catch (Exception e) {
			System.err.println("DataSet constructor failed - " + e);
			e.printStackTrace();
		}
	}

	// Remove all elements from data vectors - set their sizes to 0.
	private void clear_vectors() {
		dates.removeAllElements();
		times.removeAllElements();
	}

	// The number of fields in `fieldspecs' that will be of type float
	private int float_fields(int fieldspecs[]) {
		int result = 0;

		for (int i = 0; i < fieldspecs.length; ++i) {
			if (fieldspecs[i] == Open ||
				fieldspecs[i] == Close ||
				fieldspecs[i] == High ||
				fieldspecs[i] == Low) {
				result = result + 1;
			}
		}

		return result;
	}

	// Does `parsetype' have the specified field type?
	private boolean has_field_type(int ftype) {
		boolean result = false;
		for (int i = 0; i < parsetype.length; ++i) {
			if (parsetype[i] == ftype) result = true;
		}

		return result;
	}

	// Does `s' contain a time field?
	boolean contains_time_field(String s) {
		boolean result = false;
		int valid_parse_fields;
		StringTokenizer recs = new StringTokenizer(s, _record_separator, false);
		if (recs.countTokens() > 0) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
				_field_separator, false);

			valid_parse_fields = 0;
			for (int i = 0; i < parsetype.length && parsetype[i] != Not_set;
					++i) {
				++valid_parse_fields;
			}
			// If the number of fields in a record is greater than the number of
			// parse types, a time field is included.
			result = fields.countTokens() > valid_parse_fields;
		}
		return result;
	}

	int parsetype[];
	int float_field_count;

	// Date, time, open, high, low, close, volume, and open interest values -
	// Some fields may not be used - for those that are, lengths should all
	// be equal to the number of records in the input.
	protected Vector dates;	// String
	protected Vector times;	// String
	// Holds open, high, low, close data or, for indicator data, holds
	// the main value data.
	protected double[] value_data;
	protected double[] volumes, open_interests;

	String _record_separator, _field_separator;
	DataSet processed_data;		// the parsed data
	DataSet volume_data;		// the parsed volume data
	DataSet oi_data;			// the parsed open interest data
	boolean is_intraday;
	BasicDrawer volume_drawer;
	BasicDrawer open_interest_drawer;
}
