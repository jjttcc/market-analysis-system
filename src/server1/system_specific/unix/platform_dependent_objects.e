indexing
	description: "Builder of objects that are platform-dependent"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class PLATFORM_DEPENDENT_OBJECTS inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	database_services: MAS_DB_SERVICES is
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

	file_name_expander: FILE_NAME_EXPANDER is
		do
			create {UNIX_FILE_NAME_EXPANDER} Result
		end

	file_lock (file_name: STRING): FILE_LOCK is
		do
			create {BASIC_FILE_LOCK} Result.make (file_name)
		end

	stock_split_file (field_sep, record_sep, input_file: STRING):
			STOCK_SPLIT_FILE is
		do
			create Result.make (field_sep, record_sep, input_file)
		end

	command_line: MAS_COMMAND_LINE is
		do
			Result := command_line_cell (Void).item
		end

	command_line_cell (deflt: MAS_COMMAND_LINE): CELL [MAS_COMMAND_LINE] is
		once
			if deflt /= Void then
				create Result.put (deflt)
			else
				create Result.put (create {MAS_COMMAND_LINE}.make)
			end
		end

end -- class PLATFORM_DEPENDENT_OBJECTS
