indexing
	description: "Clients that subscribe to actions based on GUI events"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class EVENT_CLIENT

feature -- Basic operations

	respond_to_event (supplier: EVENT_SUPPLIER) is
			-- Respond to an event for `supplier'.
		deferred
		end

end
