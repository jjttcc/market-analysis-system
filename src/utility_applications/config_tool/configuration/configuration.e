indexing
	description: "Configuration of environment/platform-dependent settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		rename
			make as cu_make
		export
			{NONE} all
		redefine
--			post_process_settings, use_customized_setting,
			use_customized_setting, do_customized_setting, field_separator
--			do_customized_setting, config_file, log_error
		end

	CONFIGURATION_PROPERTIES

create

	make

feature {NONE} -- Initialization

	make (config_file_path: STRING) is
		do
			create new_file_reader.make (config_file_path)
			cu_make
		end

	initialize is
		do
			create replacement_specifications.make (0)
			create settings.make (0)

--!!!!This is probably obsolete:
			settings.extend ("", Replacement_specifier)
		end

feature -- Access

	replacement_specifications: HASH_TABLE [STRING, STRING]

feature -- Status report

	fatal_error_status: BOOLEAN
			-- Did a fatal configuration error occur?

feature -- Status setting

feature -- Basic operations

feature {NONE} -- Implementation - Hook routine implementations

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	configuration_type: STRING is "Configuration Tool"

--	post_process_settings is
--		do
--		end

	check_results is
		do
		end

	use_customized_setting (key, value: STRING): BOOLEAN is
		do
			if
				equal (key, Replacement_specifier) or in_replace_block
			then
				Result := True
			end
		end

	do_customized_setting (key, value: STRING) is
		do
			if equal (key, Replacement_specifier) then
				if equal (value, Start_specifier) then
					in_replace_block := True
				elseif equal (value, End_specifier) then
					in_replace_block := False
				else
					log_error ("Appropriate error message goes here!!!")
				end
			elseif in_replace_block then
				replacement_specifications.force (value, key)
			end
		end

	new_file_reader: FILE_READER

feature {NONE} -- Implementation

	field_separator: STRING is ""

	in_replace_block: BOOLEAN

invariant

end
