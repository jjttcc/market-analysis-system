indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE_FACTORY inherit

	BASIC_TUPLE_FACTORY
		redefine
			product, execute
		end

feature

	execute (arg: ANY) is
		do
			!!product.make
		end

feature -- Access

	product: VOLUME_TUPLE

end -- class VOLUME_TUPLE_FACTORY
