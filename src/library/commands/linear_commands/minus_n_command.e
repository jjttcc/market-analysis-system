indexing
	description:
		"An n-record command that simply retrieves the value at the%
		%current position minus n of the input";
	date: "$Date$";
	revision: "$Revision$"

class MINUS_N_COMMAND inherit

	N_RECORD_COMMAND
		export {MARKET_FUNCTION}
			set_n
		redefine
			execute
		end

creation

	make

feature

	execute (arg: ANY) is
		do
			check target.index > n end
			value := target.i_th (target.index - n).value
		ensure then
			value = target.i_th (target.index - n).value
		end

end -- class MINUS_N_COMMAND
