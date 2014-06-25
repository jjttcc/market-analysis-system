note
	description: "Configuration file abstraction"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CONFIGURATION_FILE inherit

	FILE_READER
		rename
			make as rf_make, tokens as records
		export
			{NONE} rf_make
			{ANY} records
		redefine
			tokenize, forth
		end

	MCT_CONFIGURATION_PROPERTIES
		export
			{NONE} all
		end

	EXECUTION_ENVIRONMENT
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

	make (line_field_sep: STRING; platfm: MCT_PLATFORM)
		require
			args_exist: line_field_sep /= Void and platfm /= Void
		do
			platform := platfm
			rf_make (Configuration_file_path)
			line_field_separator := line_field_sep
		ensure
			line_field_separator_set: line_field_separator = line_field_sep
			platform_set: platform = platfm
		end

feature -- Access

	platform: MCT_PLATFORM
			-- The platform on which the executable for this process
			-- is targeted

	Configuration_file_path: STRING
			-- The full path of the MCT configuration file
		require
			platform_exists: platform /= Void
		local
			config_path: STRING
			dir: DIRECTORY
			env: expanded OPERATING_ENVIRONMENT
		once
			config_path := get (Mct_dir_env_var)
			if config_path /= Void and then not config_path.is_empty then
				create dir.make (config_path)
				if dir.exists then
					Result := config_path + env.Directory_separator.out +
						Configuration_file_name
				end
			end
			if Result = Void then
				-- The `Mct_dir_env_var' env. variable is not set or is
				-- set to an invalid directory, so use the default path.
				Result := platform.Default_configuration_file_location +
					Configuration_file_name
			end
		end

	Configuration_file_name: STRING = "mctrc"
			-- The name of the MCT configuration file

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

	forth
		do
			Precursor
			post_process
		end

feature -- Element change

	mark_block_as_default (tag, value, begin_value: STRING)
			-- Mark the block containing `tag + line_field_separator + value'
			-- whose begin-value matches `begin_value' as a default block by
			-- inserting the string `Default_record' before the end of the
			-- block and deleting `Default_record' from any other block
			-- whose begin-value matches `begin_value'.
		require
			has_been_tokenized: contents /= Void
			args_exist: tag /= Void value /= Void begin_value /= Void
		local
			exc: expanded EXCEPTION_SERVICES
			exception_occurred: BOOLEAN
		do
			if not exception_occurred then
				mark_as_default_failed := False
				remove_default_marks (begin_value)
				-- Insert the "default mark" only if the specified
				-- block exists:
				if
					matching_indices (matching_block_boundaries (
					begin_value, records), records,
					tag + line_field_separator + value).count > 0
				then
					insert_default_mark (tag, value, begin_value)
				end
			else
				mark_as_default_failed := True
				exc.set_verbose_reporting_off
				mark_as_default_failure_reason := exc.error_information (
					Write_error, False)
			end
		rescue
			exception_occurred := True
			retry
		end

feature -- Basic operations

	tokenize (separator: STRING)
		do
			Precursor (separator)
			post_process
		end

feature {NONE} -- Implementation

	remove_default_marks (begin_value: STRING)
			-- Remove the "default marks" from all blocks whose begin-value
			-- matches `begin_value'.
		require
			arg_exists: begin_value /= Void
		local
			new_records: ARRAYED_LIST [STRING]
			-- begin-end indices of all targeted blocks:
			block_boundaries: LIST [INTEGER_INTERVAL]
			-- indices of all `Default-record' records to be removed
			default_indices: LIST [INTEGER]
		do
			create new_records.make (0)
			block_boundaries := matching_block_boundaries (begin_value,
				records)
			default_indices := matching_indices (block_boundaries, records,
				Default_record)
			from
				records.start
			invariant
				no_default_records: matching_indices (
					matching_block_boundaries (begin_value, new_records),
					new_records, Default_record).count = 0;
				records_count_minus_default_count:
					new_records.count <= records.count - default_indices.count
			variant
				records.count - records.index + 1
			until
				records.exhausted
			loop
				if not default_indices.has (records.index) then
					new_records.extend (records.item)
				end
				records.forth
			end
			check
				no_default_records: matching_indices (
					matching_block_boundaries (begin_value, new_records),
					new_records, Default_record).count = 0
				records_count_minus_default_count:
					new_records.count = records.count - default_indices.count
			end
			records := new_records
		ensure
			no_more_default_records: matching_indices (
				matching_block_boundaries (begin_value, records),
				records, Default_record).count = 0
		end

	insert_default_mark (tag, value, begin_value: STRING)
			-- Mark the first block, b, that satisfies: (b's begin-value
			-- matches `begin_value' and b contains `tag +
			-- line_field_separator + value') as the "default block".
		require
			args_exist: tag /= Void value /= Void begin_value /= Void
			at_least_one_target: matching_indices (
				matching_block_boundaries (begin_value, records),
				records, tag + line_field_separator + value).count > 0
		local
			-- begin-end indices of "candidate" blocks
			candidate_block_boundaries: LIST [INTEGER_INTERVAL]
			-- indices of all `Default-record' records to be removed
			target_indices: LIST [INTEGER]
			sought_value: STRING
		do
			candidate_block_boundaries := matching_block_boundaries (
				begin_value, records)
			sought_value := tag + line_field_separator + value
			target_indices := matching_indices (candidate_block_boundaries,
				records, sought_value)
			check
				at_least_one: target_indices.count > 0
			end
			records.go_i_th (target_indices @ 1)
			records.put_right (Default_record)
			target.open_write
			records.do_if (agent write_line, agent not_last)
			target.close
		ensure
			exactly_one_matching_default_block: matching_indices (
				matching_block_boundaries (begin_value, records),
				records, Default_record).count = 1
			first_default_block_equals_first_targeted_block:
			intervals_containing_target (matching_block_boundaries (begin_value,
				records), records, Default_record).i_th (1).is_equal (
			intervals_containing_target (matching_block_boundaries (begin_value,
				records), records, tag + line_field_separator + value).i_th (1))
		end

	post_process
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

feature {NONE} -- Implementation - utilities

	matching_block_boundaries (begin_value: STRING;
		target_list: LIST [STRING]): LIST [INTEGER_INTERVAL]
			-- Begin/end indices of all blocks in `target_list'
			-- whose "begin-value" matches `begin_value'
		require
			args_exist: begin_value /= Void and target_list /= Void
		local
			begin_rec: STRING
			starti: INTEGER
		do
			create {LINKED_LIST [INTEGER_INTERVAL]} Result.make
			begin_rec := begin_record (begin_value)
			from
				target_list.start
			until
				target_list.exhausted
			loop
				if equal (target_list.item, begin_rec) then
					-- Beginning of a target block
					from
						starti := target_list.index
					until
						target_list.exhausted or
						is_end_of_block (target_list.item)
					loop
						target_list.forth
					end
					if not target_list.exhausted then
						Result.extend (create {INTEGER_INTERVAL}.make (
							starti, target_list.index))
					else
						-- The end of `target_list' was reached and
						-- no end block was found - regard the last
						-- record as the end of the current block.
						Result.extend (create {INTEGER_INTERVAL}.make (
							starti, target_list.count))
					end
				end
				if not target_list.exhausted then
					target_list.forth
				end
			end
		ensure
			Result_exists: Result /= Void
		end

	matching_indices (intervals: LIST [INTEGER_INTERVAL];
		target_list: LIST [STRING]; tgt: STRING): LIST [INTEGER]
			-- For each block, b, in `target_list' whose
			-- begin-end indices are specified in `intervals':
			--   The indices, if any, of the records in b matching `tgt'
		require
			args_exist: intervals /= Void and target_list /= Void and
				tgt /= Void
			intervals_valid: intervals.for_all (agent within_range (?,
				target_list))
		do
			create {ARRAYED_LIST [INTEGER]} Result.make (0)
			from
				intervals.start
			until
				intervals.exhausted
			loop
				-- For each index, i, within the block designated by
				-- `intervals.item' for which `equal (target_list @ i, tgt)':
				-- add i to `Result'.
				from
					target_list.go_i_th (intervals.item.lower)
				until
					target_list.index = intervals.item.upper + 1
				loop
					if equal (target_list.item, tgt) then
						Result.extend (target_list.index)
					end
					target_list.forth
				end
				intervals.forth
			end
		ensure
			Result_exists: Result /= Void
		end

	intervals_containing_target (intervals: LIST [INTEGER_INTERVAL];
		target_list: LIST [STRING]; tgt: STRING): LIST [INTEGER_INTERVAL]
			-- All elements of `intervals' that represent a block in
			-- `target_list' that contains the record `tgt'
		require
			args_exist: intervals /= Void and target_list /= Void and
				tgt /= Void
		local
			match: BOOLEAN
		do
			create {LINKED_LIST [INTEGER_INTERVAL]} Result.make
			from
				intervals.start
			until
				intervals.exhausted
			loop
				match := False
				from
					target_list.go_i_th (intervals.item.lower)
				until
					match or target_list.index = intervals.item.upper + 1
				loop
					if equal (target_list.item, tgt) then
						Result.extend (intervals.item)
						match := True
					end
					target_list.forth
				end
				intervals.forth
			end
			Result.compare_objects
		ensure
			Result_exists: Result /= Void
			object_comparison: Result.object_comparison
		end

	line_field_separator: STRING
			-- Separator used to delimit fields in a line (record)

	write_line (s: STRING)
			-- Write `s' appended with '%N' to `target'.
		require
			s_exists: s /= Void
		do
			if
				is_end_of_block (s) and
				s.item (s.count) = line_field_separator @ 1
			then
				-- Don't output the extra `line_field_separator'.
				target.put_string (End_tag + "%N")
			else
				target.put_string (s + "%N")
			end
		end

	begin_record (begin_value: STRING): STRING
		require
			begin_value_exists: begin_value /= Void
		do
			Result := Begin_tag + line_field_separator + begin_value
		ensure
			definition: Result.is_equal (Begin_tag + line_field_separator +
				begin_value)
		end

feature {NONE} -- Implementation - status report utilities

	within_range (index_range: INTEGER_INTERVAL;
		target_list: LIST [STRING]): BOOLEAN
			-- Is the specified pair of indices within the valid index
			-- range of `target_list'?
		require
			args_exist: index_range /= Void and target_list /= Void
		do
			Result := index_range.lower <= index_range.upper and
				1 <= index_range.lower and
				target_list.count >= index_range.upper
		end

	not_last (s: STRING): BOOLEAN
		do
			Result := not records.islast
		ensure
			not_last: Result = not records.islast
		end

	is_beginning_of_block (s: STRING): BOOLEAN
			-- Is `s' the beginning of a "block"?
		do
			Result := s /= Void and then
				equal (s.substring (1, Begin_tag.count), Begin_tag)
		end

	is_end_of_block (s: STRING): BOOLEAN
			-- Is `s' the end of a "block"?
		do
			Result := s /= Void and then
				equal (s.substring (1, End_tag.count), End_tag)
		end

feature {NONE} -- Implementation - constants

	Write_error: STRING
		once
			Result := "Error writing to configuration file " +
				Configuration_file_path
		end

	Default_record: STRING
		once
			Result := Mark_specifier + line_field_separator + Default_mark
		ensure
			definition: Result.is_equal (Mark_specifier +
				line_field_separator + Default_mark)
		end

invariant

	end_of_block_vs_in_block: at_end_of_block implies not in_block
	in_block_vs_end_of_block: in_block implies not at_end_of_block
	in_block_constraint: (item /= Void and
		is_beginning_of_block (item)) implies in_block
	separator_exists: line_field_separator /= Void
	platform_exists: platform /= Void

end
