indexing
	description: "Abstraction for a registrant of MARKET_EVENTs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_EVENT_REGISTRANT inherit

	EVENT_REGISTRANT_WITH_HISTORY
		redefine
			event_history
		end

	TERMINABLE

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

feature -- Basic operations

	load_history is
		local
			hfile: PLAIN_TEXT_FILE
			scanner: MARKET_EVENT_SCANNER
			exception_occurred: BOOLEAN
			env: expanded APP_ENVIRONMENT
		do
			if
				exception_occurred and exception = Operating_system_exception
			then
				-- hfile.make_open_read failed because the file does not
				-- exist.  This is not really an error, so continue.
				check
					eh_created: event_history /= Void
				end
				event_history.compare_objects
			elseif hfile_name /= Void then
				!!hfile.make_open_read (
					env.file_name_with_app_directory (hfile_name))
				!!scanner.make (hfile)
				scanner.execute
				fill_event_history (scanner.product)
				event_history.compare_objects
				hfile.close
			end
		ensure then
			event_history.object_comparison
		rescue
			exception_occurred := true
			retry
		end

	cleanup is
		local
			hfile: PLAIN_TEXT_FILE
			scanner: MARKET_EVENT_SCANNER
			fld_sep, record_sep: STRING
			env: expanded APP_ENVIRONMENT
		do
			-- Open the event history file, delete its current contents and
			-- save all elements of `event_history' into the file.
			if hfile_name /= Void then
				!!hfile.make_create_read_write (
					env.file_name_with_app_directory (hfile_name))
				-- Make the scanner to get its field separator.
				!!scanner.make (hfile)
				fld_sep := scanner.field_separator
				record_sep := scanner.record_separator
				from
					event_history.start
				until
					event_history.after
				loop
					hfile.put_string (event_guts (
						event_history.item_for_iteration, fld_sep))
					hfile.put_string (record_sep)
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

	hfile_name: STRING
			-- Event history file name

	event_guts (e: MARKET_EVENT; separator: STRING): STRING is
		local
			guts: ARRAY [STRING]
			i: INTEGER
		do
			from
				!!Result.make (0)
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
				!!event_history.make (l.count)
				l.start
			until
				l.exhausted
			loop
				event_history.extend (l.item, l.item.unique_id)
				l.forth
			end
		end

	event_information (e: TYPED_EVENT): STRING is
			-- Reporting information extracted from `e'
		do
			if
				-- Don't print the time if it's midnight - non-intraday
				-- trading period.
				e.time /= Void and then not (e.time.hour = 0 and
					e.time.minute = 0)
			then
				Result := concatenation (<<"Event name: ", e.name, ", date: ",
										e.date, ", time: ", e.time,
										", type: ", e.type.name,
										"%Ndescription: ", e.description>>)
			elseif e.date /= Void then
				Result := concatenation (<<"Event name: ", e.name, ", date: ",
										e.date, ", type: ", e.type.name,
										"%Ndescription: ", e.description>>)
			else
				Result := concatenation (<<"Event name: ", e.name,
										", time stamp: ", e.time_stamp,
										", type: ", e.type.name,
										"%Ndescription: ", e.description>>)
			end
		end

end -- MARKET_EVENT_REGISTRANT
