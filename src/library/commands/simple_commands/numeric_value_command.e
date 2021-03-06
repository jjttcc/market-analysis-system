note
	description: "Numeric commands that simply hold a settable value - %
		%Can function as constants or variables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class NUMERIC_VALUE_COMMAND inherit

	NUMERIC_COMMAND
		rename
			is_equal as numeric_command_is_equal
		undefine
			is_editable
		redefine
			prepare_for_editing, name
		end

	FUNCTION_PARAMETER
		export
			{NONE} all
			{ANY} infix "<"
		undefine
			set_name
		select
			is_equal
		end

	CONFIGURABLE_EDITABLE_COMMAND
		rename
			is_equal as editable_is_equal
		end

creation

	make

feature

	make (r: DOUBLE)
		do
			value := r
			is_editable := True
		ensure
			set: dabs (value - r) < epsilon
			editable: is_editable
		end

feature -- Access

	Default_name: STRING = "{Numeric value}"

	name: STRING
		do
			Result := Precursor
			if Result = Void or else Result.is_empty then
				Result := Default_name
			else
				Result := "{" + Result + "}"
			end
		end

	description: STRING
		do
			if name.is_equal (Default_name) then
				Result := name
			else
				Result := name + " (Numeric value)"
			end
		end

	owner: TREE_NODE
		do
			Result := Current
		end

feature -- Status report

	arg_mandatory: BOOLEAN = False

feature -- Status setting

	set_value (arg: DOUBLE)
			-- Set value to `arg'.
		do
			value := arg
		ensure
			value_set: dabs (value - arg) < epsilon
		end

feature -- Basic operations

	execute (arg: ANY)
		do
		ensure then
			value = old value
		end

	prepare_for_editing (l: LIST [FUNCTION_PARAMETER])
		do
			l.extend (Current)
		end

feature {NONE} -- FUNCTION_PARAMETER interface

	valid_value (v: STRING): BOOLEAN
		do
			Result := v /= Void and v.is_real
		end

	current_value: STRING
		do
			Result := value.out
		end

	current_value_equals (v: STRING): BOOLEAN
		do
			Result := valid_value (v) and then value - v.to_real < Epsilon
		end

	value_type_description: STRING = "real value"

	change_value (new_value: STRING)
		do
			set_value (new_value.to_real)
		end

end -- class NUMERIC_VALUE_COMMAND
