indexing
	description:
		"Abstraction for a user interface that obtains selections needed for %
		%creation of a recursive structure (or tree) of objects of type G"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class OBJECT_EDITING_INTERFACE [G] inherit

	EDITING_INTERFACE

	GLOBAL_SERVICES
		export
			{NONE} all
		end

feature -- Access

	object_selection_from_type (type: STRING; msg: STRING; top: BOOLEAN): G is
			-- User-selected object whose type conforms to `type'.
			-- `top' specifies whether the returned instance will be
			-- the top of the tree.
		require
			types_not_void: object_types /= Void
			type_is_valid: object_types @ type /= Void
			editor_set: editor /= Void
		local
			obj_list: LIST [G]
		do
			if top then
				-- Clear current object list for the new tree.
				current_objects.wipe_out
			end
			obj_list := object_types @ type
			Result := user_object_selection (obj_list, msg)
			current_objects.extend (Result)
			if initialization_needed then
				initialize_object (Result)
			end
		ensure
			result_not_void: Result /= Void
		end

	object_selection_from_list (obj_list: LIST [G]; msg: STRING): G is
			-- Object selected by user from `obj_list'.  If
			-- initialization_needed = true, then Result will be
			-- initialized.
		require
			ol_not_void: obj_list /= Void
		do
			Result := user_object_selection (obj_list, msg)
			--!!!???: current_objects.extend (Result)
			if initialization_needed then
				initialize_object (Result)
			end
		ensure
			result_not_void_if_ol_not_empty:
				not obj_list.empty implies Result /= Void
		end

	object_types: HASH_TABLE [ARRAYED_LIST [G], STRING] is
			-- Hash table of lists of class instances - each list contains
			-- instances of all classes whose type conforms to the Hash
			-- table key.  Defaults to Void for the convenience of
			-- descendants that don't need to find objects by their type.
		do
		end

	market_tuple_list_selection (msg: STRING): CHAIN [MARKET_TUPLE] is
			-- User-selected list of market tuples
		deferred
		end

feature {NONE} -- Implementation

	user_object_selection (objects: LIST [G]; msg: STRING): G is
			-- User's selection of a member of `objects' (deep-cloned) or
			-- a member of `current_objects' that is in `objects' (shared)
		require
			objs_not_void: objects /= Void
		local
			obj_names, tree_names: ARRAYED_LIST [STRING]
			tree_objects: LIST [G]
			first_pair, second_pair: PAIR [LIST [STRING], STRING]
			selection: INTEGER
			do_clone: BOOLEAN
			general_msg: STRING
		do
			!LINKED_SET [G]!tree_objects.make
			tree_objects.fill (valid_types (objects, current_objects))
			from
				!!tree_names.make (tree_objects.count)
				tree_objects.start
			until
				tree_objects.exhausted
			loop
				tree_names.extend (tree_objects.item.generator)
				tree_objects.forth
			end
			from
				!!obj_names.make (objects.count)
				objects.start
			until
				objects.exhausted
			loop
				obj_names.extend (objects.item.generator)
				objects.forth
			end
			if tree_names.empty then
				general_msg := concatenation (<<
							"Select an object for the ", msg, ":%N">>)
			else
				general_msg := concatenation (<<
							"Select an object for the ", msg, ":%N",
							"(Objects selected from current tree will be %
							%shared; objects selected%Nfrom the list of all %
							%objects will be copied.)%N">>)
			end
			!!first_pair.make (tree_names,
								"[Valid objects from current tree:]%N")
			!!second_pair.make (obj_names, "[List of all valid objects:]%N")
			from
				selection := multilist_selection (<<first_pair, second_pair>>,
													general_msg)
				if selection <= tree_names.count then
					Result := tree_objects @ selection
					do_clone := false
				else
					Result := objects @ (selection - tree_objects.count)
					do_clone := clone_needed
				end
			until
				accepted_by_user (Result)
			loop
				selection := multilist_selection (<<first_pair, second_pair>>,
													general_msg)
				if selection <= tree_names.count then
					Result := tree_objects @ selection
					do_clone := false
				else
					Result := objects @ (selection - tree_objects.count)
					do_clone := clone_needed
				end
			end
			if do_clone then
				Result := deep_clone (Result)
			end
		ensure
			Result /= Void
		end

	initialization_map: HASH_TABLE [INTEGER, STRING] is
			-- Mapping of G names to initialization classifications
		deferred
		end

	initialize_object (arg: G) is
			-- Set object parameters.
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
			if current_object_list = Void then
				!LINKED_LIST [G]!current_object_list.make
			end
			Result := current_object_list
		ensure
			Result /= Void
		end

	current_object_list: LIST [G]

	accepted_by_user (o: G): BOOLEAN is
			-- Does the user want to select `o'?
		deferred
		end

feature -- Implementation - options

	clone_needed: BOOLEAN is
			-- Do selected objects need to be cloned?
		deferred
		end

	initialization_needed: BOOLEAN is
			-- Does the selected object need to be initialized?
		deferred
		end

end -- OBJECT_EDITING_INTERFACE
