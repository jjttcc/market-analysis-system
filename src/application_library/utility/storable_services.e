note
    description: "Services for STORABLE_LISTs"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

deferred class STORABLE_SERVICES [G] inherit

    TERMINABLE

    GENERAL_UTILITIES
        export
            {NONE} all
        end

feature -- Access

    last_error: STRING
            -- Description of last error that occurred
        deferred
        end

    real_list: STORABLE_LIST [ANY]
            -- The actual persistent list
        deferred
        end

    working_list: STORABLE_LIST [ANY]
            -- Working list used for editing
        deferred
        end

feature -- Status report

    changed: BOOLEAN
            -- Did the last editing operation make a change that was
            -- saved to persistent store?

    dirty: BOOLEAN
            -- Did the last operation make a change that may need to be
            -- saved to persistent store?

    readonly: BOOLEAN
            -- Are changes not allowed to be saved?

    ok_to_save: BOOLEAN
            -- Are changes allowed to be saved?

    abort_edit: BOOLEAN
            -- Should the edit session be aborted?
        do
            Result := not ok_to_save and not readonly
        ensure
            definition: Result = (not ok_to_save and not readonly)
        end

feature -- Basic operations

    edit_list
            -- Allow user to edit the list and save the changes.
        local
            at_end: BOOLEAN
        do
            changed := False
            begin_edit
            if not abort_edit then
                do_edit
                at_end := True
                end_edit
            end
        ensure
            not_dirty: not dirty
            not_locked: not lock.locked
        rescue
            if not abort_edit and not at_end then
                end_edit
            end
        end

feature {NONE} -- Implementation

    save
            -- Save user's changes to persistent store.
        require
            changed_and_ok_to_save: dirty and ok_to_save
            not_aborted: not abort_edit
        do
--!!!!!<markedit - ensure unique names...>
            real_list.copy (working_list)
check_for_duplicate_names (real_list)
            real_list.save
            show_message ("The changes have been saved.")
            deep_copy_list (working_list, real_list)
            synchronize_lists
            dirty := False
            end_save
            changed := True
        ensure then
            not_dirty: not dirty
            changed: changed
        end

    begin_edit
            -- Perform actions necessary to begin the editing session,
            -- including attempting to lock the persistent file.
        do
            readonly := False
            ok_to_save := True
            dirty := False
            initialize_lock
            lock.try_lock
            if not lock.locked then
                if lock.error_occurred then
                    show_message (lock.last_error)
                end
                prompt_for_edit_state
                if ok_to_save then
                    show_message ("Waiting to obtain a lock ...")
                    lock.lock
                    show_message ("  Lock obtained - continuing.%N")
                elseif abort_edit then
                    show_message ("Aborting edit session.%N")
                else
                    check check_readonly: readonly end
                    show_message ("Continuing - changes will not be saved.%N")
                end
            end
            if not abort_edit or working_list = Void then
                retrieve_persistent_list
                initialize_working_list
            end
        ensure
            locked_read_or_abort:
                ok_to_save and lock.locked or readonly or abort_edit
            working_list_set: working_list /= Void
        end

    end_edit
            -- Perform actions necessary to end the editing session,
            -- including ensuring that the file lock is released.
        require
            lock_set: lock /= Void
            abort_rules: abort_edit implies not dirty and not lock.locked
        do
            if dirty then
                -- The working list was changed, but the user elected not
                -- to save the changes; so throw away the changes by
                -- restoring the working list as a deep copy of the real
                -- list and ensure not dirty.
                deep_copy_list (working_list, real_list)
                dirty := False
            end
            if lock.locked then
                lock.unlock
            end
        ensure
            not_dirty: not dirty
        end

    lock: FILE_LOCK

    prompt_for_edit_state
            -- Prompt the user as to whether to "edit" read-only, wait for
            -- lock to clear, or abort edit.
        local
            c: CHARACTER
        do
            c := prompt_for_char ("Failed to lock item.  Wait for lock, %
                %Disallow changes, or Abort? (w/d/a) ", "wWdDaA")
            inspect
                c
            when 'w', 'W' then
                readonly := False
                ok_to_save := True
            when 'd', 'D' then
                readonly := True
                ok_to_save := False
            when 'a', 'A' then
                ok_to_save := False
                readonly := False
            end
        ensure
            readonly_or_wait_or_abort: (readonly and not ok_to_save) or
                (not readonly and ok_to_save) or
                (not readonly and not ok_to_save)
        end

    initialize_lock
            -- Ensure `lock' has been created and is unlocked.
        do
            if lock /= Void and lock.locked then
                lock.unlock
            else
                do_initialize_lock
            end
        ensure
            lock_set: lock /= Void and not lock.locked
        end

    cleanup
        local
            unlock_failed: BOOLEAN
        do
            if unlock_failed then
                show_message (lock.last_error)
            elseif lock /= Void and lock.locked then
                lock.unlock
            end
        ensure then
            unlocked: lock /= Void and not lock.error_occurred implies
                not lock.locked
        rescue
            unlock_failed := True
            retry
        end

    check_for_duplicate_names (object_list: STORABLE_LIST [ANY])
        local
            node_list: STORABLE_LIST [TREE_NODE]
        do
            node_list ?= object_list
            if node_list /= Void then
                from
                    node_list.start
                until
                    node_list.off
                loop
log_error("==== calling cfnnc for " + node_list.item.name + " ====[%N")
log_error(node_list.item.out + "]N")
                    check_for_node_name_conflict (node_list.item)
                    node_list.forth
                end
--!!!!!<markedit>: in progress...
            end
        end

    check_for_node_name_conflict (node: TREE_NODE)
        local
            node_name_table: HASH_TABLE [INTEGER, STRING]
            keys: ARRAY [STRING]
            key_list: ARRAY [STRING]
            nodes_and_components: LINKED_LIST [TREE_NODE]
        do
            create node_name_table.make (0)
            create nodes_and_components.make
            node.descendants.do_all(
                agent (curnode: TREE_NODE; list: LINKED_LIST [TREE_NODE])
                    do list.extend(curnode) end
                (?, nodes_and_components))
            node.all_components.do_all(
                agent (curnode: TREE_NODE; list: LINKED_LIST [TREE_NODE])
                    do list.extend(curnode) end
                (?, nodes_and_components))
            -- Put all descendants'/components' names into node_name_table:
            nodes_and_components.do_all (
                agent (curnode: TREE_NODE; table: HASH_TABLE[INTEGER,STRING])
                    local
                        i: INTEGER
                        name: STRING
                    do
                        i := 1; name := curnode.name
                        if table.has (name) then
                            i := (table.at(name)) + 1
--log_error("cfnnc, duplicates (" + i.out + ") found for " + name + "%N")
                        end
                        table.force (i, name)
--log_error("cfnnc, i: " + i.out + ", name: " + name + ", type: " +
--curnode.generating_type + ", tblsz: " + table.count.out + "%N")
                    end
                (?, node_name_table))
            key_list := node_name_table.current_keys
log_error("KEY_LIST count: " + key_list.count.out + "%N")
            key_list.do_all (
                agent (curname: STRING; table: HASH_TABLE[INTEGER,STRING])
                    local
                        curcount: INTEGER
                    do
                        curcount := table @ curname
                        if curcount > 1 then
                            log_error ((curcount - 1).out +
                                " duplicates found for '" + curname + "'%N")
                        else
                            log_error ("(" + curname + " is OK)%N")
                        end
                    end
                (?, node_name_table))
        end

feature {NONE} -- Hook routines

    do_edit
            -- Hook method called by edit_list
        require
            working_list_set: working_list /= Void
        deferred
        end

    show_message (s: STRING)
            -- Display `s' to the user.
        deferred
        end

    prompt_for_char (msg, charselection: STRING): CHARACTER
        deferred
        end

    retrieve_persistent_list
            -- Retrieve the current contents of the storable list from
            -- persistent store.
        deferred
        end

    initialize_working_list
        deferred
        ensure
            list_set: working_list /= Void
        end

    end_save
            -- Hook for end of save routine, if needed
        do
        end

    do_initialize_lock
        deferred
        ensure
            lock_not_void: lock /= Void and not lock.locked
        end

    synchronize_lists
            -- Perform any needed syncrhonization of in-memory lists
            -- after changes have been saved to persistent store.
        do
            -- Null operation - Redefine if needed.
        end

invariant

    read_implication: readonly implies not ok_to_save and not abort_edit
    save_implication: ok_to_save implies not readonly and not abort_edit
    not_locked_when_readonly: readonly implies
        (lock /= Void implies not lock.locked)
    abort_rules: abort_edit implies not dirty and
        (lock /= Void implies not lock.locked)

end -- STORABLE_SERVICES
