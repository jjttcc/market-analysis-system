indexing
	description:
		"Editor of objects to be used in a MAL application"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class APPLICATION_EDITOR inherit

feature -- Access

	user_interface: EDITING_INTERFACE
			-- Interface used to obtain data selections from user

feature -- Status setting

	set_user_interface (arg: like user_interface) is
			-- Set user_interface to `arg'.
		require
			arg_not_void: arg /= Void
		do
			user_interface := arg
		ensure
			user_interface_set: user_interface = arg and
				user_interface /= Void
		end

end -- APPLICATION_EDITOR
