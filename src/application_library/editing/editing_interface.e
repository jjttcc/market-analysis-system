indexing
	description:
		"Abstraction for a user interface that allows the user to edit %
		%application elements"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class EDITING_INTERFACE inherit

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	editor: APPLICATION_EDITOR
			-- Editor used to set Gs' operands and parameters

	last_error: STRING
			-- Description of last error that occurred

feature -- Status report

	error_occurred: BOOLEAN
			-- Did an error occur during the last operation?

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
				choices.item.set_right (False)
				choices.forth
			end
			do_choice (descr, choices, allowed_selections)
		ensure
			-- For each user-selection of an element of `choices', the
			-- right member of that pair is set to true; the right
			-- member of all other elements of `choices' is false.
		end

	character_choice (msg, chars: STRING): CHARACTER is
		do
			from
			until
				chars.has (Result)
			loop
				Result := character_selection (msg)
			end
		end

	character_selection (msg: STRING): CHARACTER is
			-- User-selected character
		deferred
		end

	integer_selection (msg: STRING): INTEGER is
			-- User-selected integer value
		deferred
		end

	real_selection (msg: STRING): REAL is
			-- User-selected real value
		deferred
		end

	string_selection (msg: STRING): STRING is
			-- User-selected string value
		deferred
		end

	date_time_selection (msg: STRING): DATE_TIME is
			-- User's selection of date/time
		deferred
		end

feature -- Basic operations

	show_message (msg: STRING) is
			-- Display `msg' to user -for example, as an error, warning, or
			-- informational message.
		deferred
		end

feature {NONE} -- Implementation

	Exit_value: INTEGER is -1
			-- Value indicating menu is to be exited - negative so as not
			-- to conflict with the unique values or with the numbered
			-- list selections

	Null_value: INTEGER is -2
			-- Value indicating nullness - negative so as not
			-- to conflict with the unique values or with the numbered
			-- list selections

	Show_help_value: INTEGER is 0
			-- Value indicating "Help" selection

	Save_value: INTEGER is 1
			-- Value indicating "Save data" selection

	Create_new_value: INTEGER is 2
			-- Value indicating "Create new item" selection

	Remove_value: INTEGER is 3
			-- Value indicating "Remove item" selection

	View_value: INTEGER is 4
			-- Value indicating "View item" selection

	Edit_value: INTEGER is 5
			-- Value indicating "Edit item" selection


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

	distinguish_duplicates (l: LIST [STRING]) is
			-- Distinguish each duplicate string in `l' by appending
			-- " [#{n}]" to the duplicate, where {n} is the number of the
			-- duplicate according to its reverse order in the list - from
			-- end to beginning.
		require
			not_void: l /= Void
		local
			ht: HASH_TABLE [LINKED_LIST [CHARACTER], STRING]
			i: INTEGER
			ilst: LINKED_LIST [CHARACTER]
			keys: ARRAY [STRING]
		do
			if not l.empty then
				create ht.make (l.count)
				from
					l.start
				until
					l.exhausted
				loop
					ilst := ht @ l.item
					if ilst = Void then
						create ilst.make
						ht.put (ilst, l.item)
					end
					ilst.extend ('x')
					l.forth
				end
				from
					i := 1; keys := ht.current_keys
				until i > keys.count loop
					(ht @ (keys @ i)).start
					i := i + 1
				end
				from
					l.finish
				until
					l.exhausted
				loop
					ilst := ht @ l.item
					if ilst.count > 1 then
						l.put (concatenation (<<l.item, " [#",
							ilst.index, "]">>))
						ilst.forth
					end
					l.back
				end
			end
		end

invariant

	editor_not_void: editor /= Void

end -- EDITING_INTERFACE
