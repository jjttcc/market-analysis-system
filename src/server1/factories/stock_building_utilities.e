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
			name: STRING
			i, last_sep_index: INTEGER
		do
			name := clone (input_file.name)
			-- Strip directory path from the file name:
			from
				i := 1
				last_sep_index := 0
			until
				i = 0
			loop
				i := name.index_of (Directory_separator, i + 1)
				if i /= 0 then
					last_sep_index := i
				end
			end
			if last_sep_index > 0 then
				name.tail (name.count - last_sep_index)
			end
			--!!!For now, set the name and symbol to the file name.
			!!product.make (name, time_period_type)
			product.set_name (name)
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
