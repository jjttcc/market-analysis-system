indexing
	description: "Commands with a settable 'is_editable' feature"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class CONFIGURABLE_EDITABLE_COMMAND

feature -- Status report

	is_editable: BOOLEAN
			-- Is Current editable?

feature -- Status setting

	set_is_editable (arg: BOOLEAN) is
			-- Set `is_editable' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			is_editable := arg
		ensure
			is_editable_set: is_editable = arg and is_editable /= Void
		end

end
