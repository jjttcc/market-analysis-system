indexing
	description: "Clients that subscribe to actions based on GUI events"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

deferred class EVENT_CLIENT

feature -- Basic operations

	respond_to_event (supplier: EVENT_SUPPLIER) is
			-- Respond to an event for `supplier'.
		deferred
		end

end
