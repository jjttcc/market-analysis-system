indexing
	description: "Tools for building widgets"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class WIDGET_BUILDER inherit

feature -- Access

	new_menu_item (label: STRING; actions: CONTAINER [PROCEDURE [ANY, TUPLE]]):
		EV_MENU_ITEM is
			-- A new menu item with label `label' and actions `actions'
		require
			args_exist: label /= Void and actions /= Void
		do
			create Result.make_with_text (label)
			add_actions (Result.select_actions, actions)
		ensure
			result_exists: Result /= Void
			text_set: Result.text.is_equal (label)
		end

	new_button (label: STRING; actions: CONTAINER [PROCEDURE [ANY, TUPLE]]):
		EV_BUTTON is
			-- A button with label `label' and actions `actions'
		require
			args_exist: label /= Void and actions /= Void
		do
			create Result.make_with_text (label)
			add_actions (Result.select_actions, actions)
			Result.set_minimum_width (Result.width + 9)
		ensure
			result_exists: Result /= Void
			text_set: Result.text.is_equal (label)
		end

	new_error_dialog (text: STRING): EV_INFORMATION_DIALOG is
			-- Error reporting dialog
		require
			args_exist: text /= Void
		local
			pixmaps: expanded EV_STOCK_PIXMAPS
		do
			create Result.make_with_text (text)
			Result.set_title ("Error")
			Result.set_pixmap (pixmaps.error_pixmap)
		ensure
			result_exists: Result /= Void
			text_set: Result.text.is_equal (text)
		end

feature -- Basic operations

	add_actions (action_sequence: EV_NOTIFY_ACTION_SEQUENCE;
		actions: CONTAINER [PROCEDURE [ANY, TUPLE]]) is
			-- Add `actions' to `action_sequence'.
		require
			args_exist: action_sequence /= Void and actions /= Void
		do
			actions.linear_representation.do_all (agent action_sequence.extend)
		end

end
