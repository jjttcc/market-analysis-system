indexing
	description: "Tuple factory that creates an OPEN_INTEREST_TUPLE";
	date: "$Date$";
	revision: "$Revision$"

class OI_TUPLE_FACTORY inherit

	VOLUME_TUPLE_FACTORY
		redefine
			product, execute
		end

feature

	execute (arg: ANY) is
		do
			!!product.make
		end

feature -- Access

	product: OPEN_INTEREST_TUPLE

end -- class OI_TUPLE_FACTORY
