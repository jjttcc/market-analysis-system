indexing
	description:
		"An n-record command that finds the lowest value in the last %
		%n trading periods"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class LOWEST_VALUE inherit

	N_RECORD_LINEAR_COMMAND
		rename
			make as nrlc_make
		redefine
			start_init, sub_action, target
		end

	OPERATOR_COMMAND
		undefine
			arg_mandatory, initialize
		redefine
			operator
		end

creation

	make

feature -- Initialization

	make (t: CHAIN [MARKET_TUPLE]; o: like operator; i: like n) is
		require
			not_void: t /= Void and o /= Void
		do
			nrlc_make (t, n)
			set_operator (o)
		ensure
			set: target = t and operator = o
		end

feature -- Access

	operator: BASIC_NUMERIC_COMMAND
			-- Operator that determines which field in each tuple to
			-- examine for the lowest value

feature {NONE} -- Basic operations

	sub_action (current_index: INTEGER) is
		do
			operator.execute (target @ current_index)
			if operator.value < value then
				value := operator.value
			end
		end

	start_init is
		do
			value := 999999999
		end

feature {NONE}

	target: LIST [BASIC_MARKET_TUPLE]

end -- class LOWEST_VALUE
