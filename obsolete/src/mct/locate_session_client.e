indexing
	description: "Client that accepts the host name and port number %
		%obtained by the LOCATE_SESSION_WINDOW"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

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
