/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package application_library;

import java.util.*;
import support.NetworkProtocolUtilities;
import graph_library.DataSet;

/** Abstraction for parsing market and indicator data sent from
the Market Analysis server */
abstract public class AbstractParser extends NetworkProtocolUtilities {
	public static final int Date = 1, Open = 2, High = 3, Low = 4, Close = 5,
		Volume = 6, Open_interest = 7, Not_set = 0;

// Initialization

	// Constructor - fieldspecs specifies the fields format of each tuple -
	// e.g., date, high, low, close, volume.
	public AbstractParser(int fieldspecs[], String record_sep,
			String field_sep) {

		parsetype = fieldspecs;
		record_separator = record_sep;
		field_separator = field_sep;

		dates = new Vector();
		times = new Vector();
		float_field_count = float_fields(fieldspecs);
	}

// Access

	// Specifications of the type (date, open, etc.) and order of each field
	// in a tuple.
	public int[] field_specifications() {
		return parsetype;
	}

	// Parsed data set result
	abstract public DataSet result();

	// Parsed volume
	abstract public DataSet volume_result();

	// Parsed open interest
	abstract public DataSet open_interest_result();

	// The latest date-time in the parsed data set - null if no data set
	// has been parsed or if it contains no dates
	public Calendar latest_date_time() {
		Calendar result = null;
		if (dates != null && ! dates.isEmpty()) {
			String date = (String) dates.elementAt(dates.size() - 1);
			if (times != null && ! times.isEmpty()) {
				String time = (String) times.elementAt(dates.size() - 1);
//!!!:
System.out.println("date, time: " + date + ", " + time + " [Abs.Prsr.ldt]");
System.out.flush();
				result = date_time_from_dataset_strings(date, time);
			} else {
System.out.println("date: " + date);
				result = date_from_dataset_string(date);
			}
		}
System.out.println("parser - latest dt result: " + result);
		return result;
	}

	public String record_separator() {
		return record_separator;
	}

	public String field_separator() {
		return field_separator;
	}

// Element change

	// Set the tuple field specifications.
	// Precondition: fs != null
	// Postcondition: field_specifications() == fs
	public void set_field_specifications(int[] fs) {
		parsetype = fs;
	}

// Basic operations

	// Parse `s' into a DataSet according to record_separator and
	// field_separator.
	// result() gives the new DataSet.
	// Postcondition: result() != null
	public void parse(String s) throws Exception {
		is_intraday = contains_time_field(s);
		prepare_for_parse();
		StringTokenizer recs = new StringTokenizer(s, record_separator, false);
		clear_vectors();
		do_main_parse(recs);
	}

// Potential hook routines

	// Is there no open field in the field specifications?
	protected boolean has_no_open_field() {
		return ! has_field_type(Open) && has_field_type(High) &&
			has_field_type(Low);
	}

// Hook routines

	// Perform the main parse work with `recs'.
	abstract protected void do_main_parse(StringTokenizer recs)
		throws Exception;

	// Perform any needed preprations before parsing.
	protected void prepare_for_parse() {
		// do nothing - redefine if needed.
	}

// Implementation

	// Remove all elements from data vectors - set their sizes to 0.
	protected void clear_vectors() {
		dates.removeAllElements();
		times.removeAllElements();
	}

	// The number of fields in `fieldspecs' that will be of type float
	protected int float_fields(int fieldspecs[]) {
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
	protected boolean has_field_type(int ftype) {
		boolean result = false;
		for (int i = 0; i < parsetype.length; ++i) {
			if (parsetype[i] == ftype) result = true;
		}

		return result;
	}

	// Does `s' contain a time field?
	protected boolean contains_time_field(String s) {
		boolean result = false;
		int valid_parse_fields;
		StringTokenizer recs = new StringTokenizer(s, record_separator, false);
		if (recs.countTokens() > 0) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
				field_separator, false);

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

// Implementation - attributes

	protected int parsetype[];
	protected int float_field_count;

	// Date, time, open, high, low, close, volume, and open interest values -
	// Some fields may not be used - for those that are, lengths should all
	// be equal to the number of records in the input.
	protected Vector dates;	// String
	protected Vector times;	// String

	protected String record_separator, field_separator;
	protected boolean is_intraday;
}
