indexing
	description: "Windows associated with a MAS session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class SESSION_WINDOW inherit

	EV_TITLED_WINDOW
		export
			{NONE} all
			{ANY} show, lock_update, unlock_update, extend, set_menu_bar,
			set_minimum_width, set_minimum_height, is_destroyed
		end

create

	default_create, make_with_title

feature -- Access

	host_name: STRING
			-- Host name used by the MAS server for this session

	port_number: STRING
			-- Port number used by the MAS server for this session

feature -- Element change

	set_host_name (arg: STRING) is
			-- Set `host_name' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			host_name := arg
		ensure
			host_name_set: host_name = arg and host_name /= Void
		end

	set_port_number (arg: STRING) is
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
