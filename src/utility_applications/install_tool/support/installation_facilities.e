indexing
	description: "Constants needed globally for the installation"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

class INSTALLATION_CONSTANTS inherit

feature -- Access

	install_dir_name: STRING is "install"
			-- Directory where the installation specification files live

	mctrc_file_name: STRING is "mctrc"

	
	mct_directory: STRING is "c:/Program Files/mct"

--!!!!Remove:
	Test_mct_directory: STRING is "Program_Files_mct"

	directory_separator: CHARACTER is
		local
			op_env: expanded OPERATING_ENVIRONMENT
		once
			Result := op_env.directory_separator
		end

end
