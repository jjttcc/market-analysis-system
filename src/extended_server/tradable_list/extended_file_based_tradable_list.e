indexing
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class EXTENDED_FILE_BASED_TRADABLE_LIST inherit

	FILE_BASED_TRADABLE_LIST
		redefine
			target_tradable_out_of_date, append_new_data, turn_caching_off,
			add_to_cache, clear_cache
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

feature {NONE} -- Implementation

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
			if caching_on then
				file_status := file_status_cache @ idx
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
				tradable_factory.turn_start_input_from_beginning_off
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
				tradable_factory.turn_start_input_from_beginning_on
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

end
