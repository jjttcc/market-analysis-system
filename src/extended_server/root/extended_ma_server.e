indexing
	description: "Root class for the extended version of the %
		%Market Analysis Server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTENDED_MA_SERVER inherit

	MA_SERVER
		rename
			make as mas_make
		redefine
		end

	ERROR_SUBSCRIBER

creation

	make

feature {NONE} -- Initialization

	make is
		local
			platform: expanded PLATFORM_DEPENDENT_OBJECTS
			cl_dummy: MAS_COMMAND_LINE
		do
			-- Force the platform's command-line to be an "extended" one.
			cl_dummy := platform.command_line_cell (extended_command_line).item
			mas_make
		end

	compile_this is
		local
			-- "proprietary" components that are not currently used.
			composite_tradable: COMPOSITE_TRADABLE
			basic_composite_tradable: BASIC_COMPOSITE_TRADABLE
		do
		end

feature {NONE} -- Implementation - Hook routines

feature {NONE} -- Implementation - Attributes

	extended_command_line: EXTENDED_MAS_COMMAND_LINE is
		local
			platform: expanded EXTENDED_PLATFORM_DEPENDENT_OBJECTS
		do
			Result := platform.command_line
		end

end
