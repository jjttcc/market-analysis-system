indexing
	description: "ODBC Database handle for MAS functionality"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_ODBC_HANDLE inherit

	ACTION

	DATABASE_APPL[ODBC]
		rename
			login as anc_login
		end

feature -- access

	connected: BOOLEAN

feature -- Basic operations

	login (data_source: STRING; username: STRING; password: STRING) is
		require else
			valid_data_source: data_source /= Void and data_source.count > 0
		do
			anc_login(username, password)
			set_data_source(data_source)
			set_base
			create session_control.make
		end

	connect is
		require
			connected = false
		do
			session_control.connect
			connected := session_control.is_connected
			create selection.make
		end

	disconnect is
		require
			is_connected: connected = true
		do
			session_control.disconnect
			connected := session_control.is_connected
		end

	retrieve (sql: STRING): LINKED_LIST[DB_RESULT] is
		require
			sql_valid_and_not_empty: sql /= Void and sql.count > 0
			connected: connected
		local
			db_result: LINKED_LIST[DB_RESULT]
			ok: BOOLEAN
		do
			create db_result.make
			selection.set_container(db_result)
			selection.query(sql)
			ok := selection.is_ok
			if ok then
				selection.load_result
				selection.terminate
			else
--				log(error_message + "%N" + sql)
			end
			Result:= db_result
		end

feature --Change

	set_argument (arg: ANY; var_name: STRING) is
		require 
			valid_argument: arg /= Void
			var_exist: var_name /= Void
		do
		 -- arg refers to the actual value; host_var refers to the bind variable.
			selection.set_map_name (clone(arg), clone(var_name))
		end

	unset_argument (var_name: STRING) is
		require 
			var_exist: var_name /= Void
		do
			selection.unset_map_name (clone(var_name))
		end

feature

	raise_error is
		do
			session_control.raise_error
		end

feature {NONE}

	session_control: DB_CONTROL

	selection: DB_SELECTION

invariant
	session_control /= Void

end
