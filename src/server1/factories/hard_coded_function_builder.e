indexing
	description:
		"Builder of a list of market functions"
	note:
		"Hard-coded for testing for now, but may evolve into a legitimate %
		%class"
	date: "$Date$";
	revision: "$Revision$"

class FUNCTION_BUILDER inherit

	FACTORY
		redefine
			product
		end

feature -- Access

	product: LIST [MARKET_FUNCTION]

feature -- Basic operations

	execute (arg: ANY) is
		do
		end

end -- FUNCTION_BUILDER
