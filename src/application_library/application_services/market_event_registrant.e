indexing
	description: "Abstraction for a registrant of MARKET_EVENTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class MARKET_EVENT_REGISTRANT inherit

	EVENT_REGISTRANT_WITH_HISTORY
		redefine
			event_history
		end

	EXCEPTIONS
		export {NONE}
			all
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	event_history: HASH_TABLE [MARKET_EVENT, STRING]

	field_separator: STRING
			-- Field separator for history file

	record_separator: STRING
			-- Record separator for history file

	hfile_name: STRING
			-- Event history file name

feature -- Basic operations

	load_history is
		local
			hfile: INPUT_FILE
			scanner: MARKET_EVENT_SCANNER
			exception_occurred: BOOLEAN
			env: expanded APP_ENVIRONMENT
		do
			if
				exception_occurred and exception = Operating_system_exception
			then
				-- hfile.open_read failed.  This is not really an
				-- error, so continue.
				check
					eh_created: event_history /= Void
				end
				event_history.compare_objects
			elseif hfile_name /= Void then
				create hfile.make (
					env.file_name_with_app_directory (hfile_name))
				if hfile.exists then
					hfile.open_read
					hfile.set_field_separator (field_separator)
					hfile.set_record_separator (record_separator)
					create scanner.make (hfile)
					scanner.execute
					fill_event_history (scanner.product)
					event_history.compare_objects
					hfile.close
				else
					create event_history.make (0)
					event_history.compare_objects
				end
			else
				create event_history.make (0)
				event_history.compare_objects
			end
		ensure then
			object_comparison: event_history.object_comparison
		rescue
			exception_occurred := True
			retry
		end

	save_history is
			-- Save event history to persistent store.
		local
			hfile: PLAIN_TEXT_FILE
			scanner: MARKET_EVENT_SCANNER
			env: expanded APP_ENVIRONMENT
		do
			-- Open the event history file, delete its current contents and
			-- save all elements of `event_history' into the file.
			if hfile_name /= Void then
				create {INPUT_FILE} hfile.make_create_read_write (
					env.file_name_with_app_directory (hfile_name))
				from
					event_history.start
				until
					event_history.after
				loop
					hfile.put_string (event_guts (
						event_history.item_for_iteration, field_separator))
					hfile.put_string (record_separator)
					event_history.forth
				end
				hfile.close
			end
			-- Clear the event cache and event history so that they won't
			-- be stored if this instance is saved to persistent store,
			-- since the history is stored separately (above) and the cache
			-- does not need to be persistent.
			event_cache.wipe_out
			event_history.clear_all
		end

feature {NONE} -- Implementation

	event_guts (e: MARKET_EVENT; separator: STRING): STRING is
		local
			guts: ARRAY [STRING]
			i: INTEGER
		do
			from
				create Result.make (0)
				i := 1
				guts := e.guts
			until
				i = guts.count
			loop
				Result.append (guts @ i)
				Result.append (separator)
				i := i + 1
			end
			-- Append the last field without a trailing separator:
			Result.append (guts @ i)
		end

	fill_event_history (l: LIST [MARKET_EVENT]) is
			-- Create `event_history' and fill it with the contents of `l'.
		do
			from
				create event_history.make (l.count)
				l.start
			until
				l.exhausted
			loop
				event_history.extend (l.item, l.item.unique_id)
				l.forth
			end
		end

	event_information (e: MARKET_EVENT): STRING is
			-- Reporting information extracted from `e'
		require
			e_not_void: e /= Void
		local
			tag: STRING
		do
			tag := clone (e.tag)
			tag.to_upper
			Result := concatenation (<<"Event for: ", tag>>)
			if
				-- Don't print the time if it's midnight - non-intraday
				-- trading period.
				e.time /= Void and then not (e.time.hour = 0 and
					e.time.minute = 0)
			then
				Result.append (concatenation (<<", date: ", e.date,
					", time: ", e.time>>))
			elseif e.date /= Void then
				Result.append (concatenation (<<", date: ", e.date>>))
			else
				Result.append (concatenation (<<", time stamp: ",
					e.time_stamp>>))
			end
			Result.append (concatenation (<<", type: ", e.type.name,
				"%Ndescription: ", e.description>>))
		end


invariant

	separators_set: field_separator /= Void and record_separator /= Void

end -- MARKET_EVENT_REGISTRANT
