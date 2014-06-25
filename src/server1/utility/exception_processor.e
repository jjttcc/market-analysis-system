note
	description: "Application-based processing of caught exceptions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXCEPTION_PROCESSOR inherit

	EXCEPTION_SERVICES
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		undefine
			print
		end

	MAS_COMMAND_LINE_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make
		do
		end

feature -- Basic operations

	abort_command_line_processing: BOOLEAN
			-- Should command-line processing be aborted?
		do
			Result := fatal_command_line_tag_names.has (tag_name)
		end

feature {NONE} -- Implementation

	fatal_command_line_tag_names: LINEAR [STRING]
			-- Tag names that are fatal for command-line processing
		note
			once_status: global
		local
			names: ARRAY [STRING]
		once
			names := <<"Broken pipe", Line_limit_reached,
				"Connection reset by peer">>
			Result := names.linear_representation
			Result.compare_objects
		ensure
			object_comparison: Result.object_comparison
		end

end
