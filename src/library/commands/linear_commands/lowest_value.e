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
			start_init, sub_action, target, initialize
		select
			initialize
		end

	UNARY_OPERATOR [REAL]
		rename
			initialize as uo_initialize
		undefine
			arg_mandatory
		redefine
			operand
		end

creation

	make

feature -- Initialization

	make (t: CHAIN [MARKET_TUPLE]; o: like operand; i: like n) is
		require
			not_void: t /= Void and o /= Void
		do
			nrlc_make (t, i)
			set_operand (o)
		ensure
			set: target = t and operand = o and n = i
		end

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			Precursor (arg)
			uo_initialize (arg)
		end

feature -- Access

	operand: BASIC_NUMERIC_COMMAND
			-- Operand that determines which field in each tuple to
			-- examine for the lowest value

feature {NONE} -- Basic operations

	sub_action (current_index: INTEGER) is
		do
			operand.execute (target @ current_index)
			if operand.value < value then
				value := operand.value
			end
		end

	start_init is
		do
			value := 999999999
		end

feature {NONE}

	target: LIST [BASIC_MARKET_TUPLE]

end -- class LOWEST_VALUE
