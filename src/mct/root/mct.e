note
	description:
		"Root class for the MAS Control Terminal, an application to control %
		%the MAS server, charting client, and other MAS components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	make
        do
			setup_application
			if setup_succeeded then
				event_loop
			end
        end

	setup_application
        local
            main_window: EV_TITLED_WINDOW
		do
			default_create
            create builder
            main_window := builder.main_window
            main_window.show
			if builder.configuration.start_session_on_startup then
				builder.current_main_actions.start_server
			end
			setup_succeeded := True
			if command_line_options.is_debug then
				print ("Settings:%N" + builder.configuration.settings_report)
			end
		ensure
			setup_succeeded: setup_succeeded
			builder_exists: builder /= Void
		rescue
			exit_needed := True
			if is_developer_exception then
				log_error (developer_exception_name)
			else
				log_error (Setup_failed_msg)
			end
			launch
		end

	event_loop
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

	command_line_options: COMMAND_LINE
		do
			Result := builder.command_line
		end

	version: MAS_PRODUCT_INFO
		once
			create Result
		end

	setup_succeeded: BOOLEAN
			-- Did setup_application succeed?

feature {NONE} -- Implementation

	button_abort (i, j, k: INTEGER; x, y, z: DOUBLE; l, m: INTEGER)
		do
			exit (1)
		end

	key_abort (e: EV_KEY)
		do
			exit (1)
		end

	exit_needed: BOOLEAN

	log_error (msg: STRING)
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

	builder: APPLICATION_WINDOW_BUILDER

feature {NONE} -- Implementation - hook routine implementations

	application_name: STRING = "application"

feature {NONE} -- Implementation - constants

	Setup_failed_msg: STRING = "Initialization failed."

end
