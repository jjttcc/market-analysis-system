indexing
	description: "Abstraction for a user who is an event registrant"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EVENT_USER inherit

	USER
		rename
			make as u_make
		end

	EVENT_REGISTRANT_WITH_HISTORY
		rename
			make as er_make
		end

	GLOBAL_SERVICES
		rename
			event_types as global_event_types
		end

	GLOBAL_APPLICATION

creation

	make

feature -- Initialization

	make is
		do
			u_make
			er_make
		end

feature -- Basic operations

	perform_notify (elist: LIST [TYPED_EVENT]) is
		local
			msg: STRING
			e: TYPED_EVENT
		do
			if not email_addresses.empty then
				!!msg.make (elist.count * 120)
				from
					elist.start
				until
					elist.exhausted
				loop
					e := elist.item
					msg.append (concatenation (<<"Event name: ",
								e.name, ", time stamp: ",
								e.time_stamp, ", type: ", e.type.name,
								"%Ndescription: ", e.description, "%N%N">>))
					elist.forth
				end
				notify_by_email (msg, concatenation (<<elist.count,
								" TA Events Received at ", current_date,
								", ", current_time>>))
			end
		end

end -- EVENT_USER
