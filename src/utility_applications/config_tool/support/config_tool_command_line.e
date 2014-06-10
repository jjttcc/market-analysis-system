note
	description: "Parser of command-line arguments for the Configuration Tool"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class CONFIG_TOOL_COMMAND_LINE inherit

	COMMAND_LINE

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	prepare_for_argument_processing
		do
		end

	finish_argument_processing
		do
			initialization_complete := True
		end

feature -- Access

	usage: STRING
			-- Message: how to invoke the program from the command-line
		do
			Result := "Usage: " + command_name + " [options]" +
				"%NOptions:%N" +
				"   -cmdfile <file>   Obtain instructions from <file> %N" +
				"   -file <target>    Operate on the file with path %
					%<target>%N" +
				"   -h                Print this help message%N"
		end

feature -- Access -- settings

	command_file_path: STRING
			-- Path of the file from which instructions (commands) will be read

	target_file_path: STRING
			-- Path of the file to be modified

feature {NONE} -- Implementation

	set_command_file_path
			-- Set `command_file_path' and remove its settings from `contents'.
		do
			if option_in_contents ('c') then
				if contents.item.count > 2 then
					create command_file_path.make (contents.item.count - 2)
					command_file_path.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
					last_argument_found := True
				else
					contents.remove
					last_argument_found := True
					if not contents.exhausted then
						create command_file_path.make (contents.item.count)
						command_file_path.append (contents.item)
						contents.remove
					else
						error_occurred := True
						log_errors (<<Command_file_error>>)
					end
				end
			end
		end

	set_target_file_path
			-- Set `target_file_path' and remove its settings from `contents'.
		do
			if option_in_contents ('f') then
				if contents.item.count > 2 then
					create target_file_path.make (contents.item.count - 2)
					target_file_path.append (contents.item.substring (
						3, contents.item.count))
					contents.remove
					last_argument_found := True
				else
					contents.remove
					last_argument_found := True
					if not contents.exhausted then
						create target_file_path.make (contents.item.count)
						target_file_path.append (contents.item)
						contents.remove
					else
						error_occurred := True
						log_errors (<<Target_file_error>>)
					end
				end
			end
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]]
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_command_file_path)
			Result.extend (agent set_target_file_path)
		end

	initialization_complete: BOOLEAN

feature {NONE} -- Implementation - Constants

	Command_file_error: STRING
		"File path for -cmdfile option was not specified.%N"

	Target_file_error: STRING
		"File path for -file option was not specified.%N"

invariant

end
