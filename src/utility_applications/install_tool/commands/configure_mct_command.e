indexing
	description: "Configuration of MCT settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class CONFIGURE_MCT_COMMAND inherit

	INSTALL_COMMAND

	INSTALLATION_FACILITIES
		export
			{NONE} all
		end

create

    make

feature {NONE} -- Initialization

	make is
        do
			create config_command_line.make (spec_file_name, mctrc_file_name)
        end

feature -- Access

	description: STRING is "Configuring"

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (options: INSTALL_TOOL_COMMAND_LINE) is
		local
			file_processor: FILE_PROCESSOR
		do
			spec_file.put_string (spec_file_intro (options))
			spec_file.put_string (spec_body)
			spec_file.put_string (spec_file_conclusion)
			spec_file.close
			create file_processor.make
			file_processor.execute (config_command_line)
			options.set_mctrc_contents (file_processor.target_file_contents)
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
--print ("Spec body: '" + Result + "'%N")
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
				create Result.make_open_read (install_dir_name +
					directory_separator.out + nt_spec_file_name)
			else
				create Result.make_open_read (install_dir_name +
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
			Result := Result + appdir_spec
		end

	spec_file_conclusion: STRING is
			-- End of the MCT specification file
		once
			Result := "replaceend%N"
		end

	spec_file_name: STRING is "repl_spec"

	nt_spec_file_name: STRING is "nt_repl_spec"

	pre_nt_spec_file_name: STRING is "pre_nt_repl_spec"

	config_command_line: HARD_CODED_CONFIG_TOOL_COMMAND_LINE

end
