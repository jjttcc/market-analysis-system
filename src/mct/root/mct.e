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
		redefine
			application_name, log_error
		end

create

    make

feature {NONE} -- Initialization

--@@@Note: Consider adding a CL option to the server (perhaps not documented)
--such as:
--
--mas -p -b 1234 --report_back 9999
--
--To tell it to, as a client, report back to the MCT on port 9999 that is has
--started succesfully.  The MCT would respond as a server in this case.
	make is
        do
			setup_application
			if setup_succeeded then
				event_loop
			end
        end

	setup_application is
        local
            main_window: EV_TITLED_WINDOW
			builder: APPLICATION_WINDOW_BUILDER
		do
			default_create
            create builder
            main_window := builder.main_window
            main_window.show
			setup_succeeded := True
			if command_line_options.is_debug then
				print ("Settings:%N" + builder.configuration.settings_report)
			end
		ensure
			setup_succeeded: setup_succeeded
		rescue
			exit_needed := True
			if is_developer_exception then
				log_error (developer_exception_name)
			else
				log_error (Setup_failed_msg)
			end
			launch
		end

	event_loop is
		do
			launch
		rescue
			debug
				print ("event loop retrying%N")
			end
			if assertion_violation then
				exit_needed := True
				log_error (error_information (Assert_string, true))
			end
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

	setup_succeeded: BOOLEAN
			-- Did setup_application succeed?

feature {NONE} -- Implementation

	button_abort (i, j, k: INTEGER; x, y, z: DOUBLE; l, m: INTEGER) is
		do
			exit (1)
		end

	key_abort (e: EV_KEY) is
		do
			exit (1)
		end

	exit_needed: BOOLEAN

	log_error (msg: STRING) is
		local
			wbldr: expanded WIDGET_BUILDER
			dialog: EV_MESSAGE_DIALOG
		do
			dialog := wbldr.new_error_dialog (msg, Void)
			dialog.show
			if exit_needed then
				dialog.key_press_actions.extend (agent key_abort)
				dialog.default_push_button.pointer_button_press_actions.extend (
					agent button_abort)
			end
		end

feature {NONE} -- Implementation - hook routine implementations

	application_name: STRING is "application"

feature {NONE} -- Implementation - constants

	Setup_failed_msg: STRING is "Initialization failed."

end
