import java.lang.*;
import java.util.*;

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
	}

	// Parse `s' according to record_separator and field_separator.
	public void parse(String s) {
		StringTokenizer recs = new StringTokenizer(s, _record_separator, false);
		for (int i = 0; recs.hasMoreTokens(); ++i) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
													_field_separator, false);
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				switch (parsetype[j]) {
					case Date:
						dates[i] = fields.nextToken();
						break;
					case Open:
						opens[i] = parse_float(fields.nextToken());
						break;
					case High:
						highs[i] = parse_float(fields.nextToken());
						break;
					case Low:
						lows[i] = parse_float(fields.nextToken());
						break;
					case Close:
						closes[i] = parse_float(fields.nextToken());
						break;
					case Volume:
						volumes[i] = parse_int(fields.nextToken());
						break;
					case Open_interest:
						open_interests[i] = parse_int(fields.nextToken());
						break;
				}
			}
		}
	}

	public String record_separator() {
		return _record_separator;
	}

	public String field_separator() {
		return _field_separator;
	}

// Implementation

	float parse_float(String s) {
		return Float.valueOf(s).floatValue();
	}

	int parse_int(String s) {
		return Integer.parseInt(s);
	}

	int parsetype[];

	// Date, open, high, low, close, volume, and open interest values -
	// Some fields may not be used - for those that are, lengths should all
	// be equal to the number of records in the input.
	// NOTE: Although these are all public, their contents must not be
	// changed by a client - I should provide access functions, but I don't
	// want to take the time.
	public String dates[];
	public float opens[], highs[], lows[], closes[];
	public int volumes[], open_interests[];

	String _record_separator, _field_separator;
}
