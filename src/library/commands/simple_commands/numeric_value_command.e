indexing
	description:
		"A numeric command that evaluates to a constant value"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONSTANT inherit

	NUMERIC_COMMAND
		redefine
			is_editable, prepare_for_editing, name
		end

	FUNCTION_PARAMETER
		export
			{NONE} all
		end

creation

	make

feature

	make (r: REAL) is
		do
			value := r
			is_editable := True
		ensure
			set: rabs (value - r) < epsilon
			editable: is_editable
		end

feature -- Access

	name: STRING is
		do
			Result := Precursor
			if Result.is_empty then
				Result := "{Constant}"
			else
				Result := "{" + Result + "}"
			end
		end

feature -- Status report

	arg_mandatory: BOOLEAN is False

	is_editable: BOOLEAN

feature -- Status setting

	set_value (arg: REAL) is
			-- Set value to `arg'.
		require
			arg /= Void
		do
			value := arg
		ensure
			value_set: rabs (value - arg) < epsilon
		end

	set_is_editable (arg: BOOLEAN) is
			-- Set `is_editable' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			is_editable := arg
		ensure
			is_editable_set: is_editable = arg and is_editable /= Void
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
		ensure then
			value = old value
		end

	prepare_for_editing (l: LIST [FUNCTION_PARAMETER]) is
		do
			l.extend (Current)
		end

feature {NONE} -- FUNCTION_PARAMETER interface

	valid_value (v: STRING): BOOLEAN is
		do
			Result := v /= Void and v.is_real
		end

	current_value: STRING is
		do
			Result := value.out
		end

	current_value_equals (v: STRING): BOOLEAN is
		do
			Result := valid_value (v) and then value - v.to_real < Epsilon
		end

	value_type_description: STRING is "constant real value"

	change_value (new_value: STRING) is
		do
			set_value (new_value.to_real)
		end

end -- class CONSTANT
