indexing
	description:
		"A command that plays the role of client of a BOOLEAN_OPERATOR by, %
		%in its execute routine, providing two operands for the %
		%BINARY_OPERATOR [BOOLEAN] and, when the operator evaluates to true, %
		%executing a 'true command', and when false, executing a 'false %
		%command'."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class BOOLEAN_RELATION_CLIENT inherit

	RESULT_COMMAND [BOOLEAN]
		redefine
			initialize
		end

creation

	make

feature -- Initialization

	make (bool_oper: like boolean_operator; true_command, false_command:
			like true_cmd) is
		require
			args_not_void: bool_oper /= Void and true_command /= Void and
				false_command /= Void
		do
			boolean_operator := bool_oper
			true_cmd := true_command
			false_cmd := false_command
		ensure
			bool_op_set:
					boolean_operator = bool_oper and boolean_operator /= Void
			true_cmd_set: true_cmd = true_command and true_cmd /= Void
			false_cmd_set: false_cmd = false_command and false_cmd /= Void
		end

	initialize (arg: ANY) is
		do
			boolean_operator.initialize (arg)
			?1.initialize (arg)
			?2.initialize (arg)
		end

feature -- Access

	boolean_operator: BINARY_OPERATOR [BOOLEAN, BOOLEAN]
			-- Operator used to compare two values

	?1: RESULT_COMMAND [REAL]
			-- Command that extracts the value to use if boolean_operator
			-- evaluates as true

	?2: RESULT_COMMAND [REAL]
			-- Command that extracts the value to use if boolean_operator
			-- evaluates as false

feature -- Status report

	arg_mandatory: BOOLEAN
		do
			Result := boolean_operator.arg_mandatory or
				true_cmd.arg_mandatory or false_cmd.arg_mandatory
		end

feature -- Status setting

	set_boolean_operator (arg: like boolean_operator) is
			-- Set boolean_operator to `arg'.
		require
			arg /= Void
		do
			boolean_operator := arg
		ensure
			boolean_operator_set: boolean_operator = arg and
									boolean_operator /= Void
		end

	set_true_cmd (arg: like true_cmd) is
			-- Set true_cmd to `arg'.
		require
			arg /= Void
		do
			true_cmd := arg
		ensure
			true_cmd_set: true_cmd = arg and
								true_cmd /= Void
		end

	set_false_cmd (arg: like false_cmd) is
			-- Set false_cmd to `arg'.
		require
			arg /= Void
		do
			false_cmd := arg
		ensure
			false_cmd_set: false_cmd = arg and
									false_cmd /= Void
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			boolean_operator.execute (arg)
			if boolean_operator.value then
				true_cmd.execute (arg)
				value := true_cmd.value
			else
				false_cmd.execute (arg)
				value := false_cmd.value
			end
		end

invariant

	boolean_operator_not_void: boolean_operator /= Void
	true_cmd_not_void: true_cmd /= Void
	false_cmd_not_void: false_cmd /= Void

end -- class BOOLEAN_RELATION_CLIENT
