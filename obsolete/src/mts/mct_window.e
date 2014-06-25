indexing
	description: "MCT application windows"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MCT_WINDOW inherit

	EV_TITLED_WINDOW
		export
			{NONE} all
			{ANY} show
		end

create

	make

feature {NONE} -- Initialization

	make is
		do
			default_create
			create actions.make (Current)
			build_contents
		end

	build_contents is
			-- Build the interface for this window.
		require
			actions_exist: actions /= Void
		do
			build_menu_bar
			set_menu_bar (standard_menu_bar)
			build_primitives
			close_request_actions.extend (agent actions.close_window)
			set_title (window_title)
--			set_size (window_width, window_height)
		end

feature {NONE} -- Menu implementation

	standard_menu_bar: EV_MENU_BAR
			-- Standard menu bar for this window

	file_menu: EV_MENU

	-- !!!Experimental:
	advanced_menu: EV_MENU

	help_menu: EV_MENU

	build_menu_bar is
			-- Create and populate `standard_menu_bar'.
		require
			menu_bar_not_yet_created: standard_menu_bar = Void
		local
			menu_item: EV_MENU_ITEM
		do
			create standard_menu_bar
			-- File menu
			create file_menu.make_with_text ("&File")
			create menu_item.make_with_text ("E&xit")
			file_menu.extend (menu_item)
			standard_menu_bar.extend (file_menu)
			-- Close the application when the 'Exit' menu item is selected.
			menu_item.select_actions.extend (agent actions.close_window)
			-- "Advanced" menu
			create advanced_menu.make_with_text ("&Advanced")
			create menu_item.make_with_text (
				"&Server startup configuration")
			advanced_menu.extend (menu_item)
			standard_menu_bar.extend (advanced_menu)
			menu_item.select_actions.extend (
				agent actions.configure_server_startup)
			-- Help menu
			create help_menu.make_with_text ("&Help")
			create menu_item.make_with_text ("&About")
			help_menu.extend (menu_item)
			standard_menu_bar.extend (help_menu)
			menu_item.select_actions.extend (agent actions.show_about_box)
		ensure
			menu_bar_created: standard_menu_bar /= Void and then
				not standard_menu_bar.is_empty
		end

feature {NONE} -- Misc. primitives implementation

	enclosing_box: EV_VERTICAL_BOX
			-- Invisible primitives container

--!!!Check: Do we need to hold onto these buttons within Current?:
	start_mas_button: EV_BUTTON

	exit_button: EV_BUTTON

	new_error_dialog (text: STRING): EV_INFORMATION_DIALOG is
			-- Error reporting window
		do
			create Result.make_with_text (text)
			Result.set_title ("Error")
			Result.set_pixmap (default_pixmaps.error_pixmap)
		end

	build_primitives is
		require
		do
			-- Avoid flicker on some platforms.
			lock_update
			-- Cover entire window area with a primitive container.
			create enclosing_box
			extend (enclosing_box)
			build_buttons
			-- Allow screen refresh on some platoforms.
			unlock_update
		ensure
			enclosing_box_created: enclosing_box /= Void
			start_mas_button_created: start_mas_button /= Void
			exit_button_created: exit_button /= Void
		end

	build_buttons is
			-- Build button components.
		local
			btn: EV_BUTTON
		do
			create start_mas_button.make_with_text ("Start MAS Charts")
			start_mas_button.select_actions.extend (
				agent actions.start_charting_app)
			enclosing_box.extend (start_mas_button)
			create btn.make_with_text ("Start MAS Command-line")
			btn.select_actions.extend (agent actions.start_command_line)
			enclosing_box.extend (btn)
			create exit_button.make_with_text ("Close")
			exit_button.select_actions.extend (agent actions.close_window)
			enclosing_box.extend (exit_button)
create btn.make_with_text ("Other 2")
btn.select_actions.extend (agent actions.close_window)
enclosing_box.extend (btn)
		ensure
			start_mas_button_created: start_mas_button /= Void
			exit_button_created: exit_button /= Void
		end

feature {NONE} -- Implementation

	actions: ACTIONS

feature {NONE} -- Implementation / Constants

	Window_title: STRING is "MAS Control Terminal"
			-- Title of the window

	Window_width: INTEGER = 350
			-- Initial width for this window

	Window_height: INTEGER = 335
			-- Initial height for this window

end
