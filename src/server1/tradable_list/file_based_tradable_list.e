indexing
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FILE_BASED_TRADABLE_LIST inherit

	INPUT_MEDIUM_BASED_TRADABLE_LIST
		redefine
			start, forth, finish, back, remove_current_item, input_medium
		end

	TIMING_SERVICES
		export
			{NONE} all
		end

feature -- Access

	file_names: LIST [STRING] is
			-- Names of all files with tradable data to be processed
		deferred
		end

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

	remove_current_item is
		do
			file_names.prune (file_names.item)
			Precursor
			if not symbol_list.off then
				file_names.go_i_th (symbol_list.index)
			end
		end

	initialize_input_medium is
		local
			file: INPUT_FILE
		do
			create {OPTIMIZED_INPUT_FILE} file.make (file_names.item)
			input_medium := file
			if file.exists then
				file.open_read
			else
				log_errors (<<"Failed to open input file ",
					file_names.item, " - file does not exist.%N">>)
				fatal_error := True
			end
print (generating_type + ": init input med returning type: " +
input_medium.generating_type + "%N")
		end

	input_medium: INPUT_FILE

invariant

	file_names_correspond_to_symbols:
		file_names /= Void and symbols.count = file_names.count
	file_names_and_symbol_list: symbol_list.index = file_names.index

end
