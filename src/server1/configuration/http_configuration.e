indexing
	description: "Configurations for obtaining tradable data from an http %
		%connection, read from a configuration file"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class HTTP_CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		export
			{NONE} all
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	APPLICATION_CONSTANTS
		export
			{NONE} all
		end

--	DATABASE_CONSTANTS
--		export
--			{NONE} all
--		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Initialization

	initialize_settings_table is
		do
			create settings.make (0)
		end

feature -- Access
feature -- Status report
feature {NONE} -- Implementation - Hook routine implementations

	configuration_type: STRING is "http"

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	configuration_file_name: STRING is
		do
			Result := file_name_with_app_directory (
				Default_http_config_file_name)
		end

	check_for_missing_specs (ftbl: ARRAY[ANY]) is
--!!!Can this be moved to CONFIGURATION_UTILITIES?
			-- Check for missing http field specs in `ftbl'.   Expected
			-- types of ftbl's contents are: <<BOOLEAN, STRING,
			-- BOOLEAN, STRING, ...>>.
		require
			count_even: ftbl.count \\ 2 = 0
		local
			s: STRING
			i: INTEGER
			emtpy: BOOLEAN_REF
			all_empty, problem: BOOLEAN
			es: expanded EXCEPTION_SERVICES
			ex: expanded EXCEPTIONS
		do
			from i := 1; all_empty := true until i > ftbl.count loop
				emtpy ?= ftbl @ i
				check
					correct_type: emtpy /= Void
				end
				if emtpy.item then
					s := concatenation (<<s, "Missing specification in ",
						"http configuration file:%N",
						ftbl @ (i+1), ".%N">>)
					problem := true
				else
					all_empty := false
				end
				i := i + 2
			end
			if problem and not all_empty then
				log_error (s)
				es.last_exception_status.set_fatal (true)
				ex.raise ("Fatal error reading http configuration file")
			end
		end

	check_results is
		do
		end

invariant

end
