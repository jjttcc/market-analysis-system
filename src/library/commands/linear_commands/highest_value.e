indexing
	description: 
		"An abstraction for a market vector analyzer that finds%
		%the highest high value in the last n trading periods."
	date: "$Date$";
	revision: "$Revision$"

class HIGHEST_HIGH inherit

	N_RECORD_COMMAND
		redefine
			start_init, sub_action, set_input, target
		end

creation

	make

feature {NONE} -- Implementation

	start_init is
		do
			value := 0
		end

	sub_action (current_index: INTEGER) is
		do
			if (target @ current_index).high.value > value then
				value := (target @ current_index).high.value
			end
		end

feature {NONE}

	target: ARRAYED_LIST [BASIC_MARKET_TUPLE]

feature {TEST_FUNCTION_FACTORY}

	set_input (in: LINEAR [BASIC_MARKET_TUPLE]) is
		local
			l: ARRAYED_LIST [BASIC_MARKET_TUPLE]
		do
			l ?= in
			check l /= Void end
			target := l
		ensure then
			target = in
			target /= Void
		end

end -- class HIGHEST_HIGH
