/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package support;

import java.awt.*;
import common.NetworkProtocol;
import java.util.Date;


// Utilities that aid in communicating with the server according to the
// network protocol specification
public class NetworkProtocolUtilities implements NetworkProtocol {

	// The date-time range, formatted according to the protocol, for a
	// time-delimited data request starting at `start' and ending at `end'
	public String date_time_range(Date start, Date end) {
return ""; //!!!!To be implemented
	}

//!!!Needed:?
	public Date date_from_string(Date d) {
return null; //!!!!To be implemented
	}

	// A date-time one second later than `d'
	// Preconditiion: d != null
	public Date one_second_later(Date d) {
		return new Date(d.getTime() + 1);
	}
}
