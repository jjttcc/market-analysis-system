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
		do
			spec_file.put_string (spec_file_intro (options))
			spec_file.put_string (spec_body)
			spec_file.put_string (spec_file_conclusion)
			spec_file.close
		end

feature {NONE} -- Implementation

	spec_body: STRING is
		once
			if not spec_guts_file.is_empty then
				spec_guts_file.read_stream (spec_guts_file.count)
				Result := spec_guts_file.last_string
			else
				Result := ""
			end
print ("Spec body: '" + Result + "'%N")
		end

	spec_file: PLAIN_TEXT_FILE is
			-- The specification file to be created
		once
			create Result.make_open_write (spec_file_name)
		end

	spec_guts_file: PLAIN_TEXT_FILE is
			-- The file from which to obtain the 'guts' of the
			-- specification file
		once
			if is_nt then
				create Result.make_open_read (install_dir +
					directory_separator.out + nt_spec_file_name)
			else
				create Result.make_open_read (install_dir +
					directory_separator.out + pre_nt_spec_file_name)
			end
		end

	spec_file_intro (options: INSTALL_TOOL_COMMAND_LINE): STRING is
			-- Beginning of the MCT specification file
		local
			appdir_spec: STRING
		once
			Result := "replacestart%N"
			appdir_spec := "{main_mas_dir}" + options.application_dir + "%N"
			appdir_spec.replace_substring_all (directory_separator.out, "/")
		end

	spec_file_conclusion: STRING is
			-- End of the MCT specification file
		once
			Result := "replaceend%N"
		end

	install_dir: STRING is "install"

	spec_file_name: STRING is "repl_spec"

	nt_spec_file_name: STRING is "nt_repl_spec"

	pre_nt_spec_file_name: STRING is "pre_nt_repl_spec"

	command_variable_name: STRING is "COMSPEC"

	nt_command_name: STRING is "CMD"

	directory_separator: CHARACTER is
		local
			op_env: expanded OPERATING_ENVIRONMENT
		once
			Result := op_env.directory_separator
		end

	is_nt: BOOLEAN is
			-- Is the system "NT or better" (as opposed to "pre-NT")?
		local
			ex_env: expanded EXECUTION_ENVIRONMENT
			s, command_name, nt_cmd: STRING
			last_dirsep: INTEGER
		do
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
