indexing
	description: "Builders of MCT application windows"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class APPLICATION_WINDOW_BUILDER inherit

feature -- Access

	main_window: EV_TITLED_WINDOW is
			-- The MCT main window
		local
			main_box: EV_VERTICAL_BOX
		do
			create Result.make_with_title (Main_window_title)
			-- Avoid flicker on some platforms.
			Result.lock_update
			create current_actions
			create main_box
			current_actions.set_owner_window (Result)
			Result.extend (main_box)
			add_main_window_buttons (main_box)
			Result.set_menu_bar (main_window_menu_bar)
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

	add_main_window_buttons (c: EV_CONTAINER) is
			-- Add all buttons needed for the main window
		local
			action_set: ACTION_SET
		do
			action_sets.set_actions (current_actions)
			action_set := action_sets.start_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.connect_to_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.terminate_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.close_window_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
		end

feature {NONE} -- Menu components

	file_menu: EV_MENU is
			-- The file menu
		require
			current_actions_exist: current_actions /= Void
		do
			create Result.make_with_text ("&File")
			Result.extend (widget_builder.new_menu_item ("E&xit",
				<<agent current_actions.close_window>>))
		end

	advanced_menu: EV_MENU is
			-- The 'advanced' menu
		require
			current_actions_exist: current_actions /= Void
		do
			create Result.make_with_text ("&Advanced")
			Result.extend (widget_builder.new_menu_item (
				"&Server startup configuration",
				<<agent current_actions.configure_server_startup>>))
		end

	help_menu: EV_MENU is
			-- The help menu
		require
			current_actions_exist: current_actions /= Void
		do
			create Result.make_with_text ("&Help")
			Result.extend (widget_builder.new_menu_item ("&About",
				<<agent current_actions.show_about_box>>))
		end

feature {NONE} -- Implementation

	current_actions: ACTIONS

	widget_builder: expanded WIDGET_BUILDER

	action_sets: expanded ACTION_SETS

feature {NONE} -- Implementation / Constants

	Main_window_title: STRING is "MAS Control Terminal"
			-- Title of the window

end
