indexing
	description: "Configuration of environment/platform-dependent settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MCT_CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		rename
			file_reader as config_file, new_file_reader as new_config_file,
			make as cu_make
		export
			{NONE} all
		redefine
			post_process_settings, use_customized_setting,
			do_customized_setting, config_file
		end

	MCT_CONFIGURATION_PROPERTIES

	ERROR_PUBLISHER
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make (subs: ARRAY [ERROR_SUBSCRIBER]) is
			-- Make with error subscribers `subs'.
		do
			if subs /= Void then
				subs.linear_representation.do_all (agent add_error_subscriber)
			end
			cu_make
		end

	initialize is
		do
			create settings.make (0)
			create start_server_commands.make

			settings.extend ("", Valid_port_numbers_specifier)
			settings.extend ("", Hostname_specifier)
			settings.extend ("", Start_server_cmd_specifier)
			settings.extend ("", Start_cl_client_cmd_specifier)
			settings.extend ("", Chart_cmd_specifier)
			settings.extend ("", Termination_cmd_specifier)
			settings.extend ("", Browse_docs_cmd_specifier)
			settings.extend ("", Browse_intro_cmd_specifier)
			settings.extend ("", Browse_faq_cmd_specifier)
			create user_defined_variables.make (1, 0)
			create user_defined_values.make (1, 0)
		ensure
			zero_counts: user_defined_variables.count = 0 and
				user_defined_values.count = 0
		end

feature -- Access

	valid_portnumbers: LIST [STRING] is
		do
			Result := (settings @ Valid_port_numbers_specifier).split (
				Valid_port_numbers_separator)
		ensure
			not_void: Result /= Void
		end

	hostname: STRING is
		do
			Result := settings @ Hostname_specifier
		ensure
			not_void: Result /= Void
		end

feature -- Commands

	default_start_server_command: EXTERNAL_COMMAND
			-- Specified default 'start-server' command

	start_server_commands: LINKED_SET [EXTERNAL_COMMAND]
			-- Configured 'start-server' commands

	start_command_line_client_command: EXTERNAL_COMMAND
			-- Command to start the command-line client

	chart_command: EXTERNAL_COMMAND
			-- Command to start the charting client

	termination_command: EXTERNAL_COMMAND
			-- Command to terminate a server

	browse_documentation_command: EXTERNAL_COMMAND
			-- Command to browse the MCT documentation

	browse_intro_command: EXTERNAL_COMMAND
			-- Command to browse the "MCT introduction"

	browse_faq_command: EXTERNAL_COMMAND
			-- Command to browse the FAQ

feature -- Status report

	fatal_error_status: BOOLEAN
			-- Did a fatal configuration error occur?

	terminate_sessions_on_exit: BOOLEAN
			-- Should all owned MAS sessions be terminated on exit?

	save_command_as_default_failed: BOOLEAN is
			-- Did the last call to `save_command_as_default ' fail?
		do
			Result := config_file.mark_as_default_failed
		end

	save_command_as_default_failure_reason: STRING is
			-- Did the last call to `save_command_as_default ' fail?
		do
			Result := config_file.mark_as_default_failure_reason
		end

feature -- Status setting

	set_terminate_sessions_on_exit (arg: BOOLEAN) is
			-- Set `terminate_sessions_on_exit' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			terminate_sessions_on_exit := arg
		ensure
			terminate_sessions_on_exit_set: terminate_sessions_on_exit = arg
				and terminate_sessions_on_exit /= Void
		end

feature -- Basic operations

	save_command_as_default (cmd: EXTERNAL_COMMAND) is
			-- Save `cmd' in the configuration file as a default command.
		do
			config_file.mark_block_as_default (Command_name_specifier,
				cmd.name, cmd.identifier)
		end

feature {NONE} -- Implementation - Hook routine implementations

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	configuration_type: STRING is "MAS Control Terminal"

	post_process_settings is
		do
			-- Replace all "non-dynamic" tokens in `user_defined_values'
			-- with their specified values:
			user_defined_values.linear_representation.do_all (
				agent replace_configuration_tokens)
			-- Replace all "non-dynamic" tokens in `settings' with their
			-- specified values:
			settings.linear_representation.do_all (
				agent replace_configuration_tokens)
			-- Replace all "non-dynamic" tokens in the `command_string' of
			-- `start_server_commands' with their specified values:
			start_server_commands.linear_representation.do_all (
				agent replace_command_string_tokens)
			if not settings.item (Start_server_cmd_specifier).is_empty then
				start_server_commands.extend (create {SESSION_COMMAND}.make (
				Start_server_cmd_specifier,
				settings @ Start_server_cmd_specifier))
			end
			if settings.has (Start_cl_client_cmd_specifier) then
				create {SESSION_COMMAND}
					start_command_line_client_command.make (
						Start_cl_client_cmd_specifier,
						settings @ Start_cl_client_cmd_specifier)
			end
			if settings.has (Chart_cmd_specifier) then
				create {SESSION_COMMAND} chart_command.make (
					Chart_cmd_specifier, settings @ Chart_cmd_specifier)
			end
			if settings.has (Termination_cmd_specifier) then
				create {SESSION_COMMAND} termination_command.make (
					Termination_cmd_specifier,
					settings @ Termination_cmd_specifier)
			end
			if settings.has (Browse_docs_cmd_specifier) then
				create {EXTERNAL_COMMAND} browse_documentation_command.make (
					Browse_docs_cmd_specifier,
					settings @ Browse_docs_cmd_specifier)
			end
			if settings.has (Browse_intro_cmd_specifier) then
				create {EXTERNAL_COMMAND} browse_intro_command.make (
					Browse_intro_cmd_specifier,
					settings @ Browse_intro_cmd_specifier)
			end
			if settings.has (Browse_faq_cmd_specifier) then
				create {EXTERNAL_COMMAND} browse_faq_command.make (
					Browse_faq_cmd_specifier,
					settings @ Browse_faq_cmd_specifier)
			end
			if
				default_start_server_command = Void and then
				not start_server_commands.is_empty
			then
				default_start_server_command := start_server_commands.first
			end
print ("%N<<<<BEGIN PRINT SETTINGS.%N>>>>")
settings.linear_representation.do_all (agent print_str)
print ("%N<<<<END PRINT SETTINGS.%N>>>>")
print ("%N<<<<BEGIN start_server_commands SETTINGS.%N>>>>")
start_server_commands.linear_representation.do_all (agent print_cmd)
print ("%N<<<<END start_server_commands SETTINGS.%N>>>>")
		end

	check_results is
		do
			create error_report.make (0);
			check_for_empty_fields (<<
				Valid_port_numbers_specifier, Hostname_specifier,
				Start_cl_client_cmd_specifier, Chart_cmd_specifier,
				Termination_cmd_specifier, Browse_docs_cmd_specifier,
				Browse_intro_cmd_specifier, Browse_faq_cmd_specifier>>)
			if default_start_server_command = Void then
				error_report.append ("Default " + Start_server_cmd_specifier +
					" is not set.%N")
				fatal_error_status := True
			end
			settings.linear_representation.do_all (
				agent check_for_unreplaced_tokens)
			user_defined_values.linear_representation.do_all (
				agent check_for_unreplaced_tokens)
			start_server_commands.linear_representation.do_all (
				agent check_for_unreplaced_commands)
			if not error_report.is_empty then
				error_report.prepend ("Error in configuration file (" +
					config_file.configuration_file_name + "):%N")
				publish_error (error_report)
			end
		end

	use_customized_setting (key, value: STRING): BOOLEAN is
		do
			if
				config_file.in_block or config_file.at_end_of_block or
				equal (key, User_definition_specifier)
			then
				Result := True
			end
		end

	do_customized_setting (key, value: STRING) is
		do
			if equal (key, User_definition_specifier) then
				process_user_definition (value)
			else
				check
					in_or_at_end_of_block:
						config_file.in_block xor config_file.at_end_of_block
				end
				process_block (key, value)
			end
		end

	process_block (key, value: STRING) is
		require
			in_or_at_end_of_block: config_file.in_block xor
				config_file.at_end_of_block
		do
			if config_file.current_block_is_start_server_cmd then
				if config_file.in_block then
					process_start_server_cmd (key, value)
				else
					check
						at_end_and_start_server: config_file.at_end_of_block
						and config_file.current_block_is_start_server_cmd
					end
					make_start_server_cmd
					current_cmd_is_default := False
				end
			end
		end

	new_config_file: CONFIGURATION_FILE is
		do
			create Result.make (Field_separator, Record_separator)
		end

feature {NONE} -- Implementation - Utilities

	replace_configuration_tokens (s: STRING) is
		local
			keys, values: ARRAY [STRING]
			cp_start_index: INTEGER
		do
			keys := <<Hostname_specifier>>
			values := <<hostname>>
			cp_start_index := keys.upper + 1
			keys.resize (1, keys.upper + user_defined_variables.count)
			values.resize (1, keys.upper)
			keys.subcopy (user_defined_variables, 1,
				user_defined_variables.upper, cp_start_index)
			values.subcopy (user_defined_values, 1,
				user_defined_variables.upper, cp_start_index)
			replace_tokens (s, keys, values,
				Token_start_delimiter, Token_end_delimiter)
		end

	replace_command_string_tokens (c: EXTERNAL_COMMAND) is
			-- Replace the tokens in `c's command_string with the specified
			-- values.
		do
			replace_configuration_tokens (c.command_string)
		end

	process_start_server_cmd (key, value: STRING) is
			-- Process a block-definition of a start-server command.
		require
			in_block: config_file.in_block
		do
			if key.is_equal (Command_specifier) then
				current_cmd_string := value
			elseif key.is_equal (Command_description_specifier) then
				current_cmd_desc := value
			elseif key.is_equal (Command_name_specifier) then
				current_cmd_name := value
			elseif
				key.is_equal (Mark_specifier) and
				value.is_equal (Default_mark)
			then
				current_cmd_is_default := True
			end
		end

	make_start_server_cmd is
			-- Make a 'start-server' command and add it to
			-- `start_server_commands'.
		require
			at_end_of_block: config_file.at_end_of_block
		local
			c: SESSION_COMMAND
		do
			replace_configuration_tokens (current_cmd_string)
			create c.make (Start_server_cmd_specifier, current_cmd_string)
			c.set_name (current_cmd_name)
			c.set_description (current_cmd_desc)
			if current_cmd_is_default then
				default_start_server_command := c
			end
			start_server_commands.extend (c)
		end

	process_user_definition (value: STRING) is
			-- Process a user-defined variable definition
		local
			i: INTEGER
		do
			i := value.index_of (User_definition_separator, 1)
			if i < 2 then
				error_report.append ("Incorrect format for user-defined %
					%variable: " + value + "%N(at line " +
					current_line.out + ").%N")
			else
				user_defined_variables.force (value.substring (1, i - 1),
					user_defined_variables.upper + 1)
				user_defined_values.force (value.substring (i + 1,
					value.count), user_defined_values.upper + 1)
				check
					at_least_one: user_defined_variables.item (
						user_defined_variables.upper).count > 0
				end
			end
		end

	check_field (key: STRING) is
			-- If `settings @ key' is empty, append notification
			-- for the condition to `error_report'.
		require
			error_report_exists: error_report /= Void
			setting_exists: settings.has (key)
		do
			if settings.item (key).is_empty then
				error_report.append ("Value for " + key + " is not set.%N")
				if required_specifiers.has (key) then
					fatal_error_status := True
				end
			end
		end

	check_for_empty_fields (keys: ARRAY [STRING]) is
			-- For each key, k, in `keys', if `settings @ k' is empty,
			-- append notification for the condition to `error_report'.
		require
			error_report_exists: error_report /= Void
			settings_exist: keys.linear_representation.for_all (
				agent settings.has)
		do
			keys.linear_representation.do_all (agent check_field)
		end

	check_for_unreplaced_tokens (s: STRING) is
			-- Check `s' for tokens that were not replaced.
		require
			s_exists: s /= Void
		local
			work_s: STRING
			empties: ARRAY [STRING]
			i: INTEGER
		do
print ("Checking '" + s + "'%N")
			-- Eliminate side effects on `s':
			work_s := clone (s)
			create empties.make (1, dynamic_tokens.upper)
			from
				i := empties.lower
			until
				i > empties.upper
			loop
				empties.put ("", i)
				i := i + 1
			end
print ("dynamic tokens: '")
dynamic_tokens.linear_representation.do_all (agent print_str)
print ("'%N")
print ("Before replace - work_s: '" + work_s + "'%N")
			-- In `work_s', replace all `dynamic_tokens' with empty strings.
			replace_tokens (work_s, dynamic_tokens, empties,
				Token_start_delimiter, Token_end_delimiter)
print ("After replace - work_s: '" + work_s + "'%N")
			i := work_s.index_of (Token_start_delimiter, 1)
			if i > 0 and work_s.index_of (Token_end_delimiter, i) > 0 then
				error_report.append ("The setting '" + s + "' contains one %
					%or more undefined tokens.%N")
			end
		end

	check_for_unreplaced_commands (c: EXTERNAL_COMMAND) is
			-- Check `c's `command_string' for tokens that were not replaced.
		require
			c_valid: c /= Void and c.command_string /= Void
		do
print ("Checking cmd: '" + c.command_string + "'%N")
			check_for_unreplaced_tokens (c.command_string)
		end

print_str (s: STRING) is
do
	 print ("'" + s + "'%N")
end

print_cmd (c: EXTERNAL_COMMAND) is
do
	 print ("cmd: " + c.name + ": '" + c.command_string + "'%N")
end

feature {NONE} -- Implementation

	current_cmd_string, current_cmd_desc, current_cmd_name: STRING

	current_cmd_is_default: BOOLEAN

	config_file: CONFIGURATION_FILE

	error_report: STRING

	required_specifiers: LINKED_LIST [STRING] is
			-- Configuration fields that are required
		once
			create Result.make
			Result.extend (Valid_port_numbers_specifier)
			Result.compare_objects
		ensure
			Result.object_comparison
		end

	dynamic_tokens: ARRAY [STRING] is
			-- "<word>" tokens that are to be converted on the fly, rather
			-- than converted on start-up - without the surrounding "<>"
		once
			Result := (<<Port_number_specifier>>)
		end

	user_defined_variables: ARRAY [STRING]
			-- User-defined variable names

	user_defined_values: ARRAY [STRING]
			-- User-defined values, one for each element
			-- of `user_defined_variables'

invariant

	default_start_server_command_exists: default_start_server_command /= Void
	start_server_commands_exist: start_server_commands /= Void
	start_command_line_client_command_exists:
		start_command_line_client_command /= Void
	chart_command_exists: chart_command /= Void
	termination_command_exists: termination_command /= Void
	user_defined_arrays_exist: user_defined_variables /= Void and
		user_defined_values /= Void
	user_defined_arrays_match:
		user_defined_variables.lower = user_defined_values.lower and
		user_defined_variables.upper = user_defined_values.upper

end
