note
	description: "Platform-dependent features for UNIX systems"
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

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		end

feature -- Access

	Default_configuration_file_location: STRING
			-- Default location (complete path) of the MCT configuration
			-- file (with a directory separator on the end)
		once
			Result := get ("HOME")
			if Result /= Void then
				Result := Result + "/.mas/"
			else
				-- @@Handle unlikely error: $HOME is not set.
			end
		end

feature -- Basic operations

	convert_path (s: STRING)
			-- Apply file-path modifications to `s'.
		do
			-- No conversion is needed for UNIX systems.
		end

invariant

	config_file_location_ends_with_dir_separator:
		Default_configuration_file_location.item (
		Default_configuration_file_location.count) = Directory_separator

end
