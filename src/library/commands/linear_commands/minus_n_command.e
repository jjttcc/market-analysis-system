indexing
	description:
		"An n-record command that simply retrieves the value at the%
		%current position minus n of the input vector";
	date: "$Date$";
	revision: "$Revision$"

class MINUS_N_COMMAND inherit

	N_RECORD_COMMAND
		redefine
			execute
		end

feature

	execute (arg: ANY) is
		do
			check input.index > n end
			value := input.i_th(input.index - n).value
		end

end -- class MINUS_N_COMMAND
