note
	description: "Copying of MCT file to its official location"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COPY_MCT_FILE_COMMAND inherit

	INSTALL_COMMAND

	INSTALLATION_FACILITIES
		export
			{NONE} all
		end

create

    make

feature {NONE} -- Initialization

	make
        do
        end

feature -- Access

	description: STRING = "Installing MCT configuration file"

feature -- Status report

	arg_mandatory: BOOLEAN = True

feature -- Basic operations

	execute (options: INSTALL_TOOL_COMMAND_LINE)
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
