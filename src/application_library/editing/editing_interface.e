indexing
	description:
		"Abstraction for a user interface that allows the user to edit %
		%application elements"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class

	EDITING_INTERFACE

feature -- Access

	editor: APPLICATION_EDITOR
			-- Editor used to set Gs' operands and parameters

feature -- Status setting

	set_editor (arg: like editor) is
			-- Set editor to `arg'.
		require
			arg_not_void: arg /= Void
		do
			editor := arg
		ensure
			editor_set: editor = arg and editor /= Void
		end

feature -- Access

	show_message (msg: STRING) is
			-- Display `msg' to user -for example, as an error, warning, or
			-- informational message.
		deferred
		end

	choice (descr: STRING; choices: LIST [PAIR [STRING, BOOLEAN]];
				allowed_selections: INTEGER) is
			-- The user's selections of the specified choices -
			-- from 1 to choices.count selections (with `descr' providing
			-- a description of the choices to the user)
		require
			not_void: choices /= Void
			as_valid: allowed_selections > 0 and allowed_selections <=
				choices.count
		do
			-- Initialize all `right' elements of `choices' to false
			from
				choices.start
			until
				choices.exhausted
			loop
				choices.item.set_right (false)
				choices.forth
			end
			do_choice (descr, choices, allowed_selections)
		ensure
			-- For each user-selection of an element of `choices', the
			-- right member of that pair is set to true; the right
			-- member of all other elements of `choices' is false.
		end

	integer_selection (msg: STRING): INTEGER is
			-- User-selected integer value
		deferred
		end

	real_selection (msg: STRING): REAL is
			-- User-selected real value
		deferred
		end

feature {NONE} -- Implementation - Hook methods

	do_choice (descr: STRING; choices: LIST [PAIR [STRING, BOOLEAN]];
				allowed_selections: INTEGER) is
			-- Implementation of `choice'
		deferred
		end

	multilist_selection (lists: ARRAY [PAIR [LIST [STRING], STRING]];
				general_msg: STRING): INTEGER is
			-- User's selection of one element from one of the `lists'.
			-- Display all lists in `lists' that are not empty and return
			-- the relative position of the selected item.  For example,
			-- if the first list has a count of 5 and the 2nd item in the
			-- 2nd list is selected, return a value of 7 (5 + 2).
		require
			not_void: lists /= Void
			-- Not all lists in `lists' are empty
		deferred
		ensure
			high_enough: Result >= 1
			-- Result <= total number of elements in `lists'
		end

end -- EDITING_INTERFACE
