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

feature -- Access

	event_history: LINKED_LIST [MARKET_EVENT]

feature -- Basic operations

	load_history is
		local
			hfile: PLAIN_TEXT_FILE
			scanner: MARKET_EVENT_SCANNER
			exception_occurred: BOOLEAN
		do
			if
				exception_occurred and exception = Operating_system_exception
			then
				-- hfile.make_open_read failed because the file does not
				-- exist.  This is not really an error, so continue.
				!!event_history.make
				event_history.compare_objects
			elseif hfile_name /= Void then
				!!hfile.make_open_read (hfile_name)
				!!scanner.make (hfile)
				scanner.execute
				event_history := scanner.product
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
		do
			-- Open the event history file, delete its current contents and
			-- save all elements of `event_history' into the file.
			if hfile_name /= Void then
				!!hfile.make_create_read_write (hfile_name)
				-- Make the scanner to get its field separator.
				!!scanner.make (hfile)
				fld_sep := scanner.field_separator
				record_sep := scanner.record_separator
				from
					event_history.start
				until
					event_history.exhausted
				loop
					hfile.put_string (event_guts (event_history.item, fld_sep))
					hfile.put_string (record_sep)
					event_history.forth
				end
				hfile.close
			end
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

end -- MARKET_EVENT_REGISTRANT
