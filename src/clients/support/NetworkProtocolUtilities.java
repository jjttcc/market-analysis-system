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
	public String date_time_range(Calendar start, Calendar end) {
		String start_string = standard_formatted_date(start,
			Client_request_date_field_separator) +
			Client_request_date_time_separator +
			standard_formatted_time(start, Client_request_time_field_separator);
		String end_string = standard_formatted_date(end,
			Client_request_date_field_separator) +
			Client_request_date_time_separator +
			standard_formatted_time(end, Client_request_time_field_separator);
		return start_string +
			Client_request_date_time_range_separator + end_string;
	}

//!!!Needed:?
	public Calendar date_from_string(Calendar date) {
return null; //!!!!To be implemented
	}

	// A date-time one second later than `date'
	// Preconditiion: date != null
	public Calendar one_second_later(Calendar date) {
		int y, m, d, h, min, s;
		y = date.get(date.YEAR);
		m = date.get(date.MONTH);
		d = date.get(date.DATE);
		h = date.get(date.HOUR_OF_DAY);
		min = date.get(date.MINUTE);
		s = date.get(date.SECOND);

		return new GregorianCalendar(y, m, d, h, min, s);
	}
}
