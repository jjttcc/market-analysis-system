indexing
	description:
		"Root class for the MAS Control Terminal, an application to control %
		%the MAS server, charting client, and other MAS components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class

    MCT

create
    make

feature {NONE} -- Initialization

    make is
        local
            application: EV_APPLICATION
            main_window: EV_TITLED_WINDOW
			builder: expanded APPLICATION_WINDOW_BUILDER
        do
            create application
            main_window := builder.main_window
            main_window.show
            application.launch
        end

end
