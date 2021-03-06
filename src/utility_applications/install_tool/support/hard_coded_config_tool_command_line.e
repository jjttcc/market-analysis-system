note
	description: "Parser of command-line arguments for the Configuration Tool"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class HARD_CODED_CONFIG_TOOL_COMMAND_LINE inherit

	CONFIG_TOOL_COMMAND_LINE
		rename
			make as ctcl_make_unused
		export
			{NONE} ctcl_make_unused
		redefine
			main_setup_procedures
		end

creation

	make

feature {NONE} -- Initialization

	make (cmd_file_path, tgt_file_path: STRING)
		require
			args_exist: cmd_file_path /= Void and tgt_file_path /= Void
		do
			command_file_path := cmd_file_path
			target_file_path := tgt_file_path
		ensure
			set: command_file_path = cmd_file_path and
				target_file_path = tgt_file_path
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]]
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
		end

invariant

end
