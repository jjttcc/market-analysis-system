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
		// !!For now (hack, hack), hard code these sizes - In the finished
		// version, perhaps a Vector should be used.
		dates = new Vector();
		opens = new Vector();
		highs = new Vector();
		lows = new Vector();
		closes = new Vector();
		volumes = new Vector();
		open_interests = new Vector();
	}

	// Parse `s' according to record_separator and field_separator.
	public void parse(String s) {
		StringTokenizer recs = new StringTokenizer(s, _record_separator, false);
		clear_vectors();
		for (int i = 0; recs.hasMoreTokens(); ++i) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
													_field_separator, false);
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				switch (parsetype[j]) {
					case Date:
						dates.addElement(fields.nextToken());
						break;
					case Open:
						opens.addElement(parse_float(fields.nextToken()));
						break;
					case High:
						highs.addElement(parse_float(fields.nextToken()));
						break;
					case Low:
						lows.addElement(parse_float(fields.nextToken()));
						break;
					case Close:
						closes.addElement(parse_float(fields.nextToken()));
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
		process_data();
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

	Float parse_float(String s) {
		return Float.valueOf(s);
	}

	Integer parse_int(String s) {
		return Integer.valueOf(s);
	}

	// Put the parsed data into a data set.
	void process_data() {
		//!!!For now, just produce an array of indexes and close values to
		//!!!feed the DataSet.
		double xy_data[] = new double[closes.size() * 2];
		for (int i = 0, j = 0; j < closes.size(); i += 2, ++j) {
			xy_data[i] = j + 1; // x
			xy_data[i+1] = ((Float) closes.elementAt(j)).floatValue(); // y
		}
		try {
			processed_data = new DataSet(xy_data, xy_data.length / 2);
		}
		catch (Exception e) {
			System.out.println("DataSet constructor failed!!!!!!!!");
			// !!!What to do with e?
		}
	}

	// Remove all elements from data vectors - set their sizes to 0.
	void clear_vectors() {
		dates.removeAllElements(); opens.removeAllElements();
		highs.removeAllElements(); lows.removeAllElements();
		closes.removeAllElements(); volumes.removeAllElements();
		open_interests.removeAllElements();
	}

	int parsetype[];

	// Date, open, high, low, close, volume, and open interest values -
	// Some fields may not be used - for those that are, lengths should all
	// be equal to the number of records in the input.
	// NOTE: Although these are all public, their contents must not be
	// changed by a client - I should provide access functions, but I don't
	// want to take the time.
	public Vector dates;	// String
	public Vector opens, highs, lows, closes;	// float
	public Vector volumes, open_interests;	// int

	String _record_separator, _field_separator;
	DataSet processed_data;		// the parsed data
}
