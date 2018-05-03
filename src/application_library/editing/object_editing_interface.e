note
    description:
        "Abstraction for a user interface that obtains selections needed for %
        %creation of a recursive structure (or tree) of objects of type G"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

deferred class OBJECT_EDITING_INTERFACE [G] inherit

    EDITING_INTERFACE

    GLOBAL_SERVICES
        export
            {NONE} all
        end

    GENERAL_UTILITIES
        export
            {NONE} all
        end

feature -- Access

    object_selection_from_type (type: STRING; desc: STRING; top: BOOLEAN): G
            -- User-selected object whose type conforms to `type' and is
            -- not represented in `exclude_list'.
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
            obj_list := valid_types_exclude (object_types @ type, exclude_list)
            Result := user_object_selection (obj_list, desc)
            configure_object (Result, desc)
            current_objects.extend (Result)
            if initialization_needed then
                initialize_object (Result)
            end
        ensure
            result_not_void: Result /= Void
        end

    object_selection_from_list (obj_list: LIST [G]; desc: STRING): G
            -- Object selected by user from `obj_list'.  If
            -- initialization_needed = True, then Result will be
            -- initialized.
        require
            ol_not_void: obj_list /= Void
        do
            Result := user_object_selection (obj_list, desc)
            if initialization_needed then
                initialize_object (Result)
            end
        ensure
            result_not_void_if_ol_not_empty:
                not obj_list.is_empty implies Result /= Void
        end

    object_types: HASH_TABLE [ARRAYED_LIST [G], STRING]
            -- Hash table of lists of class instances - each list contains
            -- instances of all classes whose type conforms to the Hash
            -- table key.  Defaults to Void for the convenience of
            -- descendants that don't need to find objects by their type.
        do
        end

    exclude_list: LIST [G]
            -- List of objects to exclude from user selections

feature -- Status setting

    reset
            -- Initialize state and clear cached values.
        do
            initialization_needed := False
            if current_object_list /= Void then
                current_object_list.wipe_out
            end
            descendant_reset
        end

    set_exclude_list (arg: like exclude_list)
            -- Set exclude_list to `arg'.
        require
            arg_not_void: arg /= Void
        do
            exclude_list := arg
        ensure
            exclude_list_set: exclude_list = arg and exclude_list /= Void
        end

feature {NONE} -- Implementation

    user_object_selection (objects: LIST [G]; tag: STRING): G
            -- User's selection of a member of `objects' (deep-cloned) or
            -- a member of `current_objects' that is in `objects' (shared)
            -- If the selection is from `current_objects',
            -- initialization_needed will be False; otherwise it will be True.
        require
            objs_not_void: objects /= Void
        local
            obj_names, tree_names: ARRAYED_LIST [STRING]
            tree_objects: LIST [G]
            first_pair, second_pair: PAIR [LIST [STRING], STRING]
            selection: INTEGER
            general_msg: STRING
        do
            create {LINKED_SET [G]} tree_objects.make
            tree_objects.fill (valid_types (current_objects, objects))
            create tree_names.make (tree_objects.count)
            tree_objects.do_all (agent add_selection_tag (tree_names, ?, True))
            distinguish_duplicates (tree_names)
            create obj_names.make (objects.count)
            objects.do_all (agent add_selection_tag (obj_names, ?, False))
            if tree_names.is_empty then
                general_msg := concatenation (<<
                            "%N<<Select an object for the ", tag, ":>>%N">>)
            else
                general_msg := concatenation (<<
                            "%N<<Select an object for the ", tag, ":>>%N",
                            "(Objects selected from current tree will be %
                            %shared; objects selected%Nfrom the list of all %
                            %objects will be copied.)%N">>)
            end
            create first_pair.make (tree_names,
                                "[Valid objects from current tree:]%N")
            create second_pair.make (obj_names,
                "[List of valid non-shared objects:]%N")
            from
                selection := multilist_selection (<<first_pair, second_pair>>,
                                                    general_msg)
                if selection <= tree_names.count then
                    -- Selection is from the list of previously chosen objects.
                    Result := tree_objects @ selection
                    -- The user wants an alias to a previously chosen object,
                    -- so it should not be cloned and its current settings
                    -- should not be changed.
                    do_clone := False
                    initialization_needed := False
                else
                    -- Selection is NOT from the list of previously
                    -- chosen objects.
                    Result := objects @ (selection - tree_objects.count)
                    do_clone := clone_needed
                    initialization_needed := True
                end
            until
                accepted_by_user (Result)
            loop
                selection := multilist_selection (<<first_pair, second_pair>>,
                                                    general_msg)
                if selection <= tree_names.count then
                    Result := tree_objects @ selection
                    do_clone := False
                else
                    Result := objects @ (selection - tree_objects.count)
                    do_clone := clone_needed
                end
            end
            if do_clone then
                Result := Result.deep_twin
                if editing_needed then
                    edit_object (Result, tag)
                end
            end
        ensure
            Result /= Void
        end

    initialization_map: HASH_TABLE [INTEGER, STRING]
            -- Mapping of G names to initialization classifications
        deferred
        end

    initialize_object (arg: G)
            -- Set object parameters.  (Use `description', if appropriate.)
        require
            editor_set: editor /= Void
            arg_not_void: arg /= Void
        deferred
        end

    configure_object (arg: G; description: STRING)
            -- Configure object, if needed.  (Use `description',
            -- if appropriate.)
        require
            arg_not_void: arg /= Void
        deferred
        end

    valid_types (obj_list, ref_list: LIST [G]): LIST [G]
            -- All elements of `obj_list' whose type matches that of
            -- an element of `ref_list'
        require
            not_void: obj_list /= Void and ref_list /= Void
        do
            create {LINKED_LIST [G]} Result.make
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

    valid_types_exclude (obj_list, ref_list: LIST [G]): LIST [G]
            -- All elements of `obj_list' whose type DOES NOT match that of
            -- an element of `ref_list'
        require
            ol_not_void: obj_list /= Void
        local
            exclude_current: BOOLEAN
        do
            create {LINKED_LIST [G]} Result.make
            if ref_list = Void then
                Result.append (obj_list)
            else
                from
                    obj_list.start
                until
                    obj_list.exhausted
                loop
                    from
                        ref_list.start
                        exclude_current := False
                    until
                        ref_list.exhausted or exclude_current
                    loop
                        if obj_list.item.same_type (ref_list.item) then
                            exclude_current := True
                        else
                            ref_list.forth
                        end
                    end
                    if not exclude_current then
                        Result.extend (obj_list.item)
                    end
                    obj_list.forth
                end
            end
        end

    current_objects: LIST [G]
        do
            if current_object_list = Void then
                create {LINKED_LIST [G]} current_object_list.make
            end
            Result := current_object_list
        ensure
            Result /= Void
        end

    current_object_list: LIST [G]

    add_selection_tag (taglist: SEQUENCE [STRING]; o: G; with_name: BOOLEAN)
            -- Extract relevant information from `o' and add it to
            -- `taglist'.  If `with_name', include `o's name.
        require
            args_exist: taglist /= Void and o /= Void
        do
            if with_name then
                taglist.extend (o.generator + name_for (o))
            else
                taglist.extend (o.generator)
            end
        end

feature {NONE} -- Implementation - hook methods

    accepted_by_user (o: G): BOOLEAN
            -- Does the user want to select `o'?
        deferred
        end

    clone_needed: BOOLEAN
            -- Do selected objects need to be cloned?
        deferred
        end

    do_clone: BOOLEAN
            -- Within `user_object_selection', does the selected object
            -- need to be cloned?  (For use by hook routines)

    initialization_needed: BOOLEAN
            -- Does the selected object need to be initialized?

    editing_needed: BOOLEAN
            -- Does the newly selected object need editing?
        deferred
        end

    edit_object (o: G; msg: STRING)
            -- Perform any needed editing of `o'.
        require
            editing_needed: editing_needed
        do
            -- default null implementation
        end

    descendant_reset
            -- Reset descendant's state - null by default - redefine if needed.
        do
        end

    name_for (o: G): STRING
            -- `o's name (preceded by a space and enclosed in parentheses),
            -- or empty string if `o' has no name or if the name is not
            -- relevant for editing purposes
        require
            o_exists: o /= Void
        deferred
        ensure
            Result_exists: Result /= Void
        end

end -- OBJECT_EDITING_INTERFACE
