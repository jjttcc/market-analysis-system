indexing
	description: "Provider of the host name and port number obtained from %
		%the user when locating an unowned mas session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

deferred class LOCATE_SESSION_SUPPLIER

feature -- Access

	host_name: STRING is
			-- The host name obtained from the user
		deferred
		end

	port_number: STRING is
			-- The port number obtained from the user
		deferred
		end

	action_code: INTEGER
			-- The action code specified by the last call to `register_client'

end
