indexing
	description: "Copying of MCT file to its official location"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class COPY_MCT_FILE_COMMAND inherit

	INSTALL_COMMAND

	INSTALLATION_CONSTANTS
		export
			{NONE} all
		end

create

    make

feature {NONE} -- Initialization

	make is
        do
        end

feature -- Access

	description: STRING is "Installing MCT configuration file"

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature -- Basic operations

	execute (options: INSTALL_TOOL_COMMAND_LINE) is
		local
			mct_dir: DIRECTORY
			mct_file: PLAIN_TEXT_FILE
		do
			create mct_dir.make (mct_directory)
			if not mct_dir.exists then
				mct_dir.create_dir
				create mct_file.make_open_write (mct_directory +
					directory_separator.out + mctrc_file_name)
				mct_file.put_string (options.mctrc_contents)
				mct_file.close
			end
		end

end
