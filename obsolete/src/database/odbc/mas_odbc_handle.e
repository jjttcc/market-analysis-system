indexing
	description: "Database handle for MAS functionality"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAS_ODBC_HANDLE inherit

	ACTION

	RDB_HANDLE

creation
	make

feature --initialisation

	make (data_source: STRING; market_relation: STRING) is
	require
		valid_data_source: data_source /= void
		valid_relation_name: market_relation /= void
	do 
		relation := market_relation
		set_data_source(data_source)
		!!last_result.make
		initialise_db
	end

feature -- access

	last_result: LINKED_LIST[DB_RESULT]

	current_query: STRING

	relation: STRING

	connected: BOOLEAN

	set_argument (arg: ANY; var_name: STRING) is
	require 
		valid_argument: arg /= void
		var_exist: var_name /= void
		current_query_valid: current_query /= void
	do
		 -- arg refers to the actual value; host_var refers to the bind variable.
		base_selection.set_map_name (clone(arg), clone(var_name))
	end

	unset_argument (var_name: STRING) is
	require 
		var_exist: var_name /= void
	do
		base_selection.unset_map_name (clone(var_name))
	end

	set_current_query (q: STRING) is
	require
		valid_query: q /= void
	do
		current_query := q
	ensure
		current_query = q
	end

	connect is
	require
		connected = false
	do
		if session_control = Void then
			!!session_control.make
		end
		session_control.connect
		connected := session_control.is_connected
	end

	disconnect is
	require
		is_connected: connected = true
	do
		session_control.disconnect
		connected := session_control.is_connected
	end

	make_selection is	
	do
		if not last_result.empty then
			last_result.wipe_out
		end
		base_selection.set_container(last_result)
		base_selection.query(current_query)
		base_selection.load_result
		base_selection.terminate
		session_control.commit
	end

	raise_error is
		do
			session_control.raise_error
		end

feature {NONE}

	session_control: DB_CONTROL

	base_selection: DB_SELECTION

	repository: DB_REPOSITORY

	initialise_db is
		-- Initialization of the Relational Database:
		-- This will set various informations to perform a correct
		-- connection to the Relational database
	do
		set_base
		!!session_control.make
		!! base_selection.make	-- 'base_selection' provides a SELECT query mechanism.
		make_repository
	end

	make_repository is
		-- A 'repository' is used to store objects, and to access
		-- them as Eiffel objects, or DB tuples.
	do
		!! repository.make(relation)
	end

invariant
	session_control /= void

end -- class MAS_SELECTOR_ODBC
