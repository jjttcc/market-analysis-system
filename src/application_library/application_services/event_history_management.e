note
	description: "Services for loading and saving event histories for %
		%MARKET_EVENT_REGISTRANTs - intended to be used via inheritance"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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

	load_market_event_histories
			-- Load event history for all MARKET_EVENT_REGISTRANTs.
		local
			l: LIST [MARKET_EVENT_REGISTRANT]
			lock: FILE_LOCK
		do
			error_occurred := False
			register_for_termination (Current)
			make_event_locks
			l := market_event_registrants
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

	save_market_event_histories
			-- Save event history for all MARKET_EVENT_REGISTRANTs.
		local
			l: FILE_LOCK
		do
			from
				market_event_registrants.start
			until
				market_event_registrants.exhausted
			loop
				l := event_locks.item (
					market_event_registrants.item.hfile_name)
				-- Don't save the history for the current registrant
				-- unless it was successfully locked.
				if l.locked then
					market_event_registrants.item.save_history
					l.unlock
				end
				market_event_registrants.forth
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
					market_event_registrants.count)
			end
			check
				locks_empty: event_locks.is_empty
			end
			from
				market_event_registrants.start
			until
				market_event_registrants.exhausted
			loop
				hfname := market_event_registrants.item.hfile_name
				l := make_lock (env.file_name_with_app_directory (hfname,
					False))
				event_locks.put (l, hfname)
				market_event_registrants.forth
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
				market_event_registrants.start
			until
				market_event_registrants.exhausted
			loop
				l := event_locks.item (
					market_event_registrants.item.hfile_name)
				if l.locked then
					l.unlock
				end
				market_event_registrants.forth
			end
			event_locks.wipe_out
		ensure then
			no_locks: event_locks.is_empty
		end

end -- class EVENT_HISTORY_MANAGEMENT
