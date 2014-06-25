indexing
	description: "Provider of the host name and port number obtained from %
		%the user when locating an unowned mas session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	client: LOCATE_SESSION_CLIENT

feature -- Client services

	register_client (c: LOCATE_SESSION_CLIENT; actn_code: INTEGER) is
			-- Register `c' as a "session-location" client with `actn_code'
			-- spcifying what action for the client to take on callback.
		require
			arg_exists: c /= Void
		do
			client := c
			action_code := actn_code
		ensure
			client_set: client = c
			code_set: action_code = actn_code
		end

end
