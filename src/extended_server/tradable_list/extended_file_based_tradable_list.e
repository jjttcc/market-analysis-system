indexing
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class EXTENDED_FILE_BASED_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			setup_input_medium, close_input_medium, start, forth, finish,
			back, remove_current_item, target_tradable_out_of_date,
			append_new_data, turn_caching_off, add_to_cache, clear_cache
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
			current_input_file.start
			if not fatal_error then
				tradable_factory.set_input (current_input_file)
				current_input_file.set_field_separator (
					tradable_factory.field_separator)
				current_input_file.set_record_separator (
					tradable_factory.record_separator)
			end
		ensure then
			indices_at_1: current_input_file.readable implies
				(current_input_file.field_index = 1 and
				current_input_file.record_index = 1)
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

	file_status_cache: HASH_TABLE [TRADABLE_FILE_STATUS, INTEGER]
			-- File-status cache - mirrors `cache'

	turn_caching_off is
		do
			Precursor
			file_status_cache.clear_all
		end

	clear_cache is
		do
			Precursor
			file_status_cache.clear_all
		end

	add_to_cache (t: TRADABLE [BASIC_MARKET_TUPLE]; idx: INTEGER) is
		do
			Precursor (t, idx)
			if caching_on then
				check
					input_file_valid: current_input_file /= Void and
						not current_input_file.is_closed
				end
				file_status_cache.force (create {TRADABLE_FILE_STATUS}.make (
					clone (current_input_file.name), current_input_file.date,
					current_input_file.count), idx)
			end
		ensure then
			status_added_if_caching_on: caching_on implies equal (
				(file_status_cache @ idx).file_name, current_input_file.name)
				and (file_status_cache @ idx).last_modification_time =
				current_input_file.date and
				(file_status_cache @ idx).file_size = current_input_file.count
		end

	update_file_status_cache (idx: INTEGER) is
			-- If `caching_on', update the TRADABLE_FILE_STATUS at the
			-- specified index `idx'.
		require
			input_file_valid: current_input_file /= Void and
				not current_input_file.is_closed
			object_in_cache_if_caching_on: caching_on implies
				file_status_cache @ idx /= Void
			file_name_set: caching_on implies equal (
				(file_status_cache @ idx).file_name, current_input_file.name)
		local
			file_status: TRADABLE_FILE_STATUS
		do
			file_status := file_status_cache @ idx
			if caching_on then
				file_status.set_last_modification_time (current_input_file.date)
				file_status.set_file_size (current_input_file.count)
			end
		ensure then
			status_updated_if_caching_on: caching_on implies
				(file_status_cache @ idx).last_modification_time =
				current_input_file.date and
				(file_status_cache @ idx).file_size = current_input_file.count
			file_name_unchanged: caching_on implies equal (
				(file_status_cache @ idx).file_name, current_input_file.name)
		end

	status_work_file: FILE
			-- Work file used to obtain status information

feature {NONE} -- Hook routine implementations

	target_tradable_out_of_date: BOOLEAN is
		local
			current_file_status: TRADABLE_FILE_STATUS
		do
			current_file_status := file_status_cache @ index
			if current_file_status = Void then
				-- Assume the cache is empty and thus there is no data
				-- that can be out of date.
				Result := False
			else
				if status_work_file = Void then
					create {PLAIN_TEXT_FILE} status_work_file.make (
						current_file_status.file_name)
				else
					status_work_file.make (current_file_status.file_name)
				end
				-- Result := "current input file is newer and larger than
				--    last recorded":
				Result := status_work_file.date >
					current_file_status.last_modification_time and
					status_work_file.count > current_file_status.file_size
			end
		end

	append_new_data is
		local
			current_file_status: TRADABLE_FILE_STATUS
		do
			current_file_status := file_status_cache @ index
			setup_input_medium
			check
				current_input_file.readable
			end
			if not fatal_error then
				check
					current_file_was_updated:
						not current_input_file.is_closed and
						current_input_file.date >
						current_file_status.last_modification_time and
						current_input_file.count > current_file_status.file_size
				end
				-- Advance the file cursor to the beginning of the new
				-- data.  Note: file position numbering starts a 0.
				current_input_file.position_cursor (
					current_file_status.file_size)
				tradable_factory.set_product (target_tradable)
				tradable_factory.execute
				update_file_status_cache (index)
				if tradable_factory.error_occurred then
					report_errors (target_tradable.symbol,
						tradable_factory.error_list)
					if tradable_factory.last_error_fatal then
						fatal_error := True
					end
				end
				close_input_medium
			else
				-- A fatal error indicates that the current tradable
				-- is invalid, or not readable, or etc., so ensure
				-- that target_tradable is not set to this invalid
				-- object.
				target_tradable := Void
			end
		end

invariant

	caches_correspond: cache.count = file_status_cache.count
	file_names_correspond_to_symbols:
		file_names /= Void and symbols.count = file_names.count
	file_names_and_symbol_list: symbol_list.index = file_names.index

end
