indexing
	description: "Actions for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class ACTIONS

feature -- Access

	owner_window: EV_WINDOW
			-- Window that owns Current

feature -- Element change

	set_owner_window (arg: EV_WINDOW) is
			-- Set `owner_window' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			owner_window := arg
		ensure
			owner_window_set: owner_window = arg and owner_window /= Void
		end

feature -- Actions

	close_window is
		do
			(create {EV_ENVIRONMENT}).application.destroy
		end

	show_about_box is
			-- Display an "about" box.
		local
			about_dialog: EV_INFORMATION_DIALOG
		do
			create about_dialog.make_with_text (
				-- !!!Use the KDE apps' "about" box as a model to make
				-- this look more polished.
				"MAS Control Terminal%N%N(c) 2003%NAuthor: Jim Cochrane")
			about_dialog.set_title ("About MCT")
			about_dialog.show_modal_to_window (owner_window)
		end

	start_charting_app is
			-- Start the MAS Charting application - Start the MAS server
			-- first if it is not currently running.
		do
			if not server_is_running then
				start_server
			end
			print ("Start MAS charting app. Stub!!!%N")
		end

	connect_to_session is
			-- Connect to an existing MAS "session".
		do
			print ("Connect to MAS session Stub!!!%N")
		end

	terminate_session is
			-- Terminate an existing MAS "session".
		do
			print ("Terminate a MAS session Stub!!!%N")
		end

	start_server is
			-- Start the MAS server.
		do
			print ("Start MAS server Stub!!!%N")
			server_is_running := True
		end

	start_command_line is
			-- Start the MAS command-line client.
		do
			print ("Start MAS command-line Stub!!!%N")
		end

	configure_server_startup is
			-- Configure how the server is to be started up.
		do
			print ("Configure server startup Stub!!!%N")
		end

feature {NONE} -- Implementation - Status report

	server_is_running: BOOLEAN
			-- Is the MAS server currently running?

feature {NONE} -- Implementation

end
