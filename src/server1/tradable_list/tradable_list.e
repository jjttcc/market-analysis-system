indexing
	description:
		"An iterable list of tradables"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TRADABLE_LIST inherit

	LINEAR [TRADABLE [BASIC_MARKET_TUPLE]]

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

feature -- Access

	file_names: LINEAR [STRING] is
			-- Names of tradable data files
		deferred
		end

	search_by_file_name (name: STRING) is
			-- Find the tradable whose associated file name matches `name'.
		deferred
		ensure
			index_match: file_names.index = index
		end

	search_by_symbol (s: STRING) is
			-- Find the tradable whose associated symbol matches `s'.
		deferred
		ensure
			index_match: file_names.index = index
		end

	symbols: LIST [STRING] is
			-- The symbol of each tradable, extracted from `file_names'
		local
			fnames: LINEAR [STRING]
		do
			fnames := file_names
			!LINKED_LIST [STRING]!Result.make
			from fnames.start until fnames.exhausted loop
				Result.extend (symbol_from_file_name (fnames.item))
				fnames.forth
			end
		ensure
			-- Result.count = file_names.count
			-- The contents of Result are in the same order as the
			-- corresponding contents of `file_names'.
		end

	symbol_from_file_name (fname: STRING): STRING is
			-- Tradable symbol extracted from `fname' - directory component
			-- and suffix ('.' and all characters that follow it) of the
			-- file name are removed.  `fname' is not changed.
		local
			i, last_sep_index: INTEGER
			strutil: STRING_UTILITIES
		do
			!!strutil.make (clone (fname))
			if strutil.target.has (Directory_separator) then
				-- Strip directory path from the file name:
				strutil.tail (Directory_separator)
			end
			if strutil.target.has ('.') then
				-- Strip off "suffix":
				strutil.head ('.')
			end
			Result := strutil.target
		end

end -- class TRADABLE_LIST
