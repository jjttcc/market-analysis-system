indexing
	description: "Abstraction for an event registrant that simply logs %
				%events to a file"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class EVENT_LOG_FILE inherit

	PLAIN_TEXT_FILE
		rename
			make as file_make_unused
		export {NONE}
			all
		end

	EVENT_REGISTRANT_WITH_HISTORY
		rename
			make as er_make
		end

	GLOBAL_SERVICES
		rename
			event_types as global_event_types
		end

creation

	make

feature -- Initialization

	make (fname: STRING) is
		require
			not_void_and_not_empty: fname /= Void and not fname.empty
		do
			make_open_append (fname)
			er_make
		end

feature -- Basic operations

	perform_notify (elist: LIST [TYPED_EVENT]) is
		local
			e: TYPED_EVENT
		do
			from
				elist.start
			until
				elist.exhausted
			loop
				e := elist.item
				put_string (concatenation (<<"Event received:%Nname: ",
						e.name, ", time stamp: ",
						e.time_stamp, ", type: ", e.type.name,
						"%Ndescription: ", e.description, "%N">>))
				elist.forth
			end
		end

invariant

	appendable: file_writable and is_open_append

end -- EVENT_LOG_FILE
