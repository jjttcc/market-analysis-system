note
	description: "Platform-dependent features for Windows systems"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
		%License to be determined"

class MCT_PLATFORM inherit

	CONFIGURATION_CONSTANTS
		export
			{NONE} all
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
			{ANY} Directory_separator
		end

feature -- Access

	Default_configuration_file_location: STRING = "C:\Program Files\mct\"
			-- Default location (complete path) of the MCT configuration
			-- file (with a directory separator on the end)

feature -- Basic operations

	convert_path (s: STRING)
			-- Apply file-path modifications to `s'.
		local
			regexp_tool: expanded REGULAR_EXPRESSION_UTILITIES
			scopy: STRING
		do
			scopy := regexp_tool.gsub ("([^" + Escape_character + "])" +
				Backslash + Slash, "\1" + Backslash + Backslash, s)
			scopy := regexp_tool.sub ("^" + Backslash + Slash,
				Backslash + Backslash, scopy)
			s.copy (scopy)
		end

invariant

	config_file_location_ends_with_dir_separator:
		Default_configuration_file_location.item (
		Default_configuration_file_location.count) = Directory_separator

end
