indexing
	description:
		"An abstraction that provides a virtual list of tradables by %
		%holding a list that contains the input data file name of each %
		%tradable and loading the current tradable from its input file, %
		%giving the illusion that it is iterating over a list of tradables %
		%in memory.  The purpose of this scheme is to avoid using the %
		%large amount of memory that would be required to hold a large %
		%list of tradables in memory at once."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class FILE_TRADABLE_LIST inherit

	FILE_BASED_TRADABLE_LIST
		rename
			make as parent_make
		end

creation

	make

feature -- Initialization

	make (fnames: LIST [STRING]; factory: TRADABLE_FACTORY) is
			-- `symbols' will be created from `fnames'
		local
			slist: LINKED_LIST [STRING]
		do
			file_names := fnames
			create slist.make
			from fnames.start until fnames.exhausted loop
				slist.extend (symbol_from_file_name (fnames.item))
				fnames.forth
			end
			file_names.start
			parent_make (slist, factory)
		ensure
			symbols_set_from_fnames:
				symbols /= Void and symbols.count = fnames.count
			file_names_set: file_names = fnames
		end

feature -- Access

	file_names: LIST [STRING]
			-- Names of all files with tradable data to be processed

feature {NONE} -- Implementation

	symbol_from_file_name (fname: STRING): STRING is
			-- Tradable symbol extracted from `fname' - directory component
			-- and suffix ('.' and all characters that follow it) of the
			-- file name are removed.  `fname' is not changed.
		do
			strutil.set_target (clone (fname))
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

	strutil: expanded STRING_UTILITIES

invariant

end -- class FILE_TRADABLE_LIST
