indexing
	description: "Objects that allow the user to select one of the available %
		%start-server commands"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class START_SERVER_SELECTION inherit

	ACTIONS

create

	make

feature {NONE} -- Initialization

	make (conf: MCT_CONFIGURATION;
			ext_cmds: HASH_TABLE [EXTERNAL_COMMAND, STRING]) is
		require
			conf_exists: conf /= Void and ext_cmds /= Void
		do
			configuration := conf
			external_commands := ext_cmds
		ensure
			configuration_set: configuration = conf
			external_commands_set: external_commands = ext_cmds
		end

feature -- Basic operations

	execute is
			-- Configure how the server is to be started up.
		local
			cmds: LINEAR [EXTERNAL_COMMAND]
			window: LIST_SELECTION_WINDOW
			rows: LINKED_LIST [LIST [STRING]]
			label: STRING
		do
			create rows.make
			rows.extend (create {LINKED_LIST [STRING]}.make)
			-- Add muli-list column titles.
			rows.first.extend (Name)
			rows.first.extend (Description)
			create server_cmd_table.make (
				configuration.start_server_commands.count)
			cmds := configuration.start_server_commands
			-- Add one row to `rows' for each element of `cmds'.
			from
				cmds.start
			until
				cmds.exhausted
			loop
				-- Add new row.
				rows.extend (create {LINKED_LIST [STRING]}.make)
				if cmds.item.name = Void or else cmds.item.name.is_empty then
					label := cmds.item.identifier
				else
					label := cmds.item.name
				end
				rows.last.extend (label)
				server_cmd_table.put (cmds.item, label)
				if cmds.item.description = Void then
					rows.last.extend ("")
				else
					rows.last.extend (cmds.item.description)
				end
				cmds.forth
			end
			create window.make (Window_title, rows)
			set_owner_window (window)
			window.show
			window.register_client (agent respond_to_server_selection_event)
		end

feature {NONE} -- Implementation

	server_cmd_table: HASH_TABLE [EXTERNAL_COMMAND, STRING]

	respond_to_server_selection_event (supplier: LIST_SELECTION_WINDOW) is
			-- Respond to a "start-server-selection" event.
		local
			selected_command: EXTERNAL_COMMAND
		do
			if supplier.selected_item /= Void then
				selected_command := server_cmd_table @
					supplier.selected_item.first
				check
					start_srvr_cmd_set: selected_command /= Void and
					selected_command.identifier.is_equal (
						configuration.Start_server_cmd_specifier) and
					external_commands.has (selected_command.identifier)
				end
				external_commands.replace (selected_command,
					selected_command.identifier)
			end
			-- !!Need to modify the mctrc file to mark the selected command
			-- as the default.
		end

feature {NONE} -- Implementation - constants

	Name: STRING is "Command name"

	Description: STRING is "Description"

	Window_title: STRING is "Start-server selection"

end
