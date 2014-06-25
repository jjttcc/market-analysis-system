note
	description: "Builder of objects that are platform-dependent"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class PLATFORM_DEPENDENT_OBJECTS inherit

	GENERAL_UTILITIES
		export {NONE}
			all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

feature -- Access

	database_services: MAS_DB_SERVICES
		local
			gs: expanded GLOBAL_SERVICES
		do
			create {ECLI_SERVICES} Result.make (gs.debug_state.data_retrieval)
			if Result.fatal_error then
				if
					Result.last_error /= Void and not Result.last_error.is_empty
				then
					log_errors (<<"Fatal database error: ",
						Result.last_error, ".%N">>)
				else
					log_error ("Fatal database error.%N")
				end
			end
		end

	file_name_expander: FILE_NAME_EXPANDER
		do
			create {UNIX_FILE_NAME_EXPANDER} Result
		end

	file_lock (file_name: STRING): FILE_LOCK
		do
			create {BASIC_FILE_LOCK} Result.make (file_name)
		end

	stock_split_file (field_sep, record_sep, input_file: STRING):
			STOCK_SPLIT_FILE
		do
			create Result.make (field_sep, record_sep, input_file)
		end

	command_line: MAS_COMMAND_LINE
		do
			Result := command_line_cell (Void).item
		end

	command_line_cell (deflt: MAS_COMMAND_LINE): CELL [MAS_COMMAND_LINE]
		once
			if deflt /= Void then
				create Result.put (deflt)
			else
				create Result.put (create {MAS_COMMAND_LINE}.make)
			end
		end

end -- class PLATFORM_DEPENDENT_OBJECTS
