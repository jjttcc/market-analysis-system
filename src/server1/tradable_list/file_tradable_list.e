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
		redefine
			target_tradable_out_of_date, append_new_data, turn_caching_off,
			add_to_cache, clear_cache
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
			create file_status_cache.make (cache_size)
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
				-- Position current_input_file's "cursor" at the first
				-- unread character (after the last character that was
				-- previously read).
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

end -- class FILE_TRADABLE_LIST
