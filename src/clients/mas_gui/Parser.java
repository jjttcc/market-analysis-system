import java.lang.*;
import java.util.*;
import graph.*;

/** Technical Analysis Parser - parses market and indicator data sent from
the TA server */
class TA_Parser {
	public static final int Date = 1, Open = 2, High = 3, Low = 4, Close = 5,
		Volume = 6, Open_interest = 7;

	// Constructor - fieldspecs specifies the fields format of each tuple -
	// e.g., date, high, low, close, volume.
	TA_Parser(int fieldspecs[], String record_sep, String field_sep) {
		parsetype = fieldspecs;
		_record_separator = record_sep;
		_field_separator = field_sep;

		dates = new Vector();
		float_field_count = float_fields(fieldspecs);
		volumes = new Vector();
		open_interests = new Vector();
	}

	// Parse `s' into a DataSet according to record_separator and
	// field_separator.  `drawer' is the tuple drawer to use for the
	// DataSet.  result() gives the new DataSet.
	public void parse(String s, Drawer drawer) {
		int float_index = 0;
		StringTokenizer recs = new StringTokenizer(s, _record_separator, false);
		clear_vectors();
		float_data = new double[recs.countTokens() * float_field_count];
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
						volumes.addElement(parse_int(fields.nextToken()));
						break;
					case Open_interest:
						open_interests.addElement(
							parse_int(fields.nextToken()));
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
	private void process_data(Drawer drawer) {
		try {
			int length = float_data.length / float_field_count;
			if (length > 0)
			{
				processed_data = new DataSet(float_data, length, drawer);
			}
			else
			{
				processed_data = new DataSet(drawer);
			}
		}
		catch (Exception e) {
			System.err.println("DataSet constructor failed - " + e);
			e.printStackTrace();
			System.exit(-1);
		}
	}

	// Remove all elements from data vectors - set their sizes to 0.
	private void clear_vectors() {
		dates.removeAllElements();
		volumes.removeAllElements();
		open_interests.removeAllElements();
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

	int parsetype[];
	int float_field_count;

	// Date, open, high, low, close, volume, and open interest values -
	// Some fields may not be used - for those that are, lengths should all
	// be equal to the number of records in the input.
	protected Vector dates;	// String
	protected double[] float_data;
	protected Vector volumes, open_interests;	// int

	String _record_separator, _field_separator;
	DataSet processed_data;		// the parsed data
}
