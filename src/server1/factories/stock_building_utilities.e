indexing
	description: "Tradable factory that manufactures STOCKs"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK_FACTORY inherit

	TRADABLE_FACTORY
		redefine
			product
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

creation

	make

feature -- Access

	product: STOCK

	tuple_maker: BASIC_TUPLE_FACTORY is
		do
			!VOLUME_TUPLE_FACTORY!Result
		end

feature {NONE}

	make_product is
		local
			i, last_sep_index: INTEGER
		do
			--!!!For now, set the name and symbol to `symbol'.
			!!product.make (symbol, time_period_type)
			product.set_name (symbol)
		end

	index_vector: ARRAY [INTEGER] is
		do
			!!Result.make (1, 6)
			if no_open then
				Result := << Date_index, High_index, Low_index,
								CLose_index, Volume_index >>
			else
				Result := << Date_index, Open_index, High_index, Low_index,
								Close_index, Volume_index >>
			end
		end

end -- STOCK_FACTORY
