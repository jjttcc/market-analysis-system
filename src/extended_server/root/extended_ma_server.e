note
    description: "Root class for the extended version of the %
        %Market Analysis Server"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_MA_SERVER inherit

	MA_SERVER
		rename
			make as mas_make
		redefine
			polling_timeout_milliseconds, factory_builder
		end

	ERROR_SUBSCRIBER

creation

	make

feature {NONE} -- Initialization

	make
		local
			platform: expanded PLATFORM_DEPENDENT_OBJECTS
			cl_dummy: MAS_COMMAND_LINE
		do
			-- Force the platform's command-line to be an "extended" one.
			cl_dummy := platform.command_line_cell (extended_command_line).item
			mas_make
		end

	compile_this
		local
			-- components that are not currently used.
			composite_tradable: COMPOSITE_TRADABLE
			basic_composite_tradable: BASIC_COMPOSITE_TRADABLE
		do
		end

feature {NONE} -- Hood routine implementations

	polling_timeout_milliseconds: INTEGER
		do
			Result := extended_command_line.polling_timeout_milliseconds
		end

feature {NONE} -- Implementation

	factory_builder: EXTENDED_GLOBAL_OBJECT_BUILDER
		once
			create Result.make
		end

feature {NONE} -- Implementation - Attributes

	extended_command_line: EXTENDED_MAS_COMMAND_LINE
		local
			platform: expanded EXTENDED_PLATFORM_DEPENDENT_OBJECTS
		do
			if extended_command_line_implementation = Void then
				extended_command_line_implementation := platform.command_line
			end
			Result := extended_command_line_implementation
		end

	extended_command_line_implementation: EXTENDED_MAS_COMMAND_LINE

end
