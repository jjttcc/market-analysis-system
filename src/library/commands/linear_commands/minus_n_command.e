indexing
	description:
		"An n-record linear command that simply retrieves the value at the %
		%current position minus n of the input";
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MINUS_N_COMMAND inherit

	N_RECORD_LINEAR_COMMAND
		redefine
			execute
		end

creation

	make

feature

	execute (arg: ANY) is
		do
			check
				target_index_gt_n: target.index > n
			end
			value := target.i_th (target.index - n).value
		ensure then
			value = target.i_th (target.index - n).value
		end

end -- class MINUS_N_COMMAND
