note
	description:
		"An abstraction that provides a virtual list of tradables by %
		%holding a list that contains the input data file name of each %
		%tradable and loading the current tradable from its input file, %
		%giving the illusion that it is iterating over a list of tradables %
		%in memory.  The purpose of this scheme is to avoid using the %
		%large amount of memory that would be required to hold a large %
		%list of tradables in memory at once."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class FILE_TRADABLE_LIST inherit

	FILE_BASED_TRADABLE_LIST
		rename
			make as parent_make
		redefine
			retrieve_tradable_data
		end

creation

	make

feature -- Initialization

	make (fnames: LIST [STRING]; factory: TRADABLE_FACTORY)
			-- `symbols' will be created from `fnames'
		local
			slist: LINKED_LIST [STRING]
		do
			file_names := fnames
			create slist.make
			from fnames.start until fnames.exhausted loop
				slist.extend (symbol_from_file_name (fnames.item))
				fnames.forth
			end
			file_names.start
			parent_make (slist, factory)
		ensure
			symbols_set_from_fnames:
				symbols /= Void and symbols.count = fnames.count
			file_names_set: file_names = fnames
		end

feature -- Access

	file_names: LIST [STRING]
			-- Names of all files with tradable data to be processed

	external_data_service_active: BOOLEAN = True

feature {NONE} -- Implementation

    retrieve_tradable_data (symbol: STRING)
        local
            cmd: POSIX_EXEC_PROCESS
        do
            create cmd.make("/tmp/retrieve_tradable_data.rb", <<symbol>>)
            cmd.execute
            cmd.wait_for (True)
			if cmd.exit_code /= 0 then
				fatal_error := True
                log_errors(<<"Retrieval of data for " + symbol + " failed",
					" (exit code: " + cmd.exit_code.out + ")%N">>)
			end
        end

end -- class FILE_TRADABLE_LIST
