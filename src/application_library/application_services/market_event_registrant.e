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
			elseif hfile_name /= Void then
				!!hfile.make_open_read (hfile_name)
				!!scanner.make (hfile)
				scanner.execute
				event_history := scanner.product
				hfile.close
			end
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
			if hfile_name /= Void then
				-- Create the file if it doesn't exist:
				!!hfile.make_open_write (hfile_name)
				hfile.close
				-- Re-open the file - readable to satisfy scanner constraint:
				hfile.open_read_write
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
			end
			hfile.close
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
