note
	description: "Services for loading and saving event histories for %
		%TRADABLE_EVENT_REGISTRANTs - intended to be used via inheritance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class EVENT_HISTORY_MANAGEMENT inherit

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

	TERMINABLE

feature

	error_occurred: BOOLEAN
			-- Did an error occur during the last operation?

	last_error: STRING
			-- Description of the last error that occurred

	load_tradable_event_histories
			-- Load event history for all TRADABLE_EVENT_REGISTRANTs.
		local
			l: LIST [TRADABLE_EVENT_REGISTRANT]
			lock: FILE_LOCK
		do
			error_occurred := False
			register_for_termination (Current)
			make_event_locks
			l := tradable_event_registrants
			from
				l.start
			until
				l.exhausted
			loop
				lock := event_locks.item (l.item.hfile_name)
				lock.try_lock
				if not lock.locked then
					error_occurred := True
					last_error := concatenation (<<"Failed to lock event ",
						"history file ", lock.file_path, " - results will ",
						"not be saved.">>)
				end
				l.item.load_history
				l.forth
			end
		ensure
			on_error: error_occurred implies last_error /= Void
		end

	save_tradable_event_histories
			-- Save event history for all TRADABLE_EVENT_REGISTRANTs.
		local
			l: FILE_LOCK
		do
			from
				tradable_event_registrants.start
			until
				tradable_event_registrants.exhausted
			loop
				l := event_locks.item (
					tradable_event_registrants.item.hfile_name)
				-- Don't save the history for the current registrant
				-- unless it was successfully locked.
				if l.locked then
					tradable_event_registrants.item.save_history
					l.unlock
				end
				tradable_event_registrants.forth
			end
			event_locks.wipe_out
			unregister_for_termination (Current)
		end

	make_event_locks
			-- Make locks for event history files.
		local
			l: FILE_LOCK
			env: expanded APP_ENVIRONMENT
			hfname: STRING
		do
			if event_locks = Void then
				create {HASH_TABLE [FILE_LOCK, STRING]} event_locks.make (
					tradable_event_registrants.count)
			end
			check
				locks_empty: event_locks.is_empty
			end
			from
				tradable_event_registrants.start
			until
				tradable_event_registrants.exhausted
			loop
				hfname := tradable_event_registrants.item.hfile_name
				l := make_lock (env.file_name_with_app_directory (hfname,
					False))
				event_locks.put (l, hfname)
				tradable_event_registrants.forth
			end
		end

	event_locks: HASH_TABLE [FILE_LOCK, STRING]

	make_lock (name: STRING): FILE_LOCK
			-- Create a new lock.
		deferred
		end

	cleanup
			-- Remove all `event_locks'.
		local
			l: FILE_LOCK
		do
			from
				tradable_event_registrants.start
			until
				tradable_event_registrants.exhausted
			loop
				l := event_locks.item (
					tradable_event_registrants.item.hfile_name)
				if l.locked then
					l.unlock
				end
				tradable_event_registrants.forth
			end
			event_locks.wipe_out
		ensure then
			no_locks: event_locks.is_empty
		end

end -- class EVENT_HISTORY_MANAGEMENT
