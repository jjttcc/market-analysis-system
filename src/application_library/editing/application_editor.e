note
	description:
		"Editor of objects to be used in a MAL application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class APPLICATION_EDITOR inherit

feature -- Access

	user_interface: EDITING_INTERFACE
			-- Interface used to obtain data selections from user

feature -- Status setting

	set_user_interface (arg: like user_interface)
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
