indexing
	description: "Services for STORABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class STORABLE_SERVICES [G] inherit

feature -- Access

	last_error: STRING is
			-- Description of last error that occurred
		deferred
		end

	real_list: STORABLE_LIST [G] is
			-- The actual persistent list
		deferred
		end

	working_list: STORABLE_LIST [G] is
			-- Working list used for editing
		deferred
		end

feature -- Status report

	changed: BOOLEAN
			-- Did the last operation make a change that may need to be
			-- saved to persistent store?

	error_occurred: BOOLEAN is
			-- Did an error occur during the last operation?
		deferred
		end

feature -- Basic operations

	save is
		require
			changed: changed
		do
			real_list.copy (working_list)
			real_list.save
			show_message ("The changes have been saved.")
			working_list.deep_copy (real_list)
			changed := false
			end_save
		ensure then
			not_changed: not changed
		end

	begin_edit is
		do
			if working_list = Void then
				initialize_working_list
			end
			changed := false
		end

	report_errors is
		do
			if error_occurred then
				show_message (last_error)
				reset_error
			end
		end

	end_edit is
		do
			if changed then
				working_list.deep_copy (real_list)
				changed := false
			end
		end

feature {NONE} -- Hook routines

	show_message (s: STRING) is
		deferred
		end

	reset_error is
		deferred
		ensure
			no_error: not error_occurred
		end

	initialize_working_list is
		deferred
		end

	end_save is
			-- Hook for end of save routine, if needed
		do
		end

end -- STORABLE_SERVICES
