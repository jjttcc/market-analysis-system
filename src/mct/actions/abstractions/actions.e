indexing
	description: "Actions for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

deferred class ACTIONS inherit

	CLEANUP_SERVICES
		export
			{NONE} all
		end

feature -- Access

	owner_window: EV_WINDOW
			-- Window that owns Current

feature -- Element change

	set_owner_window (arg: like owner_window) is
			-- Set `owner_window' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			owner_window := arg
		ensure
			owner_window_set: owner_window = arg and owner_window /= Void
		end

feature -- Access

	port_numbers_in_use: LINKED_SET [STRING] is
			-- Port numbers currently used by running MAS sessions
		once
			create Result.make
			Result.compare_objects
		end

feature -- Actions

	exit is
			-- Exit the application, terminating all "owned" sessions.
		do
			configuration.set_terminate_sessions_on_exit (True)
			termination_cleanup;
			(create {EV_ENVIRONMENT}).application.destroy
		end

	exit_without_session_termination is
			-- Exit the application without terminating sessions.
		do
			configuration.set_terminate_sessions_on_exit (False)
			termination_cleanup;
			(create {EV_ENVIRONMENT}).application.destroy
		end

	close_window is
		do
			if owner_window /= Void then
				owner_window.destroy
			end
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
			about_dialog.set_title ("About MAS Control Terminal")
			about_dialog.show_modal_to_window (owner_window)
		end

	show_help_introduction is
			-- Display the "Help -> MCT Introduction".
		local
			help_tools: expanded HELP_TOOLS
			intro_window: EV_WINDOW
		do
			intro_window := help_tools.introduction
			intro_window.show
		end

feature {NONE} -- Implementation - utilities

	display_error (s: STRING) is
			-- Display error message `s'.
		local
			dialog: EV_WIDGET
			wbldr: expanded WIDGET_BUILDER
		do
			dialog := wbldr.new_error_dialog (s)
			dialog.show
		end

feature {NONE} -- Implementation

	external_commands: HASH_TABLE [EXTERNAL_COMMAND, STRING]

	configuration: MCT_CONFIGURATION

invariant

	configuration_exists: configuration /= Void
	port_numbers_in_use_exists: port_numbers_in_use /= Void
	compare_port_numbers: port_numbers_in_use.object_comparison
	external_commands_exist: external_commands /= Void

end
