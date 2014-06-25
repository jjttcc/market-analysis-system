indexing
	description: "Client that accepts the host name and port number %
		%obtained by the LOCATE_SESSION_WINDOW"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class LOCATE_SESSION_CLIENT

feature -- Basic operations

	respond_to_session_location (supplier: LOCATE_SESSION_SUPPLIER) is
			-- Respond to the successful location of a MAS session.
		deferred
		end

	respond_to_session_location_cancellation (
		supplier: LOCATE_SESSION_SUPPLIER) is
			-- Respond to the unsuccessful location of a MAS session.
		deferred
		end

end
