indexing
	description:
		"Abstraction for a user interface that obtains selections needed for %
		%creation of a recursive structure (or tree) of objects of type G"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class TREE_EDITING_INTERFACE [G] inherit

	EDITING_INTERFACE

	GLOBAL_SERVICES

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

feature {NONE} -- Implementation

	user_object_selection (objects: LIST [G]; msg: STRING): G is
			-- User's selection of a member of `objects' (deep-cloned) or
			-- a member of `current_objects' that is in `objects' (shared)
		local
			obj_names, tree_names: ARRAYED_LIST [STRING]
			tree_objects: LIST [G]
			first_pair, second_pair: PAIR [LIST [STRING], STRING]
			selection: INTEGER
			do_clone: BOOLEAN
			general_msg: STRING
		do
			general_msg := concatenation (<<
							"Select an object for the ", msg, ":%N",
							"(Objects selected from current tree will be %
							%shared; objects selected%Nfrom the list of all %
							%objects will be copied.)%N">>)
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
					do_clone := true
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
					do_clone := true
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

	accepted_by_user (o: G): BOOLEAN is
			-- Does the user want to select `o'?
		deferred
		end

end -- TREE_EDITING_INTERFACE
