indexing
	description:
		"Abstraction that builds the appropriate instances of factories"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FACTORY_BUILDER inherit

	ARGUMENTS
		export {NONE}
			all
		end

	EXCEPTIONS
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (fname: STRING) is
		do
			if fname /= Void then
				default_input_file_name := fname
			end
		ensure
			default_file_name: default_input_file_name = fname
		end

feature -- Access

	tradable_factory: TRADABLE_FACTORY is
			-- Factory to make tradables - stocks, commodities, etc.
			-- (Hard-coded to make a STOCK_FACTORY for now.)
		do
			Result := process_args
		end

	function_list_factory (t: TRADABLE [BASIC_MARKET_TUPLE]):
				FUNCTION_BUILDER is
			-- Builder of a list of composite functions
		do
			!!Result.make (t)
		end

	default_input_file_name: STRING

feature {NONE}

	input_file: PLAIN_TEXT_FILE

	usage is
		do
			print ("Usage: "); print (argument (0))
			print (" [input_file] [-o] [-f field_separator]%N%
				%    Where:%N        -o = data has an open field%N")
		end

	process_args: TRADABLE_FACTORY is
		local
			i: INTEGER
			no_open: BOOLEAN
			fs: STRING
		do
			no_open := true
			from
				i := 1
			until
				i > argument_count
			loop
				if argument (i) @ 1 = '-' and argument (i).count > 1 then
					if argument (i) @ 2 = 'o' then
						no_open := false
					elseif
						argument (i) @ 2 = 'f' and argument_count > i
					then
						i := i + 1
						fs := argument (i)
					else
						usage
						die (-1) -- kludgey exit for now!!
					end
				else
					!!input_file.make_open_read (argument (i))
				end
				i := i + 1
			end
			if input_file = Void then
				if default_input_file_name /= Void then
					!!input_file.make_open_read (default_input_file_name)
				else
					raise ("No input file name specified")
				end
			end
			!STOCK_FACTORY!Result.make (input_file)
			Result.set_no_open (no_open)
			if fs /= Void then
				Result.set_field_separator (fs)
			end
		end

end -- FACTORY_BUILDER
