indexing
	description: "Global entities needed by the application"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_APPLICATION

feature {NONE} -- Utility

	current_date: DATE is
		do
			!!Result.make_now
		end

	current_time: TIME is
		do
			!!Result.make_now
		end

	register_for_termination (v: TERMINABLE) is
			-- Add `v' to termination_registrants.
		require
			not_registered: not termination_registrants.has (v)
		do
			termination_registrants.extend (v)
		end

	termination_cleanup is
			-- Send cleanup notification to all members of
			-- `termination_registrants'.
		do
			from
				termination_registrants.start
			until
				termination_registrants.exhausted
			loop
				termination_registrants.item.cleanup
				termination_registrants.forth
			end
		end

feature {NONE} -- Access

	termination_registrants: LIST [TERMINABLE] is
			-- Registrants for termination cleanup notification
		once
			!LINKED_LIST [TERMINABLE]!result.make
		end

feature {NONE} -- Constants

	default_input_file_name: STRING is "/tmp/tatest"

end -- GLOBAL_APPLICATION
