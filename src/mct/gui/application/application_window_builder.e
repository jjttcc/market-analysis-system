indexing
	description: "Builders of MAS Control Terminal application windows"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class APPLICATION_WINDOW_BUILDER inherit

feature -- Access

	main_window: EV_TITLED_WINDOW is
			-- The MAS Control Terminal main window
		local
			main_box: EV_VERTICAL_BOX
		do
			create Result.make_with_title (Main_window_title)
			-- Avoid flicker on some platforms.
			Result.lock_update
			create current_main_actions.make (configuration)
			create main_box
			current_main_actions.set_owner_window (Result)
			Result.extend (main_box)
			add_main_window_buttons (main_box)
			Result.set_menu_bar (main_window_menu_bar)
			-- Allow screen refresh on some platoforms.
			Result.unlock_update
		end

	mas_session_window: SESSION_WINDOW is
			-- A MAS session window
		local
			main_box: EV_VERTICAL_BOX
		do
			create Result.make_with_title (Session_window_title)
			-- Avoid flicker on some platforms.
			Result.lock_update
			create current_mas_session_actions.make (configuration)
			create main_box
			current_mas_session_actions.set_owner_window (Result)
			Result.extend (main_box)
			add_mas_session_window_buttons (main_box)
			Result.set_menu_bar (mas_session_window_menu_bar)
			-- Allow screen refresh on some platoforms.
			Result.unlock_update
		end

feature {NONE} -- Main-window components

	main_window_menu_bar: EV_MENU_BAR is
			-- Menu bar for the main window
		do
			create Result
			Result.extend (file_menu)
			Result.extend (advanced_menu)
			Result.extend (help_menu)
		end

	mas_session_window_menu_bar: EV_MENU_BAR is
			-- Menu bar for MAS session window
		do
			create Result
			Result.extend (file_menu)
			Result.extend (help_menu)
		end

	add_main_window_buttons (c: EV_CONTAINER) is
			-- Add all buttons needed for the main window
		local
			action_set: ACTION_SET
			action_sets: expanded ACTION_SETS
		do
			action_sets.set_main_actions (current_main_actions)
			action_set := action_sets.start_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.connect_to_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.terminate_arbitrary_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.exit_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
		end

	add_mas_session_window_buttons (c: EV_CONTAINER) is
			-- Add all buttons needed for a MAS session window
		local
			action_set: ACTION_SET
			action_sets: expanded ACTION_SETS
		do
			action_sets.set_mas_session_actions (current_mas_session_actions)
			action_set := action_sets.start_chart_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.start_command_line_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.terminate_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
		end

feature {NONE} -- Menu components

	file_menu: EV_MENU is
			-- The file menu
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		local
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			create Result.make_with_text ("&File")
			Result.extend (widget_builder.new_menu_item ("E&xit",
				<<agent actions.exit>>))
		end

	advanced_menu: EV_MENU is
			-- The 'advanced' menu
		require
			current_main_actions_exist: current_main_actions /= Void
		do
			create Result.make_with_text ("&Advanced")
			Result.extend (widget_builder.new_menu_item (
				"&Server startup configuration",
				<<agent current_main_actions.configure_server_startup>>))
		end

	help_menu: EV_MENU is
			-- The help menu
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		local
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			create Result.make_with_text ("&Help")
			Result.extend (widget_builder.new_menu_item ("&About",
				<<agent actions.show_about_box>>))
		end

feature {NONE} -- Implementation

	current_main_actions: MAIN_ACTIONS

	current_mas_session_actions: MAS_SESSION_ACTIONS

	widget_builder: expanded WIDGET_BUILDER

	configuration: MCT_CONFIGURATION is
		once
			create Result.make
		end

feature {NONE} -- Implementation - Constants

	Main_window_title: STRING is "MAS Control Panel"
			-- Title of the window

	Session_window_title: STRING is "MAS"
			-- Title of the window

	Session_window_minimum_width: INTEGER is 550

end
