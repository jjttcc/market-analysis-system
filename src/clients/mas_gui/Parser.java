import java.lang.*;
import java.util.*;
import graph.*;

/** Market Analysis Parser - parses market and indicator data sent from
the Market Analysis server */
class MA_Parser {
	public static final int Date = 1, Open = 2, High = 3, Low = 4, Close = 5,
		Volume = 6, Open_interest = 7;

	// Constructor - fieldspecs specifies the fields format of each tuple -
	// e.g., date, high, low, close, volume.
	MA_Parser(int fieldspecs[], String record_sep, String field_sep) {
		parsetype = fieldspecs;
		_record_separator = record_sep;
		_field_separator = field_sep;

		dates = new Vector();
		float_field_count = float_fields(fieldspecs);
		has_volume = has_field_type(Volume);
		has_open_interest = has_field_type(Open_interest);
	}

	// Set the drawer for drawing volume.
	void set_volume_drawer(Drawer d) {
		volume_drawer = d;
	}

	// Set the drawer for open interest.
	void set_open_interest_drawer(Drawer d) {
		open_interest_drawer = d;
	}

	// Parse `s' into a DataSet according to record_separator and
	// field_separator.  `drawer' is the tuple drawer to use for the
	// DataSet.  result() gives the new DataSet.
	public void parse(String s, Drawer drawer) throws Exception {
		int float_index = 0, volume_index = 0, oi_index = 0;
		StringTokenizer recs = new StringTokenizer(s, _record_separator, false);
		clear_vectors();
		float_data = new double[recs.countTokens() * float_field_count];
		if (has_volume) {
			volumes = new double[recs.countTokens()];
		}
		if (has_open_interest) {
			open_interests = new double[recs.countTokens()];
		}
		while (recs.hasMoreTokens()) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
													_field_separator, false);
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				switch (parsetype[j]) {
					case Date:
						dates.addElement(fields.nextToken());
						break;
					case Open:
						float_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case High:
						float_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Low:
						float_data[float_index++] =
							parse_double(fields.nextToken());
						break;
					case Close:
						float_data[float_index++] =
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
		}
		process_data(drawer);
	}

	// Parsed data set result
	DataSet result() {
		return processed_data;
	}

	// Parsed volume
	DataSet volume_result() {
		return volume_data;
	}

	// Parsed volume
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

	double parse_double(String s) {
		return Float.valueOf(s).floatValue();
	}

	Integer parse_int(String s) {
		return Integer.valueOf(s);
	}

	// Put the parsed data into a data set.
	private void process_data(Drawer drawer) throws Exception {
		String[] date_array = null;
		boolean has_dates = false;

		try {
			has_dates = dates != null && ! dates.isEmpty();
			int length = float_data.length / float_field_count;
			if (length > 0) {
				processed_data = new DataSet(float_data, length, drawer);
			}
			else {
				processed_data = new DataSet(drawer);
			}
			if (has_dates) {
				date_array = new String[dates.size()];
				dates.copyInto(date_array);
				processed_data.set_dates(date_array);
			}
			if (volume_drawer != null && volumes != null &&
					volumes.length > 0) {
				volume_data = new DataSet(volumes, volumes.length,
											volume_drawer);
				if (has_dates) volume_data.set_dates(date_array);
			}
			if (open_interest_drawer != null && open_interests != null &&
					open_interests.length > 0) {
				oi_data = new DataSet(open_interests,
					open_interests.length, open_interest_drawer);
				if (has_dates) oi_data.set_dates(date_array);
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

	int parsetype[];
	int float_field_count;

	// Date, open, high, low, close, volume, and open interest values -
	// Some fields may not be used - for those that are, lengths should all
	// be equal to the number of records in the input.
	protected Vector dates;	// String
	protected double[] float_data;
	protected double[] volumes, open_interests;

	String _record_separator, _field_separator;
	DataSet processed_data;		// the parsed data
	DataSet volume_data;		// the parsed volume data
	DataSet oi_data;			// the parsed open interest data
	boolean has_volume;
	boolean has_open_interest;
	Drawer volume_drawer;
	Drawer open_interest_drawer;
}
