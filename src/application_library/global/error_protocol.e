indexing
	description: "Protocol for reportable errors"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	ERROR_PROTOCOL

feature -- Access

	Generic_error_code: INTEGER is 1

	Database_error_code: INTEGER is 2

	Internal_system_error_code: INTEGER is 3

	Initialization_error_code: INTEGER is 4

	Database_error: STRING is
		do
			Result := errors @ Database_error_code
		end

	Generic_error: STRING is
		do
			Result := errors @ Generic_error_code
		end

	Internal_system_error: STRING is
		do
			Result := errors @ Internal_system_error_code
		end

	Initialization_error: STRING is
		do
			Result := errors @ Initialization_error_code
		end

	largest_error_code: INTEGER is
		local
			keys: ARRAY [INTEGER]
			i: INTEGER
		once
			Result := -1
			keys := errors.current_keys
			from i := 1 until i = keys.count + 1 loop
				if keys @ i > Result then Result := keys @ i end
				i := i + 1
			end
		end

feature -- Access

	errors: HASH_TABLE [STRING, INTEGER] is
			-- All error descriptions
		once
			create Result.make (0)
			Result.extend ("Database error", Database_error_code)
			Result.extend ("Undetermined error", Generic_error_code)
			Result.extend ("Internal system error", Internal_system_error_code)
			Result.extend ("System initialization error",
				Initialization_error_code)
		end

end -- class ERROR_PROTOCOL
