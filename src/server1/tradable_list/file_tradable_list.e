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
		%Released under the Eiffel Forum License; see file forum.txt"

class FILE_TRADABLE_LIST inherit

	TRADABLE_LIST
		rename
			make as parent_make
		redefine
			setup_input_medium, close_input_medium, start, forth, finish,
			back, remove_current_item
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

feature -- Cursor movement

	start is
		do
			file_names.start
			Precursor
		end

	finish is
		do
			file_names.finish
			Precursor
		end

	forth is
		do
			file_names.forth
			Precursor
		end

	back is
		do
			file_names.back
			Precursor
		end

feature {NONE} -- Implementation

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

	remove_current_item is
		do
			file_names.prune (file_names.item)
			Precursor
			if not symbol_list.off then
				file_names.go_i_th (symbol_list.index)
			end
		end


	current_input_file: INPUT_FILE

invariant

	file_names_correspond_to_symbols:
		file_names /= Void and symbols.count = file_names.count
	file_names_and_symbol_list: symbol_list.index = file_names.index

end -- class FILE_TRADABLE_LIST
