indexing
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONFIGURE_MCT_COMMAND inherit

	INSTALL_COMMAND

create

    make

feature {NONE} -- Initialization

	make is
        do
        end

feature -- Access

	description: STRING is "Configuring"

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (options: INSTALL_TOOL_COMMAND_LINE) is
		local
		do
		end

feature {NONE} -- Implementation

	nt_spec_file_name: STRING is "nt_repl_spec"

	pre_nt_spec_file_name: STRING is "pre_nt_repl_spec"

	command_variable_name: STRING is "COMSPEC"

	nt_command_name: STRING is "CMD"

	is_pre_nt: BOOLEAN is
			-- Is the system a "pre-NT" system?
		local
			ex_env: expanded EXECUTION_ENVIRONMENT
			op_env: expanded OPERATING_ENVIRONMENT
			s, command_name, nt_cmd: STRING
			last_dirsep: INTEGER
		do
			s := ex_env.get (command_variable_name)
			if s /= Void and then not s.is_empty then
				last_dirsep := s.last_index_of (op_env.directory_separator, 1)
				command_name := s.substring (last_dirsep + 1, s.count)
				if not command_name.is_empty then
					nt_cmd := clone (nt_command_name)
					Result := s.substring_index (nt_cmd, 1) > 0
					if not Result then
						nt_cmd.to_lower
						Result := s.substring_index (nt_cmd, 1) > 0
					end
				end
			end
		end

end
