note
	description: "Windows associated with a MAS session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SESSION_WINDOW inherit

	EV_TITLED_WINDOW
		export
			{NONE} all
			{ANY} show, lock_update, unlock_update, extend, set_menu_bar,
			set_minimum_width, set_minimum_height, is_destroyed, title
		end

create

	default_create, make_with_title

feature -- Access

	host_name: STRING
			-- Host name used by the MAS server for this session

	port_number: STRING
			-- Port number used by the MAS server for this session

feature -- Element change

	set_host_name (arg: STRING)
			-- Set `host_name' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			host_name := arg
		ensure
			host_name_set: host_name = arg and host_name /= Void
		end

	set_port_number (arg: STRING)
			-- Set `port_number' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			port_number := arg
			set_title (title + " (" + port_number.out + ")")
		ensure
			port_number_set: port_number = arg and port_number /= Void
		end

end
