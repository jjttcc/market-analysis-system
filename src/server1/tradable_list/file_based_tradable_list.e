indexing
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class FILE_BASED_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			setup_input_medium, close_input_medium, start, forth, finish,
			back, remove_current_item
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

	open_current_file: INPUT_FILE is
			-- Open the file associated with `file_names'.item.
			-- If the open fails with an exception, log the error,
			-- set Result to Void, and allow the exception to propogate.
		do
			start_timer
			create Result.make (file_names.item)
			if Result.exists then
				Result.open_read
			else
				log_errors (<<"Failed to open input file ",
					file_names.item, " - file does not exist.%N">>)
				fatal_error := True
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
			add_timing_data ("Opening, reading, and closing data for " +
				symbol_list.item)
			report_timing
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

end
