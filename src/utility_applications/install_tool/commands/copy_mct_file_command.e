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
--print ("Trying to create the mctrc file in " + mct_dir.name + "%N")
			if not mct_dir.exists then
				mct_dir.create_dir
--print ("Created " + mct_dir.name + "%N")
			end
			create mct_file.make_open_write (mct_dir.name +
				directory_separator.out + mctrc_file_name)
--print ("Opened " + mct_file.name + "%N")
			mct_file.put_string (options.mctrc_contents)
--print ("Wrote contents to " + mct_file.name + "%N")
			mct_file.close
--print ("Closed " + mct_file.name + "%N")
		end

end
