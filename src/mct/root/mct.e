indexing
	description:
		"Root class for the MAS Control Terminal, an application to control %
		%the MAS server, charting client, and other MAS components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MCT inherit

	EV_APPLICATION

	EXCEPTION_SERVICES
		export
			{NONE} all
		undefine
			default_create, copy
		end

create

    make

feature {NONE} -- Initialization

	make is
        local
            main_window: EV_TITLED_WINDOW
			builder: APPLICATION_WINDOW_BUILDER
        do
			default_create
            create builder
            main_window := builder.main_window
            main_window.show
			event_loop
        end

	event_loop is
		do
			launch
		rescue
print ("event loop retrying%N")
			-- Try to recover from exceptions due to bugs (e.g., void target
			-- call in multi-lists).
			retry
		end

	command_line_options: MCT_COMMAND_LINE is
		do
			create Result.make
		end

	version: MAS_PRODUCT_INFO is
		once
			create Result
		end

end
