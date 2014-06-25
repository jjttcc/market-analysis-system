note

	description:
		"Constants used for the 'report-back-on-startup' protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	REPORT_BACK_PROTOCOL

feature -- String constants

	Report_back_flag: STRING = "-report_back"
			-- Flag for the "report-back" option

	Host_port_separator: CHARACTER = '^'

end
