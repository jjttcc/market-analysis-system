indexing
	description: "Configuration file abstraction"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONFIGURATION_FILE inherit

	FILE_READER
		rename
			make as rf_make
		export
			{NONE} rf_make
		redefine
			tokenize, forth
		end

	MCT_CONFIGURATION_PROPERTIES
		export
			{NONE} all
		end

	EXCEPTION_SERVICES
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make (line_field_sep, line_sep: STRING) is
		require
			args_exist: line_field_sep /= Void and line_sep /= Void
		do
			rf_make (configuration_file_name)
			line_field_separator := line_field_sep
			line_field_separator := line_field_sep
			line_separator := line_sep
		end

feature -- Status report

	in_block: BOOLEAN
			-- Is the current item inside of a begin-end "block"?

	at_end_of_block: BOOLEAN
			-- Is the current item at the end of a "block"?

	current_block_is_start_server_cmd: BOOLEAN
			-- If `in_block' or `at_end_of_block', is the block
			-- specification that of a "start-server-command"?

	mark_as_default_failed: BOOLEAN
			-- Did the last call to `mark_block_as_default' fail?

	mark_as_default_failure_reason: STRING
			-- Reason the last call to `mark_block_as_default' failed.

feature -- Cursor movement

	forth is
		do
			Precursor
			post_process
		end

feature -- Element change

	mark_block_as_default (tag, value, begin_value: STRING) is
			-- Mark the block containing `tag + line_field_separator + value'
			-- whose begin-value matches `begin_value' as a default block by
			-- inserting the string
			-- `Mark_specifier + line_field_separator + Default_mark' before
			-- the end of the block and deleting this string from any
			-- other block whose begin-value matches `begin_value.
		local
			begin_item, sought_value, default_record: STRING
			in_old_default_block, block_found, removed: BOOLEAN
			exception_occurred: BOOLEAN
			exc: expanded EXCEPTION_SERVICES
		do
			if not exception_occurred then
				mark_as_default_failed := False
				sought_value := tag + line_field_separator + value
				begin_item := Begin_tag + line_field_separator + begin_value
				default_record := Mark_specifier + line_field_separator +
					Default_mark
				from
					exhausted := False
					tokens.start
				until
					exhausted
				loop
					removed := False
					-- If this is the beginning of the block from which the
					-- default mark is to be removed,
					if equal (item, begin_item) then
						-- mark the block.
						in_old_default_block := True
					elseif in_block then
						-- If this is the new default block,
						if equal (item, sought_value) then
							-- insert the default mark, move the tokens
							-- cursor to skip over the inserted item,
							-- and note as found.
							tokens.put_right (default_record)
							tokens.forth
							block_found := True
						elseif
							in_old_default_block and
							equal (item, default_record)
						then
							-- Remove the old default mark.
							tokens.remove
							item := tokens.item
							removed := True
						elseif at_end_of_block then
							in_old_default_block := False
						end
					end
					if not removed then
						forth
					end
				end
				if block_found then
					target.open_write
					tokens.do_all (agent write_line)
					target.close
				end
			else
				mark_as_default_failed := True
				exc.set_verbose_off
				mark_as_default_failure_reason := exc.error_information (
					Write_error, False)
			end
		rescue
			exception_occurred := True
			retry
		end

feature -- Basic operations

	tokenize (separator: STRING) is
		do
			Precursor (separator)
			post_process
		end

feature {NONE} -- Implementation

	post_process is
			-- Do application-specific processing
		do
			at_end_of_block := False
			if in_block then
				if is_end_of_block (item) then
					at_end_of_block := True
					in_block := False
					if equal (item, End_tag) then
						-- The configuration logic expects all records (items)
						-- to have at least two fields, so force lines that
						-- match "^{End_tag}$" to contain two fields by
						-- appending the field separator.
						item.append (line_field_separator)
					end
				end
			elseif
				is_beginning_of_block (item)
			then
				in_block := True
				if
					equal (item.substring (
					item.count - Start_server_cmd_specifier.count + 1,
					item.count), Start_server_cmd_specifier)
				then
					current_block_is_start_server_cmd := True
				else
					current_block_is_start_server_cmd := False
				end
			end
		ensure
			end_definition: (old in_block and is_end_of_block (item)) =
				at_end_of_block
		end

	write_line (s: STRING) is
			-- Write `s' appended with '%N' to `target'.
		do
			if not tokens.islast then
				if is_end_of_block (s) then
					-- Don't output the extra `line_field_separator'.
					target.put_string (End_tag + "%N")
				else
					target.put_string (s + "%N")
				end
			end
		end

	is_beginning_of_block (s: STRING): BOOLEAN is
			-- Is `s' the beginning of a "block"?
		do
			Result := s /= Void and then
				equal (s.substring (1, Begin_tag.count), Begin_tag)
		end

	is_end_of_block (s: STRING): BOOLEAN is
			-- Is `s' the end of a "block"?
		do
			Result := s /= Void and then
				equal (s.substring (1, End_tag.count), End_tag)
		end

feature {NONE} -- Implementation - attributes

	line_field_separator: STRING

	line_separator: STRING

feature {NONE} -- Implementation - constants

	configuration_file_name: STRING is "mctrc"

	Write_error: STRING is
		once
			Result := "Error writing to configuration file " +
				configuration_file_name
		end

invariant

	end_of_block_vs_in_block: at_end_of_block implies not in_block
	in_block_vs_end_of_block: in_block implies not at_end_of_block
	in_block_constraint: (item /= Void and
		is_beginning_of_block (item)) implies in_block
	separators_exist: line_field_separator /= Void and line_separator /= Void

end
