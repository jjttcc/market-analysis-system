note

	description:
		"Constants used for the 'report-back-on-startup' protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	REPORT_BACK_PROTOCOL

feature -- String constants

	Report_back_flag: STRING = "-report_back"
			-- Flag for the "report-back" option

	Host_port_separator: CHARACTER = '^'

end
