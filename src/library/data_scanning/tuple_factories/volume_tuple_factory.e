indexing
	description: "";
	date: "$Date$";
	revision: "$Revision$"

class VOLUME_TUPLE_FACTORY inherit

	TUPLE_FACTORY

feature

	execute (arg: ANY) is
		do
			!VOLUME_TUPLE!product.make
		end

end -- class VOLUME_TUPLE_FACTORY
