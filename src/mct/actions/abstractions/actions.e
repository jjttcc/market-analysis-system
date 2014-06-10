note
	description: "Actions for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
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

	set_owner_window (arg: like owner_window)
			-- Set `owner_window' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			owner_window := arg
		ensure
			owner_window_set: owner_window = arg and owner_window /= Void
		end

feature -- Access

	port_numbers_in_use: LINKED_SET [STRING]
			-- Port numbers currently used by running MAS sessions
		once
			create Result.make
			Result.compare_objects
		end

	current_default_start_server_command: MCT_COMMAND
			-- The currently-selected "default" start-server command
		do
			Result := external_commands @
				configuration.Start_server_cmd_specifier
		end

feature -- Actions

	exit
			-- Exit the application, terminating all "owned" sessions.
		do
			configuration.set_terminate_sessions_on_exit (True)
			termination_cleanup;
			(create {EV_ENVIRONMENT}).application.destroy
		end

	exit_without_session_termination
			-- Exit the application without terminating sessions.
		do
			configuration.set_terminate_sessions_on_exit (False)
			termination_cleanup;
			(create {EV_ENVIRONMENT}).application.destroy
		end

	close_window
		do
			if owner_window /= Void then
				owner_window.destroy
			end
		end

	show_about_box
			-- Display an "about" box.
		local
			about_dialog: EV_INFORMATION_DIALOG
		do
			create about_dialog.make_with_text (
				-- @@Use the KDE apps' "about" box as a model to make
				-- this look more polished.
				"MAS Control Terminal%N%N(c) 2004%NAuthor: Jim Cochrane")
			about_dialog.set_title ("About MAS Control Terminal")
			about_dialog.show_modal_to_window (owner_window)
		end

	show_documentation
			-- Display the main MCT documentation.
		do
			external_commands.item (
				configuration.Browse_docs_cmd_specifier).execute (owner_window)
		end

	show_introduction
			-- Display the "MCT Introduction".
		do
			external_commands.item (
				configuration.Browse_intro_cmd_specifier).execute (owner_window)
		end

	show_faq
			-- Display the FAQ.
		do
			external_commands.item (
				configuration.Browse_faq_cmd_specifier).execute (owner_window)
		end

feature {NONE} -- Initialization

	make (config: MCT_CONFIGURATION)
			-- Creation routine for descendants
		require
			config_exists: config /= Void
		do
			create external_commands.make (0)
			configuration := config
			add_common_commands
			post_initialize
		end

	add_common_commands
			-- Add commands common to most contexts to `external_commands'.
		require
			external_commands_exists: external_commands /= Void
			configuration_exists: configuration /= Void
		local
			cmd: MCT_COMMAND
		do
			cmd := configuration.browse_documentation_command
			external_commands.put (cmd, cmd.identifier)
			cmd := configuration.browse_intro_command
			external_commands.put (cmd, cmd.identifier)
			cmd := configuration.browse_faq_command
			external_commands.put (cmd, cmd.identifier)
		end

	post_initialize
			-- Do any needed initialization of the descendant.
		require
			external_commands_exists: external_commands /= Void
			configuration_exists: configuration /= Void
		do
			-- Null routine - redefine if needed.
		end

feature {NONE} -- Implementation - utilities

	display_error (s: STRING)
			-- Display error message `s'.
		local
			dialog: EV_WIDGET
			wbldr: expanded WIDGET_BUILDER
		do
			dialog := wbldr.new_error_dialog (s, Void)
			dialog.show
		end

feature {NONE} -- Implementation

	external_commands: HASH_TABLE [MCT_COMMAND, STRING]

	configuration: MCT_CONFIGURATION

invariant

	configuration_exists: configuration /= Void
	port_numbers_in_use_exists: port_numbers_in_use /= Void
	compare_port_numbers: port_numbers_in_use.object_comparison
	external_commands_exist: external_commands /= Void

end
