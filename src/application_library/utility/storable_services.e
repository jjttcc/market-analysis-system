indexing
	description: "Services for STORABLE_LISTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class STORABLE_SERVICES [G] inherit

	TERMINABLE

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

	readonly: BOOLEAN
			-- Are changes not allowed to be saved?

	ok_to_save: BOOLEAN
			-- Are changes allowed to be saved?

	abort_edit: BOOLEAN is
			-- Should the edit session be aborted?
		do
			Result := not ok_to_save and not readonly
		ensure
			definition: Result = (not ok_to_save and not readonly)
		end

	error_occurred: BOOLEAN is
			-- Did an error occur during the last operation?
		deferred
		end

feature -- Basic operations

	edit_list is
			-- Allow user to edit the list and save the changes.
		local
			at_end: BOOLEAN
		do
			begin_edit
			if not abort_edit then
				do_edit
				at_end := true
				end_edit
			end
		ensure
			not_changed: not changed
			not_locked: not lock.locked
		rescue
			if not abort_edit and not at_end then
				end_edit
			end
		end

feature {NONE} -- Implementation

	save is
			-- Save user's changes to persistent store.
		require
			changed_and_ok_to_save: changed and ok_to_save
			not_aborted: not abort_edit
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
			-- Perform actions necessary to begin the editing session,
			-- including attempting to lock the persistent file.
		do
			readonly := false
			ok_to_save := true
			changed := false
			initialize_lock
			lock.try_lock
			if not lock.locked then
				if lock.error_occurred then
					show_message (lock.last_error)
				end
				prompt_for_edit_state
				if ok_to_save then
					show_message ("Waiting to obtain a lock ...")
					lock.lock
					show_message ("  Lock obtained - continuing.%N")
				elseif abort_edit then
					show_message ("Aborting edit session.%N")
				else
					check check_readonly: readonly end
					show_message ("Continuing - changes will not be saved.%N")
				end
			end
			if not abort_edit then
				retrieve_persistent_list
				initialize_working_list
			end
		ensure
			locked_read_or_abort:
				ok_to_save and lock.locked or readonly or abort_edit
		end

	report_errors is
		do
			if error_occurred then
				show_message (last_error)
				reset_error
			end
		end

	end_edit is
			-- Perform actions necessary to end the editing session,
			-- including ensuring that the file lock is released.
		require
			lock_set: lock /= Void
			abort_rules: abort_edit implies not changed and not lock.locked
		do
			if changed then
				-- The working list was changed, but the user elected not
				-- to save the changes; so throw away the changes by
				-- restoring the working list as a deep copy of the real
				-- list and ensure not changed.
				working_list.deep_copy (real_list)
				changed := false
			end
			if lock.locked then
				lock.unlock
			end
		ensure
			not_changed: not changed
		end

	lock: FILE_LOCK

	prompt_for_edit_state is
			-- Prompt the user as to whether to "edit" read-only, wait for
			-- lock to clear, or abort edit.
		local
			c: CHARACTER
		do
			c := prompt_for_char ("Failed to lock item.  Wait for lock, %
				%Disallow changes, or Abort? (w/d/a) ", "wWdDaA")
			inspect
				c
			when 'w', 'W' then
				readonly := false
				ok_to_save := true
			when 'd', 'D' then
				readonly := true
				ok_to_save := false
			when 'a', 'A' then
				ok_to_save := false
				readonly := false
			end
		ensure
			readonly_or_wait_or_abort: (readonly and not ok_to_save) or
				(not readonly and ok_to_save) or
				(not readonly and not ok_to_save)
		end

	initialize_lock is
			-- Ensure `lock' has been created and is unlocked.
		do
			if lock /= Void and lock.locked then
				lock.unlock
			else
				do_initialize_lock
			end
		ensure
			lock_set: lock /= Void and not lock.locked
		end

	cleanup is
		do
			if lock /= Void and lock.locked then
				lock.unlock
			end
		ensure then
			unlocked: lock /= Void implies not lock.locked
		end

feature {NONE} -- Hook routines

	do_edit is
			-- Hook method called by edit_list
		deferred
		end

	show_message (s: STRING) is
			-- Display `s' to the user.
		deferred
		end

	prompt_for_char (msg, charselection: STRING): CHARACTER is
		deferred
		end

	reset_error is
		deferred
		ensure
			no_error: not error_occurred
		end

	retrieve_persistent_list is
			-- Retrieve the current contents of the storable list from
			-- persistent store.
		deferred
		end

	initialize_working_list is
		deferred
		end

	end_save is
			-- Hook for end of save routine, if needed
		do
		end

	do_initialize_lock is
		deferred
		ensure
			lock_not_void: lock /= Void and not lock.locked
		end

invariant

	read_implication: readonly implies not ok_to_save and not abort_edit
	save_implication: ok_to_save implies not readonly and not abort_edit
	not_locked_when_readonly: readonly implies lock /= Void and not lock.locked
	abort_rules: abort_edit implies not changed and
		(lock /= Void implies not lock.locked)

end -- STORABLE_SERVICES
