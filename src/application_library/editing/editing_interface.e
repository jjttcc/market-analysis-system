indexing
	description:
		"Abstraction for a user interface that obtains selections needed for %
		%creation of a recursive structure of objects of type G"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class

	EDITING_INTERFACE [G]

feature -- Access

	object_selection (type: STRING; msg: STRING; top: BOOLEAN): G is
			-- User-selected object whose type conforms to `type'.
			-- `top' specifies whether the returned instance will be
			-- the top of the tree.
		require
			type_is_valid: object_types @ type /= Void
			editor_set: editor /= Void
		local
			op_names: ARRAYED_LIST [STRING]
			obj_list: ARRAYED_LIST [G]
		do
			if top then
				-- Clear current object list for the new tree.
				current_objects.wipe_out
			end
			obj_list := object_types @ type
			Result := user_object_selection (obj_list, msg)
			current_objects.extend (Result)
			initialize_object (Result)
		ensure
			result_not_void: Result /= Void
		end

	object_types: HASH_TABLE [ARRAYED_LIST [G], STRING] is
			-- Hash table of lists of class instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.
		deferred
		end

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

feature {APPLICATION_EDITOR} -- Access

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

feature {NONE} -- Implementation

	user_object_selection (obj_list: LIST [G]; msg: STRING): G is
			-- User's selection of a member of `obj_list' that will be
			-- (deep) cloned or a member of `current_objects' that is
			-- in `obj_list' that will be shared
		deferred
		end

	do_choice (descr: STRING; choices: LIST [PAIR [STRING, BOOLEAN]];
				allowed_selections: INTEGER) is
			-- Implementation of `choice'
		deferred
		end

	initialization_map: HASH_TABLE [INTEGER, STRING] is
			-- Mapping of G names to initialization classifications
		deferred
		end

	initialize_object (arg: G) is
			-- Set object parameters - operands, etc.
		require
			editor_set: editor /= Void
			arg_not_void: arg /= Void
		deferred
		end

	valid_types (ref_list, obj_list: LIST [G]): LIST [G] is
			-- All elements of `obj_list' whose type matches that of
			-- an element of `ref_list'
		do
			!LINKED_LIST [G]!Result.make
			from
				obj_list.start
			until
				obj_list.exhausted
			loop
				from
					ref_list.start
				until
					ref_list.exhausted
				loop
					if obj_list.item.same_type (ref_list.item) then
						Result.extend (obj_list.item)
						ref_list.finish
					end
					ref_list.forth
				end
				obj_list.forth
			end
		end

	current_objects: LIST [G] is
		do
			if object_list = Void then
				!LINKED_LIST [G]!object_list.make
			end
			Result := object_list
		end

	object_list: LIST [G]

end -- EDITING_INTERFACE
