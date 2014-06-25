note
	description: "Configuration of environment/platform-dependent settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		rename
			make as cu_make
		export
			{NONE} all
		redefine
			use_customized_setting, do_customized_setting, field_separator
		end

	CONFIGURATION_PROPERTIES
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make (config_file_path: STRING)
		do
			create new_file_reader.make (config_file_path)
			cu_make
		end

	initialize
		do
			create replacement_specifications.make (0)
			create settings.make (0)
		end

feature -- Access

	replacement_specifications: HASH_TABLE [STRING, STRING]

	additional_settings_report: STRING
			-- Additional settings, if any, formatted as a string
		do
			Result := ""
		end

feature -- Status report

	fatal_error_status: BOOLEAN
			-- Did a fatal configuration error occur?

feature -- Basic operations

feature {NONE} -- Implementation - Hook routine implementations

	key_index: INTEGER = 1

	value_index: INTEGER = 2

	configuration_type: STRING = "Configuration Tool"

	check_results
		do
		end

	use_customized_setting (key, value: STRING): BOOLEAN
		do
			if
				equal (key, Replacement_specifier) or in_replace_block
			then
				Result := True
			end
		end

	do_customized_setting (key, value: STRING)
		do
			if equal (key, Replacement_specifier) then
				if equal (value, Start_specifier) then
					in_replace_block := True
				elseif equal (value, End_specifier) then
					in_replace_block := False
				else
					log_error ("Invalid token for " + key + ": " + value +
						"%N(on line " + current_line.out + ")%N")
				end
			elseif in_replace_block then
				replacement_specifications.force (value, key)
			end
		end

	new_file_reader: FILE_READER

feature {NONE} -- Implementation

	field_separator: STRING = ""

	in_replace_block: BOOLEAN

invariant

end
