note
	description: "Constants needed globally for the installation"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class INSTALLATION_FACILITIES inherit

feature -- Access

	install_dir_name: STRING = "install"
			-- Directory where the installation specification files live

	mctrc_file_name: STRING = "mctrc"

	
	mct_directory: STRING = "c:/Program Files/mct"

	directory_separator: CHARACTER
			-- The directory separator used for this platform
		local
			op_env: expanded OPERATING_ENVIRONMENT
		once
			Result := op_env.directory_separator
		end

	command_variable_name: STRING = "COMSPEC"
			-- Name of the environment variable that specifies the
			-- Windows system's shell

	nt_command_name: STRING = "CMD"

feature -- Status report

	is_nt: BOOLEAN
			-- Is the system "NT or better" (as opposed to "pre-NT")?
		local
			ex_env: expanded EXECUTION_ENVIRONMENT
			s, command_name, nt_cmd: STRING
			last_dirsep: INTEGER
		do
			-- Use the "comspec" environment variable to determine whether
			-- this is an NT or pre-NT system.
			s := ex_env.get (command_variable_name)
			if s /= Void and then not s.is_empty then
				last_dirsep := s.last_index_of (directory_separator,
					s.count)
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
