indexing
	description: "COMMANDs specialized for MCT"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

deferred class MCT_COMMAND inherit

	COMMAND

feature -- Access

	identifier: STRING
			-- String that uniquely identifies the command

	description: STRING
			-- Description of the command

	contents: STRING is
			-- Contents of the command to be executed
		deferred
		ensure
			exists: Result /= Void
		end

feature -- Status report

	arg_mandatory: BOOLEAN is
		once
			Result := False
		end

feature -- Element change

	set_description (arg: STRING) is
			-- Set `description' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			description := arg
		ensure
			description_set: description = arg and description /= Void
		end

invariant

	identifier_not_empty: identifier /= Void and not identifier.is_empty

end
