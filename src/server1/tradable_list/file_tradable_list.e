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
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class FILE_TRADABLE_LIST inherit

	TRADABLE_LIST
		rename
			symbol_list as file_names
		redefine
			symbols, current_symbol, setup_input_medium, close_input_medium
		end

creation

	make

feature -- Access

	symbols: ARRAYED_LIST [STRING] is
			-- The symbol of each tradable, extracted from `file_names'
		local
			fnames: LINEAR [STRING]
		do
			fnames := file_names
			create Result.make (0)
			from fnames.start until fnames.exhausted loop
				Result.extend (symbol_from_file_name (fnames.item))
				fnames.forth
			end
			Result.compare_objects
		end

feature {NONE} -- Implementation

	search_by_file_name (name: STRING) is
		do
			from
				start
			until
				file_names.item.is_equal (name) or after
			loop
				forth
			end
		ensure then
			-- `file_names' contains `name' implies
			--	file_names.item.is_equal (name)
		end

	symbol_from_file_name (fname: STRING): STRING is
			-- Tradable symbol extracted from `fname' - directory component
			-- and suffix ('.' and all characters that follow it) of the
			-- file name are removed.  `fname' is not changed.
		local
			i, last_sep_index: INTEGER
			strutil: STRING_UTILITIES
		do
			create strutil.make (clone (fname))
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

	open_current_file: INPUT_FILE is
			-- Open the file associated with `file_names'.item.
			-- If the open fails with an exception, log the error,
			-- set Result to Void, and allow the exception to propogate.
		do
			create Result.make (file_names.item)
			if Result.exists then
				Result.open_read
			else
				log_errors (<<"Failed to open input file ",
					file_names.item, "%N">>)
				fatal_error := true
			end
		end

	setup_input_medium is
		do
			current_input_file := open_current_file
			if not fatal_error then
				tradable_factory.set_input (current_input_file)
				current_input_file.set_field_separator (
					tradable_factory.field_separator)
				current_input_file.set_record_separator (
					tradable_factory.record_separator)
			end
		end

	close_input_medium is
		do
			if not current_input_file.is_closed then
				current_input_file.close
			end
		end

	current_symbol: STRING is
		do
			Result := symbol_from_file_name (file_names.item)
		end

	current_input_file: INPUT_FILE

end -- class FILE_TRADABLE_LIST
