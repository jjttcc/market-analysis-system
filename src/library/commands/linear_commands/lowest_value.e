indexing
	description:
		"An abstraction for a market vector analyzer that finds%
		%the lowest low value in the last n trading periods."
	date: "$Date$";
	revision: "$Revision$"

class LOWEST_LOW inherit

	N_RECORD_COMMAND
		redefine
			start_init, sub_action, set_input, target
		end

creation

	make

feature {NONE} -- Basic operations

	sub_action (current_index: INTEGER) is
		do
			if (target @ current_index).low.value < value then
				value := (target @ current_index).low.value
			end
		end

	start_init is
		do
			value := 999999999
		end

feature {NONE}

	target: ARRAYED_LIST [BASIC_MARKET_TUPLE]

feature {TEST_FUNCTION_FACTORY} -- Element change

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

end -- class LOWEST_LOW
