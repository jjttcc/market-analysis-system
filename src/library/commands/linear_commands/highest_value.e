indexing
	description:
		"An n-record command that finds the highest value in the %
		%last n trading periods"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class HIGHEST_VALUE inherit

	N_RECORD_LINEAR_COMMAND
		rename
			make as nrlc_make
		redefine
			start_init, sub_action, target
		end

creation

	make

feature -- Initialization

	make (t: LIST [MARKET_TUPLE]; o: like operand; i: like n) is
		require
			not_void: t /= Void and o /= Void
			i_gt_0: i > 0
		do
			nrlc_make (t, i)
			set_operand (o)
		ensure
			set: target = t and operand = o and n = i
		end

feature {NONE} -- Implementation

	start_init is
		do
			value := 0
		end

	sub_action (current_index: INTEGER) is
		do
			operand.execute (target @ current_index)
			if operand.value > value then
				value := operand.value
			end
		end

feature {NONE}

	target: LIST [BASIC_MARKET_TUPLE]

end -- class HIGHEST_VALUE
