note
	description: "COMMANDs specialized for MCT"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MCT_COMMAND inherit

	COMMAND

feature -- Access

	identifier: STRING
			-- String that uniquely identifies the command

	description: STRING
			-- Description of the command

	contents: STRING
			-- Contents of the command to be executed
		deferred
		ensure
			exists: Result /= Void
		end

	debugging_on: BOOLEAN
			-- Is debugging turned on?

feature -- Status report

	set_debugging_on (arg: BOOLEAN)
			-- Set `debugging_on' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			debugging_on := arg
		ensure
			debugging_on_set: debugging_on = arg and debugging_on /= Void
		end

feature -- Element change

	set_description (arg: STRING)
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
