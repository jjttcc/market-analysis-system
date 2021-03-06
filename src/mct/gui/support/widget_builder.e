note
	description: "Tools for building widgets"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class WIDGET_BUILDER inherit

feature -- Access

	new_menu_item (label: STRING; actions: CONTAINER [PROCEDURE [ANY, TUPLE]]):
		EV_MENU_ITEM
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
		EV_BUTTON
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

	new_error_dialog (text: STRING;
		actions: ARRAY [PROCEDURE [ANY, TUPLE]]): EV_INFORMATION_DIALOG
			-- Error reporting dialog, with `actions' as button-select
			-- actions, if `actions' is not Void.
		require
			args_exist: text /= Void
		local
			pixmaps: expanded EV_STOCK_PIXMAPS
		do
			if actions = Void then
				create Result.make_with_text (text)
			else
				create Result.make_with_text_and_actions (text, actions)
			end
			Result.set_title ("Error")
			Result.set_pixmap (pixmaps.error_pixmap)
		ensure
			result_exists: Result /= Void
			text_set: Result.text.is_equal (text)
		end

	default_accelerator (key_code: INTEGER): EV_ACCELERATOR
			-- Accelerator with default settings with the key specified
			-- by `key_code'
		do
			create Result.make_with_key_combination (
				create {EV_KEY}.make_with_code (key_code), True, False, False)
		end

feature -- Basic operations

	add_actions (action_sequence: EV_NOTIFY_ACTION_SEQUENCE;
		actions: CONTAINER [PROCEDURE [ANY, TUPLE]])
			-- Add `actions' to `action_sequence'.
		require
			args_exist: action_sequence /= Void and actions /= Void
		do
			actions.linear_representation.do_all (agent action_sequence.extend)
		end

end
